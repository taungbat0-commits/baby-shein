import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../models/progress_model.dart';
import '../theme/app_theme.dart';

class RewardDialog extends StatefulWidget {
  final String titleEn;
  final String titleMy;
  final int starsEarned;
  final List<AchievementBadge> newBadges;

  const RewardDialog({
    super.key,
    required this.titleEn,
    required this.titleMy,
    required this.starsEarned,
    this.newBadges = const [],
  });

  static Future<void> show(
    BuildContext context, {
    required String titleEn,
    required String titleMy,
    required int starsEarned,
    List<AchievementBadge> newBadges = const [],
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RewardDialog(
        titleEn: titleEn,
        titleMy: titleMy,
        starsEarned: starsEarned,
        newBadges: newBadges,
      ),
    );
  }

  @override
  State<RewardDialog> createState() => _RewardDialogState();
}

class _RewardDialogState extends State<RewardDialog> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2))..play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(22),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 54)),
              const SizedBox(height: 8),
              Text(
                widget.titleEn,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.titleMy,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.sunYellowLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.sunYellow, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 8),
                    Text(
                      '+${widget.starsEarned} Stars!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.newBadges.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  'New Badge Unlocked! / ဆုတံဆိပ်အသစ်ရရှိပြီ!',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.lavender,
                  ),
                ),
                const SizedBox(height: 8),
                ...widget.newBadges.map(
                  (b) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(b.colorHex).withAlpha(35),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text(b.emoji, style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.titleEn,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                b.titleMy,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mintGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Awesome! ဆက်သွားမယ်'),
                ),
              ),
            ],
          ),
        ),
        ConfettiWidget(
          confettiController: _confetti,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            AppColors.skyBlue,
            AppColors.sunYellow,
            AppColors.softPink,
            AppColors.mintGreen,
            AppColors.lavender,
          ],
        ),
      ],
    );
  }
}
