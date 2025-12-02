import 'package:flutter/material.dart';

/// Simple enum to represent common flash modes.
enum FlashToggleMode {
  off,
  on,
  auto,
  torch,
}

class FlashToggleButton extends StatelessWidget {
  final FlashToggleMode mode;
  final VoidCallback onPressed;

  const FlashToggleButton({
    super.key,
    required this.mode,
    required this.onPressed,
  });

  IconData get _icon {
    switch (mode) {
      case FlashToggleMode.on:
        return Icons.flash_on_rounded;
      case FlashToggleMode.auto:
        return Icons.flash_auto_rounded;
      case FlashToggleMode.torch:
        return Icons.lightbulb_outline;
      case FlashToggleMode.off:
      default:
        return Icons.flash_off_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        _icon,
        color: Colors.white,
      ),
      tooltip: 'Flash',
    );
  }
}


