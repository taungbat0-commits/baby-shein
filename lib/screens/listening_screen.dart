import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lesson_model.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_control_bar.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/kids_illustration.dart';
import '../widgets/reward_dialog.dart';

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  final Random _rng = Random();
  int _mode = 0; // 0 = Practice, 1 = Picture Quiz
  bool _sentenceMode = false;
  int _practiceIndex = 0;

  List<LessonItem> _pool = [];
  List<LessonItem> _quizTargets = [];
  List<LessonItem> _options = [];
  int _quizIndex = 0;
  int _score = 0;
  String? _selectedId;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      final items = state.repository
          .getAllQuizItems()
          .where((e) => e.exampleEn.isNotEmpty)
          .toList();
      items.shuffle(_rng);
      setState(() => _pool = items);
      if (items.isNotEmpty) _playPracticeItem(slow: state.slowByDefault);
    });
  }

  LessonItem? get _currentPractice =>
      _pool.isEmpty ? null : _pool[_practiceIndex % _pool.length];

  void _playPracticeItem({bool slow = false, String lang = 'en'}) {
    final item = _currentPractice;
    if (item == null) return;
    final audio = context.read<AppState>().audio;
    if (_sentenceMode) {
      audio.speak(
        text: lang == 'my' ? item.exampleMy : item.exampleEn,
        audioKey: item.exampleAudioKey,
        slow: slow,
        lang: lang,
      );
    } else {
      audio.speak(
        text: lang == 'my' ? item.myanmar : item.english,
        audioKey: item.audioKey,
        slow: slow,
        lang: lang,
      );
    }
  }

  void _startQuiz() {
    final state = context.read<AppState>();
    final vocab = state.repository.getSingleWordVocabulary()..shuffle(_rng);
    final targets = vocab.take(6).toList();
    setState(() {
      _mode = 1;
      _quizTargets = targets;
      _quizIndex = 0;
      _score = 0;
      _selectedId = null;
      _answered = false;
    });
    _prepareQuizOptions();
  }

  void _prepareQuizOptions() {
    if (_quizTargets.isEmpty) return;
    final state = context.read<AppState>();
    final target = _quizTargets[_quizIndex];
    final others = state.repository
        .getSingleWordVocabulary()
        .where((e) => e.id != target.id && e.emoji != target.emoji)
        .toList()
      ..shuffle(_rng);
    final opts = [target, ...others.take(3)]..shuffle(_rng);
    setState(() {
      _options = opts;
      _selectedId = null;
      _answered = false;
    });
    _playQuizAudio(slow: state.slowByDefault);
  }

  void _playQuizAudio({bool slow = false}) {
    if (_quizTargets.isEmpty) return;
    final target = _quizTargets[_quizIndex];
    context.read<AppState>().audio.speak(
          text: target.english,
          audioKey: target.audioKey,
          slow: slow,
        );
  }

  Future<void> _selectQuizOption(LessonItem chosen) async {
    if (_answered) return;
    final target = _quizTargets[_quizIndex];
    final correct = chosen.id == target.id;
    setState(() {
      _selectedId = chosen.id;
      _answered = true;
      if (correct) _score++;
    });

    await Future<void>.delayed(const Duration(milliseconds: 950));
    if (!mounted) return;

    if (_quizIndex + 1 < _quizTargets.length) {
      setState(() => _quizIndex++);
      _prepareQuizOptions();
    } else {
      final state = context.read<AppState>();
      final badges = await state.recordGameOrQuizResult(
        category: 'listening',
        topicId: 'picture_listening',
        score: _score,
        total: _quizTargets.length,
        difficulty: 'easy',
      );
      if (!mounted) return;
      final stars = _score >= 5 ? 3 : _score >= 3 ? 2 : 1;
      await RewardDialog.show(
        context,
        titleEn: 'Listening Score: $_score / ${_quizTargets.length}',
        titleMy: 'နားထောင်မှုရမှတ် $_score / ${_quizTargets.length}',
        starsEarned: stars,
        newBadges: badges,
      );
      if (mounted) _startQuiz();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Listening • နားထောင်မှုလေ့ကျင့်ရန်')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Listen • လေ့ကျင့်မယ်')),
                  ButtonSegment(value: 1, label: Text('Quiz • ပုံရွေးမယ်')),
                ],
                selected: {_mode},
                onSelectionChanged: (s) {
                  if (s.first == 1) {
                    _startQuiz();
                  } else {
                    setState(() => _mode = 0);
                    _playPracticeItem(slow: state.slowByDefault);
                  }
                },
              ),
            ),
            Expanded(
              child: _mode == 0 ? _buildPracticeBody(state) : _buildQuizBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeBody(AppState state) {
    final item = _currentPractice;
    if (item == null) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Word • စကားလုံး'),
                selected: !_sentenceMode,
                onSelected: (_) {
                  setState(() => _sentenceMode = false);
                  _playPracticeItem(slow: state.slowByDefault);
                },
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Sentence • ဝါကျ'),
                selected: _sentenceMode,
                onSelected: (_) {
                  setState(() => _sentenceMode = true);
                  _playPracticeItem(slow: state.slowByDefault);
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.lavender.withAlpha(120), width: 2.5),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _playPracticeItem(slow: false),
                  child: KidsIllustration(
                    item: item,
                    accentColor: AppColors.lavender,
                    size: 124,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _sentenceMode ? item.exampleEn : item.english,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _sentenceMode ? 22 : 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                if (state.showMyanmarHints)
                  Text(
                    _sentenceMode ? item.exampleMy : item.myanmar,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.softPink,
                    ),
                  ),
                const SizedBox(height: 18),
                AudioControlBar(
                  primaryColor: AppColors.lavender,
                  onListen: () => _playPracticeItem(slow: false, lang: 'en'),
                  onListenMy: () => _playPracticeItem(slow: false, lang: 'my'),
                  onSlow: () => state.audio.replay(slow: true),
                  onRepeat: () => state.audio.replay(slow: state.slowByDefault),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: BouncyButton(
                  onTap: () {
                    setState(() {
                      _practiceIndex = (_practiceIndex - 1 + _pool.length) % _pool.length;
                    });
                    _playPracticeItem(slow: state.slowByDefault);
                  },
                  color: Colors.white,
                  border: Border.all(color: AppColors.border, width: 2),
                  child: const Center(
                    child: Text('◀ Previous', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BouncyButton(
                  onTap: () {
                    setState(() => _practiceIndex = (_practiceIndex + 1) % _pool.length);
                    _playPracticeItem(slow: state.slowByDefault);
                  },
                  color: AppColors.lavender,
                  child: const Center(
                    child: Text(
                      'Next ▶',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizBody() {
    if (_quizTargets.isEmpty) return const Center(child: CircularProgressIndicator());
    final target = _quizTargets[_quizIndex];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_quizIndex + 1} / ${_quizTargets.length}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              Text(
                'Score: $_score ⭐',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppColors.lavender,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AudioControlBar(
            primaryColor: AppColors.skyBlue,
            onListen: () => _playQuizAudio(slow: false),
            onSlow: () => _playQuizAudio(slow: true),
            onRepeat: () => _playQuizAudio(slow: false),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tap the matching picture • အသံနှင့်ကိုက်ညီသောပုံကို ရွေးပါ',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: _options.map((opt) {
                final isCorrect = opt.id == target.id;
                final isPicked = opt.id == _selectedId;
                Color bg = Colors.white;
                Color border = AppColors.border;
                if (_answered) {
                  if (isCorrect) {
                    bg = AppColors.mintGreenLight;
                    border = AppColors.mintGreen;
                  } else if (isPicked) {
                    bg = AppColors.softPinkLight;
                    border = AppColors.error;
                  }
                }
                return BouncyButton(
                  onTap: () => _selectQuizOption(opt),
                  color: bg,
                  border: Border.all(color: border, width: 2.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(opt.emoji, style: const TextStyle(fontSize: 54)),
                      const SizedBox(height: 8),
                      Text(
                        _answered ? opt.english : opt.myanmar,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
