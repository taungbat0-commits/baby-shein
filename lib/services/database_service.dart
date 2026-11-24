import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/profile_model.dart';
import '../models/progress_model.dart';

class DatabaseService {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'baby_shein.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE profiles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            avatar_id TEXT NOT NULL,
            grade INTEGER NOT NULL DEFAULT 1,
            stars INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE completed_lessons (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            profile_id INTEGER NOT NULL,
            lesson_id TEXT NOT NULL,
            grade INTEGER NOT NULL,
            stars_earned INTEGER NOT NULL DEFAULT 3,
            best_score INTEGER NOT NULL DEFAULT 100,
            completed_at TEXT NOT NULL,
            UNIQUE(profile_id, lesson_id)
          )
        ''');

        await db.execute('''
          CREATE TABLE learned_words (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            profile_id INTEGER NOT NULL,
            word_id TEXT NOT NULL,
            lesson_id TEXT NOT NULL,
            english TEXT NOT NULL,
            myanmar TEXT NOT NULL,
            learned_at TEXT NOT NULL,
            UNIQUE(profile_id, word_id)
          )
        ''');

        await db.execute('''
          CREATE TABLE quiz_results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            profile_id INTEGER NOT NULL,
            category TEXT NOT NULL,
            topic_id TEXT NOT NULL,
            score INTEGER NOT NULL,
            total INTEGER NOT NULL,
            difficulty TEXT NOT NULL DEFAULT 'easy',
            played_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE daily_activity (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            profile_id INTEGER NOT NULL,
            date_str TEXT NOT NULL,
            minutes_spent INTEGER NOT NULL DEFAULT 0,
            lessons_completed INTEGER NOT NULL DEFAULT 0,
            words_learned INTEGER NOT NULL DEFAULT 0,
            games_played INTEGER NOT NULL DEFAULT 0,
            stars_earned INTEGER NOT NULL DEFAULT 0,
            UNIQUE(profile_id, date_str)
          )
        ''');

        await db.execute('''
          CREATE TABLE achievements (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            profile_id INTEGER NOT NULL,
            badge_id TEXT NOT NULL,
            unlocked_at TEXT NOT NULL,
            UNIQUE(profile_id, badge_id)
          )
        ''');
      },
    );
  }

  Future<List<StudentProfile>> getProfiles() async {
    final db = await database;
    final rows = await db.query('profiles', orderBy: 'id ASC');
    return rows.map(StudentProfile.fromMap).toList();
  }

  Future<StudentProfile> createProfile({
    required String name,
    required String avatarId,
    required int grade,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final id = await db.insert('profiles', {
      'name': name.trim(),
      'avatar_id': avatarId,
      'grade': grade,
      'stars': 0,
      'created_at': now,
    });
    return StudentProfile(
      id: id,
      name: name.trim(),
      avatarId: avatarId,
      grade: grade,
      stars: 0,
      createdAt: now,
    );
  }

  Future<void> updateProfile(StudentProfile profile) async {
    if (profile.id == null) return;
    final db = await database;
    await db.update(
      'profiles',
      {
        'name': profile.name,
        'avatar_id': profile.avatarId,
        'grade': profile.grade,
        'stars': profile.stars,
      },
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<void> deleteProfile(int profileId) async {
    final db = await database;
    await db.delete('completed_lessons', where: 'profile_id = ?', whereArgs: [profileId]);
    await db.delete('learned_words', where: 'profile_id = ?', whereArgs: [profileId]);
    await db.delete('quiz_results', where: 'profile_id = ?', whereArgs: [profileId]);
    await db.delete('daily_activity', where: 'profile_id = ?', whereArgs: [profileId]);
    await db.delete('achievements', where: 'profile_id = ?', whereArgs: [profileId]);
    await db.delete('profiles', where: 'id = ?', whereArgs: [profileId]);
  }

  Future<void> addStars(int profileId, int starsToAdd) async {
    if (starsToAdd <= 0) return;
    final db = await database;
    await db.rawUpdate(
      'UPDATE profiles SET stars = stars + ? WHERE id = ?',
      [starsToAdd, profileId],
    );
    await incrementDailyActivity(profileId: profileId, starsEarned: starsToAdd);
  }

  Future<List<CompletedLessonRecord>> getCompletedLessons(int profileId) async {
    final db = await database;
    final rows = await db.query(
      'completed_lessons',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'completed_at DESC',
    );
    return rows.map(CompletedLessonRecord.fromMap).toList();
  }

  Future<bool> markLessonCompleted({
    required int profileId,
    required String lessonId,
    required int grade,
    required int starsEarned,
    required int score,
  }) async {
    final db = await database;
    final existing = await db.query(
      'completed_lessons',
      where: 'profile_id = ? AND lesson_id = ?',
      whereArgs: [profileId, lessonId],
    );
    final now = DateTime.now().toIso8601String();
    if (existing.isEmpty) {
      await db.insert('completed_lessons', {
        'profile_id': profileId,
        'lesson_id': lessonId,
        'grade': grade,
        'stars_earned': starsEarned,
        'best_score': score,
        'completed_at': now,
      });
      await addStars(profileId, starsEarned);
      await incrementDailyActivity(profileId: profileId, lessonsCompleted: 1);
      return true;
    } else {
      final prevBest = (existing.first['best_score'] as int?) ?? 0;
      final prevStars = (existing.first['stars_earned'] as int?) ?? 0;
      await db.update(
        'completed_lessons',
        {
          'stars_earned': starsEarned > prevStars ? starsEarned : prevStars,
          'best_score': score > prevBest ? score : prevBest,
          'completed_at': now,
        },
        where: 'profile_id = ? AND lesson_id = ?',
        whereArgs: [profileId, lessonId],
      );
      if (starsEarned > prevStars) {
        await addStars(profileId, starsEarned - prevStars);
      }
      return false;
    }
  }

  Future<Set<String>> getLearnedWordIds(int profileId) async {
    final db = await database;
    final rows = await db.query(
      'learned_words',
      columns: ['word_id'],
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );
    return rows.map((e) => e['word_id'] as String).toSet();
  }

  Future<bool> markWordLearned({
    required int profileId,
    required String wordId,
    required String lessonId,
    required String english,
    required String myanmar,
  }) async {
    final db = await database;
    final inserted = await db.insert(
      'learned_words',
      {
        'profile_id': profileId,
        'word_id': wordId,
        'lesson_id': lessonId,
        'english': english,
        'myanmar': myanmar,
        'learned_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    if (inserted > 0) {
      await incrementDailyActivity(profileId: profileId, wordsLearned: 1);
      return true;
    }
    return false;
  }

  Future<void> saveQuizResult({
    required int profileId,
    required String category,
    required String topicId,
    required int score,
    required int total,
    required String difficulty,
    required int starsEarned,
  }) async {
    final db = await database;
    await db.insert('quiz_results', {
      'profile_id': profileId,
      'category': category,
      'topic_id': topicId,
      'score': score,
      'total': total,
      'difficulty': difficulty,
      'played_at': DateTime.now().toIso8601String(),
    });
    if (starsEarned > 0) await addStars(profileId, starsEarned);
    await incrementDailyActivity(profileId: profileId, gamesPlayed: 1);
  }

  Future<List<QuizResultRecord>> getQuizResults(int profileId) async {
    final db = await database;
    final rows = await db.query(
      'quiz_results',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'played_at DESC',
      limit: 100,
    );
    return rows.map(QuizResultRecord.fromMap).toList();
  }

  String _todayString() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }

  Future<void> incrementDailyActivity({
    required int profileId,
    int minutesSpent = 0,
    int lessonsCompleted = 0,
    int wordsLearned = 0,
    int gamesPlayed = 0,
    int starsEarned = 0,
  }) async {
    final db = await database;
    final today = _todayString();
    await db.insert(
      'daily_activity',
      {
        'profile_id': profileId,
        'date_str': today,
        'minutes_spent': 0,
        'lessons_completed': 0,
        'words_learned': 0,
        'games_played': 0,
        'stars_earned': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    await db.rawUpdate(
      '''
      UPDATE daily_activity
      SET minutes_spent = minutes_spent + ?,
          lessons_completed = lessons_completed + ?,
          words_learned = words_learned + ?,
          games_played = games_played + ?,
          stars_earned = stars_earned + ?
      WHERE profile_id = ? AND date_str = ?
      ''',
      [minutesSpent, lessonsCompleted, wordsLearned, gamesPlayed, starsEarned, profileId, today],
    );
  }

  Future<List<DailyActivityRecord>> getDailyActivity(int profileId, {int limit = 14}) async {
    final db = await database;
    final rows = await db.query(
      'daily_activity',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'date_str DESC',
      limit: limit,
    );
    return rows.map(DailyActivityRecord.fromMap).toList();
  }

  Future<Set<String>> getUnlockedBadges(int profileId) async {
    final db = await database;
    final rows = await db.query(
      'achievements',
      columns: ['badge_id'],
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );
    return rows.map((e) => e['badge_id'] as String).toSet();
  }

  Future<bool> unlockBadge(int profileId, String badgeId) async {
    final db = await database;
    final inserted = await db.insert(
      'achievements',
      {
        'profile_id': profileId,
        'badge_id': badgeId,
        'unlocked_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    return inserted > 0;
  }

  Future<void> resetProfileProgress(int profileId) async {
    final db = await database;
    await db.delete('completed_lessons', where: 'profile_id = ?', whereArgs: [profileId]);
    await db.delete('learned_words', where: 'profile_id = ?', whereArgs: [profileId]);
    await db.delete('quiz_results', where: 'profile_id = ?', whereArgs: [profileId]);
    await db.delete('daily_activity', where: 'profile_id = ?', whereArgs: [profileId]);
    await db.delete('achievements', where: 'profile_id = ?', whereArgs: [profileId]);
    await db.update('profiles', {'stars': 0}, where: 'id = ?', whereArgs: [profileId]);
  }
}
