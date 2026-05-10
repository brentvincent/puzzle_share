/// Wordle-style 3-emoji-per-row summary grid. Each row encodes one
/// dimension (e.g., time tier, hint count tier, mistake count tier).
///
/// Tiers map to emoji strings:
/// - 3 → 🟩🟩🟩 (best)
/// - 2 → 🟩🟩🟧
/// - 1 → 🟧🟧⬛
/// - 0 → ⬛⬛⬛ (worst)
///
/// Shared across all three games so the visual reads identically in
/// any feed. Spoiler-safe by construction — never encodes solution.
class EmojiGridSummary {
  static const _green = '\u{1F7E9}'; // 🟩
  static const _orange = '\u{1F7E7}'; // 🟧
  static const _black = '\u{2B1B}'; // ⬛
  static const _yellow = '\u{1F7E8}'; // 🟨

  /// Build a single row from a tier 0..3.
  static String renderRow(int tier) {
    switch (tier.clamp(0, 3)) {
      case 3:
        return '$_green$_green$_green';
      case 2:
        return '$_green$_green$_orange';
      case 1:
        return '$_orange$_orange$_black';
      default:
        return '$_black$_black$_black';
    }
  }

  /// Build a multi-row grid joined by newlines.
  static String render(List<int> tiers) =>
      tiers.map(renderRow).join('\n');

  /// Map elapsed seconds → 0..3 tier, given a "par" time (3 stars at
  /// or below par, drops a tier per ~50% over par). Game-agnostic.
  static int starsTier(double elapsedSeconds, double parSeconds) {
    if (elapsedSeconds <= parSeconds) return 3;
    if (elapsedSeconds <= parSeconds * 1.5) return 2;
    if (elapsedSeconds <= parSeconds * 2.5) return 1;
    return 0;
  }

  /// Map hints used → 0..3 tier (0 hints = 3, 1 = 2, 2-3 = 1, 4+ = 0).
  static int hintsTier(int hintsUsed) {
    if (hintsUsed == 0) return 3;
    if (hintsUsed == 1) return 2;
    if (hintsUsed <= 3) return 1;
    return 0;
  }

  /// Map mistakes → 0..3 tier.
  static int mistakesTier(int mistakes) {
    if (mistakes == 0) return 3;
    if (mistakes == 1) return 2;
    if (mistakes <= 3) return 1;
    return 0;
  }

  /// Detect if a string is a valid render of [renderRow] for any tier.
  /// Useful in tests when checking that share text contains a grid.
  static bool isRow(String s) {
    for (int tier = 0; tier <= 3; tier++) {
      if (renderRow(tier) == s) return true;
    }
    return false;
  }

    /// Two-coloured bare row using the secondary palette (yellow). Used
  /// by Pixdojo's region-mastery shares where the warm tones read more
  /// like paint than logic — but uses the same tier scale.
  static String renderRowWarm(int tier) {
    switch (tier.clamp(0, 3)) {
      case 3:
        return '\u{2B50}\u{2B50}\u{2B50}'; // ⭐⭐⭐
      case 2:
        return '\u{2B50}\u{2B50}$_yellow';
      case 1:
        return '$_yellow$_yellow$_black';
      default:
        return '$_black$_black$_black';
    }
  }
}

/// Wordle-style 9×9 emoji grid encoding a completed sudoku solve.
///
/// ⬜ = given clue (pre-filled by the puzzle)
/// 🟦 = player-placed digit (the solver's own work)
/// 🟨 = hint-placed digit (got a nudge here)
///
/// The grid is grouped into 3×3 boxes with a space between box-columns
/// and a blank line between box-rows — mirrors the visual structure of
/// the physical grid so it reads as a sudoku at a glance.
///
/// Example output:
/// ```
/// ⬜🟦🟦 🟦⬜🟦 🟦🟦⬜
/// 🟦🟦⬜ ⬜🟦🟦 🟦⬜🟦
/// 🟦⬜🟦 🟦🟦⬜ ⬜🟦🟦
///
/// 🟦⬜🟦 ⬜🟦🟦 🟦🟦⬜
/// ...
/// ```
class SudokuEmojiGrid {
  static const _given = '\u{2B1C}';  // ⬜  pre-filled clue
  static const _player = '\u{1F7E6}'; // 🟦  player solved
  static const _hint = '\u{1F7E8}';  // 🟨  hint placed

  /// Build the emoji string from flat lists of booleans.
  ///
  /// [gridSize] — 4, 6, or 9.
  /// [isGiven]  — row-major flat list of length gridSize².
  /// [isHint]   — row-major flat list of length gridSize² (may be all false).
  ///
  /// For non-9×9 grids (4×4 / 6×6) the box-grouping adapts automatically:
  /// 4×4 → 2×2 boxes, 6×6 → 2×3 boxes.
  static String build({
    required int gridSize,
    required List<bool> isGiven,
    required List<bool> isHint,
  }) {
    assert(isGiven.length == gridSize * gridSize);
    assert(isHint.length == gridSize * gridSize);

    final boxRows = gridSize == 4 ? 2 : gridSize == 6 ? 2 : 3;
    final boxCols = gridSize ~/ boxRows;
    final rows = <String>[];

    for (int r = 0; r < gridSize; r++) {
      if (r > 0 && r % boxRows == 0) rows.add(''); // blank line between box-rows
      final cols = <String>[];
      for (int c = 0; c < gridSize; c++) {
        if (c > 0 && c % boxCols == 0) cols.add(' '); // space between box-cols
        final idx = r * gridSize + c;
        if (isGiven[idx]) {
          cols.add(_given);
        } else if (isHint[idx]) {
          cols.add(_hint);
        } else {
          cols.add(_player);
        }
      }
      rows.add(cols.join(''));
    }

    return rows.join('\n');
  }
}
