import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface, // text color
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: colorScheme.primary, // icon color from theme
        ),
        hintText: hintText,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.5), // subtle hint color
        ),
        filled: true,
        fillColor: colorScheme.surface, // input background from theme
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.25), // subtle border color
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.primary, // highlight on focus
            width: 2,
          ),
        ),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      ),
    );
  }
}
