import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lesson_model.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bouncy_button.dart';
import '../../widgets/reward_dialog.dart';

class MatchWordGame extends StatefulWidget {
  final String difficulty;
  const MatchWordGame({super.key, required this.difficulty});

  @override
  State<MatchWordGame> createState() => _MatchWordGameState();
}

class _MatchWordGameState extends State<MatchWordGame> {
  final Random _rng = Random();
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
      _questions = pool.take(_questionCount).toList();
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
        .where((e) => e.id != target.id && e.emoji != target.emoji)
        .toList()
      ..shuffle(_rng);
    final opts = [target, ...distractors.take(3)]..shuffle(_rng);
    setState(() {
      _options = opts;
      _selectedId = null;
      _answered = false;
    });
    state.audio.speak(text: target.english, audioKey: target.audioKey, slow: state.slowByDefault);
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

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    if (_index + 1 < _questions.length) {
      setState(() => _index++);
      _buildRound();
    } else {
      final state = context.read<AppState>();
      final badges = await state.recordGameOrQuizResult(
        category: 'match_word',
        topicId: 'match_word_${widget.difficulty}',
        score: _score,
        total: _questions.length,
        difficulty: widget.difficulty,
      );
      if (!mounted) return;
      final ratio = _questions.isEmpty ? 0.0 : _score / _questions.length;
      final stars = ratio >= 0.9 ? 3 : ratio >= 0.6 ? 2 : ratio > 0 ? 1 : 0;
      await RewardDialog.show(
        context,
        titleEn: 'Score: $_score / ${_questions.length}',
        titleMy: 'ရမှတ် $_score / ${_questions.length}',
        starsEarned: stars,
        newBadges: badges,
      );
      if (mounted) _startGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final target = _questions[_index];

    return Scaffold(
      appBar: AppBar(title: const Text('Match Word & Picture')),
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
                          fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.skyBlue)),
                ],
              ),
              const SizedBox(height: 12),
              BouncyButton(
                onTap: () => state.audio.speak(text: target.english, audioKey: target.audioKey),
                color: AppColors.skyBlueLight,
                border: Border.all(color: AppColors.skyBlue, width: 2.5),
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(target.english,
                            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                        const SizedBox(width: 8),
                        const Icon(Icons.volume_up_rounded, color: AppColors.skyBlue, size: 28),
                      ],
                    ),
                    if (widget.difficulty == 'easy' && state.showMyanmarHints)
                      Text(target.myanmar,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.softPink)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text('Tap the matching picture • ကိုက်ညီတဲ့ပုံကို နှိပ်ပါ',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted)),
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
                      onTap: () => _pick(opt),
                      color: bg,
                      border: Border.all(color: border, width: 2.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(opt.emoji, style: const TextStyle(fontSize: 56)),
                          if (_answered) ...[
                            const SizedBox(height: 6),
                            Text(opt.english,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
