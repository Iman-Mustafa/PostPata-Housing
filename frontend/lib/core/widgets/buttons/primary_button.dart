// lib/core/widgets/buttons/primary_button.dart
import 'package:flutter/material.dart';

enum ButtonVariant { primary, outlined }

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isOutlined = variant == ButtonVariant.outlined;
    
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : _buildButtonContent(),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : _buildButtonContent(),
            ),
    );
  }

  Widget _buildButtonContent() {
    return icon != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(text),
            ],
          )
        : Text(text);
  }
}