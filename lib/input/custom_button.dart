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

    // Use primary color as default background, or accept an override
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;
    // Use onPrimary color as default text/icon color, or accept an override
    final effectiveForegroundColor = foregroundColor ?? colorScheme.onPrimary;

    return SizedBox(
      width: double.infinity, // Ensures button takes full width like the text field
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // Disable button when loading
        style: ElevatedButton.styleFrom(
          // 1. Adopt the rounded corners (16) from CustomTextField
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), 
          ),
          // 2. Adopt the background color
          backgroundColor: effectiveBackgroundColor,
          // 3. Adopt the text/icon color
          foregroundColor: effectiveForegroundColor,
          // 4. Adopt the generous vertical padding (similar to TextField contentPadding)
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          // Ensure elevation is consistent
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