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
}
