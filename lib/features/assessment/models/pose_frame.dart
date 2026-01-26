import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Represents a single frame of pose data during jump detection
class PoseFrame {
  final int timestampMs;
  final Map<String, PosePoint> landmarks;
  final double? heelY;

  PoseFrame({
    required this.timestampMs,
    required this.landmarks,
    this.heelY,
  });

  Map<String, dynamic> toJson() => {
    'timestampMs': timestampMs,
    'landmarks': landmarks.map((key, value) => MapEntry(key, {
      'x': value.x,
      'y': value.y,
    })),
    'heelY': heelY,
  };

  factory PoseFrame.fromJson(Map<String, dynamic> json) {
    final landmarksJson = json['landmarks'] as Map<String, dynamic>;
    return PoseFrame(
      timestampMs: json['timestampMs'] as int,
      landmarks: landmarksJson.map((key, value) {
        final point = value as Map<String, dynamic>;
        return MapEntry(key, PosePoint(
          x: (point['x'] as num).toDouble(),
          y: (point['y'] as num).toDouble(),
        ));
      }),
      heelY: json['heelY'] as double?,
    );
  }

  /// Create from ML Kit Pose
  factory PoseFrame.fromPose(Pose pose, int timestampMs) {
    final landmarks = <String, PosePoint>{};
    
    // Store key body landmarks
    for (final type in PoseLandmarkType.values) {
      final landmark = pose.landmarks[type];
      if (landmark != null) {
        landmarks[type.name] = PosePoint(x: landmark.x, y: landmark.y);
      }
    }

    final leftHeel = pose.landmarks[PoseLandmarkType.leftHeel];
    
    return PoseFrame(
      timestampMs: timestampMs,
      landmarks: landmarks,
      heelY: leftHeel?.y,
    );
  }
}

/// Simple point class for serialization
class PosePoint {
  final double x;
  final double y;

  PosePoint({required this.x, required this.y});
}

/// Collection of pose frames for a complete jump
class JumpReplayData {
  final List<PoseFrame> frames;
  final double jumpHeightCm;
  final int? peakFrameIndex;
  final double? baselineHeelY;
  final double? peakHeelY;

  JumpReplayData({
    required this.frames,
    required this.jumpHeightCm,
    this.peakFrameIndex,
    this.baselineHeelY,
    this.peakHeelY,
  });

  Map<String, dynamic> toJson() => {
    'frames': frames.map((f) => f.toJson()).toList(),
    'jumpHeightCm': jumpHeightCm,
    'peakFrameIndex': peakFrameIndex,
    'baselineHeelY': baselineHeelY,
    'peakHeelY': peakHeelY,
  };

  factory JumpReplayData.fromJson(Map<String, dynamic> json) {
    final framesList = json['frames'] as List<dynamic>;
    return JumpReplayData(
      frames: framesList.map((f) => PoseFrame.fromJson(f as Map<String, dynamic>)).toList(),
      jumpHeightCm: (json['jumpHeightCm'] as num).toDouble(),
      peakFrameIndex: json['peakFrameIndex'] as int?,
      baselineHeelY: json['baselineHeelY'] as double?,
      peakHeelY: json['peakHeelY'] as double?,
    );
  }

  /// Duration of the recorded jump in milliseconds
  int get durationMs {
    if (frames.isEmpty) return 0;
    return frames.last.timestampMs - frames.first.timestampMs;
  }
}
