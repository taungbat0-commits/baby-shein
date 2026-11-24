import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/content_pack_model.dart';
import '../models/lesson_model.dart';

class DownloadedContent {
  final List<LessonModule> lessons;
  final List<DailyPhrase> phrases;

  const DownloadedContent({
    required this.lessons,
    required this.phrases,
  });
}

class ContentUpdateService {
  static const String catalogUrl = 'https://raw.githubusercontent.com/taungbat0-commits/baby-shein/main/content_packs/catalog.json';

  Future<Directory> _packsDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/downloaded_packs');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _metaFile() async {
    final dir = await _packsDir();
    return File('${dir.path}/installed.json');
  }

  Future<String?> _httpGetText(String url) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final uri = Uri.parse('$url?t=${DateTime.now().millisecondsSinceEpoch}');
      final req = await client.getUrl(uri);
      req.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');
      final res = await req.close().timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      return await res.transform(utf8.decoder).join();
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  Future<CatalogData?> fetchCatalog() async {
    final body = await _httpGetText(catalogUrl);
    if (body == null || body.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      return CatalogData.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future> getInstalledVersions() async {
    try {
      final file = await _metaFile();
      if (!await file.exists()) return {};
      final decoded = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveInstalledVersions(Map<String, int> versions) async {
    final file = await _metaFile();
    await file.writeAsString(jsonEncode(versions));
  }

  Future<bool> downloadPack(ContentPackInfo pack) async {
    final body = await _httpGetText(pack.downloadUrl);
    if (body == null || body.trim().isEmpty) return false;
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      if (!decoded.containsKey('lessons') && !decoded.containsKey('phrases')) {
        return false;
      }
      final dir = await _packsDir();
      final packFile = File('${dir.path}/${pack.id}.json');
      await packFile.writeAsString(body, encoding: utf8);

      final versions = await getInstalledVersions();
      versions[pack.id] = pack.version;
      await _saveInstalledVersions(versions);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> removePack(String packId) async {
    final dir = await _packsDir();
    final packFile = File('${dir.path}/$packId.json');
    if (await packFile.exists()) {
      await packFile.delete();
    }
    final versions = await getInstalledVersions();
    versions.remove(packId);
    await _saveInstalledVersions(versions);
  }

  Future<DownloadedContent> loadInstalledContent() async {
    final lessons = <LessonModule>[];
    final phrases = <DailyPhrase>[];
    final dir = await _packsDir();
    final versions = await getInstalledVersions();

    for (final packId in versions.keys) {
      final file = File('${dir.path}/$packId.json');
      if (!await file.exists()) continue;
      try {
        final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        final rawLessons = (json['lessons'] as List<dynamic>?) ?? [];
        for (final l in rawLessons) {
          lessons.add(LessonModule.fromJson(l as Map<String, dynamic>));
        }
        final rawPhrases = (json['phrases'] as List<dynamic>?) ?? [];
        for (final p in rawPhrases) {
          phrases.add(DailyPhrase.fromJson(p as Map<String, dynamic>));
        }
      } catch (_) {}
    }

    return DownloadedContent(lessons: lessons, phrases: phrases);
  }
}
