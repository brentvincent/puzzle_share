import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_share/puzzle_share.dart';

void main() {
  group('ShareUrlBuilder', () {
    test('always tags src=share', () {
      final url = ShareUrlBuilder.build(
        origin: 'https://ninjoku.com',
        path: '/p/v1:abc',
      );
      expect(url.contains('src=share'), isTrue);
    });

    test('threads channel/puzzleId/userShortId', () {
      final url = ShareUrlBuilder.build(
        origin: 'https://crowns.game',
        path: '/challenge/abc123',
        channel: 'twitter',
        puzzleId: 'P42',
        userShortId: 'u9',
      );
      final uri = Uri.parse(url);
      expect(uri.queryParameters['via'], 'twitter');
      expect(uri.queryParameters['pid'], 'P42');
      expect(uri.queryParameters['u'], 'u9');
    });

    test('appends to an existing query string with &', () {
      final url = ShareUrlBuilder.build(
        origin: 'https://pixdojo.com',
        path: '/challenge/x?h=abc',
        channel: 'native',
      );
      expect(url.contains('?h=abc&'), isTrue);
      expect(url.contains('via=native'), isTrue);
    });

    test('extra params override defaults', () {
      final url = ShareUrlBuilder.build(
        origin: 'https://x.com',
        path: '/p',
        extra: {'utm_campaign': 'launch'},
      );
      expect(url.contains('utm_campaign=launch'), isTrue);
    });

    test('parse returns null when src=share missing', () {
      expect(ShareUrlBuilder.parse('https://ninjoku.com/p/v1:abc'), isNull);
    });

    test('parse extracts the UTM trio', () {
      final tagged = ShareUrlBuilder.build(
        origin: 'https://crowns.game',
        path: '/challenge/abc',
        channel: 'linkedin',
        puzzleId: 'q-7',
        userShortId: 'me',
      );
      final parsed = ShareUrlBuilder.parse(tagged);
      expect(parsed, isNotNull);
      expect(parsed!.channel, 'linkedin');
      expect(parsed.puzzleId, 'q-7');
      expect(parsed.userShortId, 'me');
    });

    test('encodes special chars in puzzleId', () {
      final url = ShareUrlBuilder.build(
        origin: 'https://x.com',
        path: '/p',
        puzzleId: 'a b&c',
      );
      // The literal "a b&c" must NOT appear unencoded in the query.
      final uri = Uri.parse(url);
      expect(uri.queryParameters['pid'], 'a b&c');
    });
  });
}
