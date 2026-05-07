/// Builds shareable URLs with consistent UTM tagging across all three
/// games. Makes share-link clicks attributable in analytics without
/// each game rolling its own query-string assembly.
class ShareUrlBuilder {
  /// Build a shareable URL.
  ///
  /// - [origin] is the brand domain ("https://ninjoku.com").
  /// - [path] is the resource path ("/p/v1:..." or "/challenge/abc123").
  /// - [channel] tags how the link was shared: 'copy' | 'twitter' |
  ///   'linkedin' | 'native' | 'qr' | 'discord' | 'imessage'.
  /// - [puzzleId] / [userShortId] go into UTM-equivalent params.
  /// - [extra] merges arbitrary additional query params.
  ///
  /// Output: `<origin><path>?src=share&via=<channel>&pid=<id>&u=<short>`
  /// (only includes what's provided).
  static String build({
    required String origin,
    required String path,
    String? channel,
    String? puzzleId,
    String? userShortId,
    Map<String, String> extra = const {},
  }) {
    final base = '$origin$path';
    final params = <String, String>{
      'src': 'share',
      if (channel != null) 'via': channel,
      if (puzzleId != null) 'pid': puzzleId,
      if (userShortId != null) 'u': userShortId,
      ...extra,
    };
    if (params.isEmpty) return base;
    final separator = base.contains('?') ? '&' : '?';
    final query = params.entries
        .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return '$base$separator$query';
  }

  /// Reverse: parse the UTM trio from a URL. Returns null if no
  /// `src=share` tag is present.
  static ({String? channel, String? puzzleId, String? userShortId})? parse(
    String url,
  ) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final qp = uri.queryParameters;
    if (qp['src'] != 'share') return null;
    return (
      channel: qp['via'],
      puzzleId: qp['pid'],
      userShortId: qp['u'],
    );
  }
}
