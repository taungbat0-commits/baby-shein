import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncy_button.dart';
import 'lesson_detail_screen.dart';

class GradeLessonsScreen extends StatelessWidget {
  final int grade;

  const GradeLessonsScreen({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final lessons = state.repository.lessonsForGrade(grade);
    final completedCount = state.completedCountForGrade(grade);
    final headerColor = grade == 1 ? AppColors.skyBlue : AppColors.softPink;

    return Scaffold(
      appBar: AppBar(
        title: Text('Grade $grade • ${grade == 1 ? 'ပထမတန်း' : 'ဒုတိယတန်း'}'),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerColor.withAlpha(38),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: headerColor, width: 2),
            ),
            child: Row(
              children: [
                Text(grade == 1 ? '🎒' : '🚀', style: const TextStyle(fontSize: 38)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Completed: $completedCount / ${lessons.length} Lessons',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ပြီးမြောက်ပြီးသား သင်ခန်းစာ $completedCount ခု',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: lessons.isEmpty ? 0 : completedCount / lessons.length,
                          minHeight: 8,
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(headerColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: lessons.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                final done = state.isLessonCompleted(lesson.id);
                final cardColor = Color(lesson.colorHex);

                return BouncyButton(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LessonDetailScreen(lesson: lesson),
                      ),
                    );
                  },
                  color: Colors.white,
                  border: Border.all(
                    color: done ? AppColors.mintGreen : cardColor.withAlpha(90),
                    width: 2,
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: cardColor.withAlpha(42),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Text(lesson.icon, style: const TextStyle(fontSize: 30)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: cardColor.withAlpha(40),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Lesson ${lesson.order}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: cardColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${lesson.items.length} items',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lesson.titleEn,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              lesson.titleMy,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (done)
                        const Column(
                          children: [
                            Icon(Icons.check_circle_rounded, color: AppColors.mintGreen, size: 30),
                            Text('⭐⭐⭐', style: TextStyle(fontSize: 10)),
                          ],
                        )
                      else
                        Icon(Icons.play_circle_fill_rounded, color: cardColor, size: 34),
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
