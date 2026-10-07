import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_design_system/kh_design_system.dart';

import '../../controller/request_create_controller.dart';
import '../../controller/request_create_state.dart';
import 'create_flow_chrome.dart';
import 'request_images_section.dart' show mediaSlotPreview;

/// Editable 2-column photo mosaic for Find An Ornament compose
/// (`Find-orna-create.png` layout on CUS-S04).
///
/// Remaining-count badge, dashed Add tile, remove/retry on each slot.
/// Pick/upload goes through [requestCreateControllerProvider] like
/// [RequestImagesSection].
class FindComposePhotoMosaic extends ConsumerWidget {
  const FindComposePhotoMosaic({super.key});

  Future<void> _pick(WidgetRef ref) async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png'],
    );
    if (files.isEmpty) return;
    final controller = ref.read(requestCreateControllerProvider.notifier);
    for (final f in files) {
      final path = kIsWeb ? null : f.path;
      Uint8List data = await f.readAsBytes();
      if (data.isEmpty && path != null) {
        data = Uint8List.fromList(await File(path).readAsBytes());
      }
      if (data.isEmpty) continue;
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

    final media = state.media;
    final maxImages = state.maxImages;
    final canAdd = media.length < maxImages;
    final remaining = (maxImages - media.length).clamp(0, maxImages);
    final remainingLabel = createCopy(
      context,
      'create.photosRemaining',
      '{n} photos remaining',
    ).replaceAll('{n}', '$remaining');

    final itemCount = media.length + (canAdd ? 1 : 0);

    if (media.isEmpty) {
      return SizedBox(
        key: const Key('find-compose-mosaic'),
        height: 160,
        child: _MosaicAddTile(
          onTap: () => _pick(ref),
          disabled: state.uploading,
        ),
      );
    }

    return Stack(
      key: const Key('find-compose-mosaic'),
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: tokens.space.sm,
            crossAxisSpacing: tokens.space.sm,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) {
            if (index < media.length) {
              return _MosaicMediaTile(
                slot: media[index],
                index: index,
                onRemove: () => controller.removeMediaAt(index),
                onRetry: media[index].failure == null
                    ? null
                    : () => controller.retryFailedMediaAt(index),
              );
            }
            return _MosaicAddTile(
              onTap: () => _pick(ref),
              disabled: state.uploading,
            );
          },
        ),
        if (remaining > 0)
          PositionedDirectional(
            end: tokens.space.sm,
            bottom: tokens.space.sm,
            child: Container(
              key: const Key('find-compose-photos-remaining'),
              padding: EdgeInsets.symmetric(
                horizontal: tokens.space.sm,
                vertical: tokens.space.xs,
              ),
              decoration: BoxDecoration(
                color: tokens.ink.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(tokens.radius.sm),
              ),
              child: Text(
                remainingLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: tokens.surface,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MosaicMediaTile extends StatelessWidget {
  const _MosaicMediaTile({
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
    return ClipRRect(
      key: Key('find-compose-photo-$index'),
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
                  width: 24,
                  height: 24,
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
                  iconSize: 22,
                  tooltip: slot.failure?.message ?? 'Retry',
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                ),
              ),
            ),
          PositionedDirectional(
            top: tokens.space.xs,
            end: tokens.space.xs,
            child: GestureDetector(
              key: Key('create-remove-image-$index'),
              onTap: onRemove,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xCC000000),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MosaicAddTile extends StatelessWidget {
  const _MosaicAddTile({
    required this.onTap,
    required this.disabled,
  });

  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final label = createCopy(context, 'create.addPhoto', 'Add photo');

    return Material(
      color: tokens.paper,
      borderRadius: BorderRadius.circular(tokens.radius.md),
      child: InkWell(
        key: const Key('find-compose-add-image'),
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: disabled ? tokens.inkBorderSoft : tokens.gold,
            radius: tokens.radius.md,
            strokeWidth: 1.5,
            dashWidth: 5,
            dashSpace: 4,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_a_photo_outlined,
                  size: 28,
                  color: disabled ? tokens.inkMuted : tokens.goldDark,
                ),
                SizedBox(height: tokens.space.xs),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: disabled ? tokens.inkMuted : tokens.inkSecondary,
                      ),
                ),
              ],
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
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final len = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        canvas.drawPath(metric.extractPath(distance, distance + len), paint);
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
