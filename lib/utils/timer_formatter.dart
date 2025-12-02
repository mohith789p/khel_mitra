String formatDuration(Duration d) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds % 60)}";
}
