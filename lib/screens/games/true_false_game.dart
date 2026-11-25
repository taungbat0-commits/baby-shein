import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lesson_model.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bouncy_button.dart';
import '../../widgets/reward_dialog.dart';
import 'game_word_deck.dart';

class _TFQuestion {
  final LessonItem pictureItem;
  final LessonItem shownWordItem;
  final bool isTrue;

  const _TFQuestion({
    required this.pictureItem,
    required this.shownWordItem,
    required this.isTrue,
  });
}

class TrueFalseGame extends StatefulWidget {
  final String difficulty;
  const TrueFalseGame({super.key, required this.difficulty});

  @override
  State<TrueFalseGame> createState() => _TrueFalseGameState();
}

class _TrueFalseGameState extends State<TrueFalseGame> {
  final Random _rng = Random();
  final GameWordDeck _deck = GameWordDeck();
  List<_TFQuestion> _questions = [];
  int _index = 0;
  int _score = 0;
  bool _answered = false;
  bool? _pickedCorrect;

  int get _questionCount =>
      widget.difficulty == 'hard' ? 10 : widget.difficulty == 'medium' ? 8 : 6;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startGame());
  }

  void _startGame() {
    final state = context.read<AppState>();
    final grade = widget.difficulty == 'easy' ? 1 : null;
    final pool = state.repository.getSingleWordVocabulary(grade: grade);
    final allWords = state.repository.getSingleWordVocabulary();
    final targets = _deck.nextRound(pool, _questionCount, _rng);

    final built = <_TFQuestion>[];
    for (final target in targets) {
      final makeTrue = _rng.nextBool();
      if (makeTrue) {
        built.add(_TFQuestion(
          pictureItem: target,
          shownWordItem: target,
          isTrue: true,
        ));
      } else {
        final others = allWords
            .where((e) => e.id != target.id && e.english.toLowerCase() != target.english.toLowerCase())
            .toList();
        final fake = others.isNotEmpty ? others[_rng.nextInt(others.length)] : target;
        built.add(_TFQuestion(
          pictureItem: target,
          shownWordItem: fake,
          isTrue: fake.id == target.id,
        ));
      }
    }

    setState(() {
      _questions = built;
      _index = 0;
      _score = 0;
      _answered = false;
      _pickedCorrect = null;
    });
    _speakCurrent();
  }

  void _speakCurrent() {
    if (_questions.isEmpty) return;
    final state = context.read<AppState>();
    final q = _questions[_index];
    state.audio.speak(
      text: q.shownWordItem.english,
      audioKey: q.shownWordItem.audioKey,
      slow: state.slowByDefault,
    );
  }

  Future<void> _answer(bool userSaysTrue) async {
    if (_answered) return;
    final q = _questions[_index];
    final correct = userSaysTrue == q.isTrue;
    setState(() {
      _answered = true;
      _pickedCorrect = correct;
      if (correct) _score++;
    });

    if (!q.isTrue) {
      final state = context.read<AppState>();
      state.audio.speak(
        text: q.pictureItem.english,
        audioKey: q.pictureItem.audioKey,
        slow: state.slowByDefault,
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 1150));
    if (!mounted) return;

    if (_index + 1 < _questions.length) {
      setState(() {
        _index++;
        _answered = false;
        _pickedCorrect = null;
      });
      _speakCurrent();
    } else {
      final state = context.read<AppState>();
      final badges = await state.recordGameOrQuizResult(
        category: 'true_false',
        topicId: 'true_false_${widget.difficulty}',
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
    final q = _questions[_index];

    return Scaffold(
      appBar: AppBar(
        title: Text('True or False • Round ${_deck.round}'),
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
                    'Question ${_index + 1} / ${_questions.length}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.sunYellowLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.sunYellow),
                    ),
                    child: Text(
                      '⭐ $_score',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_index + 1) / _questions.length,
                  minHeight: 8,
                  backgroundColor: AppColors.skyBlueLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.skyBlue),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: !_answered
                          ? AppColors.skyBlue.withAlpha(140)
                          : (_pickedCorrect == true ? AppColors.mintGreen : AppColors.softPink),
                      width: 3,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'ဒီပုံနဲ့ စကားလုံး ကိုက်ညီရဲ့လား?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 126,
                        height: 126,
                        decoration: BoxDecoration(
                          color: AppColors.sunYellowLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.sunYellow, width: 3),
                        ),
                        alignment: Alignment.center,
                        child: Text(q.pictureItem.emoji, style: const TextStyle(fontSize: 64)),
                      ),
                      const SizedBox(height: 18),
                      GestureDetector(
                        onTap: _speakCurrent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.skyBlueLight,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.volume_up_rounded, color: AppColors.skyBlue),
                              const SizedBox(width: 8),
                              Text(
                                q.shownWordItem.english,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (_answered)
                        Text(
                          _pickedCorrect == true
                              ? '🎉 မှန်ပါတယ်! (${q.pictureItem.english} = ${q.pictureItem.myanmar})'
                              : '💡 အဖြေမှန်: ${q.pictureItem.english} (${q.pictureItem.myanmar})',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: _pickedCorrect == true ? AppColors.mintGreen : AppColors.softPink,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: BouncyButton(
                      onTap: () => _answer(true),
                      color: AppColors.mintGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Column(
                        children: [
                          Text('✅', style: TextStyle(fontSize: 28)),
                          SizedBox(height: 4),
                          Text(
                            'TRUE • မှန်တယ်',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: BouncyButton(
                      onTap: () => _answer(false),
                      color: AppColors.softPink,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Column(
                        children: [
                          Text('❌', style: TextStyle(fontSize: 28)),
                          SizedBox(height: 4),
                          Text(
                            'FALSE • မှားတယ်',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
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
