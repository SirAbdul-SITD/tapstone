import 'package:flutter/material.dart';
import '../models/puzzle.dart';
import '../services/palette.dart';

/// Cell state: 0 = unknown, 1 = shaded, 2 = marked white (X, not shaded)
class BoardPainter extends CustomPainter {
  final Puzzle puzzle;
  final List<List<int>> state;
  final Set<String> badCells;

  BoardPainter({
    required this.puzzle,
    required this.state,
    required this.badCells,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final h = puzzle.h, w = puzzle.w;
    final cell = size.width / w;

    for (int r = 0; r < h; r++) {
      for (int c = 0; c < w; c++) {
        final rect = Rect.fromLTWH(c * cell, r * cell, cell, cell);
        final isClue = puzzle.isClue(r, c);
        final s = state[r][c];
        final isBad = badCells.contains('$r,$c');
        Color fill;
        if (isBad) {
          fill = Palette.conflictFill;
        } else if (isClue) {
          fill = Palette.clueFill;
        } else if (s == 1) {
          fill = Palette.shadedFill;
        } else {
          fill = Palette.board;
        }
        canvas.drawRect(rect, Paint()..color = fill);

        if (!isClue && s == 2) {
          final mid = rect.center;
          final p = Paint()
            ..color = Palette.haze.withValues(alpha: 0.7)
            ..strokeWidth = cell * 0.045
            ..strokeCap = StrokeCap.round;
          final sz = cell * 0.14;
          canvas.drawLine(mid + Offset(-sz, -sz), mid + Offset(sz, sz), p);
          canvas.drawLine(mid + Offset(-sz, sz), mid + Offset(sz, -sz), p);
        }
      }
    }

    final gridPaint = Paint()
      ..color = Palette.line
      ..strokeWidth = 1;
    for (int r = 0; r <= h; r++) {
      canvas.drawLine(
          Offset(0, r * cell), Offset(size.width, r * cell), gridPaint);
    }
    for (int c = 0; c <= w; c++) {
      canvas.drawLine(
          Offset(c * cell, 0), Offset(c * cell, size.height), gridPaint);
    }
    canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..color = Palette.haze.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    for (int r = 0; r < h; r++) {
      for (int c = 0; c < w; c++) {
        final nums = puzzle.clues[r][c];
        if (nums.isNotEmpty) {
          final center = Offset((c + 0.5) * cell, (r + 0.5) * cell);
          final text = nums.join(' ');
          final tp = TextPainter(
            text: TextSpan(
                text: text,
                style: TextStyle(
                    color: Palette.cyan,
                    fontSize: cell * (nums.length > 1 ? 0.30 : 0.40),
                    fontWeight: FontWeight.w700)),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          )..layout(maxWidth: cell * 0.92);
          tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter old) =>
      old.state != state || old.badCells != badCells || old.puzzle != puzzle;
}
