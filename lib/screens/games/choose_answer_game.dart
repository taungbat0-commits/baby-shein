import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lesson_model.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bouncy_button.dart';
import '../../widgets/kids_illustration.dart';
import '../../widgets/reward_dialog.dart';
import 'game_word_deck.dart';

class ChooseAnswerGame extends StatefulWidget {
  final String difficulty;
  const ChooseAnswerGame({super.key, required this.difficulty});

  @override
  State<ChooseAnswerGame> createState() => _ChooseAnswerGameState();
}

class _ChooseAnswerGameState extends State<ChooseAnswerGame> {
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
    final pool = state.repository.getSingleWordVocabulary(grade: grade)..shuffle(_rng);
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
    final optCount = widget.difficulty == 'easy' ? 3 : 4;
    final others = state.repository
        .getSingleWordVocabulary()
        .where((e) => e.id != target.id)
        .toList()
      ..shuffle(_rng);
    final opts = [target, ...others.take(optCount - 1)]..shuffle(_rng);
    setState(() {
      _options = opts;
      _selectedId = null;
      _answered = false;
    });
  }

  Future<void> _pick(LessonItem chosen) async {
    if (_answered) return;
    final state = context.read<AppState>();
    final target = _questions[_index];
    final correct = chosen.id == target.id;
    setState(() {
      _selectedId = chosen.id;
      _answered = true;
      if (correct) _score++;
    });
    state.audio.speak(text: target.english, audioKey: target.audioKey);

    await Future<void>.delayed(const Duration(milliseconds: 950));
    if (!mounted) return;

    if (_index + 1 < _questions.length) {
      setState(() => _index++);
      _buildRound();
    } else {
      final badges = await state.recordGameOrQuizResult(
        category: 'choose_answer',
        topicId: 'choose_answer_${widget.difficulty}',
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

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Correct Answer')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Q ${_index + 1}/${_questions.length}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  Text('Score: $_score ⭐',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.mintGreen)),
                ],
              ),
              const SizedBox(height: 16),
              KidsIllustration(item: target, accentColor: AppColors.mintGreen, size: 120),
              const SizedBox(height: 12),
              Text(
                target.myanmar,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.softPink,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'What is this in English? • အင်္ဂလိပ်လို အဖြေမှန်ရွေးပါ',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: _options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final opt = _options[i];
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
                      onTap: () => _pick(opt),
                      color: bg,
                      border: Border.all(color: border, width: 2.2),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.lightPastelForIndex(i),
                            child: Text(
                              String.fromCharCode(65 + i),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppTheme.pastelForIndex(i),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              opt.english,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          if (_answered && isCorrect)
                            const Icon(Icons.check_circle_rounded, color: AppColors.mintGreen)
                          else if (_answered && isPicked)
                            const Icon(Icons.cancel_rounded, color: AppColors.error),
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
