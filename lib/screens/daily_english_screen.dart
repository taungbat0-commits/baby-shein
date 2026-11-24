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
      appBar: AppBar(title: const Text('Daily English • နေ့စဉ်သုံးစကားပြော')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
        itemCount: phrases.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return MascotBanner(
              mascotEmoji: '💬',
              accentColor: AppColors.skyBlue,
              titleEn: 'Listen in English & Myanmar!',
              titleMy: 'အင်္ဂလိပ်နဲ့ မြန်မာ နှစ်ဘာသာလုံး အသံနားထောင်နိုင်ပါတယ်',
              onTap: () => state.audio.speak(
                text: 'Listen in English and Myanmar!',
                lang: 'en',
              ),
            );
          }

          final phrase = phrases[index - 1];
          final color = AppTheme.pastelForIndex(index);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withAlpha(110), width: 2),
            ),
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
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color),
                      ),
                    ),
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: BouncyButton(
                        onTap: () => state.audio.speak(
                          text: phrase.english,
                          audioKey: phrase.audioKey,
                          slow: state.slowByDefault,
                          lang: 'en',
                        ),
                        color: color,
                        borderRadius: 14,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.volume_up_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 5),
                            Text('EN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: BouncyButton(
                        onTap: () => state.audio.speak(
                          text: phrase.myanmar,
                          audioKey: phrase.audioKey,
                          slow: state.slowByDefault,
                          lang: 'my',
                        ),
                        color: AppColors.softPink,
                        borderRadius: 14,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🇲🇲', style: TextStyle(fontSize: 15)),
                            SizedBox(width: 5),
                            Text('MY မြန်မာ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (phrase.responseEn.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.mintGreenLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '↪️ ${phrase.responseEn}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                        ),
                        Text(
                          phrase.responseMy,
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => state.audio.speak(
                                text: phrase.responseEn,
                                audioKey: '${phrase.audioKey}_res',
                                slow: state.slowByDefault,
                                lang: 'en',
                              ),
                              icon: const Icon(Icons.volume_up_rounded, size: 18),
                              label: const Text('EN Reply'),
                            ),
                            TextButton.icon(
                              onPressed: () => state.audio.speak(
                                text: phrase.responseMy,
                                audioKey: '${phrase.audioKey}_res',
                                slow: state.slowByDefault,
                                lang: 'my',
                              ),
                              icon: const Text('🇲🇲'),
                              label: const Text('MY Reply'),
                            ),
                          ],
                        ),
                      ],
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
