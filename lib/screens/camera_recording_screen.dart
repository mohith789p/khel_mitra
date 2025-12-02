import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../widgets/camera_switch_button.dart';
import '../widgets/flash_toggle_button.dart';
import '../widgets/record_button.dart';
import '../widgets/recording_timer.dart';
import 'video_preview_screen.dart';

class CameraRecordingScreen extends StatefulWidget {
  const CameraRecordingScreen({super.key});

  @override
  State<CameraRecordingScreen> createState() => _CameraRecordingScreenState();
}

class _CameraRecordingScreenState extends State<CameraRecordingScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = <CameraDescription>[];
  int _selectedCameraIndex = 0;

  bool isRecording = false;
  int flashModeIndex = 0; // index into _flashModes
  int secondsElapsed = 0;

  Timer? _recordingTimer;

  // Flash modes sequence: off -> always -> auto -> torch.
  final List<FlashMode> _flashModes = const <FlashMode>[
    FlashMode.off,
    FlashMode.always,
    FlashMode.auto,
    FlashMode.torch,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCameras();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopRecordingTimer();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_cameras.isNotEmpty) {
        _onNewCameraSelected(_cameras[_selectedCameraIndex]);
      }
    }
  }

  Future<void> _initializeCameras() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      setState(() {
        _cameras = cameras;
        _selectedCameraIndex = cameras.isNotEmpty ? 0 : 0;
      });
      if (cameras.isNotEmpty) {
        await _onNewCameraSelected(cameras[_selectedCameraIndex]);
      }
    } catch (e) {
      debugPrint('Error initializing cameras: $e');
    }
  }

  Future<void> _onNewCameraSelected(CameraDescription cameraDescription) async {
    _stopRecordingTimer();
    isRecording = false;
    secondsElapsed = 0;

    final oldController = _controller;
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: true,
    );

    await oldController?.dispose();

    try {
      await _controller!.initialize();
      await _applyFlashModeToController();
    } catch (e) {
      debugPrint('Error initializing camera controller: $e');
    }

    if (!mounted) return;
    setState(() {});
  }

  FlashToggleMode get _currentFlashModeEnum {
    final int index = flashModeIndex % _flashModes.length;
    switch (_flashModes[index]) {
      case FlashMode.always:
        return FlashToggleMode.on;
      case FlashMode.auto:
        return FlashToggleMode.auto;
      case FlashMode.torch:
        return FlashToggleMode.torch;
      case FlashMode.off:
      default:
        return FlashToggleMode.off;
    }
  }

  Future<void> _applyFlashModeToController() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      final int index = flashModeIndex % _flashModes.length;
      final FlashMode mode = _flashModes[index];
      await controller.setFlashMode(mode);
    } catch (e) {
      debugPrint('Error setting flash mode: $e');
    }
  }

  Future<void> _toggleFlashMode() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    // If current camera is front-facing, show feedback and exit since it
    // typically doesn't support flash/torch.
    if (controller.description.lensDirection == CameraLensDirection.front) {
      if (mounted) {
        _showModalMessage(
          title: 'Feature Not Supported',
          content: 'Front camera does not support flash/torch mode.',
        );
      }
      return;
    }

    setState(() {
      flashModeIndex = (flashModeIndex + 1) % _flashModes.length;
    });
    await _applyFlashModeToController();
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _onNewCameraSelected(_cameras[_selectedCameraIndex]);
  }

  Future<void> _startVideoRecording() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isRecordingVideo) {
      return;
    }

    try {
      await controller.startVideoRecording();
      setState(() {
        isRecording = true;
        secondsElapsed = 0;
      });
      _startRecordingTimer();
    } catch (e) {
      debugPrint('Error starting video recording: $e');
    }
  }

  Future<void> _stopVideoRecording() async {
    final controller = _controller;
    if (controller == null || !controller.value.isRecordingVideo) {
      return;
    }

    try {
      final file = await controller.stopVideoRecording();
      debugPrint('Video recorded to: ${file.path}');

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoPreviewScreen(
            videoPath: file.path,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error stopping video recording: $e');
    } finally {
      _stopRecordingTimer();
      if (mounted) {
        setState(() {
          isRecording = false;
        });
      } else {
        isRecording = false;
      }
    }
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !isRecording) {
        timer.cancel();
        return;
      }
      setState(() {
        secondsElapsed += 1;
      });
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  void _onRecordButtonPressed() {
    if (isRecording) {
      _stopVideoRecording();
    } else {
      _startVideoRecording();
    }
  }

  void _showModalMessage({
    required String title,
    required String content,
  }) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(),
          _buildTopControls(),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return CameraPreview(controller);
  }

  Widget _buildTopControls() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CameraSwitchButton(onPressed: _switchCamera),
              const Spacer(),
              RecordingTimer(
                seconds: secondsElapsed,
                onPressed: () {
                  // Timer tap can be used for additional actions if needed.
                },
              ),
              const Spacer(),
              FlashToggleButton(
                mode: _currentFlashModeEnum,
                onPressed: _toggleFlashMode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: RecordButton(
            isRecording: isRecording,
            onPressed: _onRecordButtonPressed,
          ),
        ),
      ),
    );
  }
}


