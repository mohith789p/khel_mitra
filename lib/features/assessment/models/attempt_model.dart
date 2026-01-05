class AttemptModel {
  final String id;
  final DateTime timestamp;
  final double jumpHeightCm;
  final String? videoPath;

  AttemptModel({
    required this.id,
    required this.timestamp,
    required this.jumpHeightCm,
    this.videoPath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'jumpHeightCm': jumpHeightCm,
    'videoPath': videoPath,
  };

  factory AttemptModel.fromJson(Map<String, dynamic> json) => AttemptModel(
    id: json['id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    jumpHeightCm: (json['jumpHeightCm'] as num).toDouble(),
    videoPath: json['videoPath'] as String?,
  );
}
