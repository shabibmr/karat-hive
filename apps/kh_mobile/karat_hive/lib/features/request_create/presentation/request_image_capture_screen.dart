import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';

import '../controller/request_create_controller.dart';
import '../controller/request_create_state.dart';
import '../routes.dart';
import 'widgets/create_flow_chrome.dart';
import 'widgets/request_images_section.dart';

/// CUS-S08 — request images. Guest keeps files local until publish bind.
/// Used by coins/bullion; Find Jewellery / Sell Gold embed images on compose.
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
        children: const [
          RequestImagesSection(),
        ],
      ),
    );
  }
}
