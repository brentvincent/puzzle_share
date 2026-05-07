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
