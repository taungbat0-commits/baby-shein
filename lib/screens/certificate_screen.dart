import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncy_button.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  String _awardTitle = 'English Star Learner';
  bool _busy = false;

  String _todayFormatted() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  Future<Uint8List> _buildPdfBytes(AppState state) async {
    final profile = state.activeProfile;
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF6FBFF),
              border: pw.Border.all(color: PdfColor.fromInt(0xFF4FB3FF), width: 6),
              borderRadius: pw.BorderRadius.circular(18),
            ),
            child: pw.Container(
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                border: pw.Border.all(color: PdfColor.fromInt(0xFFFFCA3A), width: 3),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Text(
                        'BABY SHEIN ENGLISH LEARNING',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF4FB3FF),
                          letterSpacing: 2,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'CERTIFICATE OF ACHIEVEMENT',
                        style: pw.TextStyle(
                          fontSize: 32,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF1F2D3D),
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'This certificate is proudly presented to',
                        style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        profile.name,
                        style: pw.TextStyle(
                          fontSize: 40,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFFFF7AA2),
                        ),
                      ),
                      pw.Container(
                        margin: const pw.EdgeInsets.symmetric(vertical: 8),
                        width: 340,
                        height: 2,
                        color: PdfColor.fromInt(0xFFFFCA3A),
                      ),
                      pw.Text(
                        'Award: $_awardTitle (Grade ${profile.grade})',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF1F2D3D),
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Completed ${state.completedLessons.length} Lessons  |  Learned ${state.learnedWordIds.length} Words  |  Earned ${profile.stars} Stars',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColor.fromInt(0xFF38C98F),
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Date: ${_todayFormatted()}',
                              style: const pw.TextStyle(fontSize: 14)),
                          pw.Text('App: Baby Shein Myanmar',
                              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromInt(0xFFFFF6D6),
                          border: pw.Border.all(color: PdfColor.fromInt(0xFFFFCA3A), width: 2),
                          borderRadius: pw.BorderRadius.circular(24),
                        ),
                        child: pw.Text(
                          'GOLD STAR AWARD',
                          style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromInt(0xFF1F2D3D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    return pdf.save();
  }

  Future<void> _printPdf(AppState state) async {
    setState(() => _busy = true);
    try {
      final bytes = await _buildPdfBytes(state);
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sharePdf(AppState state) async {
    setState(() => _busy = true);
    try {
      final bytes = await _buildPdfBytes(state);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/BabyShein_Certificate.pdf');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Baby Shein Certificate for ${state.activeProfile.name}',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.activeProfile;
    const titles = [
      'English Star Learner',
      'Grade 1 English Champion',
      'Grade 2 English Champion',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Certificate • ဂုဏ်ပြုလက်မှတ်')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: titles
                    .map(
                      (t) => ChoiceChip(
                        label: Text(t),
                        selected: _awardTitle == t,
                        onSelected: (_) => setState(() => _awardTitle = t),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),

              // Visual Preview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.skyBlueLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.skyBlue, width: 4),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.sunYellow, width: 3),
                  ),
                  child: Column(
                    children: [
                      const Text('🎓🏆⭐', style: TextStyle(fontSize: 34)),
                      const SizedBox(height: 6),
                      const Text(
                        'BABY SHEIN',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: AppColors.skyBlue,
                        ),
                      ),
                      const Text(
                        'Certificate of Achievement',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                      const Text(
                        'ထူးချွန်ဂုဏ်ပြုလက်မှတ်',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        profile.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: AppColors.softPink,
                        ),
                      ),
                      const Divider(color: AppColors.sunYellow, thickness: 2, height: 20),
                      Text(
                        '$_awardTitle • Grade ${profile.grade}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '⭐ ${profile.stars} Stars  •  📚 ${state.completedLessons.length} Lessons  •  📖 ${state.learnedWordIds.length} Words',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.mintGreen,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Date: ${_todayFormatted()}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              if (_busy)
                const CircularProgressIndicator()
              else
                Row(
                  children: [
                    Expanded(
                      child: BouncyButton(
                        onTap: () => _printPdf(state),
                        color: AppColors.skyBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: const Center(
                          child: Text(
                            '🖨️ Print / Save PDF',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BouncyButton(
                        onTap: () => _sharePdf(state),
                        color: AppColors.mintGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: const Center(
                          child: Text(
                            '📤 Share PDF',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
