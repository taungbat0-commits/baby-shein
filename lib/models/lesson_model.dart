class LessonItem {
  final String id;
  final String english;
  final String myanmar;
  final String phonetic;
  final String emoji;
  final String audioKey;
  final String exampleEn;
  final String exampleMy;
  final String exampleAudioKey;
  final String? grammarNote;
  final int? colorHex;

  const LessonItem({
    required this.id,
    required this.english,
    required this.myanmar,
    required this.phonetic,
    required this.emoji,
    required this.audioKey,
    required this.exampleEn,
    required this.exampleMy,
    required this.exampleAudioKey,
    this.grammarNote,
    this.colorHex,
  });

  factory LessonItem.fromJson(Map<String, dynamic> json) {
    return LessonItem(
      id: json['id'] as String,
      english: json['english'] as String,
      myanmar: json['myanmar'] as String,
      phonetic: (json['phonetic'] as String?) ?? '',
      emoji: (json['emoji'] as String?) ?? '⭐',
      audioKey: (json['audioKey'] as String?) ?? (json['id'] as String),
      exampleEn: (json['exampleEn'] as String?) ?? '',
      exampleMy: (json['exampleMy'] as String?) ?? '',
      exampleAudioKey: (json['exampleAudioKey'] as String?) ?? '${json['id']}_ex',
      grammarNote: json['grammarNote'] as String?,
      colorHex: json['colorHex'] as int?,
    );
  }
}

class LessonModule {
  final String id;
  final int grade;
  final int order;
  final String titleEn;
  final String titleMy;
  final String descriptionEn;
  final String descriptionMy;
  final String icon;
  final int colorHex;
  final String category;
  final List<LessonItem> items;

  const LessonModule({
    required this.id,
    required this.grade,
    required this.order,
    required this.titleEn,
    required this.titleMy,
    required this.descriptionEn,
    required this.descriptionMy,
    required this.icon,
    required this.colorHex,
    required this.category,
    required this.items,
  });

  factory LessonModule.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? []);
    return LessonModule(
      id: json['id'] as String,
      grade: json['grade'] as int,
      order: json['order'] as int,
      titleEn: json['titleEn'] as String,
      titleMy: json['titleMy'] as String,
      descriptionEn: (json['descriptionEn'] as String?) ?? '',
      descriptionMy: (json['descriptionMy'] as String?) ?? '',
      icon: (json['icon'] as String?) ?? '📚',
      colorHex: (json['colorHex'] as int?) ?? 0xFF4FB3FF,
      category: (json['category'] as String?) ?? 'vocabulary',
      items: rawItems.map((e) => LessonItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class DailyPhrase {
  final String id;
  final String english;
  final String myanmar;
  final String situationEn;
  final String situationMy;
  final String emoji;
  final String audioKey;
  final String responseEn;
  final String responseMy;

  const DailyPhrase({
    required this.id,
    required this.english,
    required this.myanmar,
    required this.situationEn,
    required this.situationMy,
    required this.emoji,
    required this.audioKey,
    required this.responseEn,
    required this.responseMy,
  });

  factory DailyPhrase.fromJson(Map<String, dynamic> json) {
    return DailyPhrase(
      id: json['id'] as String,
      english: json['english'] as String,
      myanmar: json['myanmar'] as String,
      situationEn: json['situationEn'] as String,
      situationMy: json['situationMy'] as String,
      emoji: (json['emoji'] as String?) ?? '💬',
      audioKey: json['audioKey'] as String,
      responseEn: (json['responseEn'] as String?) ?? '',
      responseMy: (json['responseMy'] as String?) ?? '',
    );
  }
}
