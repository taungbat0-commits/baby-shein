import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/bouncy_button.dart';
import 'choose_answer_game.dart';
import 'listen_choose_game.dart';
import 'match_word_game.dart';
import 'missing_letter_game.dart';
import 'spell_word_game.dart';

class GamesHubScreen extends StatefulWidget {
  const GamesHubScreen({super.key});

  @override
  State<GamesHubScreen> createState() => _GamesHubScreenState();
}

class _GamesHubScreenState extends State<GamesHubScreen> {
  String _difficulty = 'easy';

  void _play(Widget game) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => game));
  }

  @override
  Widget build(BuildContext context) {
    final games = [
      (
        '🖼️',
        'Match Word & Picture',
        'စကားလုံးနှင့် ပုံတွဲကစားမယ်',
        AppColors.skyBlue,
        AppColors.skyBlueLight,
        () => _play(MatchWordGame(difficulty: _difficulty)),
      ),
      (
        '✅',
        'Choose Correct Answer',
        'အဖြေမှန် ရွေးချယ်မယ်',
        AppColors.mintGreen,
        AppColors.mintGreenLight,
        () => _play(ChooseAnswerGame(difficulty: _difficulty)),
      ),
      (
        '🎧',
        'Listen And Choose',
        'အသံနားထောင်ပြီး ရွေးမယ်',
        AppColors.lavender,
        AppColors.lavenderLight,
        () => _play(ListenChooseGame(difficulty: _difficulty)),
      ),
      (
        '🔤',
        'Spell The Word',
        'စာလုံးပေါင်း ဂိမ်းကစားမယ်',
        AppColors.peach,
        AppColors.peachLight,
        () => _play(SpellWordGame(difficulty: _difficulty)),
      ),
      (
        '🧩',
        'Find Missing Letter',
        'ပျောက်နေသော အက္ခရာရှာမယ်',
        AppColors.softPink,
        AppColors.softPinkLight,
        () => _play(MissingLetterGame(difficulty: _difficulty)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Learning Games • ပညာရေးဂိမ်းများ')),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.sunYellowLight,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.sunYellow, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'Choose Level • အဆင့်ရွေးချယ်ပါ',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'easy', label: Text('Easy လွယ်')),
                      ButtonSegment(value: 'medium', label: Text('Medium လယ်')),
                      ButtonSegment(value: 'hard', label: Text('Hard ခက်')),
                    ],
                    selected: {_difficulty},
                    onSelectionChanged: (s) => setState(() => _difficulty = s.first),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: games.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final g = games[i];
                  return BouncyButton(
                    onTap: g.$6,
                    color: g.$5,
                    border: Border.all(color: g.$4, width: 2),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.center,
                          child: Text(g.$1, style: const TextStyle(fontSize: 32)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                g.$2,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                g.$3,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.play_circle_fill_rounded, color: g.$4, size: 36),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
