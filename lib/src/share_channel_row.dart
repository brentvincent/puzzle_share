import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'share_launcher.dart';
import 'share_url.dart';

/// Drop-in row of share-channel buttons: [Copy · 𝕏 · LinkedIn · Native].
/// Each game wires its own `text`/`url`/optional image provider; the
/// widget handles all platform plumbing.
///
/// On web all four buttons are useful (Twitter/LinkedIn intent into
/// new tabs). On native the Twitter/LinkedIn buttons still work but
/// most users will hit Native to get the OS share sheet.
class ShareChannelRow extends StatelessWidget {
  final String text;
  final String url;
  /// When provided, the Native channel attempts a file share with this
  /// PNG; otherwise the share is text-only.
  final Future<Uint8List?> Function()? imageProvider;
  /// Called after a button is tapped — useful for analytics.
  final void Function(String channel)? onShared;
  /// Optional brand colour for icons.
  final Color? color;
  /// Optional subject for native share (e.g., email subject).
  final String? subject;
  /// Image filename for the native share (defaults to "share.png").
  final String? imageName;

  const ShareChannelRow({
    super.key,
    required this.text,
    required this.url,
    this.imageProvider,
    this.onShared,
    this.color,
    this.subject,
    this.imageName,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).iconTheme.color;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _Btn(
          icon: Icons.copy,
          label: 'Copy',
          color: iconColor,
          onTap: () async {
            final tagged = ShareUrlBuilder.parse(url) == null
                ? '$text\n$url'
                : '$text\n$url';
            await ShareLauncher.copyToClipboard(tagged);
            onShared?.call('copy');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        _Btn(
          icon: Icons.alternate_email,
          label: '𝕏',
          color: iconColor,
          onTap: () async {
            await ShareLauncher.openTwitterIntent(text: text, url: url);
            onShared?.call('twitter');
          },
        ),
        _Btn(
          icon: Icons.business_center,
          label: 'LinkedIn',
          color: iconColor,
          onTap: () async {
            await ShareLauncher.openLinkedInIntent(url: url);
            onShared?.call('linkedin');
          },
        ),
        _Btn(
          icon: Icons.share,
          label: kIsWeb ? 'Web Share' : 'More',
          color: iconColor,
          onTap: () async {
            Uint8List? bytes;
            if (imageProvider != null && ShareLauncher.supportsImageShare) {
              try {
                bytes = await imageProvider!.call();
              } catch (_) {
                bytes = null;
              }
            }
            await ShareLauncher.shareNative(
              text: '$text\n$url',
              imageBytes: bytes,
              imageName: imageName,
              subject: subject,
            );
            onShared?.call('native');
          },
        ),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _Btn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
