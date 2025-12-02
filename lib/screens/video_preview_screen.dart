import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../widgets/video_controls_overlay.dart';

class VideoPreviewScreen extends StatefulWidget {
  final String videoPath;

  const VideoPreviewScreen({
    super.key,
    required this.videoPath,
  });

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late final VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isVideoFinished = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath));
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      await _controller.initialize();
      _controller.setLooping(false);
      _controller.addListener(_videoListener);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing VideoPlayerController: $e');
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  void _videoListener() {
    final controller = _controller;
    if (!mounted || !controller.value.isInitialized) return;

    final position = controller.value.position;
    final duration = controller.value.duration;

    if (duration > Duration.zero && position >= duration) {
      controller.pause();
      if (!_isVideoFinished && mounted) {
        setState(() {
          _isVideoFinished = true;
        });
      }
    }
  }

  void _replayVideo() {
    _controller.pause();
    _controller.seekTo(Duration.zero);
    setState(() {
      _isVideoFinished = false;
    });
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
          VideoControlsOverlay(controller: _controller),
        ],
      ),
    );
  }
}


