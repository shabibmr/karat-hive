import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';

import '../controller/request_create_controller.dart';
import '../controller/request_create_state.dart';
import '../routes.dart';
import 'widgets/create_flow_chrome.dart';

/// CUS-S08 — request images. Guest keeps files local until publish bind.
class RequestImageCaptureScreen extends ConsumerStatefulWidget {
  const RequestImageCaptureScreen({super.key});

  @override
  ConsumerState<RequestImageCaptureScreen> createState() =>
      _RequestImageCaptureScreenState();
}

class _RequestImageCaptureScreenState
    extends ConsumerState<RequestImageCaptureScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(requestCreateControllerProvider.notifier).ensureLoaded();
      ref
          .read(requestCreateControllerProvider.notifier)
          .goTo(RequestCreateStep.images);
    });
  }

  Future<void> _pick() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );
    if (res == null) return;
    final controller = ref.read(requestCreateControllerProvider.notifier);
    for (final f in res.files) {
      final path = f.path;
      if (path == null) continue;
      final ext = path.split('.').last.toLowerCase();
      final ct = ext == 'png' ? 'image/png' : 'image/jpeg';
      await controller.addImage(File(path), ct);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final state = ref.watch(requestCreateControllerProvider);
    final controller = ref.read(requestCreateControllerProvider.notifier);
    final required = state.imagesRequired;

    return CreateFlowChrome(
      title: createCopy(context, 'create.imagesTitle', 'Photos'),
      stepLabel: createCopy(context, 'create.imagesStep', 'Step · Photos'),
      bottom: DraftActions(
        busy: state.busy || state.uploading,
        continueLabel: createCopy(context, 'create.continue', 'Continue'),
        onSaveDraft: () => controller.saveDraft(),
        onContinue: () async {
          if (required && state.media.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  createCopy(
                    context,
                    'create.imagesRequired',
                    'Add at least one photo to continue.',
                  ),
                ),
              ),
            );
            return;
          }
          final ok =
              await controller.persistAndGo(RequestCreateStep.review);
          if (ok && context.mounted) {
            context.go(RequestCreatePaths.review);
          }
        },
      ),
      child: ListView(
        padding: EdgeInsets.all(tokens.space.md),
        children: [
          Text(
            createCopy(
              context,
              'create.imagesHint',
              'Add clear photos. You can reorder them; the first is the cover.',
            ),
          ),
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
                  onPressed: state.uploading ? null : _pick,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: Text(
                    createCopy(context, 'create.addPhoto', 'Add photo'),
                  ),
                ),
            ],
          ),
          if (state.failure != null) ...[
            SizedBox(height: tokens.space.md),
            KhInlineError(
              message: state.failure!.message ??
                  createCopy(context, 'create.uploadFailed', 'Upload failed.'),
            ),
          ],
        ],
      ),
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
                  if (slot.localPath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(slot.localPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image_outlined),
                      ),
                    )
                  else
                    const Center(child: Icon(Icons.image_outlined)),
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
}
