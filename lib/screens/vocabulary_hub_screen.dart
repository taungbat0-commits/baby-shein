import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lesson_model.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncy_button.dart';
import 'downloads_screen.dart';

const Set<String> _kExcludedVocabCategories = {
  'alphabet',
  'numbers',
  'pronunciation',
  'sentences',
  'conversation',
  'grammar',
  'qa',
  'reading',
  'greetings',
};

class VocabularyHubScreen extends StatefulWidget {
  const VocabularyHubScreen({super.key});

  @override
  State<VocabularyHubScreen> createState() => _VocabularyHubScreenState();
}

class _VocabularyHubScreenState extends State<VocabularyHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _gradeFilter = 0;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final rawLessons = _gradeFilter == 0
        ? state.repository.allLessons
        : state.repository.lessonsForGrade(_gradeFilter);

    final topics = rawLessons
        .where((l) =>
            !_kExcludedVocabCategories.contains(l.category.toLowerCase()) &&
            l.items.isNotEmpty)
        .toList();

    final isSearching = _query.trim().isNotEmpty;
    final searchResults = <(LessonModule, LessonItem)>[];
    if (isSearching) {
      final q = _query.trim().toLowerCase();
      final qRaw = _query.trim();
      for (final topic in topics) {
        for (final item in topic.items) {
          if (item.english.toLowerCase().contains(q) ||
              item.myanmar.contains(qRaw)) {
            searchResults.add((topic, item));
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Vocabulary • ဝေါဟာရများ')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search English or Myanmar word...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: isSearching
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('All')),
                ButtonSegment(value: 1, label: Text('Grade 1')),
                ButtonSegment(value: 2, label: Text('Grade 2')),
              ],
              selected: {_gradeFilter},
              onSelectionChanged: (s) => setState(() => _gradeFilter = s.first),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: isSearching
                ? _buildSearchResults(state, searchResults)
                : _buildTopicsGrid(context, topics),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsGrid(BuildContext context, List<LessonModule> topics) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.86,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final topic = topics[index];
                final color = AppTheme.pastelForIndex(index);
                final bg = AppTheme.lightPastelForIndex(index);
                final emoji = topic.icon.trim().isNotEmpty
                    ? topic.icon
                    : topic.items.first.emoji;

                return BouncyButton(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VocabularyTopicDetailScreen(
                        topic: topic,
                        accentColor: color,
                        lightColor: bg,
                      ),
                    ),
                  ),
                  color: Colors.white,
                  border: Border.all(color: color.withAlpha(135), width: 2),
                  borderRadius: 24,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'G${topic.grade}',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Text(emoji, style: const TextStyle(fontSize: 32)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        topic.titleEn,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        topic.titleMy,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.softPink,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${topic.items.length} Words • ${topic.items.length} လုံး',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: topics.length,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
          sliver: SliverToBoxAdapter(
            child: BouncyButton(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DownloadsScreen()),
              ),
              color: AppColors.skyBlueLight,
              border: Border.all(color: AppColors.skyBlue, width: 2),
              padding: const EdgeInsets.all(14),
              child: const Row(
                children: [
                  Text('📥', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Download More Vocabulary Topics',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
                        ),
                        Text(
                          'ယာဉ်များ၊ အဝတ်အစားနှင့် ဝေါဟာရခေါင်းစဉ်အသစ်များ ထပ်ထည့်မယ်',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.skyBlue, size: 28),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(
    AppState state,
    List<(LessonModule, LessonItem)> results,
  ) {
    if (results.isEmpty) {
      return const Center(
        child: Text(
          '🔍 ရှာမတွေ့ပါ • No matching words',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final (topic, item) = results[index];
        final color = AppTheme.pastelForIndex(index);
        return _VocabWordCard(
          item: item,
          color: color,
          state: state,
          topicTag: '${topic.icon} ${topic.titleEn}',
        );
      },
    );
  }
}

class VocabularyTopicDetailScreen extends StatelessWidget {
  final LessonModule topic;
  final Color accentColor;
  final Color lightColor;

  const VocabularyTopicDetailScreen({
    super.key,
    required this.topic,
    required this.accentColor,
    required this.lightColor,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final emoji = topic.icon.trim().isNotEmpty
        ? topic.icon
        : (topic.items.isNotEmpty ? topic.items.first.emoji : '📚');

    return Scaffold(
      appBar: AppBar(
        title: Text('$emoji ${topic.titleEn}'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: lightColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor, width: 2),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.titleMy,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        '${topic.items.length} Words • ဝေါဟာရ ${topic.items.length} လုံး',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 28),
              itemCount: topic.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = topic.items[index];
                final cardColor = AppTheme.pastelForIndex(index);
                return _VocabWordCard(
                  item: item,
                  color: cardColor,
                  state: state,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabWordCard extends StatelessWidget {
  final LessonItem item;
  final Color color;
  final AppState state;
  final String? topicTag;

  const _VocabWordCard({
    required this.item,
    required this.color,
    required this.state,
    this.topicTag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withAlpha(110), width: 1.8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withAlpha(38),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(item.emoji, style: const TextStyle(fontSize: 30)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.english,
                            style: const TextStyle(
                              fontSize: 18.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        if (topicTag != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withAlpha(35),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              topicTag!,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      item.myanmar,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.softPink,
                      ),
                    ),
                    if (item.exampleEn.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item.exampleEn,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: BouncyButton(
                  onTap: () => state.audio.speak(
                    text: item.english,
                    audioKey: item.audioKey,
                    slow: state.slowByDefault,
                    lang: 'en',
                  ),
                  color: color,
                  borderRadius: 14,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.volume_up_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 5),
                      Text(
                        'EN အသံ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BouncyButton(
                  onTap: () => state.audio.speak(
                    text: item.myanmar,
                    audioKey: item.audioKey,
                    slow: state.slowByDefault,
                    lang: 'my',
                  ),
                  color: AppColors.softPinkLight,
                  border: Border.all(color: AppColors.softPink, width: 1.5),
                  borderRadius: 14,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🇲🇲', style: TextStyle(fontSize: 15)),
                      SizedBox(width: 5),
                      Text(
                        'MY အသံ',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
