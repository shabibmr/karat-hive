import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';

import '../../../app/guards.dart';
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
        continueEnabled: !required || controller.canContinuePhotos,
        continueLabel: createCopy(context, 'create.continue', 'Continue'),
        onSaveDraft: () async {
          final ok = await controller.saveDraft();
          if (ok && context.mounted) {
            controller.resetFlow();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  createCopy(context, 'create.draftSaved', 'Draft saved'),
                ),
              ),
            );
            context.go('${AppGuards.customerRequests}?tab=DRAFTS');
          }
        },
        onContinue: () async {
          if (required && !controller.canContinuePhotos) {
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
            // push (not go): keeps this step in history so hardware/gesture
            // back returns here instead of exiting the app (`RequestCreatePaths`
            // are flat siblings under `UnauthShell`, so `go()` would replace
            // this screen's entire nested-Navigator stack).
            context.push(RequestCreatePaths.review);
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
