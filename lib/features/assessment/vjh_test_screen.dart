import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:khel_mitra/features/assessment/data/attempts_repository.dart';
import 'package:khel_mitra/features/assessment/models/attempt_model.dart';
import 'package:khel_mitra/features/assessment/pose_painter.dart';
import 'package:khel_mitra/features/assessment/results_screen.dart';
import 'package:path_provider/path_provider.dart';

enum TestState {
  countdown,
  recording,
  processing,
  complete,
}

class VJHTestScreen extends StatefulWidget {
  final double pixelToCmRatio;

  const VJHTestScreen({super.key, required this.pixelToCmRatio});

  @override
  State<VJHTestScreen> createState() => _VJHTestScreenState();
}

class _VJHTestScreenState extends State<VJHTestScreen> {
  // Camera
  CameraController? _cameraController;
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  bool _isProcessing = false;
  List<Pose> _poses = [];
  Size _imageSize = Size.zero;
  bool _isInitialized = false;
  bool _isCameraDisposed = false;

  // Test State
  TestState _testState = TestState.countdown;
  int _countdown = 3;
  Timer? _countdownTimer;

  // Jump Detection
  final List<double> _heelYHistory = [];
  double? _baselineHeelY;
  double? _peakHeelY;
  double? _jumpHeightCm;
  bool _jumpDetected = false;
  bool _landingDetected = false;

  // Video Recording
  String? _videoPath;
  final AttemptsRepository _attemptsRepo = AttemptsRepository();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _handleCameraError("No cameras available");
        return;
      }

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();
      if (mounted && !_isCameraDisposed) {
        setState(() => _isInitialized = true);
        _startCountdown();
      }
    } catch (e) {
      debugPrint("Camera init error: $e");
      _handleCameraError("Camera failed to initialize");
    }
  }

  void _handleCameraError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
      Navigator.pop(context);
    }
  }

  void _startCountdown() {
    _countdown = 3;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() => _countdown--);

      if (_countdown <= 0) {
        timer.cancel();
        _startRecording();
      }
    });
  }

  Future<void> _startRecording() async {
    setState(() => _testState = TestState.recording);

    // Start video recording
    try {
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _videoPath = '${dir.path}/vjh_$timestamp.mp4';
      // await _cameraController!.startVideoRecording();
      debugPrint("Recording started: $_videoPath");
    } catch (e) {
      debugPrint("Video recording error: $e");
    }

    // Start pose stream for jump detection
    _startPoseStream();

    // Auto-stop after 15 seconds max
    Timer(const Duration(seconds: 15), () {
      if (_testState == TestState.recording) {
        _stopRecording();
      }
    });
  }

  void _startPoseStream() {
    if (_cameraController == null || _isCameraDisposed) return;

    _cameraController!.startImageStream((CameraImage image) {
      if (_isProcessing || _testState != TestState.recording) return;
      _processImage(image);
    });
  }

  Future<void> _processImage(CameraImage image) async {
    _isProcessing = true;

    try {
      if (_isCameraDisposed || !mounted) return;

      final inputImage = _convertCameraImage(image);
      if (inputImage != null) {
        final poses = await _poseDetector.processImage(inputImage);
        if (mounted && !_isCameraDisposed && poses.isNotEmpty) {
          setState(() {
            _poses = poses;
            _imageSize = Size(image.width.toDouble(), image.height.toDouble());
          });

          _processJumpDetection(poses.first);
        }
      }
    } catch (e) {
      debugPrint("Pose error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  void _processJumpDetection(Pose pose) {
    final leftHeel = pose.landmarks[PoseLandmarkType.leftHeel];
    if (leftHeel == null) return;

    final heelY = leftHeel.y;
    _heelYHistory.add(heelY);

    // Establish baseline from first 10 frames (approx 0.3s)
    if (_baselineHeelY == null && _heelYHistory.length >= 10) {
      _baselineHeelY = _heelYHistory.take(10).reduce((a, b) => a + b) / 10;
      debugPrint("Baseline established: $_baselineHeelY");
    }

    if (_baselineHeelY == null) return;

    // Detect jump (heel goes UP in image = Y decreases significantly)
    final jumpThreshold = _baselineHeelY! - 50; // 50 pixels
    if (!_jumpDetected && heelY < jumpThreshold) {
      _jumpDetected = true;
      _peakHeelY = heelY;
      debugPrint("Jump detected! HeelY: $heelY");
    }

    // Track peak during jump
    if (_jumpDetected && !_landingDetected) {
      if (heelY < (_peakHeelY ?? heelY)) {
        _peakHeelY = heelY;
      }

      // Detect landing (heel returns close to baseline)
      if (heelY > _baselineHeelY! - 20) {
        _landingDetected = true;
        debugPrint("Landing detected! Peak was: $_peakHeelY");
        _stopRecording();
      }
    }
  }

  Future<void> _stopRecording() async {
    if (_testState != TestState.recording) return;

    setState(() => _testState = TestState.processing);

    try {
      if (_cameraController != null && !_isCameraDisposed) {
        await _cameraController!.stopImageStream();
      }
      // Video recording was disabled, skip stopVideoRecording
      debugPrint("Recording stopped");
    } catch (e) {
      debugPrint("Stop recording error: $e");
    }

    _calculateResult();
  }

  void _calculateResult() {
    if (_baselineHeelY != null && _peakHeelY != null) {
      final pixelHeight = _baselineHeelY! - _peakHeelY!;
      _jumpHeightCm = pixelHeight * widget.pixelToCmRatio;
      debugPrint("Jump height: $_jumpHeightCm cm (pixels: $pixelHeight)");
    } else {
      _jumpHeightCm = 0;
    }

    // Save attempt
    final attempt = AttemptModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      jumpHeightCm: _jumpHeightCm ?? 0,
      videoPath: _videoPath,
    );
    _attemptsRepo.saveAttempt(attempt);

    // Navigate to results screen (pushReplacement to avoid camera issues)
    _isCameraDisposed = true;
    _cameraController?.dispose();
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResultsScreen(attempt: attempt)),
    );
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
    _countdownTimer?.cancel();
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
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Only show camera preview when not in complete state and camera is valid
          if (_testState != TestState.complete && !_isCameraDisposed)
            _buildCameraPreview(),
          if (_poses.isNotEmpty && _testState == TestState.recording)
            CustomPaint(
              painter: PosePainter(
                _poses,
                _imageSize,
                InputImageRotation.rotation90deg,
              ),
            ),
          // Countdown
          if (_testState == TestState.countdown)
            Container(
              color: Colors.black54,
              child: Center(
                child: Text(
                  "$_countdown",
                  style: const TextStyle(fontSize: 120, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          // Recording indicator
          if (_testState == TestState.recording)
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fiber_manual_record, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text("JUMP NOW!", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          // Processing
          if (_testState == TestState.processing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text("Processing...", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
              ),
            ),
          // Results
          if (_testState == TestState.complete)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 80),
                    const SizedBox(height: 24),
                    const Text("Jump Height", style: TextStyle(color: Colors.white70, fontSize: 18)),
                    Text(
                      "${_jumpHeightCm?.toStringAsFixed(1) ?? '0'} cm",
                      style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      ),
                      child: const Text("Done", style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    final controller = _cameraController;
    if (controller == null || _isCameraDisposed || !controller.value.isInitialized) {
      return Container(color: Colors.black);
    }
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.previewSize?.height ?? 1,
            height: controller.value.previewSize?.width ?? 1,
            child: controller.buildPreview(),
          ),
        ),
      ),
    );
  }
}
