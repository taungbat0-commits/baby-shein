class AppUpdateInfo {
  final int latestVersionCode;
  final String latestVersionName;
  final String apkUrl;
  final String releaseNotesEn;
  final String releaseNotesMy;
  final bool forceUpdate;

  const AppUpdateInfo({
    required this.latestVersionCode,
    required this.latestVersionName,
    required this.apkUrl,
    this.releaseNotesEn = '',
    this.releaseNotesMy = '',
    this.forceUpdate = false,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      latestVersionCode: (json['latestVersionCode'] as num?)?.toInt() ?? 0,
      latestVersionName: (json['latestVersionName'] as String?) ?? '',
      apkUrl: (json['apkUrl'] as String?) ?? '',
      releaseNotesEn: (json['releaseNotesEn'] as String?) ?? '',
      releaseNotesMy: (json['releaseNotesMy'] as String?) ?? '',
      forceUpdate: (json['forceUpdate'] as bool?) ?? false,
    );
  }
}

class RemoteAnnouncement {
  final String id;
  final String titleEn;
  final String titleMy;
  final String messageEn;
  final String messageMy;
  final String marqueeText;

  const RemoteAnnouncement({
    required this.id,
    required this.titleEn,
    required this.titleMy,
    required this.messageEn,
    required this.messageMy,
    this.marqueeText = '',
  });

  factory RemoteAnnouncement.fromJson(Map<String, dynamic> json) {
    return RemoteAnnouncement(
      id: (json['id'] as String?) ?? '',
      titleEn: (json['titleEn'] as String?) ?? '',
      titleMy: (json['titleMy'] as String?) ?? '',
      messageEn: (json['messageEn'] as String?) ?? '',
      messageMy: (json['messageMy'] as String?) ?? '',
      marqueeText: (json['marqueeText'] as String?) ?? '',
    );
  }
}

class GameChallengeItem {
  final String id;
  final String mode; // 'sentence' or 'quiz'
  final String promptEn;
  final String promptMy;
  final String emoji;
  final String audioKey;
  final List<String> words;
  final List<String> options;
  final int answerIndex;
  final String explanationMy;

  const GameChallengeItem({
    required this.id,
    required this.mode,
    required this.promptEn,
    required this.promptMy,
    this.emoji = '🎯',
    this.audioKey = '',
    this.words = const [],
    this.options = const [],
    this.answerIndex = 0,
    this.explanationMy = '',
  });

  factory GameChallengeItem.fromJson(Map<String, dynamic> json) {
    return GameChallengeItem(
      id: (json['id'] as String?) ?? '',
      mode: (json['mode'] as String?) ?? 'quiz',
      promptEn: (json['promptEn'] as String?) ?? '',
      promptMy: (json['promptMy'] as String?) ?? '',
      emoji: (json['emoji'] as String?) ?? '🎯',
      audioKey: (json['audioKey'] as String?) ?? '',
      words: ((json['words'] as List<dynamic>?) ?? [])
          .map((e) => e.toString())
          .toList(),
      options: ((json['options'] as List<dynamic>?) ?? [])
          .map((e) => e.toString())
          .toList(),
      answerIndex: (json['answerIndex'] as num?)?.toInt() ?? 0,
      explanationMy: (json['explanationMy'] as String?) ?? '',
    );
  }
}

class GameChallengePack {
  final String id;
  final String titleEn;
  final String titleMy;
  final String descriptionMy;
  final String mode; // 'sentence', 'quiz', 'mixed'
  final String emoji;
  final int colorHex;
  final int grade;
  final bool isDownloaded;
  final List<GameChallengeItem> items;

  const GameChallengePack({
    required this.id,
    required this.titleEn,
    required this.titleMy,
    this.descriptionMy = '',
    this.mode = 'mixed',
    this.emoji = '🎯',
    this.colorHex = 0xFF9B7BFF,
    this.grade = 1,
    this.isDownloaded = false,
    required this.items,
  });

  factory GameChallengePack.fromJson(
    Map<String, dynamic> json, {
    bool isDownloaded = false,
  }) {
    final rawItems = (json['items'] as List<dynamic>?) ?? [];
    return GameChallengePack(
      id: (json['id'] as String?) ?? '',
      titleEn: (json['titleEn'] as String?) ?? 'Game Pack',
      titleMy: (json['titleMy'] as String?) ?? 'ဂိမ်းအစု',
      descriptionMy: (json['descriptionMy'] as String?) ?? '',
      mode: (json['mode'] as String?) ?? 'mixed',
      emoji: (json['emoji'] as String?) ?? '🎯',
      colorHex: (json['colorHex'] as num?)?.toInt() ?? 0xFF9B7BFF,
      grade: (json['grade'] as num?)?.toInt() ?? 1,
      isDownloaded: isDownloaded,
      items: rawItems
          .map((e) => GameChallengeItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ContentPackInfo {
  final String id;
  final int version;
  final String titleEn;
  final String titleMy;
  final String descriptionEn;
  final String descriptionMy;
  final int grade;
  final String type;
  final String icon;
  final int colorHex;
  final String sizeLabel;
  final String downloadUrl;

  const ContentPackInfo({
    required this.id,
    required this.version,
    required this.titleEn,
    required this.titleMy,
    required this.descriptionEn,
    required this.descriptionMy,
    required this.grade,
    required this.type,
    required this.icon,
    required this.colorHex,
    required this.sizeLabel,
    required this.downloadUrl,
  });

  factory ContentPackInfo.fromJson(Map<String, dynamic> json) {
    return ContentPackInfo(
      id: json['id'] as String,
      version: (json['version'] as int?) ?? 1,
      titleEn: json['titleEn'] as String,
      titleMy: json['titleMy'] as String,
      descriptionEn: (json['descriptionEn'] as String?) ?? '',
      descriptionMy: (json['descriptionMy'] as String?) ?? '',
      grade: (json['grade'] as int?) ?? 1,
      type: (json['type'] as String?) ?? 'lesson',
      icon: (json['icon'] as String?) ?? '📦',
      colorHex: (json['colorHex'] as int?) ?? 0xFF4FB3FF,
      sizeLabel: (json['sizeLabel'] as String?) ?? '15 KB',
      downloadUrl: json['downloadUrl'] as String,
    );
  }
}

class CatalogData {
  final AppUpdateInfo? appUpdate;
  final RemoteAnnouncement? announcement;
  final List<ContentPackInfo> packs;

  const CatalogData({
    this.appUpdate,
    this.announcement,
    required this.packs,
  });

  factory CatalogData.fromJson(Map<String, dynamic> json) {
    final updRaw = json['appUpdate'] as Map<String, dynamic>?;
    final annRaw = json['announcement'] as Map<String, dynamic>?;
    final rawPacks = (json['packs'] as List<dynamic>?) ?? [];
    return CatalogData(
      appUpdate: updRaw == null ? null : AppUpdateInfo.fromJson(updRaw),
      announcement: annRaw == null ? null : RemoteAnnouncement.fromJson(annRaw),
      packs: rawPacks
          .map((e) => ContentPackInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
