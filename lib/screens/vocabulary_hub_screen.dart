import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lesson_model.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncy_button.dart';

class VocabularyHubScreen extends StatefulWidget {
  const VocabularyHubScreen({super.key});

  @override
  State<VocabularyHubScreen> createState() => _VocabularyHubScreenState();
}

class _VocabularyHubScreenState extends State<VocabularyHubScreen> {
  int _gradeFilter = 0; // 0 = All, 1 = Grade 1, 2 = Grade 2
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final allWords = <LessonItem>[];
    final lessons = _gradeFilter == 0
        ? state.repository.allLessons
        : state.repository.lessonsForGrade(_gradeFilter);

    for (final l in lessons) {
      if (l.category == 'alphabet' || l.category == 'numbers') continue;
      allWords.addAll(l.items);
    }

    final filtered = _query.trim().isEmpty
        ? allWords
        : allWords.where((w) {
            final q = _query.toLowerCase();
            return w.english.toLowerCase().contains(q) || w.myanmar.contains(_query);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary • ဝေါဟာရများ'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search English or Myanmar word...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('All')),
                ButtonSegment(value: 1, label: Text('Grade 1')),
                ButtonSegment(value: 2, label: Text('Grade 2')),
              ],
              selected: {_gradeFilter},
              onSelectionChanged: (s) => setState(() => _gradeFilter = s.first),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = filtered[index];
                final color = AppTheme.pastelForIndex(index);

                return BouncyButton(
                  onTap: () => state.audio.speak(
                    text: item.english,
                    audioKey: item.audioKey,
                    slow: state.slowByDefault,
                  ),
                  color: Colors.white,
                  border: Border.all(color: color.withAlpha(90), width: 1.8),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: color.withAlpha(38),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(item.emoji, style: const TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.english,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              item.myanmar,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.softPink,
                              ),
                            ),
                            if (item.exampleEn.isNotEmpty)
                              Text(
                                item.exampleEn,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => state.audio.speak(
                          text: item.english,
                          audioKey: item.audioKey,
                          slow: true,
                        ),
                        icon: const Text('🐢', style: TextStyle(fontSize: 20)),
                        tooltip: 'Slow audio',
                      ),
                      Icon(Icons.volume_up_rounded, color: color, size: 28),
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
