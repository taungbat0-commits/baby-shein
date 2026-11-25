import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/lesson_model.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/reward_dialog.dart';
import 'game_word_deck.dart';

class _FlipCard {
  final String pairId;
  final bool isPicture;
  final LessonItem item;
  bool faceUp = false;
  bool matched = false;

  _FlipCard({
    required this.pairId,
    required this.isPicture,
    required this.item,
  });
}

class MemoryFlipGame extends StatefulWidget {
  final String difficulty;
  const MemoryFlipGame({super.key, required this.difficulty});

  @override
  State<MemoryFlipGame> createState() => _MemoryFlipGameState();
}

class _MemoryFlipGameState extends State<MemoryFlipGame> {
  final Random _rng = Random();
  final GameWordDeck _deck = GameWordDeck();
  List<_FlipCard> _cards = [];
  int? _firstIndex;
  bool _busy = false;
  int _moves = 0;
  int _matchedPairs = 0;

  int get _pairCount =>
      widget.difficulty == 'hard' ? 8 : widget.difficulty == 'medium' ? 6 : 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startGame());
  }

  void _startGame() {
    final state = context.read<AppState>();
    final grade = widget.difficulty == 'easy' ? 1 : null;
    final pool = state.repository.getSingleWordVocabulary(grade: grade);
    final chosen = _deck.nextRound(pool, _pairCount, _rng);

    final deckCards = <_FlipCard>[];
    for (final item in chosen) {
      deckCards.add(_FlipCard(pairId: item.id, isPicture: true, item: item));
      deckCards.add(_FlipCard(pairId: item.id, isPicture: false, item: item));
    }
    deckCards.shuffle(_rng);

    setState(() {
      _cards = deckCards;
      _firstIndex = null;
      _busy = false;
      _moves = 0;
      _matchedPairs = 0;
    });
  }

  Future<void> _tapCard(int index) async {
    if (_busy) return;
    final card = _cards[index];
    if (card.faceUp || card.matched) return;

    setState(() => card.faceUp = true);

    if (_firstIndex == null) {
      _firstIndex = index;
      return;
    }

    final prevIdx = _firstIndex!;
    final prevCard = _cards[prevIdx];
    _firstIndex = null;
    _moves++;

    if (prevCard.pairId == card.pairId && prevCard.isPicture != card.isPicture) {
      setState(() {
        prevCard.matched = true;
        card.matched = true;
        _matchedPairs++;
      });
      final state = context.read<AppState>();
      state.audio.speak(
        text: card.item.english,
        audioKey: card.item.audioKey,
        slow: state.slowByDefault,
      );

      final totalPairs = _cards.length ~/ 2;
      if (_matchedPairs >= totalPairs) {
        _busy = true;
        await Future<void>.delayed(const Duration(milliseconds: 700));
        if (!mounted) return;
        final stars = _moves <= totalPairs + 2
            ? 3
            : _moves <= totalPairs * 2
                ? 2
                : 1;
        final badges = await state.recordGameOrQuizResult(
          category: 'memory_flip',
          topicId: 'memory_flip_${widget.difficulty}',
          score: totalPairs,
          total: totalPairs,
          difficulty: widget.difficulty,
        );
        if (!mounted) return;
        await RewardDialog.show(
          context,
          titleEn: 'Round ${_deck.round} • All $totalPairs Pairs Found!',
          titleMy: 'အကျော့ ${_deck.round} • $_moves ကြိမ်ဖြင့် အကုန်တွဲမိပါပြီ!',
          starsEarned: stars,
          newBadges: badges,
        );
        if (mounted) _startGame();
      }
    } else {
      _busy = true;
      await Future<void>.delayed(const Duration(milliseconds: 750));
      if (!mounted) return;
      setState(() {
        prevCard.faceUp = false;
        card.faceUp = false;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final totalPairs = _cards.length ~/ 2;
    final cols = _cards.length <= 8 ? 2 : (_cards.length <= 12 ? 3 : 4);

    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Flip • Round ${_deck.round}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.sunYellowLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.sunYellow, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      '🃏 တွဲမိ: $_matchedPairs / $totalPairs',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                    Text(
                      '👆 အကြိမ်: $_moves',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'ပုံကတ်နှင့် အင်္ဂလိပ်စကားလုံးကတ်ကို တွဲရှာပါ',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  itemCount: _cards.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: cols == 2 ? 1.25 : 0.92,
                  ),
                  itemBuilder: (_, i) {
                    final card = _cards[i];
                    final showFront = card.faceUp || card.matched;
                    return GestureDetector(
                      onTap: () => _tapCard(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: card.matched
                              ? AppColors.mintGreenLight
                              : (showFront ? Colors.white : AppColors.skyBlue),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: card.matched
                                ? AppColors.mintGreen
                                : (showFront ? AppColors.skyBlue : Colors.white),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.skyBlue.withAlpha(45),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: showFront
                            ? (card.isPicture
                                ? Text(
                                    card.item.emoji,
                                    style: TextStyle(fontSize: cols == 4 ? 34 : 44),
                                  )
                                : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      card.item.english,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: cols == 4 ? 16 : 20,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ))
                            : const Text('❓', style: TextStyle(fontSize: 32)),
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
