import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncy_button.dart';

class _DrawnStroke {
  final List<Offset> points;
  final Color color;
  _DrawnStroke(this.points, this.color);
}

class WritingScreen extends StatefulWidget {
  final String? initialLetter;

  const WritingScreen({super.key, this.initialLetter});

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  final List<String> _alphabet = List.generate(26, (i) => String.fromCharCode(65 + i));
  int _letterIndex = 0;
  bool _uppercase = true;
  bool _showDottedGuide = true;
  bool _showSolidExample = false;
  Color _selectedColor = AppColors.skyBlue;

  final List<_DrawnStroke> _strokes = [];
  _DrawnStroke? _activeStroke;

  String get _displayLetter {
    final ch = _alphabet[_letterIndex];
    return _uppercase ? ch : ch.toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialLetter != null && widget.initialLetter!.isNotEmpty) {
      final idx = _alphabet.indexOf(widget.initialLetter!.toUpperCase());
      if (idx >= 0) _letterIndex = idx;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakCurrent());
  }

  void _speakCurrent() {
    final letter = _alphabet[_letterIndex];
    context.read<AppState>().audio.speak(
          text: letter,
          audioKey: 'g1_alpha_${letter.toLowerCase()}',
        );
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _activeStroke = null;
    });
  }

  void _selectLetter(int index) {
    setState(() {
      _letterIndex = index;
      _strokes.clear();
      _activeStroke = null;
    });
    _speakCurrent();
  }

  @override
  Widget build(BuildContext context) {
    const colors = [
      AppColors.skyBlue,
      AppColors.softPink,
      AppColors.mintGreen,
      AppColors.lavender,
      AppColors.peach,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Writing Practice • လက်ရေးလေ့ကျင့်ရန်'),
        actions: [
          IconButton(
            onPressed: _speakCurrent,
            icon: const Icon(Icons.volume_up_rounded),
            tooltip: 'Listen',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Uppercase / Lowercase & Guide Toggles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text('ABC (အကြီး)')),
                        ButtonSegment(value: false, label: Text('abc (အသေး)')),
                      ],
                      selected: {_uppercase},
                      onSelectionChanged: (s) {
                        setState(() {
                          _uppercase = s.first;
                          _strokes.clear();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Toggle chips for Dotted Guide & Example Letter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilterChip(
                    label: const Text('Dotted Guide • အစက်လမ်းကြောင်း'),
                    selected: _showDottedGuide,
                    onSelected: (v) => setState(() => _showDottedGuide = v),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Example • နမူနာ'),
                    selected: _showSolidExample,
                    onSelected: (v) => setState(() => _showSolidExample = v),
                  ),
                ],
              ),
            ),

            // Letter selector strip
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                itemCount: _alphabet.length,
                itemBuilder: (_, i) {
                  final label = _uppercase ? _alphabet[i] : _alphabet[i].toLowerCase();
                  final selected = i == _letterIndex;
                  return GestureDetector(
                    onTap: () => _selectLetter(i),
                    child: Container(
                      width: 40,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.skyBlue : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? AppColors.skyBlue : AppColors.border,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: selected ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Touchscreen Drawing Canvas
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.skyBlue, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.skyBlue.withAlpha(40),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: GestureDetector(
                    onPanStart: (details) {
                      setState(() {
                        _activeStroke = _DrawnStroke(
                          [details.localPosition],
                          _selectedColor,
                        );
                        _strokes.add(_activeStroke!);
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        _activeStroke?.points.add(details.localPosition);
                      });
                    },
                    onPanEnd: (_) => _activeStroke = null,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _LetterTracePainter(
                        letter: _displayLetter,
                        showDottedGuide: _showDottedGuide,
                        showSolidExample: _showSolidExample,
                        strokes: _strokes,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Crayon Colors & Clear / Next Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: colors.map((c) {
                      final active = _selectedColor == c;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = c),
                        child: Container(
                          width: active ? 36 : 30,
                          height: active ? 36 : 30,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: active ? AppColors.textDark : Colors.white,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: BouncyButton(
                          onTap: _clearCanvas,
                          color: AppColors.softPinkLight,
                          border: Border.all(color: AppColors.softPink, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Center(
                            child: Text(
                              '🧹 Clear • ဖျက်မယ်',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: BouncyButton(
                          onTap: () {
                            if (_strokes.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Draw the letter with your finger first! လက်ချောင်းနဲ့ အရင်ရေးကြည့်ပါ'),
                                ),
                              );
                              return;
                            }
                            _speakCurrent();
                            _selectLetter((_letterIndex + 1) % _alphabet.length);
                          },
                          color: AppColors.mintGreen,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Center(
                            child: Text(
                              'Next Letter ▶',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LetterTracePainter extends CustomPainter {
  final String letter;
  final bool showDottedGuide;
  final bool showSolidExample;
  final List<_DrawnStroke> strokes;

  _LetterTracePainter({
    required this.letter,
    required this.showDottedGuide,
    required this.showSolidExample,
    required this.strokes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Primary school handwriting guide lines
    final linePaint = Paint()
      ..color = AppColors.skyBlue.withAlpha(75)
      ..strokeWidth = 1.6;
    final topY = size.height * 0.24;
    final midY = size.height * 0.50;
    final baseY = size.height * 0.76;

    canvas.drawLine(Offset(18, topY), Offset(size.width - 18, topY), linePaint);
    canvas.drawLine(Offset(18, baseY), Offset(size.width - 18, baseY), linePaint);

    // Dashed midline
    double x = 18;
    while (x < size.width - 18) {
      canvas.drawLine(Offset(x, midY), Offset((x + 10).clamp(0, size.width - 18), midY), linePaint);
      x += 18;
    }

    final fontSize = size.height * 0.62;

    // 2. Optional solid example letter
    if (showSolidExample) {
      final solidPainter = TextPainter(
        text: TextSpan(
          text: letter,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: AppColors.sunYellow.withAlpha(110),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      solidPainter.paint(
        canvas,
        Offset(
          (size.width - solidPainter.width) / 2,
          (size.height - solidPainter.height) / 2,
        ),
      );
    }

    // 3. Dotted / Hollow tracing guide letter
    if (showDottedGuide) {
      final outlinePainter = TextPainter(
        text: TextSpan(
          text: letter,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.2
              ..color = AppColors.textMuted.withAlpha(115),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final offset = Offset(
        (size.width - outlinePainter.width) / 2,
        (size.height - outlinePainter.height) / 2,
      );
      outlinePainter.paint(canvas, offset);

      // Subtle white dash mask creates dotted tracing outline
      final maskPaint = Paint()
        ..color = Colors.white.withAlpha(185)
        ..strokeWidth = 2.6;
      for (double dy = offset.dy; dy < offset.dy + outlinePainter.height; dy += 11) {
        canvas.drawLine(
          Offset(offset.dx, dy),
          Offset(offset.dx + outlinePainter.width, dy),
          maskPaint,
        );
      }
    }

    // 4. Child's finger strokes
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(stroke.points.first, 7, paint..style = PaintingStyle.fill);
      } else {
        final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LetterTracePainter oldDelegate) => true;
}
