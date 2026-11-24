class StudentProfile {
  final int? id;
  final String name;
  final String avatarId;
  final int grade;
  final int stars;
  final String createdAt;

  const StudentProfile({
    this.id,
    required this.name,
    required this.avatarId,
    required this.grade,
    this.stars = 0,
    required this.createdAt,
  });

  StudentProfile copyWith({
    int? id,
    String? name,
    String? avatarId,
    int? grade,
    int? stars,
    String? createdAt,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarId: avatarId ?? this.avatarId,
      grade: grade ?? this.grade,
      stars: stars ?? this.stars,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'avatar_id': avatarId,
      'grade': grade,
      'stars': stars,
      'created_at': createdAt,
    };
  }

  factory StudentProfile.fromMap(Map<String, dynamic> map) {
    return StudentProfile(
      id: map['id'] as int?,
      name: map['name'] as String,
      avatarId: map['avatar_id'] as String,
      grade: map['grade'] as int,
      stars: (map['stars'] as int?) ?? 0,
      createdAt: map['created_at'] as String,
    );
  }
}

class AvatarOption {
  final String id;
  final String emoji;
  final String labelEn;
  final String labelMy;
  final int colorHex;

  const AvatarOption({
    required this.id,
    required this.emoji,
    required this.labelEn,
    required this.labelMy,
    required this.colorHex,
  });

  static const List<AvatarOption> all = [
    AvatarOption(id: 'owl', emoji: '🦉', labelEn: 'Momo Owl', labelMy: 'မိုမို ဇီးကွက်', colorHex: 0xFF4FB3FF),
    AvatarOption(id: 'cat', emoji: '🐱', labelEn: 'Kitty', labelMy: 'ကြောင်လေး', colorHex: 0xFFFF7AA2),
    AvatarOption(id: 'bunny', emoji: '🐰', labelEn: 'Sunny Bunny', labelMy: 'ယုန်လေး', colorHex: 0xFFFFCA3A),
    AvatarOption(id: 'panda', emoji: '🐼', labelEn: 'Poko Panda', labelMy: 'ပန်ဒါလေး', colorHex: 0xFF38C98F),
    AvatarOption(id: 'bear', emoji: '🐻', labelEn: 'Bobo Bear', labelMy: 'ဝက်ဝံလေး', colorHex: 0xFFFF9B6A),
    AvatarOption(id: 'unicorn', emoji: '🦄', labelEn: 'Starry', labelMy: 'ကြယ်လေး', colorHex: 0xFF9B7BFF),
  ];

  static AvatarOption byId(String id) {
    return all.firstWhere((a) => a.id == id, orElse: () => all.first);
  }
}
