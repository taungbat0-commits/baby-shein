import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  Set<String> _bundledAssets = {};
  bool _initialized = false;
  bool _soundEnabled = true;
  String? _lastKey;
  String? _lastText;

  Future<void> init({bool soundEnabled = true}) async {
    _soundEnabled = soundEnabled;
    if (_initialized) return;

    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      _bundledAssets = manifest
          .listAssets()
          .where((path) => path.startsWith('assets/audio/'))
          .toSet();
    } catch (_) {
      _bundledAssets = {};
    }

    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.08);
      await _tts.setVolume(1.0);
    } catch (_) {}

    _initialized = true;
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    if (!enabled) stop();
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    try {
      await _tts.stop();
    } catch (_) {}
  }

  String? _findAssetRelativePath(String audioKey) {
    final mp3Path = 'assets/audio/$audioKey.mp3';
    if (_bundledAssets.contains(mp3Path)) return 'audio/$audioKey.mp3';
    final wavPath = 'assets/audio/$audioKey.wav';
    if (_bundledAssets.contains(wavPath)) return 'audio/$audioKey.wav';
    return null;
  }

  Future<void> speak({
    required String text,
    String? audioKey,
    bool slow = false,
  }) async {
    if (!_soundEnabled) return;
    if (!_initialized) await init(soundEnabled: _soundEnabled);

    _lastKey = audioKey;
    _lastText = text;
    await stop();

    if (audioKey != null && audioKey.isNotEmpty) {
      final assetRelPath = _findAssetRelativePath(audioKey);
      if (assetRelPath != null) {
        try {
          await _player.setPlaybackRate(slow ? 0.68 : 1.0);
          await _player.play(AssetSource(assetRelPath));
          return;
        } catch (_) {}
      }
    }

    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(slow ? 0.28 : 0.46);
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> replay({bool slow = false}) async {
    if (_lastText == null) return;
    await speak(text: _lastText!, audioKey: _lastKey, slow: slow);
  }

  bool hasBundledAudio(String audioKey) => _findAssetRelativePath(audioKey) != null;
  int get bundledAudioCount => _bundledAssets.length;

  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }
}
