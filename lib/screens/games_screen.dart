import 'dart:math';
import 'package:flutter/material.dart';
import '../models/app_models.dart';

class GamesScreen extends StatefulWidget {
  final AppStateController state;
  final VoidCallback onChanged;

  const GamesScreen({super.key, required this.state, required this.onChanged});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _wheelCtrl;
  double _currentAngle = 0;
  double _targetAngle = 0;
  String? _wheelResult;

  bool _scratched = false;
  String? _scratchPrize;

  final List<Offset?> _scratchPoints = [];

  @override
  void initState() {
    super.initState();
    _wheelCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _wheelCtrl.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_wheelCtrl.isAnimating) return;
    if (widget.state.freeSpinsLeft > 0) {
      widget.state.freeSpinsLeft -= 1;
    } else if (widget.state.points >= 30) {
      widget.state.points -= 30;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تحتاج إلى 30 نقطة أو دورة مجانية')),
      );
      return;
    }

    final prizes = [1.5, 5.0, 2.0, 10.0, 0.5, 3.0];
    final idx = Random().nextInt(prizes.length);
    final won = prizes[idx];
    _currentAngle = _targetAngle;
    _targetAngle = _currentAngle + (pi * 8) + (idx * (2 * pi / prizes.length));

    _wheelCtrl.forward(from: 0).then((_) {
      widget.state.balanceEgp += won;
      widget.onChanged();
      setState(() => _wheelResult = 'مبروك! ربحت ${won.toStringAsFixed(2)} ج.م.');
    });
  }

  void _newScratchCard() {
    if (widget.state.freeScratchesLeft > 0) {
      widget.state.freeScratchesLeft -= 1;
    } else if (widget.state.points >= 25) {
      widget.state.points -= 25;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تحتاج إلى 25 نقطة لبطاقة جديدة')),
      );
      return;
    }
    setState(() {
      _scratchPoints.clear();
      _scratched = false;
      final won = [2.5, 5.0, 7.5, 10.0][Random().nextInt(4)];
      _scratchPrize = '${won.toStringAsFixed(2)} ج.م.';
      widget.state.balanceEgp += won;
      widget.onChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    final angle = Tween<double>(begin: _currentAngle, end: _targetAngle)
        .animate(CurvedAnimation(parent: _wheelCtrl, curve: Curves.easeOutCubic))
        .value;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: const Color(0xFFFAF5D8), borderRadius: BorderRadius.circular(24)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('نقاطك: ${widget.state.points}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF5B0E5B)),
                onPressed: widget.state.points >= 100
                    ? () {
                        widget.state.points -= 100;
                        widget.state.balanceEgp += 2.0;
                        widget.onChanged();
                      }
                    : null,
                child: const Text('حول 100 نقطة = 2 ج.م.'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // عجلة الحظ
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFFEFECEF), borderRadius: BorderRadius.circular(24)),
          child: Column(
            children: [
              const Text('عجلة الحظ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Transform.rotate(
                angle: angle,
                child: CustomPaint(
                  size: const Size(210, 210),
                  painter: _WheelPainter(),
                ),
              ),
              if (_wheelResult != null) ...[
                const SizedBox(height: 12),
                Text(_wheelResult!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5B0E5B))),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF5B0E5B)),
                  onPressed: _spinWheel,
                  child: Text(widget.state.freeSpinsLeft > 0 ? 'أدر العجلة مجانًا' : 'أدر العجلة (30 نقطة)'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // بطاقة الخربش
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFFEFECEF), borderRadius: BorderRadius.circular(24)),
          child: Column(
            children: [
              const Text('بطاقة الخربش', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _scratchPoints.add(details.localPosition);
                    if (_scratchPoints.length > 22) _scratched = true;
                  });
                },
                onPanEnd: (_) => _scratchPoints.add(null),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF5D8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        _scratchPrize ?? 'اضغط على بطاقة جديدة بالأسفل',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF5B0E5B)),
                      ),
                      if (_scratchPrize != null && !_scratched)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            color: const Color(0xFF5B0E5B),
                            alignment: Alignment.center,
                            child: const Text('اخربش هنا بإصبعك', style: TextStyle(color: Color(0xFFFAF5D8), fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF5B0E5B)),
                  onPressed: _newScratchCard,
                  child: Text(widget.state.freeScratchesLeft > 0 ? 'احصل على بطاقة مجانية' : 'بطاقة جديدة (25 نقطة)'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFF5B0E5B),
      const Color(0xFFFAF5D8),
      const Color(0xFFF4C400),
      const Color(0xFFE3DEE5),
      const Color(0xFF7A1C7A),
      const Color(0xFFF8CE10),
    ];
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final sweep = (2 * pi) / colors.length;
    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()..color = colors[i];
      canvas.drawArc(rect, i * sweep, sweep, true, paint);
    }
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 18, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
