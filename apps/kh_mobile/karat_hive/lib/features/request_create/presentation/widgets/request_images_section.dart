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

/// Shared photo picker used by the dedicated images step and by the combined
/// Find Jewellery / Sell Gold compose page.
class RequestImagesSection extends ConsumerWidget {
  const RequestImagesSection({super.key, this.showHint = true});

  final bool showHint;

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
      final bytes = f.bytes;
      final path = f.path;
      Uint8List? data = bytes;
      if (data == null && path != null && !kIsWeb) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          createCopy(context, 'create.imagesTitle', 'Photos'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        if (showHint) ...[
          SizedBox(height: tokens.space.sm),
          Text(
            createCopy(
              context,
              'create.imagesHint',
              'Add clear photos. You can reorder them; the first is the cover.',
            ),
          ),
        ],
        SizedBox(height: tokens.space.md),
        Wrap(
          spacing: tokens.space.sm,
          runSpacing: tokens.space.sm,
          children: [
            for (var i = 0; i < state.media.length; i++)
              _MediaTile(
                slot: state.media[i],
                index: i,
                onRemove: () => controller.removeMediaAt(i),
              ),
            if (state.media.length < state.maxImages)
              OutlinedButton.icon(
                key: const Key('create-add-image'),
                onPressed: state.uploading ? null : () => _pick(ref),
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(
                  createCopy(context, 'create.addPhoto', 'Add photo'),
                ),
              ),
          ],
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
  });

  final MediaSlot slot;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _preview(context),
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
                    ),
                  PositionedDirectional(
                    top: 0,
                    end: 0,
                    child: IconButton(
                      key: Key('create-remove-image-$index'),
                      iconSize: 18,
                      onPressed: onRemove,
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            slot.localLabel ?? slot.key,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _preview(BuildContext context) {
    if (slot.localBytes != null && slot.localBytes!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          slot.localBytes!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image_outlined),
        ),
      );
    }
    if (!kIsWeb && slot.localPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(slot.localPath!),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image_outlined),
        ),
      );
    }
    return const Center(child: Icon(Icons.image_outlined));
  }
}
