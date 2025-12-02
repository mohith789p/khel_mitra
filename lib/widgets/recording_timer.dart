import 'package:flutter/material.dart';
import '../utils/timer_formatter.dart';

class RecordingTimer extends StatelessWidget {
  final int seconds;
  final TextStyle? style;
  final VoidCallback onPressed;

  const RecordingTimer({
    super.key,
    required this.seconds,
    required this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle effectiveStyle = style ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ) ??
        const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Text(
        TimerFormatter.formatSeconds(seconds),
        style: effectiveStyle,
      ),
    );
  }
}


