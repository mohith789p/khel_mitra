import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:khel_mitra/features/assessment/pose_painter.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  CameraController? _cameraController;
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  
  // Busy flag to prevent buffer starvation
  bool _isProcessing = false;
  
  List<Pose> _poses = [];
  Size _imageSize = Size.zero;
  bool _isInitialized = false;
  bool _isCameraDisposed = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      debugPrint("No cameras available");
      return;
    }

    // Use back camera
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.medium, // SD for performance
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    try {
      await _cameraController!.initialize();
      if (mounted && !_isCameraDisposed) {
        setState(() => _isInitialized = true);
        _startImageStream();
      }
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  void _startImageStream() {
    if (_cameraController == null || _isCameraDisposed) return;
    
    _cameraController!.startImageStream((CameraImage image) {
      // CRITICAL: Drop frame if we're already processing one
      if (_isProcessing) {
        return; // Drop frame to prevent buffer overflow
      }
      _processImage(image);
    });
  }

  Future<void> _processImage(CameraImage image) async {
    // Set busy flag IMMEDIATELY
    _isProcessing = true;
    
    try {
      // Don't process if disposed
      if (_isCameraDisposed || !mounted) return;
      
      final inputImage = _convertCameraImage(image);
      if (inputImage != null) {
        final poses = await _poseDetector.processImage(inputImage);
        if (mounted && !_isCameraDisposed) {
          setState(() {
            _poses = poses;
            _imageSize = Size(image.width.toDouble(), image.height.toDouble());
          });
        }
      }
    } catch (e) {
      debugPrint("Pose error: $e");
    } finally {
      // ALWAYS release the busy flag
      _isProcessing = false;
    }
  }

  InputImage? _convertCameraImage(CameraImage image) {
    final camera = _cameraController?.description;
    if (camera == null) return null;

    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isAndroid) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    }
    rotation ??= InputImageRotation.rotation0deg;

    final format = Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888;

    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    _isCameraDisposed = true;
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _cameraController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Calibration")),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fixed: Use CameraPreview widget properly
          _buildCameraPreview(),
          if (_poses.isNotEmpty)
            CustomPaint(
              painter: PosePainter(
                _poses,
                _imageSize,
                InputImageRotation.rotation90deg,
              ),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(
                "Poses: ${_poses.length}\nImg: ${_imageSize.width.toInt()}x${_imageSize.height.toInt()}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    final controller = _cameraController!;
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.previewSize?.height ?? 1,
            height: controller.value.previewSize?.width ?? 1,
            // Fixed: Use the actual CameraPreview widget from the camera package
            child: controller.buildPreview(),
          ),
        ),
      ),
    );
  }
}
