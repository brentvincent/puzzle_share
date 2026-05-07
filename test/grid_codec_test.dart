import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_share/puzzle_share.dart';

void main() {
  List<List<int>> randomGrid(int size, int seed) {
    var s = seed;
    int next() {
      s = (s * 1103515245 + 12345) & 0x7fffffff;
      return s;
    }
    return [
      for (int r = 0; r < size; r++)
        [for (int c = 0; c < size; c++) next() % 10],
    ];
  }

  group('GridCodec v1 (9x9)', () {
    test('round-trips an empty board', () {
      final empty = [for (int r = 0; r < 9; r++) List.filled(9, 0)];
      final token = GridCodec.encode(empty);
      expect(token, startsWith('v1:'));
      final back = GridCodec.decode(token);
      expect(back, equals(empty));
    });

    test('round-trips full 9x9 boards across many seeds', () {
      for (final seed in [1, 7, 42, 99, 1000]) {
        final grid = randomGrid(9, seed);
        final token = GridCodec.encode(grid);
        final back = GridCodec.decode(token);
        expect(back, equals(grid), reason: 'seed=$seed');
      }
    });

    test('output is URL-safe and short', () {
      final grid = randomGrid(9, 42);
      final token = GridCodec.encode(grid);
      expect(token.length, lessThan(70));
      expect(RegExp(r'^[A-Za-z0-9_:.-]+$').hasMatch(token), isTrue);
    });
  });

  group('GridCodec sized (Crowns)', () {
    test('encodes and decodes 8x8 with explicit size', () {
      final g = randomGrid(8, 7);
      final token = GridCodec.encodeSized(g);
      expect(token, startsWith('v1.8.'));
      expect(GridCodec.isSizedToken(token), isTrue);
      expect(GridCodec.decode(token), equals(g));
    });

    test('encodes and decodes 5x5', () {
      final g = randomGrid(5, 100);
      final token = GridCodec.encodeSized(g);
      expect(token, startsWith('v1.5.'));
      expect(GridCodec.decode(token), equals(g));
    });

    test('rejects bad size annotation', () {
      expect(() => GridCodec.decode('v1.999.AAA'), throwsFormatException);
      expect(() => GridCodec.decode('v1.x.AAA'), throwsFormatException);
    });
  });

  group('GridCodec v2 (progress)', () {
    test('round-trips givens + current', () {
      final givens = randomGrid(9, 1);
      final current = randomGrid(9, 2);
      final token = GridCodec.encodeWithProgress(givens, current);
      expect(token, startsWith('v2:'));
      expect(GridCodec.isProgressToken(token), isTrue);
      final decoded = GridCodec.decodeWithProgress(token);
      expect(decoded.givens, equals(givens));
      expect(decoded.current, equals(current));
    });

    test('decodeWithProgress rejects v1 tokens', () {
      final v1 = GridCodec.encode(randomGrid(9, 5));
      expect(() => GridCodec.decodeWithProgress(v1), throwsFormatException);
    });
  });

  group('GridCodec rejection cases', () {
    test('decode rejects malformed input', () {
      expect(() => GridCodec.decode('garbage'), throwsFormatException);
      expect(() => GridCodec.decode('v3:abc'), throwsFormatException);
      expect(() => GridCodec.decode('v1:'), throwsFormatException);
    });
  });
}
