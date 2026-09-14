import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';

import '../controller/request_create_controller.dart';
import '../controller/request_create_state.dart';
import '../routes.dart';
import 'widgets/create_flow_chrome.dart';

/// CUS-S08 — attach reference photos. Required for Find-An-Ornament and
/// Sell-Old-Gold; optional otherwise (`RequestCreateState.imagesRequired`).
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
      ref.read(requestCreateControllerProvider.notifier).prefetchImageIntent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final state = ref.watch(requestCreateControllerProvider);
    final controller = ref.read(requestCreateControllerProvider.notifier);
    final canAdd = state.media.length < state.maxImages;
    final missingRequired = state.imagesRequired && state.mediaKeys.isEmpty;

    return CreateFlowChrome(
      title: createCopy(context, 'create.imagesTitle', 'Photos'),
      stepLabel: createCopy(context, 'create.stepImages', 'Add photos'),
      bottom: DraftActions(
        busy: state.busy,
        onSaveDraft: () => controller.saveDraft(),
        onContinue: () async {
          if (missingRequired) return;
          final ok = await controller.persistAndGo(RequestCreateStep.review);
          if (ok && context.mounted) context.go(RequestCreatePaths.review);
        },
        continueEnabled: !missingRequired,
      ),
      child: ListView(
        padding: EdgeInsets.all(tokens.space.md),
        children: [
          Text(
            state.imagesRequired
                ? createCopy(
                    context,
                    'create.imagesRequiredHint',
                    'At least 1 photo of the actual item is required.',
                  )
                : createCopy(
                    context,
                    'create.imagesOptionalHint',
                    'Photos are optional but help vendors respond faster.',
                  ),
          ),
          SizedBox(height: tokens.space.md),
          if (missingRequired)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.space.md),
              child: KhInlineError(
                message: createCopy(
                  context,
                  'create.imagesRequiredError',
                  'Add at least 1 photo to continue.',
                ),
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final slot in state.media)
                _ImageSlotChip(
                  slot: slot,
                  onRetry: () => controller.retryImage(slot),
                  onRemove: () => controller
                      .removeMediaAt(state.media.indexOf(slot)),
                ),
              if (canAdd)
                ActionChip(
                  key: const Key('request-image-add'),
                  avatar: const Icon(Icons.add_a_photo_outlined, size: 18),
                  label: Text(createCopy(context, 'create.addPhoto', 'Add photo')),
                  onPressed: state.uploading ? null : controller.addImage,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImageSlotChip extends StatelessWidget {
  const _ImageSlotChip({
    required this.slot,
    required this.onRetry,
    required this.onRemove,
  });

  final MediaSlot slot;
  final VoidCallback onRetry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (slot.failure != null) {
      return ActionChip(
        key: Key('request-image-retry-${slot.key}'),
        avatar: const Icon(Icons.error_outline, size: 18),
        label: Text(createCopy(context, 'create.retryPhoto', 'Retry')),
        onPressed: onRetry,
      );
    }
    if (slot.uploading) {
      return Chip(
        key: Key('request-image-uploading-${slot.key}'),
        avatar: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: Text(slot.localLabel ?? createCopy(context, 'create.uploading', 'Uploading…')),
      );
    }
    return InputChip(
      key: Key('request-image-${slot.key}'),
      avatar: const Icon(Icons.check_circle, size: 18),
      label: Text(slot.localLabel ?? slot.key.split('/').last),
      onDeleted: onRemove,
    );
  }
}
