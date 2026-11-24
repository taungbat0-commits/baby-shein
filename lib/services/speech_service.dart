import 'dart:math';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechEvaluation {
  final String recognizedText;
  final int accuracyPercent;
  final bool passed;

  const SpeechEvaluation({
    required this.recognizedText,
    required this.accuracyPercent,
    required this.passed,
  });
}

class SpeechService {
  final SpeechToText _speech = SpeechToText();

  bool _isInitialized = false;
  bool _isAvailable = false;
  String? _englishLocaleId;
  String? _unavailableReasonEn;
  String? _unavailableReasonMy;

  bool get isAvailable => _isAvailable;
  bool get isListening => _speech.isListening;
  String? get unavailableReasonEn => _unavailableReasonEn;
  String? get unavailableReasonMy => _unavailableReasonMy;

  Future<bool> init() async {
    if (_isInitialized) return _isAvailable;
    _isInitialized = true;

    try {
      final available = await _speech.initialize(onError: (_) {}, onStatus: (_) {});
      if (!available) {
        _isAvailable = false;
        _unavailableReasonEn =
            'Microphone permission or on-device speech recognition is not available on this phone.';
        _unavailableReasonMy =
            'ဤဖုန်းတွင် မိုက်ခရိုဖုန်းခွင့်ပြုချက် သို့မဟုတ် အသံဖတ်စနစ် (Speech Recognition) မရရှိနိုင်ပါ။';
        return false;
      }

      final locales = await _speech.locales();
      final englishLocale = locales.where((l) => l.localeId.toLowerCase().startsWith('en'));

      if (englishLocale.isEmpty) {
        _isAvailable = false;
        _unavailableReasonEn =
            'English voice recognition pack is not installed on this device. You can still listen and practice aloud!';
        _unavailableReasonMy =
            'ဤဖုန်းတွင် အင်္ဂလိပ်အသံဖတ်စနစ် ထည့်သွင်းမထားပါ။ အသံနားထောင်ပြီး လိုက်ဆိုလေ့ကျင့်နိုင်ပါသည်။';
        return false;
      }

      _englishLocaleId = englishLocale.first.localeId;
      _isAvailable = true;
      return true;
    } catch (_) {
      _isAvailable = false;
      _unavailableReasonEn = 'Speech recognition is unavailable offline on this device.';
      _unavailableReasonMy = 'ဤဖုန်းတွင် အင်တာနက်မပါဘဲ အသံစစ်ဆေးမှု မရရှိနိုင်ပါ။';
      return false;
    }
  }

  Future<void> startListening({
    required void Function(String words, bool isFinal) onResult,
  }) async {
    if (!_isInitialized) await init();
    if (!_isAvailable) return;

    await _speech.listen(
      localeId: _englishLocaleId ?? 'en_US',
      listenFor: const Duration(seconds: 6),
      pauseFor: const Duration(seconds: 2),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      ),
      onResult: (result) => onResult(result.recognizedWords, result.finalResult),
    );
  }

  Future<void> stopListening() async {
    if (_speech.isListening) await _speech.stop();
  }

  SpeechEvaluation evaluate(String target, String spoken) {
    final cleanTarget = _normalize(target);
    final cleanSpoken = _normalize(spoken);

    if (cleanSpoken.isEmpty) {
      return const SpeechEvaluation(recognizedText: '', accuracyPercent: 0, passed: false);
    }
    if (cleanSpoken == cleanTarget || cleanSpoken.contains(cleanTarget)) {
      return SpeechEvaluation(recognizedText: spoken, accuracyPercent: 100, passed: true);
    }

    final dist = _levenshtein(cleanTarget, cleanSpoken);
    final maxLen = max(cleanTarget.length, cleanSpoken.length);
    final score = maxLen == 0 ? 0 : (((maxLen - dist) / maxLen) * 100).round();
    final clamped = score.clamp(0, 100);
    return SpeechEvaluation(recognizedText: spoken, accuracyPercent: clamped, passed: clamped >= 65);
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;
    final v0 = List<int>.generate(t.length + 1, (i) => i);
    final v1 = List<int>.filled(t.length + 1, 0);
    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        final cost = s[i] == t[j] ? 0 : 1;
        v1[j + 1] = min(min(v1[j] + 1, v0[j + 1] + 1), v0[j] + cost);
      }
      for (int j = 0; j <= t.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v0[t.length];
  }
}
