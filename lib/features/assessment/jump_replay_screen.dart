import 'dart:math';
import 'package:flutter/material.dart';
import 'package:khel_mitra/features/assessment/models/attempt_model.dart';
import 'package:khel_mitra/features/assessment/models/pose_frame.dart';

class JumpReplayScreen extends StatefulWidget {
  final AttemptModel attempt;

  const JumpReplayScreen({super.key, required this.attempt});

  @override
  State<JumpReplayScreen> createState() => _JumpReplayScreenState();
}

class _JumpReplayScreenState extends State<JumpReplayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentFrameIndex = 0;
  bool _isPlaying = false;

  JumpReplayData? get _replayData => widget.attempt.replayData;

  @override
  void initState() {
    super.initState();
    final duration = _replayData?.durationMs ?? 1000;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: max(duration, 500)),
    );

    _animationController.addListener(_onAnimationTick);
    _animationController.addStatusListener(_onAnimationStatus);
  }

  void _onAnimationTick() {
    if (_replayData == null || _replayData!.frames.isEmpty) return;

    final progress = _animationController.value;
    final totalDuration = _replayData!.durationMs;
    final currentTimeMs = (progress * totalDuration).round();

    // Find frame closest to current time
    int bestIndex = 0;
    int minDiff = 999999;
    for (int i = 0; i < _replayData!.frames.length; i++) {
      final diff = (_replayData!.frames[i].timestampMs - currentTimeMs).abs();
      if (diff < minDiff) {
        minDiff = diff;
        bestIndex = i;
      }
    }

    if (bestIndex != _currentFrameIndex) {
      setState(() => _currentFrameIndex = bestIndex);
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() => _isPlaying = false);
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _animationController.stop();
    } else {
      if (_animationController.value >= 1.0) {
        _animationController.reset();
      }
      _animationController.forward();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _replay() {
    _animationController.reset();
    _animationController.forward();
    setState(() => _isPlaying = true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_replayData == null || _replayData!.frames.isEmpty) {
      return _buildErrorScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Jump Replay"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Skeleton Animation Area
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade900.withOpacity(0.3),
                    Colors.purple.shade900.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Grid background
                    CustomPaint(
                      painter: _GridPainter(),
                      size: Size.infinite,
                    ),
                    // Skeleton
                    Center(
                      child: CustomPaint(
                        painter: _SkeletonPainter(
                          frame: _replayData!.frames[_currentFrameIndex],
                          isPeakFrame: _currentFrameIndex == _replayData!.peakFrameIndex,
                        ),
                        size: const Size(300, 400),
                      ),
                    ),
                    // Frame indicator
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Frame ${_currentFrameIndex + 1}/${_replayData!.frames.length}",
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ),
                    // Peak indicator
                    if (_currentFrameIndex == _replayData!.peakFrameIndex)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_upward, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                "PEAK HEIGHT",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Jump Height Display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text(
                  "${widget.attempt.jumpHeightCm.toStringAsFixed(1)} cm",
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Jump Height",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          // Timeline
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildTimeline(),
          ),
          const SizedBox(height: 16),
          // Controls
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _replay,
                  icon: const Icon(Icons.replay, color: Colors.white),
                  iconSize: 32,
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.purple.shade400],
                    ),
                  ),
                  child: IconButton(
                    onPressed: _togglePlayPause,
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    iconSize: 48,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Skip to peak frame
                    final peakIndex = _replayData!.peakFrameIndex ?? 0;
                    _animationController.value = peakIndex / _replayData!.frames.length;
                    setState(() => _currentFrameIndex = peakIndex);
                  },
                  icon: const Icon(Icons.arrow_upward, color: Colors.white),
                  iconSize: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        // Progress bar
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Colors.white12,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _animationController.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.purple.shade400],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        // Time labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${_replayData!.frames[_currentFrameIndex].timestampMs}ms",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            Text(
              "${_replayData!.durationMs}ms total",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Jump Replay"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.grey.shade600),
            const SizedBox(height: 16),
            Text(
              "No replay data available",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Go Back"),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints grid background
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Paints animated skeleton from pose frame
class _SkeletonPainter extends CustomPainter {
  final PoseFrame frame;
  final bool isPeakFrame;

  _SkeletonPainter({required this.frame, this.isPeakFrame = false});

  @override
  void paint(Canvas canvas, Size size) {
    final jointPaint = Paint()
      ..color = isPeakFrame ? Colors.green : Colors.cyan
      ..style = PaintingStyle.fill;

    final bonePaint = Paint()
      ..color = isPeakFrame ? Colors.green.shade300 : Colors.cyan.shade300
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Calculate scale to fit in view
    final landmarks = frame.landmarks;
    if (landmarks.isEmpty) return;

    // Find bounds
    double minX = double.infinity, maxX = 0;
    double minY = double.infinity, maxY = 0;
    for (final point in landmarks.values) {
      if (point.x < minX) minX = point.x;
      if (point.x > maxX) maxX = point.x;
      if (point.y < minY) minY = point.y;
      if (point.y > maxY) maxY = point.y;
    }

    final poseWidth = maxX - minX;
    final poseHeight = maxY - minY;
    final scale = min(size.width / poseWidth, size.height / poseHeight) * 0.7;
    final offsetX = (size.width - poseWidth * scale) / 2 - minX * scale;
    final offsetY = (size.height - poseHeight * scale) / 2 - minY * scale;

    Offset transform(PosePoint p) {
      return Offset(p.x * scale + offsetX, p.y * scale + offsetY);
    }

    // Draw bones (connections)
    final connections = [
      ['leftShoulder', 'rightShoulder'],
      ['leftShoulder', 'leftElbow'],
      ['leftElbow', 'leftWrist'],
      ['rightShoulder', 'rightElbow'],
      ['rightElbow', 'rightWrist'],
      ['leftShoulder', 'leftHip'],
      ['rightShoulder', 'rightHip'],
      ['leftHip', 'rightHip'],
      ['leftHip', 'leftKnee'],
      ['leftKnee', 'leftAnkle'],
      ['rightHip', 'rightKnee'],
      ['rightKnee', 'rightAnkle'],
      ['leftAnkle', 'leftHeel'],
      ['rightAnkle', 'rightHeel'],
      ['nose', 'leftShoulder'],
      ['nose', 'rightShoulder'],
    ];

    for (final conn in connections) {
      final p1 = landmarks[conn[0]];
      final p2 = landmarks[conn[1]];
      if (p1 != null && p2 != null) {
        canvas.drawLine(transform(p1), transform(p2), bonePaint);
      }
    }

    // Draw joints
    for (final point in landmarks.values) {
      canvas.drawCircle(transform(point), 6, jointPaint);
    }

    // Highlight heels (tracking points)
    final leftHeel = landmarks['leftHeel'];
    if (leftHeel != null) {
      canvas.drawCircle(
        transform(leftHeel),
        10,
        Paint()..color = Colors.yellow.withOpacity(0.7),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SkeletonPainter oldDelegate) {
    return oldDelegate.frame != frame || oldDelegate.isPeakFrame != isPeakFrame;
  }
}
