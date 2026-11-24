class RemoteAnnouncement {
  final String id;
  final String titleEn;
  final String titleMy;
  final String messageEn;
  final String messageMy;

  const RemoteAnnouncement({
    required this.id,
    required this.titleEn,
    required this.titleMy,
    required this.messageEn,
    required this.messageMy,
  });

  factory RemoteAnnouncement.fromJson(Map<String, dynamic> json) {
    return RemoteAnnouncement(
      id: (json['id'] as String?) ?? '',
      titleEn: (json['titleEn'] as String?) ?? '',
      titleMy: (json['titleMy'] as String?) ?? '',
      messageEn: (json['messageEn'] as String?) ?? '',
      messageMy: (json['messageMy'] as String?) ?? '',
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
  final RemoteAnnouncement? announcement;
  final List<ContentPackInfo> packs;

  const CatalogData({
    this.announcement,
    required this.packs,
  });

  factory CatalogData.fromJson(Map<String, dynamic> json) {
    final annRaw = json['announcement'] as Map<String, dynamic>?;
    final rawPacks = (json['packs'] as List<dynamic>?) ?? [];
    return CatalogData(
      announcement: annRaw == null ? null : RemoteAnnouncement.fromJson(annRaw),
      packs: rawPacks
          .map((e) => ContentPackInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
