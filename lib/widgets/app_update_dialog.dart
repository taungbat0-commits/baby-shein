import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/content_pack_model.dart';
import '../theme/app_theme.dart';

class AppUpdateDialog extends StatelessWidget {
  final AppUpdateInfo update;
  final String currentVersionName;

  const AppUpdateDialog({
    super.key,
    required this.update,
    required this.currentVersionName,
  });

  static Future<void> show(
    BuildContext context, {
    required AppUpdateInfo update,
    required String currentVersionName,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: !update.forceUpdate,
      builder: (_) => AppUpdateDialog(
        update: update,
        currentVersionName: currentVersionName,
      ),
    );
  }

  Future<void> _downloadApk(BuildContext context) async {
    final uri = Uri.tryParse(update.apkUrl.trim());
    if (uri == null) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download လင့်ခ်ဖွင့်မရပါ — အင်တာနက်ပြန်စစ်ပေးပါ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notes = update.releaseNotesMy.trim().isNotEmpty
        ? update.releaseNotesMy.trim()
        : (update.releaseNotesEn.trim().isNotEmpty
            ? update.releaseNotesEn.trim()
            : 'ဂိမ်းအသစ်များနှင့် ပြင်ဆင်ချက်အသစ်များ ပါဝင်ပါသည်။');

    return PopScope(
      canPop: !update.forceUpdate,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.skyBlueLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.skyBlue, width: 2.5),
              ),
              alignment: Alignment.center,
              child: const Text('🚀', style: TextStyle(fontSize: 38)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Version အသစ် ထွက်ရှိပါပြီ!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.sunYellowLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.sunYellow),
              ),
              child: Text(
                'v$currentVersionName  →  v${update.latestVersionName}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.skyBlueLight.withAlpha(130),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                notes,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (!update.forceUpdate) ...[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('နောက်မှ', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.skyBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => _downloadApk(context),
                    icon: const Icon(Icons.download_rounded, color: Colors.white),
                    label: const Text(
                      'Download ဆွဲမယ်',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
