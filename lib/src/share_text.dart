/// Canonical share-text template shared across all three games.
///
/// Format:
/// ```
/// {brand} 🏆 {stars}
/// {difficulty} · {time} · {hints}{maybeStreak}
/// {emojiGrid}
/// {url}
/// ```
///
/// Game-specific variation is parameterised; the structure stays
/// identical so feed previews look like a family.
class ShareTextTemplate {
  static const _trophy = '\u{1F3C6}'; // 🏆
  static const _star = '\u{2B50}'; // ⭐
  static const _fire = '\u{1F525}'; // 🔥

  /// Build the standard share text.
  static String standard({
    required String brand,
    required int stars,
    String? difficulty,
    Duration? elapsed,
    int? hintsUsed,
    int? streakDays,
    String? emojiGrid,
    required String url,
  }) {
    final starString = _star * stars.clamp(0, 5);
    final headerLine = '$brand $_trophy $starString';

    final segments = <String>[];
    if (difficulty != null) segments.add(difficulty);
    if (elapsed != null) segments.add(formatElapsed(elapsed));
    if (hintsUsed != null) {
      segments.add(hintsUsed == 0 ? '0 hints' : '$hintsUsed hint${hintsUsed == 1 ? '' : 's'}');
    }
    final statsLine = segments.join(' · ');

    final streakLine = (streakDays != null && streakDays > 1)
        ? '\n$_fire $streakDays-day streak'
        : '';

    final body = [
      if (statsLine.isNotEmpty) '$statsLine$streakLine'
      else if (streakLine.isNotEmpty) streakLine.trimLeft(),
      if (emojiGrid != null && emojiGrid.isNotEmpty) emojiGrid,
      url,
    ].join('\n');

    return '$headerLine\n$body';
  }

  /// Format a [Duration] as `MM:SS` (or `H:MM:SS` if ≥ 1h).
  static String formatElapsed(Duration d) {
    final totalSeconds = d.inSeconds;
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    String pad(int n) => n.toString().padLeft(2, '0');
    if (h > 0) return '${pad(h)}:${pad(m)}:${pad(s)}';
    return '${pad(m)}:${pad(s)}';
  }
}
