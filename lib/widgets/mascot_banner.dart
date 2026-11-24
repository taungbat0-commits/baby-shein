import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MascotBanner extends StatefulWidget {
  final String titleEn;
  final String titleMy;
  final String mascotEmoji;
  final Color accentColor;
  final VoidCallback? onTap;

  const MascotBanner({
    super.key,
    required this.titleEn,
    required this.titleMy,
    this.mascotEmoji = '🦉',
    this.accentColor = AppColors.skyBlue,
    this.onTap,
  });

  @override
  State<MascotBanner> createState() => _MascotBannerState();
}

class _MascotBannerState extends State<MascotBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.accentColor.withAlpha(42),
              AppColors.sunYellowLight,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: widget.accentColor.withAlpha(95), width: 2),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (_, child) {
                return Transform.translate(
                  offset: Offset(0, -4 * _controller.value),
                  child: child,
                );
              },
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.accentColor, width: 2.5),
                ),
                alignment: Alignment.center,
                child: Text(widget.mascotEmoji, style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.titleEn,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.titleMy,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.volume_up_rounded, color: widget.accentColor, size: 26),
          ],
        ),
      ),
    );
  }
}
