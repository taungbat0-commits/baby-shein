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
          Text(
            item.emoji,
            style: TextStyle(fontSize: size * (item.colorHex != null ? 0.36 : 0.52)),
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
