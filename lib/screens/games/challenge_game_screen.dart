import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/content_pack_model.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bouncy_button.dart';
import '../../widgets/reward_dialog.dart';
import '../downloads_screen.dart';

class GamePacksScreen extends StatelessWidget {
  final String difficulty;
  const GamePacksScreen({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final packs = state.allGamePacks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Packs • ဝါကျစီနှင့် ဉာဏ်စမ်း'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        itemCount: packs.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == packs.length) {
            return BouncyButton(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DownloadsScreen()),
              ),
              color: AppColors.skyBlueLight,
              border: Border.all(color: AppColors.skyBlue, width: 2),
              padding: const EdgeInsets.all(14),
              child: const Row(
                children: [
                  Text('📥', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Download More Game Packs',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                        ),
                        Text(
                          'ဝါကျစီနှင့် ဉာဏ်စမ်းဂိမ်းအသစ်များ ထပ်ထည့်မယ်',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.skyBlue, size: 28),
                ],
              ),
            );
          }

          final pack = packs[index];
          final color = Color(pack.colorHex);
          final bg = AppTheme.lightPastelForIndex(index);
          final modeTag = pack.mode == 'sentence'
              ? '🧱 ဝါကျစီဂိမ်း'
              : pack.mode == 'quiz'
                  ? '💡 ဉာဏ်စမ်းဂိမ်း'
                  : '🎯 စုံလင်ဂိမ်း';

          return BouncyButton(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChallengeGameScreen(pack: pack, difficulty: difficulty),
              ),
            ),
            color: Colors.white,
            border: Border.all(color: color.withAlpha(140), width: 2),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Text(pack.emoji, style: const TextStyle(fontSize: 30)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pack.titleEn,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          if (pack.isDownloaded)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.mintGreenLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'PACK',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.mintGreen,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        pack.titleMy,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.softPink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$modeTag • မေးခွန်း ${pack.items.length} ခု',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.play_circle_fill_rounded, color: color, size: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChallengeGameScreen extends StatefulWidget {
  final GameChallengePack pack;
  final String difficulty;

  const ChallengeGameScreen({
    super.key,
    required this.pack,
    required this.difficulty,
  });

  @override
  State<ChallengeGameScreen> createState() => _ChallengeGameScreenState();
}

class _ChallengeGameScreenState extends State<ChallengeGameScreen> {
  final Random _rng = Random();
  final Set<String> _usedIds = {};
  int _round = 0;

  List<GameChallengeItem> _questions = [];
  int _index = 0;
  int _score = 0;
  bool _answered = false;
  bool _isCorrect = false;

  List<String> _poolWords = [];
  List<int> _chosenPoolIndices = [];
  int? _selectedOption;

  int get _questionCount {
    final desired = widget.difficulty == 'hard' ? 8 : widget.difficulty == 'medium' ? 6 : 5;
    return desired.clamp(1, widget.pack.items.length);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startGame());
  }

  void _startGame() {
    final all = widget.pack.items;
    if (all.isEmpty) return;

    _round++;
    final unseen = all.where((e) => !_usedIds.contains(e.id)).toList()..shuffle(_rng);
    final picked = <GameChallengeItem>[];
    if (unseen.length >= _questionCount) {
      picked.addAll(unseen.take(_questionCount));
    } else {
      picked.addAll(unseen);
      final pIds = picked.map((e) => e.id).toSet();
      _usedIds.clear();
      final refill = all.where((e) => !pIds.contains(e.id)).toList()..shuffle(_rng);
      picked.addAll(refill.take(_questionCount - picked.length));
    }
    for (final q in picked) {
      _usedIds.add(q.id);
    }

    setState(() {
      _questions = picked;
      _index = 0;
      _score = 0;
    });
    _prepareCurrent();
  }

  void _prepareCurrent() {
    if (_questions.isEmpty) return;
    final q = _questions[_index];
    final shuffled = List<String>.from(q.words)..shuffle(_rng);
    if (shuffled.length > 1 && shuffled.join(' ') == q.words.join(' ')) {
      shuffled.shuffle(_rng);
    }
    setState(() {
      _answered = false;
      _isCorrect = false;
      _poolWords = shuffled;
      _chosenPoolIndices = [];
      _selectedOption = null;
    });
  }

  void _speak(String text, {required String lang, String? audioKey}) {
    final state = context.read<AppState>();
    state.audio.speak(
      text: text,
      audioKey: (audioKey != null && audioKey.isNotEmpty) ? audioKey : null,
      slow: state.slowByDefault,
      lang: lang,
    );
  }

  Future<void> _finishOrNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    if (_index + 1 < _questions.length) {
      setState(() => _index++);
      _prepareCurrent();
      return;
    }

    final state = context.read<AppState>();
    final badges = await state.recordGameOrQuizResult(
      category: 'game_pack',
      topicId: widget.pack.id,
      score: _score,
      total: _questions.length,
      difficulty: widget.difficulty,
    );
    if (!mounted) return;
    final ratio = _questions.isEmpty ? 0.0 : _score / _questions.length;
    final stars = ratio >= 0.9 ? 3 : ratio >= 0.6 ? 2 : ratio > 0 ? 1 : 0;
    await RewardDialog.show(
      context,
      titleEn: 'Round $_round • Score: $_score / ${_questions.length}',
      titleMy: 'အကျော့ $_round • ရမှတ် $_score / ${_questions.length}',
      starsEarned: stars,
      newBadges: badges,
    );
    if (mounted) _startGame();
  }

  Future<void> _checkSentence() async {
    if (_answered) return;
    final q = _questions[_index];
    final built = _chosenPoolIndices.map((i) => _poolWords[i]).join(' ').trim().toLowerCase();
    final expected = q.words.join(' ').trim().toLowerCase();
    final ok = built == expected;
    setState(() {
      _answered = true;
      _isCorrect = ok;
      if (ok) _score++;
    });
    _speak(q.words.join(' '), lang: 'en', audioKey: q.audioKey);
    await _finishOrNext();
  }

  Future<void> _pickQuizOption(int optionIdx) async {
    if (_answered) return;
    final q = _questions[_index];
    final ok = optionIdx == q.answerIndex;
    setState(() {
      _selectedOption = optionIdx;
      _answered = true;
      _isCorrect = ok;
      if (ok) _score++;
    });
    if (q.answerIndex >= 0 && q.answerIndex < q.options.length) {
      _speak(q.options[q.answerIndex], lang: 'en');
    }
    await _finishOrNext();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final q = _questions[_index];
    final accent = Color(widget.pack.colorHex);
    final correctQuizAns = (q.answerIndex >= 0 && q.answerIndex < q.options.length)
        ? q.options[q.answerIndex]
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.pack.titleEn} • R$_round'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    child: Text('⭐ $_score', style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: accent.withAlpha(140), width: 2.5),
                ),
                child: Column(
                  children: [
                    Text(q.emoji, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    if (q.mode == 'quiz' && q.promptEn.isNotEmpty) ...[
                      Text(
                        q.promptEn,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      q.promptMy,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: q.mode == 'sentence' ? 18 : 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.softPink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BouncyButton(
                          onTap: () => _speak(
                            q.mode == 'sentence' ? q.words.join(' ') : q.promptEn,
                            lang: 'en',
                            audioKey: q.audioKey,
                          ),
                          color: AppColors.skyBlue,
                          borderRadius: 14,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          child: const Text(
                            '🔊 EN နားထောင်',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12.5),
                          ),
                        ),
                        const SizedBox(width: 10),
                        BouncyButton(
                          onTap: () => _speak(q.promptMy, lang: 'my', audioKey: q.audioKey),
                          color: AppColors.softPink,
                          borderRadius: 14,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          child: const Text(
                            '🇲🇲 MY နားထောင်',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (q.mode == 'sentence') ..._buildSentenceBody(q, accent) else ..._buildQuizBody(q),
              if (_answered) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _isCorrect ? AppColors.mintGreenLight : AppColors.softPinkLight,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _isCorrect ? AppColors.mintGreen : AppColors.softPink,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _isCorrect
                            ? '🎉 အရမ်းတော်တယ်! မှန်ပါတယ်'
                            : (q.mode == 'sentence'
                                ? '💡 အဖြေမှန်: ${q.words.join(' ')}'
                                : '💡 အဖြေမှန်: $correctQuizAns'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: _isCorrect ? AppColors.mintGreen : AppColors.softPink,
                        ),
                      ),
                      if (q.explanationMy.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          q.explanationMy,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSentenceBody(GameChallengeItem q, Color accent) {
    return [
      const Text(
        'စကားလုံးများကို နှိပ်ပြီး ဝါကျစီပါ:',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textMuted),
      ),
      const SizedBox(height: 8),
      Container(
        constraints: const BoxConstraints(minHeight: 74),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.skyBlueLight.withAlpha(140),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent, width: 2),
        ),
        child: _chosenPoolIndices.isEmpty
            ? const Center(
                child: Text(
                  'အောက်က စကားလုံးတွေကို နှိပ်ထည့်ပါ...',
                  style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700),
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int pos = 0; pos < _chosenPoolIndices.length; pos++)
                    GestureDetector(
                      onTap: _answered
                          ? null
                          : () => setState(() => _chosenPoolIndices.removeAt(pos)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _poolWords[_chosenPoolIndices[pos]],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          for (int i = 0; i < _poolWords.length; i++)
            if (!_chosenPoolIndices.contains(i))
              BouncyButton(
                onTap: _answered
                    ? null
                    : () => setState(() => _chosenPoolIndices.add(i)),
                color: Colors.white,
                border: Border.all(color: accent.withAlpha(160), width: 2),
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  _poolWords[i],
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
              ),
        ],
      ),
      const SizedBox(height: 18),
      Row(
        children: [
          Expanded(
            child: BouncyButton(
              onTap: _answered ? null : () => setState(() => _chosenPoolIndices.clear()),
              color: AppColors.sunYellowLight,
              border: Border.all(color: AppColors.sunYellow, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: const Center(
                child: Text('🔄 ပြန်စီမယ်', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: BouncyButton(
              onTap: (_answered || _chosenPoolIndices.length != _poolWords.length)
                  ? null
                  : _checkSentence,
              color: _chosenPoolIndices.length == _poolWords.length
                  ? AppColors.mintGreen
                  : AppColors.border,
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: const Center(
                child: Text(
                  '✅ စစ်ဆေးမယ်',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildQuizBody(GameChallengeItem q) {
    return [
      for (int i = 0; i < q.options.length; i++) ...[
        BouncyButton(
          onTap: () => _pickQuizOption(i),
          color: !_answered
              ? Colors.white
              : (i == q.answerIndex
                  ? AppColors.mintGreenLight
                  : (i == _selectedOption ? AppColors.softPinkLight : Colors.white)),
          border: Border.all(
            color: !_answered
                ? AppColors.skyBlue.withAlpha(130)
                : (i == q.answerIndex
                    ? AppColors.mintGreen
                    : (i == _selectedOption ? AppColors.softPink : AppColors.border)),
            width: 2.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.skyBlueLight,
                child: Text(
                  String.fromCharCode(65 + i),
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.skyBlue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  q.options[i],
                  style: const TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              if (_answered && i == q.answerIndex)
                const Icon(Icons.check_circle_rounded, color: AppColors.mintGreen, size: 26)
              else if (_answered && i == _selectedOption)
                const Icon(Icons.cancel_rounded, color: AppColors.softPink, size: 26),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    ];
  }
}
