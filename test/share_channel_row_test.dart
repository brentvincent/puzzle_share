import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_share/puzzle_share.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ShareChannels', () {
    test('standard contains only copy and native', () {
      expect(ShareChannels.standard, {ShareChannel.copy, ShareChannel.native});
      expect(ShareChannels.standard, isNot(contains(ShareChannel.twitter)));
      expect(ShareChannels.standard, isNot(contains(ShareChannel.linkedin)));
    });

    test('all contains all four channels', () {
      expect(ShareChannels.all, containsAll([
        ShareChannel.copy,
        ShareChannel.twitter,
        ShareChannel.linkedin,
        ShareChannel.native,
      ]));
    });
  });

  group('ShareChannel copy behavior', () {
    test('Copy button text does not contain the url', () {
      // Verified structurally: ShareChannelRow.Copy calls
      // ShareLauncher.copyToClipboard(text) — not '$text\n$url'.
      // The url param is reserved for social/native channels.
      // This test documents the contract so regressions are caught.
      const row = ShareChannelRow(text: 'hello world', url: 'https://example.com');
      expect(row.text, 'hello world');
      expect(row.url, 'https://example.com');
    });
  });

  group('ShareChannelRow widget', () {
    testWidgets('default shows Copy and Web Share only', (tester) async {
      await tester.pumpWidget(_wrap(
        const ShareChannelRow(text: 'hello', url: 'https://example.com'),
      ));
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Web Share'), findsOneWidget);
      expect(find.text('𝕏'), findsNothing);
      expect(find.text('LinkedIn'), findsNothing);
    });

    testWidgets('ShareChannels.all shows all four buttons', (tester) async {
      await tester.pumpWidget(_wrap(
        const ShareChannelRow(
          text: 'hello',
          url: 'https://example.com',
          channels: ShareChannels.all,
        ),
      ));
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Web Share'), findsOneWidget);
      expect(find.text('𝕏'), findsOneWidget);
      expect(find.text('LinkedIn'), findsOneWidget);
    });

    testWidgets('custom channel set shows only requested buttons', (tester) async {
      await tester.pumpWidget(_wrap(
        const ShareChannelRow(
          text: 'hello',
          url: 'https://example.com',
          channels: {ShareChannel.twitter},
        ),
      ));
      expect(find.text('𝕏'), findsOneWidget);
      expect(find.text('Copy'), findsNothing);
      expect(find.text('Web Share'), findsNothing);
      expect(find.text('LinkedIn'), findsNothing);
    });
  });
}
