import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lesson_model.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/mascot_banner.dart';

class _DailyTopicGroup {
  final String titleEn;
  final String titleMy;
  final String emoji;
  final List<DailyPhrase> phrases;

  _DailyTopicGroup({
    required this.titleEn,
    required this.titleMy,
    required this.emoji,
    required this.phrases,
  });
}

class DailyEnglishScreen extends StatelessWidget {
  const DailyEnglishScreen({super.key});

  List<_DailyTopicGroup> _groupByTopic(List<DailyPhrase> phrases) {
    final map = <String, _DailyTopicGroup>{};
    for (final p in phrases) {
      final key = p.situationEn.trim().toLowerCase();
      if (!map.containsKey(key)) {
        map[key] = _DailyTopicGroup(
          titleEn: p.situationEn.trim().isEmpty ? 'Daily Talk' : p.situationEn.trim(),
          titleMy: p.situationMy.trim().isEmpty ? 'နေ့စဉ်သုံး' : p.situationMy.trim(),
          emoji: p.emoji,
          phrases: [p],
        );
      } else {
        map[key]!.phrases.add(p);
      }
    }
    return map.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final topics = _groupByTopic(state.repository.dailyPhrases);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily English • နေ့စဉ်သုံးစကားပြော')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: topics.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return MascotBanner(
              mascotEmoji: '💬',
              accentColor: AppColors.skyBlue,
              titleEn: 'Choose a Conversation Topic!',
              titleMy: 'ကြိုက်တဲ့ ခေါင်းစဉ်ကိုနှိပ်ပြီး အပြန်အလှန်စကားပြော လေ့လာပါ',
              onTap: () => state.audio.speak(
                text: 'Choose a conversation topic!',
                lang: 'en',
              ),
            );
          }

          final topic = topics[index - 1];
          final color = AppTheme.pastelForIndex(index - 1);
          final bg = AppTheme.lightPastelForIndex(index - 1);

          return BouncyButton(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _DailyTopicDetailScreen(
                    topic: topic,
                    accentColor: color,
                  ),
                ),
              );
            },
            color: Colors.white,
            border: Border.all(color: color.withAlpha(130), width: 2),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Text(topic.emoji, style: const TextStyle(fontSize: 30)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.titleEn,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        topic.titleMy,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.softPink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${topic.phrases.length} Dialogues • စကားပြော ${topic.phrases.length} ခု',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: color, size: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DailyTopicDetailScreen extends StatelessWidget {
  final _DailyTopicGroup topic;
  final Color accentColor;

  const _DailyTopicDetailScreen({
    required this.topic,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${topic.emoji} ${topic.titleEn}'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        itemCount: topic.phrases.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(32),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withAlpha(110), width: 1.5),
              ),
              child: Text(
                '${topic.titleMy} — အပြန်အလှန် စကားပြောခန်းများ',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            );
          }

          final phrase = topic.phrases[index - 1];

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: accentColor.withAlpha(100), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Speaker A (Left Chat Bubble)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.82,
                    ),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: AppColors.skyBlueLight,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      border: Border.all(color: AppColors.skyBlue.withAlpha(120)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(phrase.emoji, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            const Text(
                              'Speaker A • ပြောသူ',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.skyBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          phrase.english,
                          style: const TextStyle(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (state.showMyanmarHints) ...[
                          const SizedBox(height: 3),
                          Text(
                            phrase.myanmar,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.softPink,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _MiniAudioBtn(
                                label: '🔊 EN',
                                color: AppColors.skyBlue,
                                onTap: () => state.audio.speak(
                                  text: phrase.english,
                                  audioKey: phrase.audioKey,
                                  slow: state.slowByDefault,
                                  lang: 'en',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MiniAudioBtn(
                                label: '🇲🇲 MY',
                                color: AppColors.softPink,
                                onTap: () => state.audio.speak(
                                  text: phrase.myanmar,
                                  audioKey: phrase.audioKey,
                                  slow: state.slowByDefault,
                                  lang: 'my',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                if (phrase.responseEn.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  // Speaker B (Right Reply Chat Bubble)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.82,
                      ),
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: AppColors.mintGreenLight,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(6),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        border: Border.all(color: AppColors.mintGreen.withAlpha(130)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '↪️ Reply • ပြန်ဖြေသူ',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.mintGreen,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            phrase.responseEn,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (state.showMyanmarHints && phrase.responseMy.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              phrase.responseMy,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _MiniAudioBtn(
                                  label: '🔊 EN',
                                  color: AppColors.mintGreen,
                                  onTap: () => state.audio.speak(
                                    text: phrase.responseEn,
                                    audioKey: '${phrase.audioKey}_res',
                                    slow: state.slowByDefault,
                                    lang: 'en',
                                  ),
                                ),
                              ),
                              if (phrase.responseMy.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _MiniAudioBtn(
                                    label: '🇲🇲 MY',
                                    color: AppColors.softPink,
                                    onTap: () => state.audio.speak(
                                      text: phrase.responseMy,
                                      audioKey: '${phrase.audioKey}_res',
                                      slow: state.slowByDefault,
                                      lang: 'my',
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
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

class _MiniAudioBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MiniAudioBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyButton(
      onTap: onTap,
      color: color,
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}
