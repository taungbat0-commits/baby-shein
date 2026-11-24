import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/content_pack_model.dart';
import '../models/lesson_model.dart';

typedef VersionMap = Map<String, int>;

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
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> _audioDir() async {
    final dir = await _packsDir();
    final audio = Directory('${dir.path}/audio');
    if (!await audio.exists()) await audio.create(recursive: true);
    return audio;
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

  Future<bool> _downloadBinary(String url, File target) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final req = await client.getUrl(Uri.parse(url));
      final res = await req.close().timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return false;
      final bytes = await consolidateHttpClientResponseBytes(res);
      if (bytes.length < 200) return false;
      await target.writeAsBytes(bytes, flush: true);
      return true;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }

  Set<String> _extractAudioKeys(Map<String, dynamic> decoded) {
    final keys = <String>{};
    final lessons = (decoded['lessons'] as List<dynamic>?) ?? [];
    for (final rawL in lessons) {
      final l = rawL as Map<String, dynamic>;
      final items = (l['items'] as List<dynamic>?) ?? [];
      for (final rawI in items) {
        final item = rawI as Map<String, dynamic>;
        final ak = ((item['audioKey'] as String?) ?? (item['id'] as String?) ?? '').trim();
        if (ak.isNotEmpty) {
          keys.add(ak);
          if (((item['myanmar'] as String?) ?? '').trim().isNotEmpty) {
            keys.add('${ak}_my');
          }
        }
        final exK = ((item['exampleAudioKey'] as String?) ?? '${ak}_ex').trim();
        if (((item['exampleEn'] as String?) ?? '').trim().isNotEmpty) {
          keys.add(exK);
        }
        if (((item['exampleMy'] as String?) ?? '').trim().isNotEmpty) {
          keys.add('${exK}_my');
        }
      }
    }
    final phrases = (decoded['phrases'] as List<dynamic>?) ?? [];
    for (final rawP in phrases) {
      final p = rawP as Map<String, dynamic>;
      final ak = ((p['audioKey'] as String?) ?? '').trim();
      if (ak.isEmpty) continue;
      keys.add(ak);
      if (((p['myanmar'] as String?) ?? '').trim().isNotEmpty) keys.add('${ak}_my');
      if (((p['responseEn'] as String?) ?? '').trim().isNotEmpty) keys.add('${ak}_res');
      if (((p['responseMy'] as String?) ?? '').trim().isNotEmpty) keys.add('${ak}_res_my');
    }
    return keys;
  }

  Future<CatalogData?> fetchCatalog() async {
    final body = await _httpGetText(catalogUrl);
    if (body == null || body.trim().isEmpty) return null;
    try {
      return CatalogData.fromJson(jsonDecode(body) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<VersionMap> getInstalledVersions() async {
    try {
      final file = await _metaFile();
      if (!await file.exists()) return {};
      final decoded = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveInstalledVersions(VersionMap versions) async {
    final file = await _metaFile();
    await file.writeAsString(jsonEncode(versions));
  }

  Future<bool> downloadPack(
    ContentPackInfo pack, {
    void Function(int done, int total)? onProgress,
  }) async {
    final body = await _httpGetText(pack.downloadUrl);
    if (body == null || body.trim().isEmpty) return false;
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      if (!decoded.containsKey('lessons') && !decoded.containsKey('phrases')) {
        return false;
      }

      final audioKeys = _extractAudioKeys(decoded).toList();
      final lastSlash = pack.downloadUrl.lastIndexOf('/');
      final defaultAudioBase = lastSlash > 0
          ? '${pack.downloadUrl.substring(0, lastSlash)}/audio'
          : '';
      final audioBase = ((decoded['audioBaseUrl'] as String?) ?? defaultAudioBase).trim();

      if (audioBase.isNotEmpty && audioKeys.isNotEmpty) {
        final audioDir = await _audioDir();
        int done = 0;
        onProgress?.call(0, audioKeys.length);

        const batchSize = 4;
        for (int i = 0; i < audioKeys.length; i += batchSize) {
          final end = (i + batchSize).clamp(0, audioKeys.length);
          final batch = audioKeys.sublist(i, end);
          await Future.wait(batch.map((key) async {
            final target = File('${audioDir.path}/$key.mp3');
            await _downloadBinary('$audioBase/$key.mp3', target);
            done++;
            onProgress?.call(done, audioKeys.length);
          }));
        }
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
      try {
        final decoded = jsonDecode(await packFile.readAsString()) as Map<String, dynamic>;
        final audioDir = await _audioDir();
        for (final key in _extractAudioKeys(decoded)) {
          final f = File('${audioDir.path}/$key.mp3');
          if (await f.exists()) await f.delete();
        }
      } catch (_) {}
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
        for (final l in (json['lessons'] as List<dynamic>?) ?? []) {
          lessons.add(LessonModule.fromJson(l as Map<String, dynamic>));
        }
        for (final p in (json['phrases'] as List<dynamic>?) ?? []) {
          phrases.add(DailyPhrase.fromJson(p as Map<String, dynamic>));
        }
      } catch (_) {}
    }

    return DownloadedContent(lessons: lessons, phrases: phrases);
  }
}
