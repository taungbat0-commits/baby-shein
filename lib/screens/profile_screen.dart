import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile_model.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncy_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _openProfileForm(BuildContext context, {StudentProfile? editing}) {
    final nameCtrl = TextEditingController(text: editing?.name ?? '');
    String selectedAvatar = editing?.avatarId ?? AvatarOption.all.first.id;
    int selectedGrade = editing?.grade ?? 1;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          title: Text(
            editing == null
                ? 'New Student • ကျောင်းသားအသစ်'
                : 'Edit Profile • ပြင်ဆင်ရန်',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Student Name • ကျောင်းသားအမည်',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Class • အတန်း', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 1, label: Text('Grade 1')),
                    ButtonSegment(value: 2, label: Text('Grade 2')),
                  ],
                  selected: {selectedGrade},
                  onSelectionChanged: (s) => setModalState(() => selectedGrade = s.first),
                ),
                const SizedBox(height: 14),
                const Text('Avatar • ကာတွန်းပုံရွေးပါ',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AvatarOption.all.map((a) {
                    final active = selectedAvatar == a.id;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedAvatar = a.id),
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Color(a.colorHex).withAlpha(active ? 80 : 28),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: active ? Color(a.colorHex) : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(a.emoji, style: const TextStyle(fontSize: 28)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final state = context.read<AppState>();
                if (editing == null) {
                  await state.addProfile(
                    name: name,
                    avatarId: selectedAvatar,
                    grade: selectedGrade,
                  );
                } else {
                  await state.updateActiveProfile(
                    name: name,
                    avatarId: selectedAvatar,
                    grade: selectedGrade,
                  );
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Save • သိမ်းမယ်'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final active = state.activeProfile;

    return Scaffold(
      appBar: AppBar(title: const Text('Student Profiles • ကျောင်းသားများ')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.skyBlue,
        foregroundColor: Colors.white,
        onPressed: () => _openProfileForm(context),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Child • ထပ်ထည့်မယ်'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
        itemCount: state.profiles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final p = state.profiles[index];
          final isCurrent = p.id == active.id;
          final avatar = AvatarOption.byId(p.avatarId);

          return BouncyButton(
            onTap: () => state.switchProfile(p),
            color: isCurrent ? AppColors.skyBlueLight : Colors.white,
            border: Border.all(
              color: isCurrent ? AppColors.skyBlue : AppColors.border,
              width: isCurrent ? 2.5 : 1.5,
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(avatar.colorHex).withAlpha(60),
                  child: Text(avatar.emoji, style: const TextStyle(fontSize: 30)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              p.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (isCurrent) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.mintGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Active',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Grade ${p.grade} • ⭐ ${p.stars} Stars',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: AppColors.skyBlue),
                    onPressed: () => _openProfileForm(context, editing: p),
                  ),
                if (state.profiles.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Delete Profile?'),
                          content: Text('Delete ${p.name} and all saved progress?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(c).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                              onPressed: () => Navigator.of(c).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && p.id != null) {
                        await state.deleteProfile(p.id!);
                      }
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
