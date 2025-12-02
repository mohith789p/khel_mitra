class TimerFormatter {
  const TimerFormatter._();

  /// Formats a total number of seconds into an `MM:SS` string.
  ///
  /// Negative values are treated as `0`.
  static String formatSeconds(int seconds) {
    final safeSeconds = seconds < 0 ? 0 : seconds;
    final minutes = safeSeconds ~/ 60;
    final remainingSeconds = safeSeconds % 60;

    final minutesPart = minutes.toString().padLeft(2, '0');
    final secondsPart = remainingSeconds.toString().padLeft(2, '0');

    return '$minutesPart:$secondsPart';
  }
}

String formatDuration(Duration d) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds % 60)}";
}
