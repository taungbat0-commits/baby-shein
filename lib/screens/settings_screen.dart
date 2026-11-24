import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showChangePinDialog(BuildContext context, AppState state) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    String? err;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Change Parent PIN • PIN ပြောင်းရန်'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldCtrl,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: const InputDecoration(labelText: 'Current PIN (Default: 1234)'),
              ),
              TextField(
                controller: newCtrl,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: const InputDecoration(labelText: 'New 4-digit PIN'),
              ),
              if (err != null)
                Text(err!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (oldCtrl.text.trim() != state.parentPin) {
                  setS(() => err = 'Current PIN is incorrect');
                  return;
                }
                final np = newCtrl.text.trim();
                if (!RegExp(r'^\d{4}$').hasMatch(np)) {
                  setS(() => err = 'Enter exactly 4 numbers');
                  return;
                }
                await state.setParentPin(np);
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Parent PIN updated! • PIN ပြောင်းပြီးပါပြီ')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, AppState state) {
    final pinCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Reset Progress • မှတ်တမ်းပြန်စမယ်'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter Parent PIN to reset ${state.activeProfile.name}\'s progress:'),
            const SizedBox(height: 10),
            TextField(
              controller: pinCtrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(hintText: 'Parent PIN'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              if (pinCtrl.text.trim() != state.parentPin) return;
              await state.resetActiveProfileProgress();
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Progress reset complete.')),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings • ဆက်တင်များ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Text('🔊', style: TextStyle(fontSize: 24)),
                  title: const Text('Sound & Pronunciation',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('အသံထွက်များ ဖွင့်/ပိတ်'),
                  value: state.soundEnabled,
                  onChanged: state.setSoundEnabled,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Text('🐢', style: TextStyle(fontSize: 24)),
                  title: const Text('Slow Audio by Default',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('အသံကို ဖြည်းဖြည်းချင်း အမြဲဖွင့်မည်'),
                  value: state.slowByDefault,
                  onChanged: state.setSlowByDefault,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Text('🇲🇲', style: TextStyle(fontSize: 24)),
                  title: const Text('Show Myanmar Translations',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('မြန်မာဘာသာပြန်များ ပြသမည်'),
                  value: state.showMyanmarHints,
                  onChanged: state.setShowMyanmarHints,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Text('🔐', style: TextStyle(fontSize: 24)),
                  title: const Text('Change Parent PIN',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('မိဘစစ်ဆေးရေး PIN နံပါတ်ပြောင်းရန်'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showChangePinDialog(context, state),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Text('🗑️', style: TextStyle(fontSize: 24)),
                  title: const Text('Reset Current Child Progress',
                      style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.error)),
                  subtitle: Text('${state.activeProfile.name} ၏ မှတ်တမ်းအားလုံး ပြန်စရန်'),
                  onTap: () => _showResetDialog(context, state),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Text('👨‍💻', style: TextStyle(fontSize: 24)),
                  title: Text('Developer Info', style: TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text('Name: NgaShein', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Text('✈️', style: TextStyle(fontSize: 22)),
                  title: const Text('Telegram: @ngashein528',
                      style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.skyBlue)),
                  subtitle: const Text('နှိပ်ပြီး Copy ကူးနိုင်ပါသည်'),
                  trailing: const Icon(Icons.copy_rounded, color: AppColors.skyBlue),
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: '@ngashein528'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied @ngashein528!')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.mintGreenLight,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.mintGreen, width: 1.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✅ 100% Offline Ready • အင်တာနက်မလိုဘဲ သုံးနိုင်သည်',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  'App: Baby Shein\n'
                  'Bundled Audio Files: ${state.audio.bundledAudioCount} (EN + MY)\n'
                  'Total Lessons: ${state.repository.allLessons.length} (Grade 1 & Grade 2)\n'
                  'Version: 1.0.0',
                  style: const TextStyle(fontSize: 13.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
