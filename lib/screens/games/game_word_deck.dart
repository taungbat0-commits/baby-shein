import 'dart:math';

import '../../models/lesson_model.dart';

/// Tracks played word IDs across rounds so each new round serves unseen words
/// until the entire vocabulary pool (including downloaded packs) is covered.
class GameWordDeck {
  final Set<String> _usedIds = {};
  int round = 0;

  List<LessonItem> nextRound(
    List<LessonItem> candidates,
    int count,
    Random rng,
  ) {
    round++;
    final byId = <String, LessonItem>{};
    for (final item in candidates) {
      byId[item.id] = item;
    }
    final unique = byId.values.toList();
    if (unique.isEmpty) return [];

    final targetCount = count.clamp(1, unique.length);
    final unseen = unique.where((e) => !_usedIds.contains(e.id)).toList()
      ..shuffle(rng);

    final picked = <LessonItem>[];
    if (unseen.length >= targetCount) {
      picked.addAll(unseen.take(targetCount));
    } else {
      picked.addAll(unseen);
      final pickedIds = picked.map((e) => e.id).toSet();
      _usedIds.clear();
      final refill = unique.where((e) => !pickedIds.contains(e.id)).toList()
        ..shuffle(rng);
      picked.addAll(refill.take(targetCount - picked.length));
    }

    for (final item in picked) {
      _usedIds.add(item.id);
    }
    return picked;
  }
}
