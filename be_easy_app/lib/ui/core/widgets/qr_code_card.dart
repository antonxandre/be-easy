import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../colors.dart';

class QrCodeCard extends StatelessWidget {
  final String data;
  final double size;
  final String? title;
  final String? subtitle;
  final IconData? centerIcon;
  final EdgeInsetsGeometry? padding;

  const QrCodeCard({
    super.key,
    required this.data,
    this.size = 200,
    this.title,
    this.subtitle,
    this.centerIcon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        (size <= 150 ? const EdgeInsets.all(12) : const EdgeInsets.all(18));
    final iconBoxSize = size <= 150 ? 34.0 : 44.0;
    final iconSize = size <= 150 ? 20.0 : 26.0;
    final titleTopSpace = size <= 150 ? 8.0 : 14.0;
    final titleFontSize = size <= 150 ? 13.5 : 16.0;
    final subtitleFontSize = size <= 150 ? 11.5 : 13.0;

    return Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(size <= 150 ? 18 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: size <= 150 ? 14 : 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              QrImageView(
                data: data,
                version: QrVersions.auto,
                size: size,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.textPrimary,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.textPrimary,
                ),
              ),
              if (centerIcon != null)
                Container(
                  width: iconBoxSize,
                  height: iconBoxSize,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(iconBoxSize * 0.28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    centerIcon,
                    color: AppColors.primary,
                    size: iconSize,
                  ),
                ),
            ],
          ),
          if (title != null) ...[
            SizedBox(height: titleTopSpace),
            Text(
              title!,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: subtitleFontSize,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
