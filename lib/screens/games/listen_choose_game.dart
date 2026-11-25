import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lesson_model.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/audio_control_bar.dart';
import '../../widgets/bouncy_button.dart';
import '../../widgets/reward_dialog.dart';
import 'game_word_deck.dart';

class ListenChooseGame extends StatefulWidget {
  final String difficulty;
  const ListenChooseGame({super.key, required this.difficulty});

  @override
  State<ListenChooseGame> createState() => _ListenChooseGameState();
}

class _ListenChooseGameState extends State<ListenChooseGame> {
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
    final others = state.repository
        .getSingleWordVocabulary()
        .where((e) => e.id != target.id)
        .toList()
      ..shuffle(_rng);
    final opts = [target, ...others.take(3)]..shuffle(_rng);
    setState(() {
      _options = opts;
      _selectedId = null;
      _answered = false;
    });
    _playTarget(slow: state.slowByDefault);
  }

  void _playTarget({bool slow = false}) {
    if (_questions.isEmpty) return;
    final target = _questions[_index];
    context.read<AppState>().audio.speak(
          text: target.english,
          audioKey: target.audioKey,
          slow: slow,
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

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    if (_index + 1 < _questions.length) {
      setState(() => _index++);
      _buildRound();
    } else {
      final state = context.read<AppState>();
      final badges = await state.recordGameOrQuizResult(
        category: 'listen_choose',
        topicId: 'listen_choose_${widget.difficulty}',
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
    final hideEmoji = widget.difficulty == 'hard';

    return Scaffold(
      appBar: AppBar(title: const Text('Listen And Choose')),
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
                          fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.lavender)),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lavenderLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.lavender, width: 2),
                ),
                child: Column(
                  children: [
                    const Text('🎧', style: TextStyle(fontSize: 46)),
                    const SizedBox(height: 6),
                    const Text(
                      'Listen carefully and choose • အသံနားထောင်ပြီး ရွေးပါ',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    AudioControlBar(
                      primaryColor: AppColors.lavender,
                      onListen: () => _playTarget(slow: false),
                      onSlow: () => _playTarget(slow: true),
                      onRepeat: () => _playTarget(slow: false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
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
                          if (!hideEmoji || _answered)
                            Text(opt.emoji, style: const TextStyle(fontSize: 44)),
                          const SizedBox(height: 6),
                          Text(
                            opt.english,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                          ),
                          if (_answered)
                            Text(
                              opt.myanmar,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }
}
