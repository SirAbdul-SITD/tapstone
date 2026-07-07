import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/puzzle.dart';
import '../painters/board_painter.dart';
import '../services/palette.dart';
import '../services/progress_service.dart';
import '../services/settings_service.dart';
import '../services/audio_manager.dart';

class GameScreen extends StatefulWidget {
  final Puzzle puzzle;
  final AudioManager audio;
  final VoidCallback? onNext;
  const GameScreen({
    super.key,
    required this.puzzle,
    required this.audio,
    this.onNext,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<List<int>> state;
  bool won = false;
  int moves = 0;

  int get _h => widget.puzzle.h;
  int get _w => widget.puzzle.w;

  @override
  void initState() {
    super.initState();
    state = List.generate(_h, (_) => List.filled(_w, 0));
  }

  void _haptic() {
    if (context.read<SettingsService>().haptics) {
      HapticFeedback.selectionClick();
    }
  }

  void _onTap(int r, int c) {
    if (won) return;
    if (widget.puzzle.isClue(r, c)) return;
    setState(() {
      state[r][c] = (state[r][c] + 1) % 3;
      moves++;
    });
    final v = state[r][c];
    if (v == 1) {
      widget.audio.shade();
    } else if (v == 2) {
      widget.audio.mark();
    } else {
      widget.audio.clear();
    }
    _haptic();
    _checkWin();
  }

  Set<String> _badCells() {
    final out = <String>{};
    for (int r = 0; r < _h - 1; r++) {
      for (int c = 0; c < _w - 1; c++) {
        if (state[r][c] == 1 &&
            state[r + 1][c] == 1 &&
            state[r][c + 1] == 1 &&
            state[r + 1][c + 1] == 1) {
          out.add('$r,$c');
          out.add('${r + 1},$c');
          out.add('$r,${c + 1}');
          out.add('${r + 1},${c + 1}');
        }
      }
    }
    return out;
  }

  void _checkWin() {
    final p = widget.puzzle;
    for (int r = 0; r < _h; r++) {
      for (int c = 0; c < _w; c++) {
        if (!p.isClue(r, c) && state[r][c] == 0) return;
      }
    }
    bool match = true;
    for (int r = 0; r < _h && match; r++) {
      for (int c = 0; c < _w; c++) {
        if (p.isClue(r, c)) continue;
        final want = p.solution[r][c];
        final got = state[r][c] == 1;
        if (want != got) {
          match = false;
          break;
        }
      }
    }
    if (match) {
      won = true;
      widget.audio.win();
      final stars = _starRating();
      context.read<ProgressService>().recordWin(p.id, stars);
      Future.delayed(const Duration(milliseconds: 300), _showWinSheet);
    }
  }

  int _starRating() {
    final blanks = _h * _w - widget.puzzle.clueCount;
    if (moves <= blanks) return 3;
    if (moves <= (blanks * 1.5).round()) return 2;
    return 1;
  }

  void _showWinSheet() {
    final stars = _starRating();
    showModalBottomSheet(
      context: context,
      backgroundColor: Palette.panel,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tablet Cleared',
                style: TextStyle(
                    color: Palette.chalk,
                    fontSize: 24,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    i < stars ? Icons.star : Icons.star_border,
                    color: i < stars ? Palette.amber : Palette.haze,
                    size: 44,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('Solved in $moves taps',
                style: const TextStyle(color: Palette.haze, fontSize: 14)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Palette.chalk,
                      side: const BorderSide(color: Palette.line),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Levels'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.cyan,
                      foregroundColor: Palette.slate,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      widget.onNext?.call();
                    },
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _reset() {
    setState(() {
      state = List.generate(_h, (_) => List.filled(_w, 0));
      moves = 0;
      won = false;
    });
    widget.audio.tap();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.puzzle;
    final badCells = _badCells();
    return Scaffold(
      backgroundColor: Palette.slate,
      appBar: AppBar(
        backgroundColor: Palette.slate,
        elevation: 0,
        foregroundColor: Palette.chalk,
        title: Text('Level ${p.id + 1}',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reset),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Tap to shade cells into one connected shape (no 2×2 block). '
                'Each clue\'s numbers are the lengths of shaded runs touching '
                'it, read clockwise.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Palette.haze.withValues(alpha: 0.9),
                    fontSize: 12.5,
                    height: 1.4),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Center(
                child: LayoutBuilder(builder: (context, cons) {
                  final side = (cons.maxWidth < cons.maxHeight
                          ? cons.maxWidth
                          : cons.maxHeight) -
                      32;
                  final cell = side / _w;
                  return GestureDetector(
                    onTapUp: (d) {
                      final c = (d.localPosition.dx / cell)
                          .floor()
                          .clamp(0, _w - 1);
                      final r = (d.localPosition.dy / cell)
                          .floor()
                          .clamp(0, _h - 1);
                      _onTap(r, c);
                    },
                    child: CustomPaint(
                      size: Size(side, side),
                      painter: BoardPainter(
                        puzzle: p,
                        state: state,
                        badCells: badCells,
                      ),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Taps: $moves',
                      style: const TextStyle(color: Palette.haze, fontSize: 14)),
                  Text(p.tier.toUpperCase(),
                      style: TextStyle(
                          color: Palette.tierColors[p.tier],
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
