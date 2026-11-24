class CompletedLessonRecord {
  final String lessonId;
  final int grade;
  final int starsEarned;
  final int bestScore;
  final String completedAt;

  const CompletedLessonRecord({
    required this.lessonId,
    required this.grade,
    required this.starsEarned,
    required this.bestScore,
    required this.completedAt,
  });

  factory CompletedLessonRecord.fromMap(Map<String, dynamic> map) {
    return CompletedLessonRecord(
      lessonId: map['lesson_id'] as String,
      grade: map['grade'] as int,
      starsEarned: (map['stars_earned'] as int?) ?? 1,
      bestScore: (map['best_score'] as int?) ?? 100,
      completedAt: map['completed_at'] as String,
    );
  }
}

class QuizResultRecord {
  final int? id;
  final int profileId;
  final String category;
  final String topicId;
  final int score;
  final int total;
  final String difficulty;
  final String playedAt;

  const QuizResultRecord({
    this.id,
    required this.profileId,
    required this.category,
    required this.topicId,
    required this.score,
    required this.total,
    required this.difficulty,
    required this.playedAt,
  });

  double get accuracy => total == 0 ? 0 : (score / total) * 100;

  factory QuizResultRecord.fromMap(Map<String, dynamic> map) {
    return QuizResultRecord(
      id: map['id'] as int?,
      profileId: map['profile_id'] as int,
      category: map['category'] as String,
      topicId: map['topic_id'] as String,
      score: map['score'] as int,
      total: map['total'] as int,
      difficulty: (map['difficulty'] as String?) ?? 'easy',
      playedAt: map['played_at'] as String,
    );
  }
}

class DailyActivityRecord {
  final String dateStr;
  final int minutesSpent;
  final int lessonsCompleted;
  final int wordsLearned;
  final int gamesPlayed;
  final int starsEarned;

  const DailyActivityRecord({
    required this.dateStr,
    required this.minutesSpent,
    required this.lessonsCompleted,
    required this.wordsLearned,
    required this.gamesPlayed,
    required this.starsEarned,
  });

  factory DailyActivityRecord.fromMap(Map<String, dynamic> map) {
    return DailyActivityRecord(
      dateStr: map['date_str'] as String,
      minutesSpent: (map['minutes_spent'] as int?) ?? 0,
      lessonsCompleted: (map['lessons_completed'] as int?) ?? 0,
      wordsLearned: (map['words_learned'] as int?) ?? 0,
      gamesPlayed: (map['games_played'] as int?) ?? 0,
      starsEarned: (map['stars_earned'] as int?) ?? 0,
    );
  }
}

class AchievementBadge {
  final String id;
  final String titleEn;
  final String titleMy;
  final String descEn;
  final String descMy;
  final String emoji;
  final int colorHex;

  const AchievementBadge({
    required this.id,
    required this.titleEn,
    required this.titleMy,
    required this.descEn,
    required this.descMy,
    required this.emoji,
    required this.colorHex,
  });

  static const List<AchievementBadge> all = [
    AchievementBadge(
      id: 'first_lesson', titleEn: 'First Step', titleMy: 'ပထမဆုံးခြေလှမ်း',
      descEn: 'Complete your first lesson', descMy: 'ပထမဆုံး သင်ခန်းစာ ပြီးမြောက်ပြီ',
      emoji: '🌱', colorHex: 0xFF38C98F,
    ),
    AchievementBadge(
      id: 'word_collector_20', titleEn: 'Word Explorer', titleMy: 'စကားလုံးစုဆောင်းသူ',
      descEn: 'Learn 20 English words', descMy: 'အင်္ဂလိပ်စကားလုံး ၂၀ တတ်မြောက်ပြီ',
      emoji: '📖', colorHex: 0xFF4FB3FF,
    ),
    AchievementBadge(
      id: 'word_master_50', titleEn: 'Word Hero', titleMy: 'စကားလုံးသူရဲကောင်း',
      descEn: 'Learn 50 English words', descMy: 'အင်္ဂလိပ်စကားလုံး ၅၀ တတ်မြောက်ပြီ',
      emoji: '🦸', colorHex: 0xFF9B7BFF,
    ),
    AchievementBadge(
      id: 'star_shiner_30', titleEn: 'Super Star', titleMy: 'ကြယ်ပွင့်လေး',
      descEn: 'Earn 30 stars', descMy: 'ကြယ်ပွင့် ၃၀ စုဆောင်းနိုင်ပြီ',
      emoji: '🌟', colorHex: 0xFFFFCA3A,
    ),
    AchievementBadge(
      id: 'game_champ', titleEn: 'Game Champion', titleMy: 'ဂိမ်းချန်ပီယံ',
      descEn: 'Complete 5 learning games', descMy: 'ပညာရေးဂိမ်း ၅ ခု ကစားပြီးပြီ',
      emoji: '🏆', colorHex: 0xFFFF9B6A,
    ),
    AchievementBadge(
      id: 'grade1_hero', titleEn: 'Grade 1 Graduate', titleMy: 'Grade 1 ထူးချွန်ဆု',
      descEn: 'Finish all Grade 1 lessons', descMy: 'Grade 1 သင်ခန်းစာအားလုံး ပြီးဆုံးပြီ',
      emoji: '🎓', colorHex: 0xFFFF7AA2,
    ),
    AchievementBadge(
      id: 'grade2_hero', titleEn: 'Grade 2 Graduate', titleMy: 'Grade 2 ထူးချွန်ဆု',
      descEn: 'Finish all Grade 2 lessons', descMy: 'Grade 2 သင်ခန်းစာအားလုံး ပြီးဆုံးပြီ',
      emoji: '👑', colorHex: 0xFF4FB3FF,
    ),
  ];
}

class WeakAreaSummary {
  final String category;
  final String labelEn;
  final String labelMy;
  final double averageAccuracy;
  final int attempts;

  const WeakAreaSummary({
    required this.category,
    required this.labelEn,
    required this.labelMy,
    required this.averageAccuracy,
    required this.attempts,
  });
}
