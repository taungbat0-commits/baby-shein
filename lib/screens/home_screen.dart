import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile_model.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/announcement_marquee.dart';
import '../widgets/app_update_dialog.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/mascot_banner.dart';
import 'alphabet_screen.dart';
import 'certificate_screen.dart';
import 'daily_english_screen.dart';
import 'downloads_screen.dart';
import 'games/games_hub_screen.dart';
import 'grade_lessons_screen.dart';
import 'listening_screen.dart';
import 'parent_dashboard_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';
import 'speaking_screen.dart';
import 'vocabulary_hub_screen.dart';
import 'writing_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.activeProfile;
    final avatar = AvatarOption.byId(profile.avatarId);

    final g1Done = state.completedCountForGrade(1);
    final g1Total = state.repository.grade1Lessons.length;
    final g2Done = state.completedCountForGrade(2);
    final g2Total = state.repository.grade2Lessons.length;

    if (state.shouldShowAppUpdatePopup) {
      final update = state.availableAppUpdate!;
      state.markAppUpdatePopupShown();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        AppUpdateDialog.show(
          context,
          update: update,
          currentVersionName: state.appVersionName,
        );
      });
    } else if (state.shouldShowPopup) {
      final ann = state.activeAnnouncement!;
      state.markPopupShown();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        AnnouncementPopup.show(
          context,
          announcement: ann,
          onViewLessons: () => _open(context, const DownloadsScreen()),
        );
      });
    }

    final activities = [
      ('🔤', 'Alphabet A-Z', 'အက္ခရာလေ့လာရန်', AppColors.skyBlue, AppColors.skyBlueLight, () => _open(context, const AlphabetScreen())),
      ('📚', 'Vocabulary', 'ဝေါဟာရစကားလုံးများ', AppColors.mintGreen, AppColors.mintGreenLight, () => _open(context, const VocabularyHubScreen())),
      ('🎧', 'Listening', 'နားထောင်မှုလေ့ကျင့်ရန်', AppColors.lavender, AppColors.lavenderLight, () => _open(context, const ListeningScreen())),
      ('🎤', 'Speaking', 'အသံထွက်ပြောလေ့ကျင့်ရန်', AppColors.softPink, AppColors.softPinkLight, () => _open(context, const SpeakingScreen())),
      ('✍️', 'Writing', 'လက်ရေးလေ့ကျင့်ရန်', AppColors.sunYellow, AppColors.sunYellowLight, () => _open(context, const WritingScreen())),
      ('🎮', 'Learning Games', 'ပညာရေးဂိမ်း ၉ မျိုး', AppColors.peach, AppColors.peachLight, () => _open(context, const GamesHubScreen())),
      ('💬', 'Daily English', 'နေ့စဉ်သုံးစကားပြော', AppColors.skyBlue, AppColors.skyBlueLight, () => _open(context, const DailyEnglishScreen())),
      ('📊', 'My Progress', 'တိုးတက်မှုမှတ်တမ်း', AppColors.mintGreen, AppColors.mintGreenLight, () => _open(context, const ProgressScreen())),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Profile & Settings Bar
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _open(context, const ProfileScreen()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.skyBlue.withAlpha(120), width: 2),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(avatar.colorHex).withAlpha(60),
                            child: Text(avatar.emoji, style: const TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14.5,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                'Grade ${profile.grade}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.expand_more_rounded, size: 18, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.sunYellowLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.sunYellow, width: 2),
                    ),
                    child: Text(
                      '⭐ ${profile.stars}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.border, width: 1.5),
                    ),
                    onPressed: () => _open(context, const SettingsScreen()),
                    icon: const Icon(Icons.settings_rounded, color: AppColors.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              MascotBanner(
                mascotEmoji: '🐣',
                accentColor: AppColors.skyBlue,
                titleEn: 'Hello ${profile.name}! Ready to learn?',
                titleMy: 'မင်္ဂလာပါ ${profile.name}! ဒီနေ့ အင်္ဂလိပ်စာ ပျော်ပျော်လေ့လာကြမယ်',
                onTap: () => state.audio.speak(
                  text: 'Hello ${profile.name}! Ready to learn English?',
                  lang: 'en',
                ),
              ),
              if (state.hasNewUpdates) ...[
                const SizedBox(height: 12),
                AnnouncementMarquee(
                  text: state.announcementBannerText,
                  autoHideSeconds: 15,
                  onTap: () {
                    final ann = state.activeAnnouncement;
                    if (ann != null) {
                      AnnouncementPopup.show(
                        context,
                        announcement: ann,
                        onViewLessons: () => _open(context, const DownloadsScreen()),
                      );
                    } else {
                      _open(context, const DownloadsScreen());
                    }
                  },
                  onClose: () => state.dismissAnnouncement(),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Choose Your Class • အတန်းရွေးချယ်ပါ',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _GradeCard(
                      emoji: '🎒',
                      title: 'Grade 1',
                      subtitle: 'ပထမတန်း ($g1Total ခန်း)',
                      done: g1Done,
                      total: g1Total,
                      color: AppColors.skyBlue,
                      onTap: () => _open(context, const GradeLessonsScreen(grade: 1)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GradeCard(
                      emoji: '🌟',
                      title: 'Grade 2',
                      subtitle: 'ဒုတိယတန်း ($g2Total ခန်း)',
                      done: g2Done,
                      total: g2Total,
                      color: AppColors.softPink,
                      onTap: () => _open(context, const GradeLessonsScreen(grade: 2)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Learning Activities • လေ့ကျင့်ခန်းများ',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.32,
                ),
                itemBuilder: (_, i) {
                  final a = activities[i];
                  return BouncyButton(
                    onTap: a.$6,
                    color: a.$5,
                    border: Border.all(color: a.$4.withAlpha(140), width: 2),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(a.$1, style: const TextStyle(fontSize: 30)),
                        const SizedBox(height: 6),
                        Text(
                          a.$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          a.$3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              BouncyButton(
                onTap: () => _open(context, const DownloadsScreen()),
                color: AppColors.skyBlueLight,
                border: Border.all(color: AppColors.skyBlue, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Row(
                  children: [
                    const Text('📥', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Download More Lessons',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15.5,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            'သင်ခန်းစာအသစ်များ ကြိုက်ရာရွေးပြီး ထည့်သွင်းမယ်',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.availableNewPackCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.softPink,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${state.availableNewPackCount} NEW',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      )
                    else
                      const Icon(Icons.chevron_right_rounded, color: AppColors.skyBlue, size: 28),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: BouncyButton(
                      onTap: () => _open(context, const CertificateScreen()),
                      color: AppColors.sunYellowLight,
                      border: Border.all(color: AppColors.sunYellow, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🎓', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Certificate',
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                                Text('ဂုဏ်ပြုလက်မှတ်',
                                    style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BouncyButton(
                      onTap: () => _open(context, const ParentDashboardScreen()),
                      color: AppColors.lavenderLight,
                      border: Border.all(color: AppColors.lavender, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🔒', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Parent Mode',
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                                Text('မိဘစစ်ဆေးရန်',
                                    style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final int done;
  final int total;
  final Color color;
  final VoidCallback onTap;

  const _GradeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.total,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    return BouncyButton(
      onTap: onTap,
      color: color,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: Colors.white.withAlpha(70),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
