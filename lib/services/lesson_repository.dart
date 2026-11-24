import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/lesson_model.dart';

class LessonRepository {
  List<LessonModule> _grade1Lessons = [];
  List<LessonModule> _grade2Lessons = [];
  List<DailyPhrase> _dailyPhrases = [];
  bool _loaded = false;

  Future<void> loadAll() async {
    if (_loaded) return;

    final g1Raw = await rootBundle.loadString('assets/data/grade1_lessons.json');
    final g2Raw = await rootBundle.loadString('assets/data/grade2_lessons.json');
    final dailyRaw = await rootBundle.loadString('assets/data/daily_english.json');

    final g1Json = jsonDecode(g1Raw) as Map<String, dynamic>;
    final g2Json = jsonDecode(g2Raw) as Map<String, dynamic>;
    final dailyJson = jsonDecode(dailyRaw) as Map<String, dynamic>;

    _grade1Lessons = (g1Json['lessons'] as List<dynamic>)
        .map((e) => LessonModule.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    _grade2Lessons = (g2Json['lessons'] as List<dynamic>)
        .map((e) => LessonModule.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    _dailyPhrases = (dailyJson['phrases'] as List<dynamic>)
        .map((e) => DailyPhrase.fromJson(e as Map<String, dynamic>))
        .toList();

    _loaded = true;
  }

  List<LessonModule> get grade1Lessons => _grade1Lessons;
  List<LessonModule> get grade2Lessons => _grade2Lessons;
  List<LessonModule> get allLessons => [..._grade1Lessons, ..._grade2Lessons];
  List<DailyPhrase> get dailyPhrases => _dailyPhrases;

  List<LessonModule> lessonsForGrade(int grade) =>
      grade == 1 ? _grade1Lessons : _grade2Lessons;

  LessonModule? findLessonById(String id) {
    for (final lesson in allLessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  List<LessonItem> getSingleWordVocabulary({int? grade}) {
    final source = grade == null ? allLessons : lessonsForGrade(grade);
    final result = <LessonItem>[];
    final seen = <String>{};

    for (final lesson in source) {
      if (lesson.category == 'alphabet' || lesson.category == 'pronunciation') continue;
      for (final item in lesson.items) {
        final word = item.english.trim();
        final isSingleWord = RegExp(r'^[A-Za-z]{3,10}$').hasMatch(word);
        if (isSingleWord && seen.add(word.toLowerCase())) {
          result.add(item);
        }
      }
    }
    return result;
  }

  List<LessonItem> getAllQuizItems({int? grade}) {
    final source = grade == null ? allLessons : lessonsForGrade(grade);
    final result = <LessonItem>[];
    final seen = <String>{};
    for (final lesson in source) {
      for (final item in lesson.items) {
        if (seen.add(item.id)) result.add(item);
      }
    }
    return result;
  }
}
