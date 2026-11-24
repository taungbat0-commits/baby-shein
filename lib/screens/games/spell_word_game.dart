import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lesson_model.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bouncy_button.dart';
import '../../widgets/kids_illustration.dart';
import '../../widgets/reward_dialog.dart';

class SpellWordGame extends StatefulWidget {
  final String difficulty;
  const SpellWordGame({super.key, required this.difficulty});

  @override
  State<SpellWordGame> createState() => _SpellWordGameState();
}

class _SpellWordGameState extends State<SpellWordGame> {
  final Random _rng = Random();
  List<LessonItem> _questions = [];
  int _index = 0;
  int _score = 0;

  List<String> _tiles = [];
  List<int> _chosenTileIndexes = [];
  bool _checked = false;
  bool _isCorrect = false;

  int get _questionCount =>
      widget.difficulty == 'hard' ? 8 : widget.difficulty == 'medium' ? 6 : 5;

  String get _targetWord =>
      _questions.isEmpty ? '' : _questions[_index].english.trim().toUpperCase();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startGame());
  }

  void _startGame() {
    final state = context.read<AppState>();
    var pool = state.repository.getSingleWordVocabulary();
    if (widget.difficulty == 'easy') {
      final shortWords = pool.where((e) => e.english.length <= 5).toList();
      if (shortWords.length >= 5) pool = shortWords;
    } else if (widget.difficulty == 'hard') {
      final longer = pool.where((e) => e.english.length >= 5).toList();
      if (longer.length >= 6) pool = longer;
    }
    pool.shuffle(_rng);
    setState(() {
      _questions = pool.take(_questionCount).toList();
      _index = 0;
      _score = 0;
    });
    _prepareWord();
  }

  void _prepareWord() {
    if (_questions.isEmpty) return;
    final word = _targetWord;
    final letters = word.split('');
    if (widget.difficulty == 'hard') {
      const abc = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      letters.add(abc[_rng.nextInt(abc.length)]);
      letters.add(abc[_rng.nextInt(abc.length)]);
    }
    letters.shuffle(_rng);
    setState(() {
      _tiles = letters;
      _chosenTileIndexes = [];
      _checked = false;
      _isCorrect = false;
    });
    final item = _questions[_index];
    context.read<AppState>().audio.speak(text: item.english, audioKey: item.audioKey);
  }

  Future<void> _tapTile(int tileIdx) async {
    if (_checked || _chosenTileIndexes.contains(tileIdx)) return;
    if (_chosenTileIndexes.length >= _targetWord.length) return;

    setState(() => _chosenTileIndexes.add(tileIdx));
    if (_chosenTileIndexes.length == _targetWord.length) {
      await _evaluate();
    }
  }

  void _removeAt(int slotIndex) {
    if (_checked || slotIndex >= _chosenTileIndexes.length) return;
    setState(() => _chosenTileIndexes.removeAt(slotIndex));
  }

  Future<void> _evaluate() async {
    final built = _chosenTileIndexes.map((i) => _tiles[i]).join();
    final ok = built == _targetWord;
    setState(() {
      _checked = true;
      _isCorrect = ok;
      if (ok) _score++;
    });

    final item = _questions[_index];
    context.read<AppState>().audio.speak(text: item.english, audioKey: item.audioKey);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;

    if (_index + 1 < _questions.length) {
      setState(() => _index++);
      _prepareWord();
    } else {
      final state = context.read<AppState>();
      final badges = await state.recordGameOrQuizResult(
        category: 'spell_word',
        topicId: 'spell_word_${widget.difficulty}',
        score: _score,
        total: _questions.length,
        difficulty: widget.difficulty,
      );
      if (!mounted) return;
      final ratio = _questions.isEmpty ? 0.0 : _score / _questions.length;
      final stars = ratio >= 0.9 ? 3 : ratio >= 0.6 ? 2 : ratio > 0 ? 1 : 0;
      await RewardDialog.show(
        context,
        titleEn: 'Spelling Score: $_score / ${_questions.length}',
        titleMy: 'စာလုံးပေါင်းရမှတ် $_score / ${_questions.length}',
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
    final wordLen = _targetWord.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Spell The Word')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Word ${_index + 1}/${_questions.length}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  Text('Score: $_score ⭐',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.peach)),
                ],
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => state.audio.speak(text: item.english, audioKey: item.audioKey),
                child: KidsIllustration(item: item, accentColor: AppColors.peach, size: 112),
              ),
              const SizedBox(height: 10),
              Text(
                item.myanmar,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.softPink),
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: () => state.audio.speak(text: item.english, audioKey: item.audioKey),
                icon: const Icon(Icons.volume_up_rounded),
                label: const Text('Hear Word • အသံနားထောင်မယ်'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(wordLen, (slot) {
                  final filled = slot < _chosenTileIndexes.length;
                  final ch = filled ? _tiles[_chosenTileIndexes[slot]] : '';
                  Color boxColor = Colors.white;
                  Color borderColor = AppColors.peach;
                  if (_checked) {
                    boxColor = _isCorrect ? AppColors.mintGreenLight : AppColors.softPinkLight;
                    borderColor = _isCorrect ? AppColors.mintGreen : AppColors.error;
                  }
                  return GestureDetector(
                    onTap: () => _removeAt(slot),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: wordLen > 7 ? 38 : 46,
                      height: 52,
                      decoration: BoxDecoration(
                        color: boxColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor, width: 2.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        ch,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                    ),
                  );
                }),
              ),
              if (_checked && !_isCorrect) ...[
                const SizedBox(height: 10),
                Text(
                  'Correct: $_targetWord',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.mintGreen),
                ),
              ],
              const SizedBox(height: 22),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: List.generate(_tiles.length, (i) {
                  final used = _chosenTileIndexes.contains(i);
                  return Opacity(
                    opacity: used ? 0.25 : 1.0,
                    child: BouncyButton(
                      onTap: used ? null : () => _tapTile(i),
                      color: AppColors.sunYellowLight,
                      border: Border.all(color: AppColors.sunYellow, width: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Text(
                        _tiles[i],
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              if (!_checked && _chosenTileIndexes.isNotEmpty)
                TextButton.icon(
                  onPressed: () => setState(() => _chosenTileIndexes.clear()),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Clear • ပြန်စီမယ်'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
