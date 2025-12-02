import 'package:flutter/material.dart';

class RecordButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onPressed;

  const RecordButton({
    super.key,
    required this.onPressed,
    this.isRecording = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isRecording ? Colors.red : Colors.white;
    final Color borderColor = isRecording ? Colors.red : Colors.white;
    final IconData icon =
        isRecording ? Icons.stop_rounded : Icons.fiber_manual_record_rounded;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor.withOpacity(0.9),
              width: 3,
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(isRecording ? 0.9 : 0.6),
            ),
            child: Icon(
              icon,
              color: isRecording ? Colors.white : Colors.red,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}


