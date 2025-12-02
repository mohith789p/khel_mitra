import 'package:flutter/material.dart';

class CameraSwitchButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CameraSwitchButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(
        Icons.cameraswitch_rounded,
        color: Colors.white,
      ),
      tooltip: 'Switch camera',
    );
  }
}


