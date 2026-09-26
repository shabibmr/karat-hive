import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import '../../controller/request_create_controller.dart';
import '../../controller/request_create_state.dart';
import 'create_flow_chrome.dart';

/// Shared photo picker used by the dedicated images step and by the combined
/// Find Jewellery / Sell Gold compose page.
class RequestImagesSection extends ConsumerWidget {
  const RequestImagesSection({
    super.key,
    this.showHint = true,
    this.noticeBanner,
    this.showActualItemNotice = false,
  });

  final bool showHint;
  final String? noticeBanner;
  final bool showActualItemNotice;

  Future<void> _pick(WidgetRef ref) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png'],
      allowMultiple: true,
      withData: true,
    );
    if (res == null) return;
    final controller = ref.read(requestCreateControllerProvider.notifier);
    for (final f in res.files) {
      // On web, PlatformFile.path throws — use bytes + name only.
      final path = kIsWeb ? null : f.path;
      Uint8List? data = f.bytes;
      if (data == null && path != null) {
        data = Uint8List.fromList(await File(path).readAsBytes());
      }
      if (data == null || data.isEmpty) continue;
      final name = f.name.isNotEmpty
          ? f.name
          : (path?.split(RegExp(r'[/\\]')).last ?? 'photo.jpg');
      final ext = name.split('.').last.toLowerCase();
      final ct = ext == 'png' ? 'image/png' : 'image/jpeg';
      await controller.addPickedImage(
        bytes: data,
        filename: name,
        contentType: ct,
        path: path,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final state = ref.watch(requestCreateControllerProvider);
    final controller = ref.read(requestCreateControllerProvider.notifier);

    final effectiveNotice = noticeBanner ??
        (showActualItemNotice
            ? KhStrings.of(context).s('create.actualItemPhotos')
            : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              createCopy(context, 'create.imagesTitle', 'Photos'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.space.sm,
                vertical: tokens.space.xxs,
              ),
              decoration: BoxDecoration(
                color: tokens.goldWash,
                borderRadius: BorderRadius.circular(tokens.radius.full),
                border: Border.all(color: tokens.goldRing, width: 1),
              ),
              child: Text(
                '${state.media.length} / ${state.maxImages}',
                style: context.typography.numberBadge.copyWith(color: tokens.goldDark),
              ),
            ),
          ],
        ),
        if (effectiveNotice != null && effectiveNotice.isNotEmpty) ...[
          SizedBox(height: tokens.space.sm),
          Container(
            padding: EdgeInsets.all(tokens.space.sm),
            decoration: BoxDecoration(
              color: tokens.goldWash,
              borderRadius: BorderRadius.circular(tokens.radius.sm),
              border: Border.all(color: tokens.goldRing),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: tokens.goldDark),
                SizedBox(width: tokens.space.sm),
                Expanded(
                  child: Text(
                    effectiveNotice,
                    style: context.typography.fieldInlineLabel.copyWith(
                      color: tokens.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (showHint) ...[
          SizedBox(height: tokens.space.xs),
          Text(
            createCopy(
              context,
              'create.imagesHint',
              'Add clear photos. You can reorder them; the first is the cover.',
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        SizedBox(height: tokens.space.md),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.media.length +
                (state.media.length < state.maxImages ? 1 : 0),
            separatorBuilder: (_, __) => SizedBox(width: tokens.space.sm),
            itemBuilder: (context, index) {
              if (index < state.media.length) {
                return _MediaTile(
                  slot: state.media[index],
                  index: index,
                  onRemove: () => controller.removeMediaAt(index),
                  onRetry: state.media[index].failure == null
                      ? null
                      : () => controller.retryFailedMediaAt(index),
                );
              }
              return _DashedAddTile(
                onTap: () => _pick(ref),
                disabled: state.uploading,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Read-only thumbnails for Review (CUS-S09). Prefers in-memory bytes.
class RequestMediaGallery extends StatelessWidget {
  const RequestMediaGallery({super.key, required this.media});

  final List<MediaSlot> media;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    if (media.isEmpty) {
      return Text(
        createCopy(context, 'create.field.photosNone', 'No photos attached'),
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          createCopy(context, 'create.field.photos', 'Photos'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: tokens.space.sm),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: media.length,
            separatorBuilder: (_, __) => SizedBox(width: tokens.space.sm),
            itemBuilder: (context, i) {
              return SizedBox(
                key: Key('review-photo-$i'),
                width: 64,
                height: 64,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(tokens.radius.md),
                  child: mediaSlotPreview(media[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.slot,
    required this.index,
    required this.onRemove,
    this.onRetry,
  });

  final MediaSlot slot;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SizedBox(
      width: 64,
      height: 64,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Stack(
          fit: StackFit.expand,
          children: [
            mediaSlotPreview(slot),
            if (slot.uploading)
              const ColoredBox(
                color: Color(0x66000000),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (slot.failure != null)
              ColoredBox(
                color: const Color(0x99000000),
                child: Center(
                  child: IconButton(
                    key: Key('create-retry-image-$index'),
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                    tooltip: slot.failure?.message ?? 'Retry',
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ),
              ),
            PositionedDirectional(
              top: 2,
              end: 2,
              child: GestureDetector(
                key: Key('create-remove-image-$index'),
                onTap: onRemove,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xCC000000),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedAddTile extends StatelessWidget {
  const _DashedAddTile({
    required this.onTap,
    required this.disabled,
  });

  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return InkWell(
      key: const Key('create-add-image'),
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(tokens.radius.md),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: disabled ? tokens.inkBorderSoft : tokens.gold,
          radius: tokens.radius.md,
          strokeWidth: 1.5,
          dashWidth: 4,
          dashSpace: 3,
        ),
        child: SizedBox(
          width: 64,
          height: 64,
          child: Center(
            child: Icon(
              Icons.add_a_photo_outlined,
              size: 22,
              color: disabled ? tokens.inkMuted : tokens.goldDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 1.5,
    this.dashWidth = 4,
    this.dashSpace = 3,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final len = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashSpace != dashSpace;
}

/// Shared thumbnail for compose tiles and Review gallery.
/// Prefers local pick bytes (JPEG/PNG). Remote reopen slots are often AVIF
/// and must go through [KhNetworkImage].
Widget mediaSlotPreview(MediaSlot slot) {
  if (slot.localBytes != null && slot.localBytes!.isNotEmpty) {
    return Image.memory(
      slot.localBytes!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Center(child: Icon(Icons.broken_image_outlined)),
    );
  }
  if (!kIsWeb && slot.localPath != null) {
    return Image.file(
      File(slot.localPath!),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Center(child: Icon(Icons.broken_image_outlined)),
    );
  }
  if (slot.remoteUrl != null && slot.remoteUrl!.isNotEmpty) {
    return KhNetworkImage(
      url: slot.remoteUrl!,
      contentType: slot.contentType ?? 'image/jpeg',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Center(child: Icon(Icons.broken_image_outlined)),
    );
  }
  return const Center(child: Icon(Icons.image_outlined));
}
