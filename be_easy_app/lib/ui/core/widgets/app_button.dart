import 'package:flutter/material.dart';
import '../colors.dart';

enum AppButtonType { primary, secondary, outline }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonType type;
  final double height;
  final double? width;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.type = AppButtonType.primary,
    this.height = 56,
    this.width,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (type) {
      case AppButtonType.primary:
        bg = AppColors.primary;
        fg = AppColors.onPrimary;
        break;
      case AppButtonType.secondary:
        bg = AppColors.secondary;
        fg = AppColors.onSecondary;
        break;
      case AppButtonType.outline:
        bg = Colors.transparent;
        fg = AppColors.secondary;
        border = const BorderSide(color: AppColors.secondary, width: 2);
        break;
    }

    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: type == AppButtonType.outline ? 0 : 3,
          shadowColor: bg.withValues(alpha: 0.4),
          side: border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: height >= 60 ? 18 : 15,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, size: height >= 60 ? 22 : 18, color: fg),
                  ],
                ],
              ),
      ),
    );
  }
}
