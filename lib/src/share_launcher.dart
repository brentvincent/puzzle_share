import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Multi-channel share launcher — wraps the native share sheet plus
/// dedicated Twitter / LinkedIn / clipboard intents. Each game routes
/// every share through this so platform behaviour stays consistent.
class ShareLauncher {
  /// Open the native share sheet (or Web Share API where available).
  /// If [imageBytes] is provided, attempts file share; falls back to
  /// text share if file share isn't supported.
  ///
  /// Returns true on success (sheet shown, intent fired). Does NOT
  /// confirm the user actually completed the share — the OS doesn't
  /// reliably report that.
  static Future<bool> shareNative({
    required String text,
    Uint8List? imageBytes,
    String? imageName,
    String? subject,
  }) async {
    try {
      if (imageBytes != null) {
        final file = XFile.fromData(
          imageBytes,
          name: imageName ?? 'share.png',
          mimeType: 'image/png',
        );
        final result = await Share.shareXFiles(
          [file],
          text: text,
          subject: subject,
        );
        return result.status == ShareResultStatus.success ||
            result.status == ShareResultStatus.unavailable;
      }
      final result = await Share.share(text, subject: subject);
      return result.status == ShareResultStatus.success ||
          result.status == ShareResultStatus.unavailable;
    } catch (_) {
      // Fall through to clipboard so the user always has something.
      await copyToClipboard(text);
      return false;
    }
  }

  /// Open Twitter/X intent with pre-filled text + URL.
  static Future<bool> openTwitterIntent({
    required String text,
    required String url,
  }) async {
    final uri = Uri.parse(
      'https://twitter.com/intent/tweet?text=${Uri.encodeQueryComponent(text)}&url=${Uri.encodeQueryComponent(url)}',
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Open LinkedIn share intent for a URL.
  static Future<bool> openLinkedInIntent({required String url}) async {
    final uri = Uri.parse(
      'https://www.linkedin.com/sharing/share-offsite/?url=${Uri.encodeQueryComponent(url)}',
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Copy plain text to the system clipboard.
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Whether the current platform can render a native share sheet
  /// with image attachments. Always true — share_plus attempts file share
  /// on every platform (including web via Web Share Level 2) and falls
  /// back to text-only share if the platform rejects the file.
  static bool get supportsImageShare => true;
}
