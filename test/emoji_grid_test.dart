import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_share/puzzle_share.dart';

void main() {
  group('EmojiGridSummary', () {
    test('renderRow produces 3 emoji per tier', () {
      for (int t = 0; t <= 3; t++) {
        final row = EmojiGridSummary.renderRow(t);
        expect(row.runes.length, 3, reason: 'tier=$t');
      }
    });

    test('tier 3 is all green, tier 0 is all black', () {
      expect(EmojiGridSummary.renderRow(3), '\u{1F7E9}\u{1F7E9}\u{1F7E9}');
      expect(EmojiGridSummary.renderRow(0), '\u{2B1B}\u{2B1B}\u{2B1B}');
    });

    test('clamps out-of-range tiers', () {
      expect(EmojiGridSummary.renderRow(99), EmojiGridSummary.renderRow(3));
      expect(EmojiGridSummary.renderRow(-5), EmojiGridSummary.renderRow(0));
    });

    test('render joins multiple rows with newlines', () {
      final out = EmojiGridSummary.render([3, 2, 1]);
      expect(out.split('\n').length, 3);
    });

    test('isRow recognises every valid render', () {
      for (int t = 0; t <= 3; t++) {
        expect(EmojiGridSummary.isRow(EmojiGridSummary.renderRow(t)), isTrue);
      }
      expect(EmojiGridSummary.isRow('not a row'), isFalse);
    });

    test('starsTier maps elapsed time to 0..3', () {
      expect(EmojiGridSummary.starsTier(60, 120), 3); // under par
      expect(EmojiGridSummary.starsTier(120, 120), 3); // at par
      expect(EmojiGridSummary.starsTier(170, 120), 2); // 1.4× par
      expect(EmojiGridSummary.starsTier(280, 120), 1); // 2.3× par
      expect(EmojiGridSummary.starsTier(500, 120), 0); // 4× par
    });

    test('hintsTier maps hint count to 0..3', () {
      expect(EmojiGridSummary.hintsTier(0), 3);
      expect(EmojiGridSummary.hintsTier(1), 2);
      expect(EmojiGridSummary.hintsTier(2), 1);
      expect(EmojiGridSummary.hintsTier(3), 1);
      expect(EmojiGridSummary.hintsTier(10), 0);
    });

    test('mistakesTier maps mistake count to 0..3', () {
      expect(EmojiGridSummary.mistakesTier(0), 3);
      expect(EmojiGridSummary.mistakesTier(1), 2);
      expect(EmojiGridSummary.mistakesTier(2), 1);
      expect(EmojiGridSummary.mistakesTier(5), 0);
    });

    test('renderRowWarm uses warm palette', () {
      final r3 = EmojiGridSummary.renderRowWarm(3);
      expect(r3.contains('\u{2B50}'), isTrue);
      expect(r3.contains('\u{1F7E9}'), isFalse);
    });
  });

  group('SudokuEmojiGrid', () {
    const given = '\u{2B1C}';  // ⬜
    const player = '\u{1F7E6}'; // 🟦
    const hint = '\u{1F7E8}';  // 🟨

    // Helper: build a 9×9 grid with all-given except [hintIdx] as hint
    // and [playerIdx..] as player.
    List<bool> _flat9(List<int> givenIdxs, [List<int> hintIdxs = const []]) {
      return List.generate(81, (i) => givenIdxs.contains(i) || hintIdxs.contains(i))
          .map((_) => false).toList(); // will be overridden below
    }

    test('all-given 9×9 grid uses ⬜ for every cell', () {
      final out = SudokuEmojiGrid.build(
        gridSize: 9,
        isGiven: List.filled(81, true),
        isHint: List.filled(81, false),
      );
      expect(out.replaceAll(given, '').replaceAll('\n', '').replaceAll(' ', ''), isEmpty);
    });

    test('all-player 9×9 grid uses 🟦 for every cell', () {
      final out = SudokuEmojiGrid.build(
        gridSize: 9,
        isGiven: List.filled(81, false),
        isHint: List.filled(81, false),
      );
      expect(out.replaceAll(player, '').replaceAll('\n', '').replaceAll(' ', ''), isEmpty);
    });

    test('hint cells use 🟨', () {
      final isHint = List.filled(81, false);
      isHint[0] = true; // R0C0
      final out = SudokuEmojiGrid.build(
        gridSize: 9,
        isGiven: List.filled(81, false),
        isHint: isHint,
      );
      expect(out.substring(0, hint.length), hint,
          reason: 'first cell should be 🟨');
    });

    test('9×9 grid has 9 box-rows and 2 blank-line separators', () {
      final out = SudokuEmojiGrid.build(
        gridSize: 9,
        isGiven: List.filled(81, false),
        isHint: List.filled(81, false),
      );
      final lines = out.split('\n');
      final dataLines = lines.where((l) => l.isNotEmpty).length;
      final blankLines = lines.where((l) => l.isEmpty).length;
      expect(dataLines, 9, reason: 'nine data rows');
      expect(blankLines, 2, reason: 'two blank lines between box-rows');
    });

    test('each data row has two space separators for 3×3 boxes', () {
      final out = SudokuEmojiGrid.build(
        gridSize: 9,
        isGiven: List.filled(81, false),
        isHint: List.filled(81, false),
      );
      for (final line in out.split('\n').where((l) => l.isNotEmpty)) {
        // Each row: [3 emoji][space][3 emoji][space][3 emoji]
        final spaces = ' '.allMatches(line).length;
        expect(spaces, 2, reason: 'two spaces per row (box separators)');
      }
    });

    test('4×4 grid encodes 16 cells in 4 data rows with 1 blank separator', () {
      final out = SudokuEmojiGrid.build(
        gridSize: 4,
        isGiven: List.filled(16, false),
        isHint: List.filled(16, false),
      );
      final lines = out.split('\n');
      expect(lines.where((l) => l.isNotEmpty).length, 4);
      expect(lines.where((l) => l.isEmpty).length, 1);
    });
  });
}
