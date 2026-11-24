import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keyActiveProfileId = 'active_profile_id';
  static const _keySoundEnabled = 'sound_enabled';
  static const _keySlowByDefault = 'slow_by_default';
  static const _keyShowMyanmarHints = 'show_myanmar_hints';
  static const _keyParentPin = 'parent_pin';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  int? get activeProfileId => _prefs?.getInt(_keyActiveProfileId);
  Future<void> setActiveProfileId(int id) async => _prefs?.setInt(_keyActiveProfileId, id);

  bool get soundEnabled => _prefs?.getBool(_keySoundEnabled) ?? true;
  Future<void> setSoundEnabled(bool value) async => _prefs?.setBool(_keySoundEnabled, value);

  bool get slowByDefault => _prefs?.getBool(_keySlowByDefault) ?? false;
  Future<void> setSlowByDefault(bool value) async => _prefs?.setBool(_keySlowByDefault, value);

  bool get showMyanmarHints => _prefs?.getBool(_keyShowMyanmarHints) ?? true;
  Future<void> setShowMyanmarHints(bool value) async => _prefs?.setBool(_keyShowMyanmarHints, value);

  String get parentPin => _prefs?.getString(_keyParentPin) ?? '1234';
  Future<void> setParentPin(String pin) async => _prefs?.setString(_keyParentPin, pin);
}
