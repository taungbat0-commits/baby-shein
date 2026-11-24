import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lesson_model.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncy_button.dart';
import 'writing_screen.dart';

class AlphabetScreen extends StatefulWidget {
  const AlphabetScreen({super.key});

  @override
  State<AlphabetScreen> createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends State<AlphabetScreen> {
  int _caseMode = 0; // 0 = Aa, 1 = ABC, 2 = abc

  String _formatLetter(String raw) {
    final upper = raw.toUpperCase();
    final lower = raw.toLowerCase();
    if (_caseMode == 1) return upper;
    if (_caseMode == 2) return lower;
    return '$upper$lower';
  }

  void _showLetterPopup(BuildContext context, LessonItem item, Color color) {
    final state = context.read<AppState>();
    state.audio.speak(text: '${item.english}. ${item.exampleEn}', audioKey: item.audioKey);

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: color.withAlpha(42),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
              ),
              alignment: Alignment.center,
              child: Text(item.emoji, style: const TextStyle(fontSize: 50)),
            ),
            const SizedBox(height: 12),
            Text(
              '${item.english.toUpperCase()}  ${item.english.toLowerCase()}',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              '${item.myanmar} (${item.phonetic})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.exampleEn,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            Text(
              item.exampleMy,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: color),
                    onPressed: () => state.audio.speak(
                      text: '${item.english}. ${item.exampleEn}',
                      audioKey: item.audioKey,
                    ),
                    icon: const Icon(Icons.volume_up_rounded),
                    label: const Text('Listen'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.mintGreen),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WritingScreen(initialLetter: item.english.toUpperCase()),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Write'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final alphaLesson = state.repository.findLessonById('g1_alphabet');
    final letters = alphaLesson?.items ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alphabet A-Z • အင်္ဂလိပ်အက္ခရာ'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Aa (Both)')),
                ButtonSegment(value: 1, label: Text('ABC (အကြီး)')),
                ButtonSegment(value: 2, label: Text('abc (အသေး)')),
              ],
              selected: {_caseMode},
              onSelectionChanged: (s) => setState(() => _caseMode = s.first),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.92,
              ),
              itemCount: letters.length,
              itemBuilder: (context, index) {
                final item = letters[index];
                final color = AppTheme.pastelForIndex(index);
                final bg = AppTheme.lightPastelForIndex(index);

                return BouncyButton(
                  onTap: () => _showLetterPopup(context, item, color),
                  color: bg,
                  border: Border.all(color: color.withAlpha(130), width: 2),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatLetter(item.english),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(item.emoji, style: const TextStyle(fontSize: 24)),
                      Text(
                        item.myanmar,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
