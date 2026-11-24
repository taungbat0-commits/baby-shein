import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile_model.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/announcement_marquee.dart';
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

  String _greetingEn() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _greetingMy() {
    final h = DateTime.now().hour;
    if (h < 12) return 'မင်္ဂလာနံနက်ခင်းပါ';
    if (h < 17) return 'မင်္ဂလာနေ့လယ်ခင်းပါ';
    return 'မင်္ဂလာညနေခင်းပါ';
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.activeProfile;
    final avatar = AvatarOption.byId(profile.avatarId);

    final g1Total = state.repository.grade1Lessons.length;
    final g1Done = state.completedCountForGrade(1);
    final g2Total = state.repository.grade2Lessons.length;
    final g2Done = state.completedCountForGrade(2);

    if (state.shouldShowPopup) {
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: BouncyButton(
                      onTap: () => _open(context, const ProfileScreen()),
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      borderRadius: 24,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Color(avatar.colorHex).withAlpha(55),
                            child: Text(avatar.emoji, style: const TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  'Grade ${profile.grade} • Tap to switch',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
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
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.sunYellowLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.sunYellow, width: 2),
                    ),
                    child: Row(
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 4),
                        Text(
                          '${profile.stars}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  BouncyButton(
                    onTap: () => _open(context, const SettingsScreen()),
                    color: Colors.white,
                    padding: const EdgeInsets.all(11),
                    borderRadius: 18,
                    child: const Icon(Icons.settings_rounded, color: AppColors.textDark, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              MascotBanner(
                mascotEmoji: avatar.emoji,
                titleEn: '${_greetingEn()}, ${profile.name}!',
                titleMy: '${_greetingMy()} - Baby Shein မှ ကြိုဆိုပါတယ်',
                onTap: () => state.audio.speak(
                  text: '${_greetingEn()} ${profile.name}! Let us learn English today.',
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
                        ),
                      ),
                      IconButton(
                        onPressed: () => state.dismissAnnouncement(),
                        icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              const Text(
                'Choose Your Class • အတန်းရွေးချယ်ပါ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _GradeCard(
                      grade: 1,
                      titleEn: 'Grade 1',
                      titleMy: 'ပထမတန်း (၁၄ ခန်း)',
                      emoji: '🎒',
                      color: AppColors.skyBlue,
                      completed: g1Done,
                      total: g1Total,
                      onTap: () => _open(context, const GradeLessonsScreen(grade: 1)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GradeCard(
                      grade: 2,
                      titleEn: 'Grade 2',
                      titleMy: 'ဒုတိယတန်း (၁၂ ခန်း)',
                      emoji: '🚀',
                      color: AppColors.softPink,
                      completed: g2Done,
                      total: g2Total,
                      onTap: () => _open(context, const GradeLessonsScreen(grade: 2)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Learning Activities • လေ့ကျင့်ခန်းများ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.38,
                children: [
                  _ActivityTile(
                    emoji: '🔤',
                    titleEn: 'Alphabet A-Z',
                    titleMy: 'အက္ခရာလေ့လာရန်',
                    bgColor: AppColors.skyBlueLight,
                    accentColor: AppColors.skyBlue,
                    onTap: () => _open(context, const AlphabetScreen()),
                  ),
                  _ActivityTile(
                    emoji: '📚',
                    titleEn: 'Vocabulary',
                    titleMy: 'ဝေါဟာရစကားလုံးများ',
                    bgColor: AppColors.mintGreenLight,
                    accentColor: AppColors.mintGreen,
                    onTap: () => _open(context, const VocabularyHubScreen()),
                  ),
                  _ActivityTile(
                    emoji: '🎧',
                    titleEn: 'Listening',
                    titleMy: 'နားထောင်မှုလေ့ကျင့်ရန်',
                    bgColor: AppColors.lavenderLight,
                    accentColor: AppColors.lavender,
                    onTap: () => _open(context, const ListeningScreen()),
                  ),
                  _ActivityTile(
                    emoji: '🎤',
                    titleEn: 'Speaking',
                    titleMy: 'အသံထွက်ပြောလေ့ကျင့်ရန်',
                    bgColor: AppColors.softPinkLight,
                    accentColor: AppColors.softPink,
                    onTap: () => _open(context, const SpeakingScreen()),
                  ),
                  _ActivityTile(
                    emoji: '✍️',
                    titleEn: 'Writing',
                    titleMy: 'လက်ရေးလေ့ကျင့်ရန်',
                    bgColor: AppColors.sunYellowLight,
                    accentColor: AppColors.sunYellow,
                    onTap: () => _open(context, const WritingScreen()),
                  ),
                  _ActivityTile(
                    emoji: '🎮',
                    titleEn: 'Learning Games',
                    titleMy: 'ပညာရေးဂိမ်း ၅ မျိုး',
                    bgColor: AppColors.peachLight,
                    accentColor: AppColors.peach,
                    onTap: () => _open(context, const GamesHubScreen()),
                  ),
                  _ActivityTile(
                    emoji: '💬',
                    titleEn: 'Daily English',
                    titleMy: 'နေ့စဉ်သုံးစကားပြော',
                    bgColor: AppColors.skyBlueLight,
                    accentColor: AppColors.skyBlue,
                    onTap: () => _open(context, const DailyEnglishScreen()),
                  ),
                  _ActivityTile(
                    emoji: '📊',
                    titleEn: 'My Progress',
                    titleMy: 'တိုးတက်မှုမှတ်တမ်း',
                    bgColor: AppColors.mintGreenLight,
                    accentColor: AppColors.mintGreen,
                    onTap: () => _open(context, const ProgressScreen()),
                  ),
                ],
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
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🎓', style: TextStyle(fontSize: 24)),
                          SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Certificate',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  'ဂုဏ်ပြုလက်မှတ်',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🔒', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Parent Mode',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  'မိဘစစ်ဆေးရန်',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradeCard extends StatelessWidget {
  final int grade;
  final String titleEn;
  final String titleMy;
  final String emoji;
  final Color color;
  final int completed;
  final int total;
  final VoidCallback onTap;

  const _GradeCard({
    required this.grade,
    required this.titleEn,
    required this.titleMy,
    required this.emoji,
    required this.color,
    required this.completed,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
    return BouncyButton(
      onTap: onTap,
      color: color,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 34)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(60),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completed/$total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            titleEn,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            titleMy,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
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

class _ActivityTile extends StatelessWidget {
  final String emoji;
  final String titleEn;
  final String titleMy;
  final Color bgColor;
  final Color accentColor;
  final VoidCallback onTap;

  const _ActivityTile({
    required this.emoji,
    required this.titleEn,
    required this.titleMy,
    required this.bgColor,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncyButton(
      onTap: onTap,
      color: bgColor,
      border: Border.all(color: accentColor.withAlpha(110), width: 2),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const Spacer(),
          Text(
            titleEn,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          Text(
            titleMy,
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
  }
}
