import 'package:khel_mitra/features/assessment/models/pose_frame.dart';

class AttemptModel {
  final String id;
  final DateTime timestamp;
  final double jumpHeightCm;
  final String? videoPath;
  final JumpReplayData? replayData;

  AttemptModel({
    required this.id,
    required this.timestamp,
    required this.jumpHeightCm,
    this.videoPath,
    this.replayData,
  });

  /// Check if this attempt has replay data
  bool get hasReplay => replayData != null && replayData!.frames.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'jumpHeightCm': jumpHeightCm,
    'videoPath': videoPath,
    'replayData': replayData?.toJson(),
  };

  factory AttemptModel.fromJson(Map<String, dynamic> json) => AttemptModel(
    id: json['id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    jumpHeightCm: (json['jumpHeightCm'] as num).toDouble(),
    videoPath: json['videoPath'] as String?,
    replayData: json['replayData'] != null 
        ? JumpReplayData.fromJson(json['replayData'] as Map<String, dynamic>)
        : null,
  );
}
