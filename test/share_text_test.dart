import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_share/puzzle_share.dart';

void main() {
  group('ShareTextTemplate', () {
    test('formatElapsed handles minutes', () {
      expect(ShareTextTemplate.formatElapsed(const Duration(seconds: 7)),
          '00:07');
      expect(ShareTextTemplate.formatElapsed(const Duration(minutes: 1, seconds: 30)),
          '01:30');
    });

    test('formatElapsed handles hours', () {
      expect(
        ShareTextTemplate.formatElapsed(const Duration(hours: 1, minutes: 5, seconds: 9)),
        '01:05:09',
      );
    });

    test('standard template produces 4-line output', () {
      final out = ShareTextTemplate.standard(
        brand: 'Ninjoku',
        stars: 3,
        difficulty: 'Hard',
        elapsed: const Duration(minutes: 4, seconds: 12),
        hintsUsed: 0,
        emojiGrid: '\u{1F7E9}\u{1F7E9}\u{1F7E9}',
        url: 'https://ninjoku.com/p/v1:abc',
      );
      final lines = out.split('\n');
      expect(lines.first, 'Ninjoku \u{1F3C6} \u{2B50}\u{2B50}\u{2B50}');
      expect(lines[1], 'Hard · 04:12 · 0 hints');
      expect(lines.last, 'https://ninjoku.com/p/v1:abc');
    });

    test('streak appends a line with fire emoji', () {
      final out = ShareTextTemplate.standard(
        brand: 'Crowns',
        stars: 2,
        difficulty: 'Daily',
        elapsed: const Duration(seconds: 35),
        hintsUsed: 1,
        streakDays: 7,
        emojiGrid: '\u{1F7E9}\u{1F7E9}\u{1F7E7}',
        url: 'https://crowns.game/daily/2026-05-07',
      );
      expect(out.contains('\u{1F525} 7-day streak'), isTrue);
    });

    test('singular vs plural hint suffix', () {
      final one = ShareTextTemplate.standard(
        brand: 'X',
        stars: 1,
        elapsed: const Duration(seconds: 60),
        hintsUsed: 1,
        url: 'https://x.com',
      );
      final two = ShareTextTemplate.standard(
        brand: 'X',
        stars: 1,
        elapsed: const Duration(seconds: 60),
        hintsUsed: 2,
        url: 'https://x.com',
      );
      expect(one.contains('1 hint'), isTrue);
      expect(one.contains('1 hints'), isFalse);
      expect(two.contains('2 hints'), isTrue);
    });

    test('omits stats line when nothing supplied', () {
      final out = ShareTextTemplate.standard(
        brand: 'Pixdojo',
        stars: 3,
        url: 'https://pixdojo.com/r/forest',
      );
      expect(out.contains('Pixdojo'), isTrue);
      expect(out.split('\n').length, 2);
    });
  });
}
