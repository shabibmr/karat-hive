import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'kh_network_image.dart';

/// SH-MED-05 — circular store/business logo picker & preview.
///
/// Stateless: the caller owns file-picking, upload and the persisted
/// `logoUrl`. Shows [previewBytes] (a freshly-picked, not-yet-uploaded file)
/// in preference to [logoUrl] (the last saved logo), so a pick is reflected
/// immediately without waiting on the upload round-trip.
class KhLogoPicker extends StatelessWidget {
  const KhLogoPicker({
    super.key,
    required this.onPick,
    this.onRemove,
    this.logoUrl,
    this.previewBytes,
    this.size = 90,
    this.busy = false,
    this.pickLabel = 'Upload logo',
    this.changeLabel = 'Change logo',
    this.removeLabel = 'Remove',
  });

  final VoidCallback onPick;
  final VoidCallback? onRemove;
  final String? logoUrl;
  final Uint8List? previewBytes;
  final double size;
  final bool busy;
  final String pickLabel;
  final String changeLabel;
  final String removeLabel;

  bool get _hasLogo =>
      (previewBytes != null && previewBytes!.isNotEmpty) ||
      (logoUrl != null && logoUrl!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        children: [
          InkWell(
            onTap: busy ? null : onPick,
            borderRadius: BorderRadius.circular(size / 2),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
              ),
              child: busy
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : _Avatar(
                      size: size,
                      logoUrl: logoUrl,
                      previewBytes: previewBytes,
                      colorScheme: colorScheme,
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: busy ? null : onPick,
                child: Text(_hasLogo ? changeLabel : pickLabel),
              ),
              if (_hasLogo && onRemove != null)
                TextButton(
                  onPressed: busy ? null : onRemove,
                  child: Text(
                    removeLabel,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.size,
    required this.logoUrl,
    required this.previewBytes,
    required this.colorScheme,
  });

  final double size;
  final String? logoUrl;
  final Uint8List? previewBytes;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    if (previewBytes != null && previewBytes!.isNotEmpty) {
      return ClipOval(
        child: Image.memory(
          previewBytes!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return ClipOval(
        child: KhNetworkImage(
          url: logoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.business,
            size: size * 0.44,
            color: colorScheme.primary,
          ),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo_outlined,
          size: size * 0.31,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          'Logo',
          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
