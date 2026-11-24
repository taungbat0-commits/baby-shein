import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lesson_model.dart';
import '../services/app_state.dart';
import '../services/speech_service.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_control_bar.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/kids_illustration.dart';
import '../widgets/reward_dialog.dart';

class SpeakingScreen extends StatefulWidget {
  const SpeakingScreen({super.key});

  @override
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends State<SpeakingScreen> {
  final Random _rng = Random();
  List<LessonItem> _items = [];
  int _index = 0;
  int _passedCount = 0;
  bool _checkingSpeech = true;
  bool _listening = false;
  String _heardWords = '';
  SpeechEvaluation? _evaluation;

  LessonItem? get _current => _items.isEmpty ? null : _items[_index];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setup());
  }

  Future<void> _setup() async {
    final state = context.read<AppState>();
    final vocab = state.repository.getSingleWordVocabulary()..shuffle(_rng);
    final selected = vocab.take(5).toList();
    await state.speech.init();
    if (!mounted) return;
    setState(() {
      _items = selected;
      _index = 0;
      _passedCount = 0;
      _checkingSpeech = false;
    });
    if (selected.isNotEmpty) {
      state.audio.speak(
        text: selected.first.english,
        audioKey: selected.first.audioKey,
        slow: state.slowByDefault,
      );
    }
  }

  @override
  void dispose() {
    context.read<AppState>().speech.stopListening();
    super.dispose();
  }

  Future<void> _toggleMic() async {
    final state = context.read<AppState>();
    final item = _current;
    if (item == null || !state.speech.isAvailable) return;

    if (_listening) {
      await state.speech.stopListening();
      if (mounted) setState(() => _listening = false);
      return;
    }

    await state.audio.stop();
    setState(() {
      _listening = true;
      _heardWords = '';
      _evaluation = null;
    });

    await state.speech.startListening(
      onResult: (words, isFinal) {
        if (!mounted) return;
        final eval = state.speech.evaluate(item.english, words);
        setState(() {
          _heardWords = words;
          if (isFinal || eval.passed) {
            _evaluation = eval;
            _listening = false;
          }
        });
        if (eval.passed) {
          state.speech.stopListening();
        }
      },
    );
  }

  Future<void> _nextWord({required bool countAsPassed}) async {
    final state = context.read<AppState>();
    await state.speech.stopListening();
    if (countAsPassed) _passedCount++;

    if (_index + 1 < _items.length) {
      setState(() {
        _index++;
        _listening = false;
        _heardWords = '';
        _evaluation = null;
      });
      final next = _current!;
      state.audio.speak(text: next.english, audioKey: next.audioKey, slow: state.slowByDefault);
      return;
    }

    final badges = await state.recordGameOrQuizResult(
      category: 'speaking',
      topicId: 'speaking_practice',
      score: _passedCount,
      total: _items.length,
      difficulty: 'easy',
    );
    if (!mounted) return;
    final stars = _passedCount >= 4 ? 3 : _passedCount >= 2 ? 2 : 1;
    await RewardDialog.show(
      context,
      titleEn: 'Great Speaking Practice!',
      titleMy: 'အသံထွက်လေ့ကျင့်မှု အရမ်းတော်တယ်!',
      starsEarned: stars,
      newBadges: badges,
    );
    if (mounted) _setup();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final item = _current;
    final speechReady = state.speech.isAvailable;

    return Scaffold(
      appBar: AppBar(title: const Text('Speaking • စကားပြောလေ့ကျင့်ရန်')),
      body: SafeArea(
        child: _checkingSpeech || item == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Word ${_index + 1} / ${_items.length}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        Text(
                          'Done: $_passedCount ⭐',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: AppColors.softPink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.softPink.withAlpha(120), width: 2.5),
                      ),
                      child: Column(
                        children: [
                          KidsIllustration(item: item, accentColor: AppColors.softPink, size: 118),
                          const SizedBox(height: 14),
                          Text(
                            item.english,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (item.phonetic.isNotEmpty)
                            Text(
                              item.phonetic,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.softPink,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            item.myanmar,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 14),
                          AudioControlBar(
                            primaryColor: AppColors.softPink,
                            onListen: () => state.audio.speak(
                              text: item.english,
                              audioKey: item.audioKey,
                              slow: false,
                            ),
                            onSlow: () => state.audio.speak(
                              text: item.english,
                              audioKey: item.audioKey,
                              slow: true,
                            ),
                            onRepeat: () => state.audio.replay(slow: false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!speechReady)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.sunYellowLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.sunYellow, width: 2),
                        ),
                        child: Column(
                          children: [
                            const Text('🎙️ Offline Practice Mode',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                            const SizedBox(height: 6),
                            Text(
                              state.speech.unavailableReasonEn ??
                                  'Speech recognition is unavailable on this device.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.speech.unavailableReasonMy ??
                                  'အသံနားထောင်ပြီး ကျယ်ကျယ်လေး လိုက်ဆိုလေ့ကျင့်ပါ။',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.mintGreen),
                                onPressed: () => _nextWord(countAsPassed: true),
                                icon: const Icon(Icons.check_circle_rounded),
                                label: const Text('I Said It Aloud! • လိုက်ဆိုပြီးပြီ'),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      BouncyButton(
                        onTap: _toggleMic,
                        color: _listening ? AppColors.error : AppColors.mintGreen,
                        borderRadius: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_listening ? Icons.stop_rounded : Icons.mic_rounded,
                                color: Colors.white, size: 30),
                            const SizedBox(width: 10),
                            Text(
                              _listening ? 'Listening... ပြောပါ' : 'Tap to Speak • နှိပ်ပြီးပြောပါ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_heardWords.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Heard: "$_heardWords"',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ],
                      if (_evaluation != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _evaluation!.passed
                                ? AppColors.mintGreenLight
                                : AppColors.softPinkLight,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _evaluation!.passed
                                    ? '🌟 Great Job! (${_evaluation!.accuracyPercent}%)'
                                    : 'Try again! (${_evaluation!.accuracyPercent}%)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: _evaluation!.passed
                                      ? AppColors.mintGreen
                                      : AppColors.error,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => _nextWord(countAsPassed: _evaluation!.passed),
                                child: const Text('Next Word • နောက်တစ်လုံး'),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => _nextWord(countAsPassed: false),
                          child: const Text('Skip to next word • ကျော်သွားမယ်'),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
