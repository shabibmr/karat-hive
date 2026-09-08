import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';

import '../controller/request_create_controller.dart';
import '../routes.dart';
import 'widgets/create_flow_chrome.dart';

/// CUS-S03 — four Request types (CU-02 / SH-REQ-02).
class RequestTypeScreen extends ConsumerStatefulWidget {
  const RequestTypeScreen({super.key});

  @override
  ConsumerState<RequestTypeScreen> createState() => _RequestTypeScreenState();
}

class _RequestTypeScreenState extends ConsumerState<RequestTypeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(requestCreateControllerProvider.notifier).ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final state = ref.watch(requestCreateControllerProvider);
    final controller = ref.read(requestCreateControllerProvider.notifier);

    if (state.lookupsLoading && !state.lookupsReady) {
      return KhScaffold(
        title: createCopy(context, 'create.typeTitle', 'New Request'),
        body: const KhLoadingView(),
      );
    }

    if (state.failure != null && !state.lookupsReady) {
      return KhScaffold(
        title: createCopy(context, 'create.typeTitle', 'New Request'),
        body: KhErrorView(
          message: state.failure!.message ??
              createCopy(context, 'create.loadFailed', 'Could not load.'),
          onRetry: controller.loadLookups,
        ),
      );
    }

    if (state.capBlocked) {
      return KhScaffold(
        title: createCopy(context, 'create.typeTitle', 'New Request'),
        body: KhEmptyView(
          icon: Icons.block,
          message: createCopy(
            context,
            'create.capBlocked',
            'You already have the maximum number of live Requests. Finish or cancel one before creating another.',
          ),
        ),
      );
    }

    final types = <(RequestType, String, String, Key)>[
      (
        RequestType.findOrnament,
        createCopy(context, 'create.type.ornament', 'Find An Ornament'),
        createCopy(
          context,
          'create.type.ornamentHint',
          'Buy jewellery. Direction is BUY. Budget and a reference photo are required.',
        ),
        const Key('type-find-ornament'),
      ),
      (
        RequestType.sellOldGold,
        createCopy(context, 'create.type.sellGold', 'Sell Old Gold'),
        createCopy(
          context,
          'create.type.sellGoldHint',
          'Sell jewellery you own. Direction is SELL. Photos must be of the actual item.',
        ),
        const Key('type-sell-old-gold'),
      ),
      (
        RequestType.goldCoin,
        createCopy(context, 'create.type.coins', 'Gold Coins'),
        createCopy(
          context,
          'create.type.coinsHint',
          'Buy or sell coins. Choose direction, denomination, and quantity.',
        ),
        const Key('type-gold-coin'),
      ),
      (
        RequestType.goldBullion,
        createCopy(context, 'create.type.bullion', 'Gold Bullion'),
        createCopy(
          context,
          'create.type.bullionHint',
          'Buy or sell bars. A gold rate is required to publish. Minimum indicative value applies.',
        ),
        const Key('type-gold-bullion'),
      ),
    ];

    return KhScaffold(
      title: createCopy(context, 'create.typeTitle', 'New Request'),
      body: ListView(
        padding: EdgeInsets.all(tokens.space.md),
        children: [
          Text(
            createCopy(
              context,
              'create.typePrompt',
              'Choose one Request type. You can change it until you publish.',
            ),
          ),
          SizedBox(height: tokens.space.md),
          for (final t in types) ...[
            _TypeTile(
              tileKey: t.$4,
              title: t.$2,
              hint: t.$3,
              selected: state.requestType == t.$1,
              onTap: () {
                controller.selectType(t.$1);
                context.go(RequestCreatePaths.composeFor(t.$1));
              },
            ),
            SizedBox(height: tokens.space.sm),
          ],
        ],
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.tileKey,
    required this.title,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  final Key tileKey;
  final String title;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Material(
      key: tileKey,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(
          color: selected ? tokens.gold : tokens.ink.withValues(alpha: 0.12),
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: tokens.space.xs),
              Text(hint, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
