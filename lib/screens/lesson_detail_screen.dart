import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lesson_model.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_control_bar.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/kids_illustration.dart';
import '../widgets/reward_dialog.dart';

class LessonDetailScreen extends StatefulWidget {
  final LessonModule lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int _index = 0;
  bool _completing = false;

  LessonItem get _currentItem => widget.lesson.items[_index];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playCurrent(lang: 'en'));
  }

  Future<void> _playCurrent({bool? slowOverride, String lang = 'en'}) async {
    if (!mounted) return;
    final state = context.read<AppState>();
    final item = _currentItem;
    final slow = slowOverride ?? state.slowByDefault;

    await state.audio.speak(
      text: lang == 'my' ? item.myanmar : item.english,
      audioKey: item.audioKey,
      slow: slow,
      lang: lang,
    );
    await state.recordWordLearned(widget.lesson, item);
  }

  void _goToIndex(int next) {
    if (next < 0 || next >= widget.lesson.items.length) return;
    setState(() => _index = next);
    _playCurrent(lang: 'en');
  }

  Future<void> _finishLesson() async {
    if (_completing) return;
    setState(() => _completing = true);
    final state = context.read<AppState>();
    final badges = await state.completeLesson(
      lesson: widget.lesson,
      starsEarned: 3,
      score: 100,
    );
    if (!mounted) return;
    setState(() => _completing = false);

    await RewardDialog.show(
      context,
      titleEn: 'Lesson Completed!',
      titleMy: 'သင်ခန်းစာ ပြီးမြောက်သွားပါပြီ!',
      starsEarned: 3,
      newBadges: badges,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = widget.lesson.items;
    final item = _currentItem;
    final accentColor = Color(widget.lesson.colorHex);
    final isLast = _index == items.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.titleEn),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${_index + 1} / ${items.length}',
                  style: TextStyle(fontWeight: FontWeight.w900, color: accentColor, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_index + 1) / items.length,
                  minHeight: 8,
                  backgroundColor: accentColor.withAlpha(40),
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
            ),
            SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final selected = i == _index;
                  return GestureDetector(
                    onTap: () => _goToIndex(i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      decoration: BoxDecoration(
                        color: selected ? accentColor : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selected ? accentColor : AppColors.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        items[i].phonetic.isNotEmpty && widget.lesson.category == 'numbers'
                            ? items[i].phonetic
                            : '${i + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: selected ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: accentColor.withAlpha(110), width: 2.5),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _playCurrent(lang: 'en'),
                            child: KidsIllustration(item: item, accentColor: accentColor, size: 126),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            item.english,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (item.phonetic.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                              decoration: BoxDecoration(
                                color: accentColor.withAlpha(30),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.phonetic,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                ),
                              ),
                            ),
                          ],
                          if (state.showMyanmarHints) ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _playCurrent(lang: 'my'),
                              child: Text(
                                item.myanmar,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.softPink,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          AudioControlBar(
                            primaryColor: accentColor,
                            onListen: () => _playCurrent(slowOverride: false, lang: 'en'),
                            onListenMy: () => _playCurrent(slowOverride: false, lang: 'my'),
                            onSlow: () => state.audio.replay(slow: true),
                            onRepeat: () => state.audio.replay(slow: state.slowByDefault),
                          ),
                        ],
                      ),
                    ),
                    if (item.grammarNote != null && item.grammarNote!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.sunYellowLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.sunYellow, width: 2),
                        ),
                        child: Row(
                          children: [
                            const Text('💡', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.grammarNote!,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (item.exampleEn.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.skyBlueLight.withAlpha(160),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.skyBlue.withAlpha(110), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Example • ဥပမာဝါကျ',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.skyBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.exampleEn,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            if (state.showMyanmarHints && item.exampleMy.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                item.exampleMy,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: BouncyButton(
                                    onTap: () => state.audio.speak(
                                      text: item.exampleEn,
                                      audioKey: item.exampleAudioKey,
                                      slow: state.slowByDefault,
                                      lang: 'en',
                                    ),
                                    color: AppColors.skyBlue,
                                    borderRadius: 14,
                                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.volume_up_rounded, color: Colors.white, size: 18),
                                        SizedBox(width: 5),
                                        Text(
                                          'EN ဝါကျ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (item.exampleMy.isNotEmpty) ...[
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: BouncyButton(
                                      onTap: () => state.audio.speak(
                                        text: item.exampleMy,
                                        audioKey: item.exampleAudioKey,
                                        slow: state.slowByDefault,
                                        lang: 'my',
                                      ),
                                      color: AppColors.softPink,
                                      borderRadius: 14,
                                      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('🇲🇲', style: TextStyle(fontSize: 15)),
                                          SizedBox(width: 5),
                                          Text(
                                            'MY ဝါကျ',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: Row(
                children: [
                  if (_index > 0) ...[
                    Expanded(
                      flex: 2,
                      child: BouncyButton(
                        onTap: () => _goToIndex(_index - 1),
                        color: Colors.white,
                        border: Border.all(color: AppColors.border, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
                            SizedBox(width: 4),
                            Text('Back', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 3,
                    child: BouncyButton(
                      onTap: isLast ? _finishLesson : () => _goToIndex(_index + 1),
                      color: isLast ? AppColors.mintGreen : accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLast ? 'Finish (+3 ⭐) ပြီးပါပြီ' : 'Next • ရှေ့ဆက်မယ်',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            isLast ? Icons.star_rounded : Icons.arrow_forward_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
