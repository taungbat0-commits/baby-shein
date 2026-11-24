import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../theme/app_theme.dart';

class KidsIllustration extends StatelessWidget {
  final LessonItem item;
  final Color accentColor;
  final double size;

  const KidsIllustration({
    super.key,
    required this.item,
    this.accentColor = AppColors.skyBlue,
    this.size = 130,
  });

  @override
  Widget build(BuildContext context) {
    final swatchColor = item.colorHex != null ? Color(item.colorHex!) : accentColor;
    final isNumber = RegExp(r'^\d+$').hasMatch(item.emoji.trim());

    double textSize;
    if (isNumber) {
      final len = item.emoji.trim().length;
      textSize = len >= 3 ? size * 0.34 : (len == 2 ? size * 0.44 : size * 0.52);
    } else {
      textSize = size * (item.colorHex != null ? 0.36 : 0.52);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white,
            swatchColor.withAlpha(48),
          ],
        ),
        border: Border.all(
          color: swatchColor.withAlpha(140),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: swatchColor.withAlpha(55),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (item.colorHex != null)
            Container(
              width: size * 0.68,
              height: size * 0.68,
              decoration: BoxDecoration(
                color: swatchColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                item.emoji,
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: isNumber ? FontWeight.w900 : FontWeight.normal,
                  color: isNumber ? AppColors.textDark : null,
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 14,
            child: Icon(
              Icons.auto_awesome,
              size: size * 0.14,
              color: AppColors.sunYellow,
            ),
          ),
        ],
      ),
    );
  }
}
