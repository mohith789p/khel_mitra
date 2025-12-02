import 'package:flutter/material.dart';

/// A highly customizable, theme-aware button that mimics the modern,
/// rounded aesthetic of the CustomTextField widget.
///
/// It uses the theme's color scheme for consistency and includes options
/// for text, icons, and loading states.
class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Use primary color as default background, or accept an override.
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;
    // Use onPrimary color as default text/icon color, or accept an override.
    final effectiveForegroundColor = foregroundColor ?? colorScheme.onPrimary;

    // More compact button than the original full-width, tall style.
    return SizedBox(
      height: 44, // Smaller fixed height for a compact look.
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // Disable button when loading
        style: ElevatedButton.styleFrom(
          // Rounded corners for a modern look.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // Background color.
          backgroundColor: effectiveBackgroundColor,
          // Text/icon color.
          foregroundColor: effectiveForegroundColor,
          // More compact horizontal padding.
          padding: const EdgeInsets.symmetric(horizontal: 16),
          // Ensure elevation is consistent.
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveForegroundColor),
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 24),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: effectiveForegroundColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}