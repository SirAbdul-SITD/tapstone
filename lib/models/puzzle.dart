class Puzzle {
  final int id;
  final String tier;
  final int h;
  final int w;
  final List<List<List<int>>> clues; // empty list = not a clue, else run-tuple
  final List<List<bool>> solution; // true = shaded

  Puzzle({
    required this.id,
    required this.tier,
    required this.h,
    required this.w,
    required this.clues,
    required this.solution,
  });

  factory Puzzle.fromJson(Map<String, dynamic> j) {
    final h = j['h'] as int;
    final w = j['w'] as int;
    final clStrs = (j['clues'] as List).map((e) => e as String).toList();
    final sol = (j['solution'] as List).map((e) => e as int).toList();
    final clues = List.generate(h, (r) {
      return List.generate(w, (c) {
        final s = clStrs[r * w + c];
        if (s.isEmpty) return <int>[];
        return s.split(',').map(int.parse).toList();
      });
    });
    return Puzzle(
      id: j['id'] as int,
      tier: j['tier'] as String,
      h: h,
      w: w,
      clues: clues,
      solution:
          List.generate(h, (r) => List.generate(w, (c) => sol[r * w + c] == 1)),
    );
  }

  bool isClue(int r, int c) => clues[r][c].isNotEmpty;

  int get clueCount {
    int n = 0;
    for (final row in clues) {
      for (final v in row) {
        if (v.isNotEmpty) n++;
      }
    }
    return n;
  }
}
