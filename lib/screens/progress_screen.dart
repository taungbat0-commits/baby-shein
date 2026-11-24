import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile_model.dart';
import '../models/progress_model.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncy_button.dart';
import 'certificate_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.activeProfile;
    final avatar = AvatarOption.byId(profile.avatarId);

    final g1Done = state.completedCountForGrade(1);
    final g1Total = state.repository.grade1Lessons.length;
    final g2Done = state.completedCountForGrade(2);
    final g2Total = state.repository.grade2Lessons.length;

    return Scaffold(
      appBar: AppBar(title: const Text('My Progress • တိုးတက်မှုမှတ်တမ်း')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Hero Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.skyBlueLight, AppColors.sunYellowLight],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.skyBlue, width: 2),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Text(avatar.emoji, style: const TextStyle(fontSize: 34)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Grade ${profile.grade} • ⭐ ${profile.stars} Stars',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    BouncyButton(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CertificateScreen()),
                      ),
                      color: AppColors.sunYellow,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      borderRadius: 16,
                      child: const Text(
                        '🎓 PDF',
                        style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 4 Key Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.7,
                children: [
                  _StatBox('📚', '${state.completedLessons.length}', 'Lessons Done\nပြီးသောသင်ခန်းစာ', AppColors.skyBlueLight),
                  _StatBox('📖', '${state.learnedWordIds.length}', 'Words Learned\nတတ်ပြီးစကားလုံး', AppColors.mintGreenLight),
                  _StatBox('🎮', '${state.quizResults.length}', 'Games Played\nကစားပြီးဂိမ်း', AppColors.softPinkLight),
                  _StatBox('⏱️', '${state.totalMinutesLearned}m', 'Learning Time\nလေ့လာချိန်', AppColors.lavenderLight),
                ],
              ),

              const SizedBox(height: 18),
              const Text(
                'Grade Progress • အတန်းအလိုက်တိုးတက်မှု',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              _GradeBar('Grade 1 (ပထမတန်း)', g1Done, g1Total, AppColors.skyBlue),
              const SizedBox(height: 8),
              _GradeBar('Grade 2 (ဒုတိယတန်း)', g2Done, g2Total, AppColors.softPink),

              const SizedBox(height: 20),
              const Text(
                'Achievement Badges • ဆုတံဆိပ်များ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: AchievementBadge.all.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.45,
                ),
                itemBuilder: (_, i) {
                  final b = AchievementBadge.all[i];
                  final unlocked = state.unlockedBadges.contains(b.id);
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: unlocked ? Color(b.colorHex).withAlpha(35) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: unlocked ? Color(b.colorHex) : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Opacity(
                          opacity: unlocked ? 1.0 : 0.3,
                          child: Text(b.emoji, style: const TextStyle(fontSize: 30)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          b.titleEn,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: unlocked ? AppColors.textDark : AppColors.textMuted,
                          ),
                        ),
                        Text(
                          b.titleMy,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
              const Text(
                'Daily Activity • နေ့စဉ်မှတ်တမ်း',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              if (state.dailyActivity.isEmpty)
                const Text('No daily activity yet. Start a lesson today!',
                    style: TextStyle(color: AppColors.textMuted))
              else
                ...state.dailyActivity.take(7).map(
                  (d) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(d.dateStr, style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text(
                          '📚${d.lessonsCompleted}  📖${d.wordsLearned}  🎮${d.gamesPlayed}  ⭐${d.starsEarned}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color bg;
  const _StatBox(this.emoji, this.value, this.label, this.bg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeBar extends StatelessWidget {
  final String title;
  final int done;
  final int total;
  final Color color;
  const _GradeBar(this.title, this.done, this.total, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text('$done / $total', style: TextStyle(fontWeight: FontWeight.w900, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 9,
              backgroundColor: color.withAlpha(35),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
