import 'dart:convert';

/// Encode a rectangular small-int (0-15) grid into a URL-safe token.
///
/// Token format:
/// - `v1:<base64url>` — single grid, size encoded in the byte length
///   (Ninjoku-compatible 9×9 fits in 41 bytes).
/// - `v1.<size>.<base64url>` — sized variant (Crowns-compatible) for
///   non-9×9 boards. Decoder auto-detects which form.
/// - `v2:<givens>:<current>` — co-op hand-off (Ninjoku v2 format).
///
/// Each cell occupies 4 bits (low nibble = even index, high nibble = odd
/// index). 9×9 = 81 cells = 41 bytes. 8×8 = 64 cells = 32 bytes. Etc.
class GridCodec {
  static const _v1 = 'v1';
  static const _v2 = 'v2';

  /// Encode without size annotation. Use for fixed-size 9×9 grids
  /// (compatible with Ninjoku's existing tokens).
  static String encode(List<List<int>> grid) {
    return '$_v1:${_encodeBoard(grid)}';
  }

  /// Encode with explicit size annotation (Crowns format).
  static String encodeSized(List<List<int>> grid) {
    final size = grid.length;
    return '$_v1.$size.${_encodeBoard(grid)}';
  }

  /// Encode givens + current progress for co-op hand-off.
  static String encodeWithProgress(
    List<List<int>> givens,
    List<List<int>> current,
  ) {
    return '$_v2:${_encodeBoard(givens)}:${_encodeBoard(current)}';
  }

  /// Decode any v1 form (sized or not). Returns the grid; for sized
  /// tokens the height matches the encoded size, for plain v1 tokens
  /// it's assumed 9×9.
  static List<List<int>> decode(String token) {
    if (token.startsWith('$_v1.')) {
      // Sized form: v1.<n>.<b64>
      final parts = token.split('.');
      if (parts.length != 3) {
        throw const FormatException('grid token: v1.N.B64 expects 3 parts');
      }
      final size = int.tryParse(parts[1]);
      if (size == null || size < 4 || size > 16) {
        throw FormatException('grid token: bad size "${parts[1]}"');
      }
      return _decodeBoard(parts[2], size: size);
    }
    final parts = token.split(':');
    if (parts.length != 2 || parts[0] != _v1) {
      throw FormatException('grid token: expected v1:..., got "$token"');
    }
    return _decodeBoard(parts[1], size: 9);
  }

  /// Decode a v2 (progress) token. Throws if the token is v1.
  static ({List<List<int>> givens, List<List<int>> current})
      decodeWithProgress(String token) {
    final parts = token.split(':');
    if (parts.length != 3 || parts[0] != _v2) {
      throw FormatException(
        'grid token: expected v2:G:C with 3 parts, got "$token"',
      );
    }
    return (
      givens: _decodeBoard(parts[1], size: 9),
      current: _decodeBoard(parts[2], size: 9),
    );
  }

  static bool isProgressToken(String token) => token.startsWith('$_v2:');
  static bool isSizedToken(String token) => token.startsWith('$_v1.');

  static String _encodeBoard(List<List<int>> board) {
    final size = board.length;
    final cells = size * size;
    final byteLen = (cells + 1) ~/ 2;
    final bytes = List<int>.filled(byteLen, 0);
    int cellIdx = 0;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final v = board[r][c] & 0xF;
        if (cellIdx.isEven) {
          bytes[cellIdx ~/ 2] |= v;
        } else {
          bytes[cellIdx ~/ 2] |= v << 4;
        }
        cellIdx++;
      }
    }
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  static List<List<int>> _decodeBoard(String b64Part, {required int size}) {
    var b64 = b64Part;
    while (b64.length % 4 != 0) {
      b64 += '=';
    }
    final bytes = base64Url.decode(b64);
    final cells = size * size;
    final expectedBytes = (cells + 1) ~/ 2;
    if (bytes.length != expectedBytes) {
      throw FormatException(
        'grid token: expected $expectedBytes bytes, got ${bytes.length}',
      );
    }
    final board = <List<int>>[];
    int cellIdx = 0;
    for (int r = 0; r < size; r++) {
      final row = <int>[];
      for (int c = 0; c < size; c++) {
        final b = bytes[cellIdx ~/ 2];
        final v = cellIdx.isEven ? (b & 0xF) : ((b >> 4) & 0xF);
        if (v > 15) {
          throw FormatException('grid token: invalid cell value $v at ($r,$c)');
        }
        row.add(v);
        cellIdx++;
      }
      board.add(row);
    }
    return board;
  }
}
