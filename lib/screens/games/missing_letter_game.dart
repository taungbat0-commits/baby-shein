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

class MissingLetterGame extends StatefulWidget {
  final String difficulty;
  const MissingLetterGame({super.key, required this.difficulty});

  @override
  State<MissingLetterGame> createState() => _MissingLetterGameState();
}

class _MissingLetterGameState extends State<MissingLetterGame> {
  final Random _rng = Random();
  final GameWordDeck _deck = GameWordDeck();
  List<LessonItem> _questions = [];
  int _index = 0;
  int _score = 0;

  int _missingPos = 0;
  List<String> _letterChoices = [];
  String? _pickedLetter;
  bool _answered = false;

  int get _questionCount =>
      widget.difficulty == 'hard' ? 10 : widget.difficulty == 'medium' ? 7 : 5;

  String get _word =>
      _questions.isEmpty ? '' : _questions[_index].english.trim().toUpperCase();

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
    _prepareRound();
  }

  void _prepareRound() {
    if (_questions.isEmpty) return;
    final word = _word;
    final pos = _rng.nextInt(word.length);
    final correctLetter = word[pos];

    const abc = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final choiceCount = widget.difficulty == 'easy' ? 4 : 6;
    final set = <String>{correctLetter};
    while (set.length < choiceCount) {
      set.add(abc[_rng.nextInt(abc.length)]);
    }
    final list = set.toList()..shuffle(_rng);

    setState(() {
      _missingPos = pos;
      _letterChoices = list;
      _pickedLetter = null;
      _answered = false;
    });
    final item = _questions[_index];
    context.read<AppState>().audio.speak(text: item.english, audioKey: item.audioKey);
  }

  Future<void> _selectLetter(String letter) async {
    if (_answered) return;
    final correctLetter = _word[_missingPos];
    final ok = letter == correctLetter;
    setState(() {
      _pickedLetter = letter;
      _answered = true;
      if (ok) _score++;
    });

    final item = _questions[_index];
    context.read<AppState>().audio.speak(text: item.english, audioKey: item.audioKey);
    await Future<void>.delayed(const Duration(milliseconds: 950));
    if (!mounted) return;

    if (_index + 1 < _questions.length) {
      setState(() => _index++);
      _prepareRound();
    } else {
      final state = context.read<AppState>();
      final badges = await state.recordGameOrQuizResult(
        category: 'missing_letter',
        topicId: 'missing_letter_${widget.difficulty}',
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
    final state = context.watch<AppState>();
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final item = _questions[_index];
    final word = _word;
    final correctLetter = word[_missingPos];

    return Scaffold(
      appBar: AppBar(title: const Text('Find Missing Letter')),
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
                          fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.softPink)),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => state.audio.speak(text: item.english, audioKey: item.audioKey),
                child: KidsIllustration(item: item, accentColor: AppColors.softPink, size: 118),
              ),
              const SizedBox(height: 10),
              Text(
                item.myanmar,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.softPink),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: List.generate(word.length, (i) {
                  final isMissing = i == _missingPos;
                  final display = isMissing
                      ? (_answered ? correctLetter : '?')
                      : word[i];
                  return Container(
                    width: word.length > 7 ? 36 : 44,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isMissing
                          ? (_answered ? AppColors.mintGreenLight : AppColors.sunYellowLight)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isMissing
                            ? (_answered ? AppColors.mintGreen : AppColors.softPink)
                            : AppColors.border,
                        width: 2.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      display,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isMissing ? AppColors.softPink : AppColors.textDark,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose the missing letter • ပျောက်နေတဲ့ အက္ခရာကို ရွေးပါ',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _letterChoices.map((ch) {
                  final isRight = ch == correctLetter;
                  final isPicked = ch == _pickedLetter;
                  Color bg = Colors.white;
                  Color border = AppColors.skyBlue;
                  if (_answered) {
                    if (isRight) {
                      bg = AppColors.mintGreenLight;
                      border = AppColors.mintGreen;
                    } else if (isPicked) {
                      bg = AppColors.softPinkLight;
                      border = AppColors.error;
                    }
                  }
                  return SizedBox(
                    width: 78,
                    height: 68,
                    child: BouncyButton(
                      onTap: () => _selectLetter(ch),
                      color: bg,
                      border: Border.all(color: border, width: 2.5),
                      child: Center(
                        child: Text(
                          ch,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
