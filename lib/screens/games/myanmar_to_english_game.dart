import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lesson_model.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bouncy_button.dart';
import '../../widgets/reward_dialog.dart';
import 'game_word_deck.dart';

class MyanmarToEnglishGame extends StatefulWidget {
  final String difficulty;
  const MyanmarToEnglishGame({super.key, required this.difficulty});

  @override
  State<MyanmarToEnglishGame> createState() => _MyanmarToEnglishGameState();
}

class _MyanmarToEnglishGameState extends State<MyanmarToEnglishGame> {
  final Random _rng = Random();
  final GameWordDeck _deck = GameWordDeck();
  List<LessonItem> _questions = [];
  List<LessonItem> _options = [];
  int _index = 0;
  int _score = 0;
  String? _selectedId;
  bool _answered = false;

  int get _questionCount =>
      widget.difficulty == 'hard' ? 10 : widget.difficulty == 'medium' ? 7 : 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startGame());
  }

  void _startGame() {
    final state = context.read<AppState>();
    final grade = widget.difficulty == 'easy' ? 1 : null;
    final pool = state.repository
        .getSingleWordVocabulary(grade: grade)
        .where((e) => e.myanmar.trim().isNotEmpty)
        .toList();
    setState(() {
      _questions = _deck.nextRound(pool, _questionCount, _rng);
      _index = 0;
      _score = 0;
    });
    _buildRound();
  }

  void _buildRound() {
    if (_questions.isEmpty) return;
    final state = context.read<AppState>();
    final target = _questions[_index];
    final distractors = state.repository
        .getSingleWordVocabulary()
        .where((e) =>
            e.id != target.id &&
            e.english.toLowerCase() != target.english.toLowerCase())
        .toList()
      ..shuffle(_rng);
    final opts = [target, ...distractors.take(3)]..shuffle(_rng);
    setState(() {
      _options = opts;
      _selectedId = null;
      _answered = false;
    });
    _speakMyanmar();
  }

  void _speakMyanmar() {
    if (_questions.isEmpty) return;
    final state = context.read<AppState>();
    final target = _questions[_index];
    state.audio.speak(
      text: target.myanmar,
      audioKey: target.audioKey,
      slow: state.slowByDefault,
      lang: 'my',
    );
  }

  Future<void> _pick(LessonItem chosen) async {
    if (_answered) return;
    final target = _questions[_index];
    final correct = chosen.id == target.id;
    setState(() {
      _selectedId = chosen.id;
      _answered = true;
      if (correct) _score++;
    });

    final state = context.read<AppState>();
    state.audio.speak(
      text: target.english,
      audioKey: target.audioKey,
      slow: state.slowByDefault,
      lang: 'en',
    );

    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    if (_index + 1 < _questions.length) {
      setState(() => _index++);
      _buildRound();
    } else {
      final badges = await state.recordGameOrQuizResult(
        category: 'myanmar_to_en',
        topicId: 'myanmar_to_en_${widget.difficulty}',
        score: _score,
        total: _questions.length,
        difficulty: widget.difficulty,
      );
      if (!mounted) return;
      final ratio = _questions.isEmpty ? 0.0 : _score / _questions.length;
      final stars = ratio >= 0.9 ? 3 : ratio >= 0.6 ? 2 : ratio > 0 ? 1 : 0;
      await RewardDialog.show(
        context,
        titleEn: 'Round ${_deck.round} • Score: $_score / ${_questions.length}',
        titleMy: 'အကျော့ ${_deck.round} • ရမှတ် $_score / ${_questions.length}',
        starsEarned: stars,
        newBadges: badges,
      );
      if (mounted) _startGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final target = _questions[_index];
    final showHintEmoji = widget.difficulty == 'easy' || _answered;

    return Scaffold(
      appBar: AppBar(
        title: Text('Myanmar → English • Round ${_deck.round}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Word ${_index + 1} / ${_questions.length}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.sunYellowLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.sunYellow),
                    ),
                    child: Text('⭐ $_score', style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.softPinkLight,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.softPink.withAlpha(150), width: 2.5),
                ),
                child: Column(
                  children: [
                    const Text(
                      'အင်္ဂလိပ်လို ဘယ်လိုခေါ်လဲ?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (showHintEmoji) ...[
                      Text(target.emoji, style: const TextStyle(fontSize: 44)),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      target.myanmar,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    BouncyButton(
                      onTap: _speakMyanmar,
                      color: AppColors.softPink,
                      borderRadius: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🇲🇲', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 6),
                          Text(
                            'ပြန်နားထောင်မယ်',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: _options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final opt = _options[i];
                    final isCorrectOpt = opt.id == target.id;
                    final isSelected = opt.id == _selectedId;

                    Color bg = Colors.white;
                    Color border = AppColors.skyBlue.withAlpha(120);
                    if (_answered) {
                      if (isCorrectOpt) {
                        bg = AppColors.mintGreenLight;
                        border = AppColors.mintGreen;
                      } else if (isSelected) {
                        bg = AppColors.softPinkLight;
                        border = AppColors.softPink;
                      }
                    }

                    return BouncyButton(
                      onTap: () => _pick(opt),
                      color: bg,
                      border: Border.all(color: border, width: 2.5),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              opt.english,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          if (_answered && isCorrectOpt)
                            const Icon(Icons.check_circle_rounded, color: AppColors.mintGreen, size: 26)
                          else if (_answered && isSelected)
                            const Icon(Icons.cancel_rounded, color: AppColors.softPink, size: 26),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
