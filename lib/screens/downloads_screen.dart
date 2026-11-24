import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/content_pack_model.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncy_button.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  bool _offlineFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    final ok = await context.read<AppState>().checkForUpdates();
    if (mounted) {
      setState(() => _offlineFailed = !ok);
    }
  }

  Future<void> _handleDownload(ContentPackInfo pack) async {
    final state = context.read<AppState>();
    final ok = await state.downloadPack(pack);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? '✅ "${pack.titleEn}" ထည့်သွင်းပြီးပါပြီ! Offline သုံးနိုင်ပါပြီ'
              : '❌ Download မအောင်မြင်ပါ။ အင်တာနက်စစ်ဆေးပြီး ထပ်စမ်းပါ။',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final catalog = state.remoteCatalog;
    final packs = catalog?.packs ?? [];
    final ann = catalog?.announcement;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Lessons • သင်ခန်းစာအသစ်များ'),
        actions: [
          IconButton(
            onPressed: state.checkingUpdates ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Check Updates',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              if (ann != null && ann.titleEn.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.sunYellowLight, AppColors.softPinkLight],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.softPink, width: 2),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🔔', style: TextStyle(fontSize: 30)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ann.titleEn,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                            if (ann.titleMy.isNotEmpty)
                              Text(
                                ann.titleMy,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.softPink,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              ann.messageMy.isNotEmpty ? ann.messageMy : ann.messageEn,
                              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              if (state.checkingUpdates && packs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_offlineFailed && packs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text('📡', style: TextStyle(fontSize: 44)),
                      const SizedBox(height: 8),
                      const Text(
                        'Offline Mode • အင်တာနက်မချိတ်ထားပါ',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'သင်ခန်းစာအသစ်များ ရှာဖွေ Download ဆွဲရန် အင်တာနက်ခဏဖွင့်ပြီး ပြန်စစ်ဆေးပါ။ Download ဆွဲပြီးသားများကို အင်တာနက်မလိုဘဲ ဆက်သုံးနိုင်ပါသည်။',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13.5, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try Again • ပြန်စစ်မယ်'),
                      ),
                    ],
                  ),
                )
              else if (packs.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No extra packs available yet.'),
                  ),
                )
              else
                ...packs.map((pack) {
                  final installedVer = state.installedPacks[pack.id];
                  final isInstalled = installedVer != null;
                  final needsUpdate = isInstalled && pack.version > installedVer;
                  final isBusy = state.downloadingPackId == pack.id;
                  final color = Color(pack.colorHex);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isInstalled ? AppColors.mintGreen : color.withAlpha(110),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: color.withAlpha(40),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Text(pack.icon, style: const TextStyle(fontSize: 30)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: color.withAlpha(35),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          pack.type == 'daily'
                                              ? 'Daily English'
                                              : 'Grade ${pack.grade}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        pack.sizeLabel,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: AppColors.textMuted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    pack.titleEn,
                                    style: const TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    pack.titleMy,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.softPink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pack.descriptionMy.isNotEmpty ? pack.descriptionMy : pack.descriptionEn,
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: BouncyButton(
                                onTap: isBusy || (isInstalled && !needsUpdate)
                                    ? null
                                    : () => _handleDownload(pack),
                                color: isInstalled && !needsUpdate
                                    ? AppColors.mintGreenLight
                                    : (needsUpdate ? AppColors.sunYellow : color),
                                borderRadius: 14,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Center(
                                  child: isBusy
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          isInstalled && !needsUpdate
                                              ? '✅ Installed • ထည့်ပြီးသား'
                                              : needsUpdate
                                                  ? '🔄 Update • အသစ်တင်မယ်'
                                                  : '⬇️ Download • ရွေးထည့်မယ်',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13.5,
                                            color: isInstalled && !needsUpdate
                                                ? AppColors.mintGreen
                                                : (needsUpdate
                                                    ? AppColors.textDark
                                                    : Colors.white),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            if (isInstalled) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => state.removePack(pack.id),
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: AppColors.error),
                                tooltip: 'Remove pack',
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
