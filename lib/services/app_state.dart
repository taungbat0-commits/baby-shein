import 'dart:async';
import 'package:flutter/material.dart';

import '../models/content_pack_model.dart';
import '../models/lesson_model.dart';
import '../models/profile_model.dart';
import '../models/progress_model.dart';
import 'audio_service.dart';
import 'content_update_service.dart';
import 'database_service.dart';
import 'lesson_repository.dart';
import 'preferences_service.dart';
import 'speech_service.dart';

class AppState extends ChangeNotifier {
  final DatabaseService db = DatabaseService();
  final PreferencesService prefs = PreferencesService();
  final LessonRepository repository = LessonRepository();
  final AudioService audio = AudioService();
  final SpeechService speech = SpeechService();
  final ContentUpdateService contentUpdates = ContentUpdateService();

  bool _isReady = false;
  List<StudentProfile> _profiles = [];
  StudentProfile? _activeProfile;

  Map<String, CompletedLessonRecord> _completedLessons = {};
  Set<String> _learnedWordIds = {};
  List<QuizResultRecord> _quizResults = [];
  List<DailyActivityRecord> _dailyActivity = [];
  Set<String> _unlockedBadges = {};
  CatalogData? _remoteCatalog;
  Map<String, int> _installedPacks = {};
  bool _checkingUpdates = false;
  bool _noticeHiddenThisSession = false;
  bool _popupShownThisSession = false;
  String? _downloadingPackId;
  String? _downloadProgressText;

  DateTime? _sessionStart;
  Timer? _minuteTimer;

  bool get isReady => _isReady;
  List<StudentProfile> get profiles => _profiles;
  StudentProfile get activeProfile => _activeProfile!;
  Map<String, CompletedLessonRecord> get completedLessons => _completedLessons;
  Set<String> get learnedWordIds => _learnedWordIds;
  List<QuizResultRecord> get quizResults => _quizResults;
  List<DailyActivityRecord> get dailyActivity => _dailyActivity;
  Set<String> get unlockedBadges => _unlockedBadges;

  bool get soundEnabled => prefs.soundEnabled;
  bool get slowByDefault => prefs.slowByDefault;
  bool get showMyanmarHints => prefs.showMyanmarHints;
  String get parentPin => prefs.parentPin;
  CatalogData? get remoteCatalog => _remoteCatalog;
  Map<String, int> get installedPacks => _installedPacks;
  bool get checkingUpdates => _checkingUpdates;
  String? get downloadingPackId => _downloadingPackId;
  String? get downloadProgressText => _downloadProgressText;

  RemoteAnnouncement? get activeAnnouncement {
    final ann = _remoteCatalog?.announcement;
    if (ann == null || ann.id.isEmpty) return null;
    return ann;
  }

  int get availableNewPackCount {
    final packs = _remoteCatalog?.packs ?? [];
    int count = 0;
    for (final p in packs) {
      final installedVer = _installedPacks[p.id];
      if (installedVer == null || p.version > installedVer) count++;
    }
    return count;
  }

  bool get hasNewUpdates =>
      !_noticeHiddenThisSession &&
      (activeAnnouncement != null || availableNewPackCount > 0);

  bool get shouldShowPopup =>
      !_popupShownThisSession && activeAnnouncement != null;

  void markPopupShown() {
    _popupShownThisSession = true;
  }

  String get announcementBannerText {
    final ann = activeAnnouncement;
    if (ann != null) {
      if (ann.marqueeText.trim().isNotEmpty) return ann.marqueeText.trim();
      final t = ann.titleMy.isNotEmpty ? ann.titleMy : ann.titleEn;
      final m = ann.messageMy.isNotEmpty ? ann.messageMy : ann.messageEn;
      if (t.isNotEmpty && m.isNotEmpty) return '$t  •  $m';
      return t.isNotEmpty ? t : m;
    }
    return 'သင်ခန်းစာအသစ် $availableNewPackCount ခု ရောက်နေပါပြီ! နှိပ်ပြီး Download ဆွဲထည့်နိုင်ပါတယ်';
  }

  Future<void> initialize() async {
    await prefs.init();
    await repository.loadAll();
    await _reloadInstalledPacks();
    await audio.init(soundEnabled: prefs.soundEnabled);

    _profiles = await db.getProfiles();
    if (_profiles.isEmpty) {
      final defaultProfile = await db.createProfile(name: 'Mg Mg', avatarId: 'owl', grade: 1);
      _profiles = [defaultProfile];
    }

    final savedId = prefs.activeProfileId;
    _activeProfile = _profiles.firstWhere((p) => p.id == savedId, orElse: () => _profiles.first);
    await prefs.setActiveProfileId(_activeProfile!.id!);
    await _loadProfileProgress(_activeProfile!.id!);

    _startSessionTracking();
    _isReady = true;
    notifyListeners();
    unawaited(checkForUpdates());
  }

  void _startSessionTracking() {
    _sessionStart = DateTime.now();
    _minuteTimer?.cancel();
    _minuteTimer = Timer.periodic(const Duration(minutes: 1), (_) => flushLearningTime());
  }

  Future<void> flushLearningTime() async {
    if (_activeProfile?.id == null || _sessionStart == null) return;
    final elapsed = DateTime.now().difference(_sessionStart!).inMinutes;
    if (elapsed >= 1) {
      _sessionStart = DateTime.now();
      await db.incrementDailyActivity(profileId: _activeProfile!.id!, minutesSpent: elapsed);
      _dailyActivity = await db.getDailyActivity(_activeProfile!.id!);
      notifyListeners();
    }
  }

  void handleLifecycleChange(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      audio.stop();
      speech.stopListening();
      flushLearningTime();
    } else if (state == AppLifecycleState.resumed) {
      _sessionStart = DateTime.now();
    }
  }

  Future<void> _loadProfileProgress(int profileId) async {
    final completedList = await db.getCompletedLessons(profileId);
    _completedLessons = {for (final c in completedList) c.lessonId: c};
    _learnedWordIds = await db.getLearnedWordIds(profileId);
    _quizResults = await db.getQuizResults(profileId);
    _dailyActivity = await db.getDailyActivity(profileId);
    _unlockedBadges = await db.getUnlockedBadges(profileId);
  }

  Future<void> switchProfile(StudentProfile profile) async {
    await flushLearningTime();
    _activeProfile = profile;
    await prefs.setActiveProfileId(profile.id!);
    await _loadProfileProgress(profile.id!);
    _sessionStart = DateTime.now();
    notifyListeners();
  }

  Future<void> addProfile({required String name, required String avatarId, required int grade}) async {
    final created = await db.createProfile(name: name, avatarId: avatarId, grade: grade);
    _profiles = await db.getProfiles();
    await switchProfile(created);
  }

  Future<void> updateActiveProfile({required String name, required String avatarId, required int grade}) async {
    final updated = activeProfile.copyWith(name: name.trim(), avatarId: avatarId, grade: grade);
    await db.updateProfile(updated);
    _profiles = await db.getProfiles();
    _activeProfile = _profiles.firstWhere((p) => p.id == updated.id);
    notifyListeners();
  }

  Future<bool> deleteProfile(int profileId) async {
    if (_profiles.length <= 1) return false;
    await db.deleteProfile(profileId);
    _profiles = await db.getProfiles();
    if (_activeProfile?.id == profileId) {
      await switchProfile(_profiles.first);
    } else {
      notifyListeners();
    }
    return true;
  }

  bool isLessonCompleted(String lessonId) => _completedLessons.containsKey(lessonId);

  int completedCountForGrade(int grade) {
    final ids = repository.lessonsForGrade(grade).map((e) => e.id).toSet();
    return _completedLessons.keys.where(ids.contains).length;
  }

  Future<List<AchievementBadge>> recordWordLearned(LessonModule lesson, LessonItem item) async {
    final pid = activeProfile.id!;
    final isNew = await db.markWordLearned(
      profileId: pid,
      wordId: item.id,
      lessonId: lesson.id,
      english: item.english,
      myanmar: item.myanmar,
    );
    if (isNew) {
      _learnedWordIds.add(item.id);
      _dailyActivity = await db.getDailyActivity(pid);
      final newBadges = await _evaluateAchievements();
      notifyListeners();
      return newBadges;
    }
    return [];
  }

  Future<List<AchievementBadge>> completeLesson({
    required LessonModule lesson,
    int starsEarned = 3,
    int score = 100,
  }) async {
    final pid = activeProfile.id!;
    for (final item in lesson.items) {
      await db.markWordLearned(
        profileId: pid,
        wordId: item.id,
        lessonId: lesson.id,
        english: item.english,
        myanmar: item.myanmar,
      );
      _learnedWordIds.add(item.id);
    }
    await db.markLessonCompleted(
      profileId: pid,
      lessonId: lesson.id,
      grade: lesson.grade,
      starsEarned: starsEarned,
      score: score,
    );
    await _refreshActiveProfileAndData();
    final newBadges = await _evaluateAchievements();
    notifyListeners();
    return newBadges;
  }

  Future<List<AchievementBadge>> recordGameOrQuizResult({
    required String category,
    required String topicId,
    required int score,
    required int total,
    required String difficulty,
  }) async {
    final pid = activeProfile.id!;
    final ratio = total == 0 ? 0.0 : score / total;
    final starsEarned = ratio >= 0.9 ? 3 : ratio >= 0.6 ? 2 : ratio > 0 ? 1 : 0;

    await db.saveQuizResult(
      profileId: pid,
      category: category,
      topicId: topicId,
      score: score,
      total: total,
      difficulty: difficulty,
      starsEarned: starsEarned,
    );
    await _refreshActiveProfileAndData();
    final newBadges = await _evaluateAchievements();
    notifyListeners();
    return newBadges;
  }

  Future<void> _refreshActiveProfileAndData() async {
    final pid = activeProfile.id!;
    _profiles = await db.getProfiles();
    _activeProfile = _profiles.firstWhere((p) => p.id == pid);
    await _loadProfileProgress(pid);
  }

  Future<List<AchievementBadge>> _evaluateAchievements() async {
    final pid = activeProfile.id!;
    final newlyUnlocked = <AchievementBadge>[];

    Future<void> check(String badgeId, bool condition) async {
      if (!condition || _unlockedBadges.contains(badgeId)) return;
      final added = await db.unlockBadge(pid, badgeId);
      if (added) {
        _unlockedBadges.add(badgeId);
        newlyUnlocked.add(AchievementBadge.all.firstWhere((b) => b.id == badgeId));
      }
    }

    await check('first_lesson', _completedLessons.isNotEmpty);
    await check('word_collector_20', _learnedWordIds.length >= 20);
    await check('word_master_50', _learnedWordIds.length >= 50);
    await check('star_shiner_30', activeProfile.stars >= 30);
    await check('game_champ', _quizResults.length >= 5);
    await check('grade1_hero', completedCountForGrade(1) >= repository.grade1Lessons.length && repository.grade1Lessons.isNotEmpty);
    await check('grade2_hero', completedCountForGrade(2) >= repository.grade2Lessons.length && repository.grade2Lessons.isNotEmpty);
    return newlyUnlocked;
  }

  int get totalMinutesLearned => _dailyActivity.fold<int>(0, (sum, d) => sum + d.minutesSpent);

  double get averageQuizAccuracy {
    if (_quizResults.isEmpty) return 0;
    return _quizResults.fold<double>(0, (sum, r) => sum + r.accuracy) / _quizResults.length;
  }

  List<WeakAreaSummary> get weakAreas {
    const labels = <String, List<String>>{
      'listening': ['Listening Practice', 'နားထောင်မှုလေ့ကျင့်ခန်း'],
      'speaking': ['Speaking Practice', 'စကားပြောလေ့ကျင့်ခန်း'],
      'match_word': ['Word & Picture Match', 'ပုံနှင့်စကားလုံးတွဲခြင်း'],
      'choose_answer': ['Choose Correct Answer', 'အဖြေမှန်ရွေးခြင်း'],
      'listen_choose': ['Listen & Choose', 'နားထောင်ပြီးရွေးခြင်း'],
      'spell_word': ['Spelling Game', 'စာလုံးပေါင်းဂိမ်း'],
      'missing_letter': ['Find Missing Letter', 'ပျောက်နေသောအက္ခရာရှာခြင်း'],
    };
    final grouped = <String, List<QuizResultRecord>>{};
    for (final r in _quizResults) {
      grouped.putIfAbsent(r.category, () => []).add(r);
    }
    final summaries = <WeakAreaSummary>[];
    grouped.forEach((cat, records) {
      final avg = records.fold<double>(0, (s, r) => s + r.accuracy) / records.length;
      final pair = labels[cat] ?? [cat, cat];
      summaries.add(WeakAreaSummary(
        category: cat, labelEn: pair[0], labelMy: pair[1], averageAccuracy: avg, attempts: records.length,
      ));
    });
    summaries.sort((a, b) => a.averageAccuracy.compareTo(b.averageAccuracy));
    return summaries;
  }

  Future<void> setSoundEnabled(bool value) async {
    await prefs.setSoundEnabled(value);
    audio.setSoundEnabled(value);
    notifyListeners();
  }

  Future<void> setSlowByDefault(bool value) async {
    await prefs.setSlowByDefault(value);
    notifyListeners();
  }

  Future<void> setShowMyanmarHints(bool value) async {
    await prefs.setShowMyanmarHints(value);
    notifyListeners();
  }

  Future<void> setParentPin(String pin) async {
    await prefs.setParentPin(pin);
    notifyListeners();
  }

  Future<void> resetActiveProfileProgress() async {
    await db.resetProfileProgress(activeProfile.id!);
    await _refreshActiveProfileAndData();
    notifyListeners();
  }


  Future<void> _reloadInstalledPacks() async {
    _installedPacks = await contentUpdates.getInstalledVersions();
    final downloaded = await contentUpdates.loadInstalledContent();
    repository.applyDownloadedContent(downloaded.lessons, downloaded.phrases);
  }

  Future<bool> checkForUpdates() async {
    _checkingUpdates = true;
    notifyListeners();
    final cat = await contentUpdates.fetchCatalog();
    _checkingUpdates = false;
    if (cat != null) {
      _remoteCatalog = cat;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  Future<bool> downloadPack(ContentPackInfo pack) async {
    _downloadingPackId = pack.id;
    _downloadProgressText = 'Starting...';
    notifyListeners();
    final ok = await contentUpdates.downloadPack(
      pack,
      onProgress: (done, total) {
        _downloadProgressText = 'Audio $done / $total';
        notifyListeners();
      },
    );
    if (ok) {
      await _reloadInstalledPacks();
    }
    _downloadingPackId = null;
    _downloadProgressText = null;
    notifyListeners();
    return ok;
  }

  Future<void> removePack(String packId) async {
    await contentUpdates.removePack(packId);
    await _reloadInstalledPacks();
    notifyListeners();
  }

  Future<void> dismissAnnouncement() async {
    _noticeHiddenThisSession = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _minuteTimer?.cancel();
    audio.dispose();
    super.dispose();
  }
}
