import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:khel_mitra/core/di/injection.dart';
import 'package:khel_mitra/core/theme/app_theme.dart';
import 'package:khel_mitra/features/assessment/pose_painter.dart';
import 'package:khel_mitra/features/assessment/vjh_test_screen.dart';
import 'package:khel_mitra/features/profile/domain/profile_repository.dart';
import 'package:sensors_plus/sensors_plus.dart';

enum CalibrationState {
  initializing,
  stabilizingDevice,
  calibrating,
  ready,
}

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  // Camera
  CameraController? _cameraController;
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  bool _isProcessing = false;
  List<Pose> _poses = [];
  Size _imageSize = Size.zero;
  bool _isInitialized = false;
  bool _isCameraDisposed = false;

  // Accelerometer
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  final List<double> _accelMagnitudes = [];
  static const int _accelWindowSize = 10;
  static const double _stabilityThreshold = 0.5; // m/s²
  bool _isDeviceStable = false;

  // Calibration
  CalibrationState _calibrationState = CalibrationState.initializing;
  double? _userHeightCm;
  double? _pixelToCmRatio;
  int _calibrationCountdown = 3;
  Timer? _calibrationTimer;
  double? _lastHeelY;
  double? _lastNoseY;

  @override
  void initState() {
    super.initState();
    _loadUserHeight();
    _startAccelerometer();
    _initCamera();
  }

  Future<void> _loadUserHeight() async {
    final repo = getIt<ProfileRepository>();
    _userHeightCm = await repo.getHeightCm();
    debugPrint("User height: $_userHeightCm cm");
  }

  void _startAccelerometer() {
    _accelSubscription = accelerometerEventStream().listen((event) {
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      _accelMagnitudes.add(magnitude);
      if (_accelMagnitudes.length > _accelWindowSize) {
        _accelMagnitudes.removeAt(0);
      }

      if (_accelMagnitudes.length >= _accelWindowSize) {
        final variance = _calculateVariance(_accelMagnitudes);
        final wasStable = _isDeviceStable;
        _isDeviceStable = variance < _stabilityThreshold;

        if (wasStable != _isDeviceStable && mounted) {
          setState(() {
            if (!_isDeviceStable && _calibrationState == CalibrationState.calibrating) {
              _resetCalibration();
            }
            if (_isDeviceStable && _calibrationState == CalibrationState.stabilizingDevice) {
              _calibrationState = CalibrationState.calibrating;
            }
          });
        }
      }
    });
  }

  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => pow(v - mean, 2));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showError("No cameras available");
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
        setState(() {
          _isInitialized = true;
          _calibrationState = CalibrationState.stabilizingDevice;
        });
        _startImageStream();
      }
    } catch (e) {
      debugPrint("Camera init error: $e");
      _showError("Camera error: ${e.toString().split(':').last}");
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _initCamera,
          ),
        ),
      );
    }
  }

  void _startImageStream() {
    if (_cameraController == null || _isCameraDisposed) return;

    _cameraController!.startImageStream((CameraImage image) {
      if (_isProcessing) return;
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
        if (mounted && !_isCameraDisposed) {
          setState(() {
            _poses = poses;
            _imageSize = Size(image.width.toDouble(), image.height.toDouble());
          });

          // Process calibration if device is stable
          if (_isDeviceStable && poses.isNotEmpty && _calibrationState == CalibrationState.calibrating) {
            _processCalibrationPose(poses.first);
          }
        }
      }
    } catch (e) {
      debugPrint("Pose error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  void _processCalibrationPose(Pose pose) {
    final leftHeel = pose.landmarks[PoseLandmarkType.leftHeel];
    final nose = pose.landmarks[PoseLandmarkType.nose];

    if (leftHeel == null || nose == null) {
      _resetCalibration();
      return;
    }

    // Check if pose is stable (landmarks haven't moved much)
    if (_lastHeelY != null && _lastNoseY != null) {
      final heelDelta = (leftHeel.y - _lastHeelY!).abs();
      final noseDelta = (nose.y - _lastNoseY!).abs();

      if (heelDelta > 20 || noseDelta > 20) {
        // Pose moved too much, reset
        _resetCalibration();
        return;
      }
    }

    _lastHeelY = leftHeel.y;
    _lastNoseY = nose.y;

    // Start countdown if not already running
    if (_calibrationTimer == null) {
      _startCalibrationCountdown(leftHeel.y, nose.y);
    }
  }

  void _startCalibrationCountdown(double heelY, double noseY) {
    _calibrationCountdown = 3;
    _calibrationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _calibrationCountdown--;
      });

      if (_calibrationCountdown <= 0) {
        timer.cancel();
        _calibrationTimer = null;
        _completeCalibration(heelY, noseY);
      }
    });
  }

  void _completeCalibration(double heelY, double noseY) {
    if (_userHeightCm == null) {
      debugPrint("User height not available!");
      return;
    }

    final pixelHeight = heelY - noseY;
    if (pixelHeight <= 0) {
      debugPrint("Invalid pixel height: $pixelHeight");
      _resetCalibration();
      return;
    }

    _pixelToCmRatio = _userHeightCm! / pixelHeight;
    debugPrint("Calibration complete! Ratio: $_pixelToCmRatio cm/px");

    setState(() {
      _calibrationState = CalibrationState.ready;
    });
  }

  void _resetCalibration() {
    _calibrationTimer?.cancel();
    _calibrationTimer = null;
    _lastHeelY = null;
    _lastNoseY = null;
    if (mounted && _calibrationState == CalibrationState.calibrating) {
      setState(() {
        _calibrationCountdown = 3;
      });
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
    _accelSubscription?.cancel();
    _calibrationTimer?.cancel();
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _cameraController == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.accent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Calibration", style: TextStyle(color: AppTheme.textPrimary)),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(),
          if (_poses.isNotEmpty)
            CustomPaint(
              painter: PosePainter(
                _poses,
                _imageSize,
                InputImageRotation.rotation90deg,
              ),
            ),
          // Stability overlay
          if (!_isDeviceStable)
            Container(
              color: AppTheme.error.withOpacity(0.7),
              child: const Center(
                child: Text(
                  "📱 Hold Phone Still",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          // Calibration countdown
          if (_calibrationState == CalibrationState.calibrating && _calibrationTimer != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "$_calibrationCountdown",
                  style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          // Status bar
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: _buildStatusBar(),
          ),
          // Start button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: _calibrationState == CalibrationState.ready 
                    ? AppTheme.success 
                    : AppTheme.surfaceLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _calibrationState == CalibrationState.ready ? _onStartAttempt : null,
              child: Text(
                _calibrationState == CalibrationState.ready ? "Start Attempt ✓" : "Calibrating...",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    String status;
    Color color;

    switch (_calibrationState) {
      case CalibrationState.initializing:
        status = "Initializing...";
        color = AppTheme.textMuted;
        break;
      case CalibrationState.stabilizingDevice:
        status = "Stabilize your device";
        color = AppTheme.warning;
        break;
      case CalibrationState.calibrating:
        status = "Stand still in frame";
        color = AppTheme.accent;
        break;
      case CalibrationState.ready:
        status = "Ready! ✓";
        color = AppTheme.success;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
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
            child: controller.buildPreview(),
          ),
        ),
      ),
    );
  }

  void _onStartAttempt() {
    if (_pixelToCmRatio == null) {
      debugPrint("Calibration not complete!");
      return;
    }

    // Stop camera before navigating
    _isCameraDisposed = true;
    _accelSubscription?.cancel();
    _cameraController?.stopImageStream();
    _cameraController?.dispose();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VJHTestScreen(pixelToCmRatio: _pixelToCmRatio!),
      ),
    );
  }
}
