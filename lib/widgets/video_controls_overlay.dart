import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../utils/timer_formatter.dart';
import '../input/custom_button.dart';

class VideoControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoControlsOverlay({
    super.key,
    required this.controller,
  });

  void _rewind10Seconds() {
    final currentPosition = controller.value.position;
    final target = currentPosition - const Duration(seconds: 10);
    controller.seekTo(target < Duration.zero ? Duration.zero : target);
  }

  void _forward10Seconds() {
    final currentPosition = controller.value.position;
    final total = controller.value.duration;
    final target = currentPosition + const Duration(seconds: 10);
    if (total == Duration.zero) {
      controller.seekTo(target);
    } else {
      controller.seekTo(target > total ? total : target);
    }
  }

  String _formatDuration(Duration d) {
    return formatDuration(d);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final position = value.position;
        final duration = value.duration;
        final int totalMs = duration.inMilliseconds;
        final int currentMs =
            position.inMilliseconds.clamp(0, totalMs < 0 ? 0 : totalMs);

        // Progress as a double in the range [0.0, 1.0].
        final double progress =
            (totalMs <= 0) ? 0.0 : currentMs.toDouble() / totalMs.toDouble();

        return Stack(
          children: [
            // Center playback controls
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    iconSize: 36,
                    color: Colors.white,
                    icon: const Icon(Icons.replay_10),
                    onPressed: _rewind10Seconds,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    iconSize: 48,
                    color: Colors.white,
                    icon: Icon(
                      value.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    onPressed: () {
                      if (value.isPlaying) {
                        controller.pause();
                      } else {
                        controller.play();
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    iconSize: 36,
                    color: Colors.white,
                    icon: const Icon(Icons.forward_10),
                    onPressed: _forward10Seconds,
                  ),
                ],
              ),
            ),
            // Bottom progress, timer & static action buttons
            Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: Colors.transparent,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Slider(
                        activeColor: Colors.redAccent,
                        inactiveColor: Colors.white24,
                        value: progress.clamp(0.0, 1.0),
                        min: 0,
                        max: 1,
                        onChanged: (newProgress) {
                          if (duration == Duration.zero) return;
                          final double clampedProgress =
                              newProgress.clamp(0.0, 1.0);
                          final int targetMs = (totalMs * clampedProgress)
                              .toInt()
                              .clamp(0, totalMs);
                          final target = Duration(milliseconds: targetMs);
                          controller.seekTo(target);
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '/  ${_formatDuration(duration)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Retry',
                              onPressed: () {
                                // Go back to the camera recording screen.
                                Navigator.of(context).pop();
                              },
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: 'Submit',
                              onPressed: () {
                                // 1. Show SnackBar (tied to VideoPreviewScreen's Scaffold context)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Video submitted successfully!')),
                                );

                                // 2. Wait for the user to see the message, then pop the screen.
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
                                  // Navigate back to the previous screen (e.g., the dashboard)
                                  Navigator.of(context).pop();
                                });
                              },
                              // Uses theme primary by default for background color.
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
