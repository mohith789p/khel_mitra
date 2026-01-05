import 'dart:typed_data';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:khel_mitra/poc/pose_painter.dart';

class PoseDetectorView extends StatefulWidget {
  const PoseDetectorView({super.key});

  @override
  State<PoseDetectorView> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  bool _isProcessing = false;
  List<Pose> _poses = [];
  Size _imageSize = Size.zero;
  InputImageRotation _rotation = InputImageRotation.rotation90deg;

  @override
  void dispose() {
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.previewOnly(
        previewFit: CameraPreviewFit.cover,
        onImageForAnalysis: (img) => _processImage(img),
        imageAnalysisConfig: AnalysisConfig(
          androidOptions: const AndroidAnalysisOptions.nv21(
            width: 480, // Requesting low res for performance as per PRD
          ),
          maxFramesPerSecond: 30,
        ),
        builder: (state, previewSize, previewRect) {
          return Stack(
            children: [
              if (_poses.isNotEmpty)
                Positioned.fill(
                  child: CustomPaint(
                    painter: PosePainter(
                      _poses,
                      _imageSize,
                      _rotation,
                    ),
                  ),
                ),
              // Debug overlay
              Positioned(
                top: 50,
                left: 20,
                child: Text(
                  "Poses: ${_poses.length}\nImg: ${_imageSize.width}x${_imageSize.height}",
                  style: const TextStyle(color: Colors.white, backgroundColor: Colors.black54),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future _processImage(AnalysisImage img) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final inputImage = _inputImageFromAnalysisImage(img);
      if (inputImage != null) {
        final poses = await _poseDetector.processImage(inputImage);
        if (mounted) {
          setState(() {
            _poses = poses;
            _imageSize = Size(img.width.toDouble(), img.height.toDouble());
            _rotation = inputImage.metadata?.rotation ?? InputImageRotation.rotation90deg;
          });
        }
      }
    } catch (e) {
      debugPrint("Error processing pose: $e");
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _inputImageFromAnalysisImage(AnalysisImage img) {
    // Basic conversion for Android NV21
    // Camerawesome provides nv21 by default on Android if specified in config.
    
    // Determine rotation
    // Note: CameraAwesome usually provides image in landscape relative to sensor.
    // In portrait mode, we typically need rotation90deg for back camera.
    // For front camera it might differ. Assuming Back Camera (+ Portrait) for this POC.
    const rotation = InputImageRotation.rotation90deg; 

    final format = InputImageFormat.nv21;
    final bytes = img.bytes;

    if (bytes == null) return null;

    final metadata = InputImageMetadata(
      size: Size(img.width.toDouble(), img.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: img.planes?.first.bytesPerRow ?? img.width.toInt(), 
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }
}
