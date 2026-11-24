import 'dart:async';
import 'package:flutter/material.dart';

import '../models/content_pack_model.dart';
import '../theme/app_theme.dart';

class AnnouncementMarquee extends StatefulWidget {
  final String text;
  final int autoHideSeconds;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const AnnouncementMarquee({
    super.key,
    required this.text,
    this.autoHideSeconds = 15,
    required this.onTap,
    required this.onClose,
  });

  @override
  State<AnnouncementMarquee> createState() => _AnnouncementMarqueeState();
}

class _AnnouncementMarqueeState extends State<AnnouncementMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scrollCtrl;
  Timer? _autoHideTimer;

  @override
  void initState() {
    super.initState();
    final ms = ((widget.text.length * 145) + 5200).clamp(7000, 22000);
    _scrollCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ms),
    )..repeat();

    _autoHideTimer = Timer(
      Duration(seconds: widget.autoHideSeconds),
      () {
        if (mounted) widget.onClose();
      },
    );
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 13.5,
      fontWeight: FontWeight.w800,
      color: AppColors.textDark,
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.sunYellowLight, AppColors.softPinkLight],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.softPink.withAlpha(160), width: 1.8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 6, 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.softPink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('📢', style: TextStyle(fontSize: 15)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final boxWidth = constraints.maxWidth;
                        final tp = TextPainter(
                          text: TextSpan(text: widget.text, style: textStyle),
                          maxLines: 1,
                          textDirection: TextDirection.ltr,
                        )..layout();
                        final totalDistance = boxWidth + tp.width + 32;

                        return ClipRect(
                          child: SizedBox(
                            height: 22,
                            width: boxWidth,
                            child: AnimatedBuilder(
                              animation: _scrollCtrl,
                              builder: (_, child) {
                                final dx = boxWidth - (_scrollCtrl.value * totalDistance);
                                return Transform.translate(
                                  offset: Offset(dx, 0),
                                  child: child,
                                );
                              },
                              child: OverflowBox(
                                maxWidth: double.infinity,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.text,
                                  style: textStyle,
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: widget.onClose,
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: 0.0),
              duration: Duration(seconds: widget.autoHideSeconds),
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 3,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.softPink.withAlpha(150),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnnouncementPopup extends StatelessWidget {
  final RemoteAnnouncement announcement;
  final VoidCallback onViewLessons;

  const AnnouncementPopup({
    super.key,
    required this.announcement,
    required this.onViewLessons,
  });

  static Future<void> show(
    BuildContext context, {
    required RemoteAnnouncement announcement,
    required VoidCallback onViewLessons,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => AnnouncementPopup(
        announcement: announcement,
        onViewLessons: onViewLessons,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = announcement.titleMy.isNotEmpty
        ? announcement.titleMy
        : announcement.titleEn;
    final body = announcement.messageMy.isNotEmpty
        ? announcement.messageMy
        : announcement.messageEn;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.sunYellowLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.softPink, width: 2.5),
            ),
            alignment: Alignment.center,
            child: const Text('📢', style: TextStyle(fontSize: 36)),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          if (announcement.titleEn.isNotEmpty && announcement.titleMy.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              announcement.titleEn,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.skyBlue,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.skyBlueLight.withAlpha(140),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('ပိတ်မယ်', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softPink,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onViewLessons();
                  },
                  child: const Text('အသစ်ကြည့်မယ်', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
