import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/mascot_banner.dart';

class DailyEnglishScreen extends StatelessWidget {
  const DailyEnglishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final phrases = state.repository.dailyPhrases;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily English • နေ့စဉ်သုံးစကားပြော'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
        itemCount: phrases.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return MascotBanner(
              mascotEmoji: '💬',
              accentColor: AppColors.skyBlue,
              titleEn: 'Tap any card to hear & practice!',
              titleMy: 'ကတ်လေးတွေကို နှိပ်ပြီး အသံနားထောင် လိုက်ဆိုကြည့်ပါ',
              onTap: () => state.audio.speak(
                text: 'Tap any card to hear and practice daily English!',
              ),
            );
          }

          final phrase = phrases[index - 1];
          final color = AppTheme.pastelForIndex(index);

          return BouncyButton(
            onTap: () => state.audio.speak(
              text: phrase.english,
              audioKey: phrase.audioKey,
              slow: state.slowByDefault,
            ),
            color: Colors.white,
            border: Border.all(color: color.withAlpha(110), width: 2),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(phrase.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withAlpha(35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${phrase.situationEn} • ${phrase.situationMy}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.volume_up_rounded, color: color, size: 28),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  phrase.english,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  phrase.myanmar,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.softPink,
                  ),
                ),
                if (phrase.responseEn.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => state.audio.speak(
                      text: phrase.responseEn,
                      slow: state.slowByDefault,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.mintGreenLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Text('↪️ ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  phrase.responseEn,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14.5,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  phrase.responseMy,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.volume_up_rounded, color: AppColors.mintGreen, size: 22),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
