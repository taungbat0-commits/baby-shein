import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile_model.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final TextEditingController _pinCtrl = TextEditingController();
  bool _unlocked = false;
  String? _errorMsg;

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  void _verifyPin(AppState state) {
    if (_pinCtrl.text.trim() == state.parentPin) {
      setState(() {
        _unlocked = true;
        _errorMsg = null;
      });
    } else {
      setState(() => _errorMsg = 'Wrong PIN • PIN နံပါတ် မှားနေပါသည်');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Parent Mode • မိဘစစ်ဆေးရေး')),
      body: SafeArea(
        child: _unlocked ? _buildDashboard(state) : _buildPinGate(state),
      ),
    );
  }

  Widget _buildPinGate(AppState state) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.lavender, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔒', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 10),
              const Text(
                'Enter Parent PIN',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                'မိဘစစ်ဆေးရေး PIN နံပါတ် ၄ လုံးထည့်ပါ\n(Default PIN: 1234)',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13.5),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pinCtrl,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 12),
                decoration: InputDecoration(
                  hintText: '••••',
                  counterText: '',
                  errorText: _errorMsg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onSubmitted: (_) => _verifyPin(state),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.lavender),
                  onPressed: () => _verifyPin(state),
                  child: const Text('Unlock • ဖွင့်မယ်'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(AppState state) {
    final profile = state.activeProfile;
    final avatar = AvatarOption.byId(profile.avatarId);
    final weakAreas = state.weakAreas;
    final avgAcc = state.averageQuizAccuracy.toStringAsFixed(0);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Switch Child Strip
          if (state.profiles.length > 1) ...[
            const Text('Select Child • ကလေးရွေးချယ်ရန်',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 6),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.profiles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final p = state.profiles[i];
                  return ChoiceChip(
                    label: Text('${AvatarOption.byId(p.avatarId).emoji} ${p.name}'),
                    selected: p.id == profile.id,
                    onSelected: (_) => state.switchProfile(p),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Child Summary Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lavenderLight,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.lavender, width: 2),
            ),
            child: Row(
              children: [
                Text(avatar.emoji, style: const TextStyle(fontSize: 38)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${profile.name} (Grade ${profile.grade})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Total Time: ${state.totalMinutesLearned} mins • Avg Quiz: $avgAcc%',
                        style: const TextStyle(
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

          const SizedBox(height: 16),

          // Key Metrics Row
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  'Lessons',
                  '${state.completedLessons.length}/${state.repository.allLessons.length}',
                  AppColors.skyBlueLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricCard('Words', '${state.learnedWordIds.length}', AppColors.mintGreenLight),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricCard('Avg Score', '$avgAcc%', AppColors.sunYellowLight),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Text(
            'Learning Areas & Weak Spots • အားနည်းချက်နှင့် စွမ်းဆောင်ရည်',
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          if (weakAreas.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'No quiz or game results yet. Have your child play a game or listening quiz to see detailed strengths and weak areas.\nဂိမ်း သို့မဟုတ် Quiz ကစားပြီးပါက အားသာချက်/အားနည်းချက်များ ဤနေရာတွင် ပေါ်လာပါမည်။',
                  style: TextStyle(fontSize: 13.5, color: AppColors.textMuted),
                ),
              ),
            )
          else
            ...weakAreas.map((w) {
              final acc = w.averageAccuracy;
              final barColor = acc < 60
                  ? AppColors.error
                  : acc < 80
                      ? AppColors.peach
                      : AppColors.mintGreen;
              final statusText = acc < 60
                  ? 'Needs Practice • ထပ်လေ့ကျင့်သင့်သည်'
                  : acc < 80
                      ? 'Good Progress • တိုးတက်နေပြီ'
                      : 'Strong • အရမ်းကောင်းသည်';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: barColor.withAlpha(110), width: 1.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${w.labelEn} (${w.labelMy})',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                        ),
                        Text(
                          '${acc.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: barColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (acc / 100).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: barColor.withAlpha(35),
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$statusText (${w.attempts} tries)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: barColor),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 16),
          const Text(
            'Recent Quiz & Game Results • မကြာသေးမီ ရမှတ်များ',
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          if (state.quizResults.isEmpty)
            const Text('No quiz records yet.', style: TextStyle(color: AppColors.textMuted))
          else
            ...state.quizResults.take(8).map(
              (r) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${r.category.replaceAll('_', ' ').toUpperCase()} (${r.difficulty})',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                    Text(
                      '${r.score}/${r.total} (${r.accuracy.toStringAsFixed(0)}%)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.skyBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color bg;
  const _MetricCard(this.label, this.value, this.bg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
