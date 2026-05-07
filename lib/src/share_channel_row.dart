import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'share_launcher.dart';
import 'share_url.dart';

/// Which channels to surface in [ShareChannelRow].
/// Defaults to [ShareChannels.standard] (Copy + Web Share).
/// Pass [ShareChannels.all] or a custom set to re-enable X / LinkedIn.
enum ShareChannel { copy, twitter, linkedin, native }

class ShareChannels {
  static const standard = {ShareChannel.copy, ShareChannel.native};
  static const all = {
    ShareChannel.copy,
    ShareChannel.twitter,
    ShareChannel.linkedin,
    ShareChannel.native,
  };
}

/// Drop-in row of share-channel buttons.
/// Defaults to Copy + Web Share. Pass `channels: ShareChannels.all` (or a
/// custom set) to surface X / LinkedIn as well.
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
  /// Which channels to show. Defaults to Copy + Web Share.
  final Set<ShareChannel> channels;

  const ShareChannelRow({
    super.key,
    required this.text,
    required this.url,
    this.imageProvider,
    this.onShared,
    this.color,
    this.subject,
    this.imageName,
    this.channels = ShareChannels.standard,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).iconTheme.color;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (channels.contains(ShareChannel.copy))
          _Btn(
            icon: Icons.copy,
            label: 'Copy',
            color: iconColor,
            onTap: () async {
              // Copy text only — no URL. Paste destinations like iMessage
              // and WhatsApp don't benefit from a link in the body; the
              // URL is for social platforms that render OG previews.
              await ShareLauncher.copyToClipboard(text);
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
        if (channels.contains(ShareChannel.twitter))
          _Btn(
            icon: Icons.alternate_email,
            label: '𝕏',
            color: iconColor,
            onTap: () async {
              await ShareLauncher.openTwitterIntent(text: text, url: url);
              onShared?.call('twitter');
            },
          ),
        if (channels.contains(ShareChannel.linkedin))
          _Btn(
            icon: Icons.business_center,
            label: 'LinkedIn',
            color: iconColor,
            onTap: () async {
              await ShareLauncher.openLinkedInIntent(url: url);
              onShared?.call('linkedin');
            },
          ),
        if (channels.contains(ShareChannel.native))
          _Btn(
            icon: Icons.share,
            label: 'Web Share',
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
