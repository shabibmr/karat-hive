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

    final types = <_TypeCardData>[
      _TypeCardData(
        type: RequestType.findOrnament,
        title: createCopy(context, 'create.type.ornament', 'Find An Ornament'),
        tag: 'BUY · BESPOKE & CATALOGUE',
        hint: createCopy(
          context,
          'create.type.ornamentHint',
          'Commission custom jewelry designs or match catalog pieces from verified UAE craftsmen.',
        ),
        icon: Icons.diamond_outlined,
        highlights: const ['Custom Designs', 'Target Budget', 'Reference Photos'],
        key: const Key('type-find-ornament'),
      ),
      _TypeCardData(
        type: RequestType.sellOldGold,
        title: createCopy(context, 'create.type.sellGold', 'Sell Old Gold'),
        tag: 'SELL · INSTANT QUOTES',
        hint: createCopy(
          context,
          'create.type.sellGoldHint',
          'Monetize pre-owned, scrap, or broken gold with competitive buy-back bids from jewellers.',
        ),
        icon: Icons.balance_rounded,
        highlights: const ['Multiple Bids', 'Any Karat', 'Direct Settlement'],
        key: const Key('type-sell-old-gold'),
      ),
      _TypeCardData(
        type: RequestType.goldCoin,
        title: createCopy(context, 'create.type.coins', 'Buy/Sell Gold Coins'),
        tag: 'BUY OR SELL · MINTED',
        hint: createCopy(
          context,
          'create.type.coinsHint',
          'Trade Sovereigns, Krugerrands, and standard bullion coins at transparent market premiums.',
        ),
        icon: Icons.monetization_on_outlined,
        highlights: const ['Standard Weights', 'Sealed Packs', 'Live Spot Rates'],
        key: const Key('type-gold-coin'),
      ),
      _TypeCardData(
        type: RequestType.goldBullion,
        title: createCopy(context, 'create.type.bullion', 'Buy/Sell Bullions'),
        tag: 'BUY OR SELL · INVESTMENT',
        hint: createCopy(
          context,
          'create.type.bullionHint',
          'Institutional-grade investment bars from certified refiners with verified assay certification.',
        ),
        icon: Icons.crop_landscape_rounded,
        highlights: const ['24K / 999.9', 'Assay Certified', 'AED 500+ Floor'],
        key: const Key('type-gold-bullion'),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A1128),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1128),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFFDFBF7), size: 18),
          onPressed: () => context.canPop() ? context.pop() : context.go('/customer/home'),
        ),
        title: Text(
          createCopy(context, 'create.typeTitle', 'New Request'),
          style: const TextStyle(
            color: Color(0xFFFDFBF7),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space.md,
            vertical: tokens.space.sm,
          ),
          children: [
            // Hero Salon Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.diamond, size: 12, color: Color(0xFFF1E5AC)),
                        SizedBox(width: 8),
                        Text(
                          'KARAT HIVE SALON',
                          style: TextStyle(
                            color: Color(0xFFF1E5AC),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'What would you like to request?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFDFBF7),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Broadcast your specifications directly to certified UAE jewellers with zero intermediaries.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFB0B9D0),
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // 4 Showroom Facade Cards
            for (final card in types) ...[
              _TypeTile(
                data: card,
                selected: state.requestType == card.type,
                onTap: () {
                  controller.selectType(card.type);
                  // push (not go): preserves history so back returns here.
                  context.push(RequestCreatePaths.composeFor(card.type));
                },
              ),
              SizedBox(height: tokens.space.md),
            ],

            // Trust Assurance Footer
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF111A36).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_outlined, size: 15, color: Color(0xFFD4AF37)),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '100% Identity Masking  •  48h Window  •  Verified UAE Jewellers',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFB0B9D0),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TypeCardData {
  const _TypeCardData({
    required this.type,
    required this.title,
    required this.tag,
    required this.hint,
    required this.icon,
    required this.highlights,
    required this.key,
  });

  final RequestType type;
  final String title;
  final String tag;
  final String hint;
  final IconData icon;
  final List<String> highlights;
  final Key key;
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _TypeCardData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: data.key,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
          if (selected)
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
              blurRadius: 18,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFFD4AF37).withValues(alpha: 0.15),
          highlightColor: const Color(0xFFD4AF37).withValues(alpha: 0.08),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: selected
                    ? const [
                        Color(0xFF1E2A54),
                        Color(0xFF131D3B),
                      ]
                    : const [
                        Color(0xFF151F3D),
                        Color(0xFF0E152C),
                      ],
              ),
              border: Border.all(
                color: selected
                    ? const Color(0xFFF1E5AC)
                    : const Color(0xFFD4AF37).withValues(alpha: 0.28),
                width: selected ? 1.8 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with Art Deco icon badge, Tag, and Forward Action
                Row(
                  children: [
                    // Art Deco Icon Frame
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF263566),
                            Color(0xFF111A36),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.45),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        data.icon,
                        size: 22,
                        color: const Color(0xFFF1E5AC),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Direction / Category Pill
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            data.tag,
                            style: const TextStyle(
                              color: Color(0xFFE3C65A),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Chevron circle
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: Color(0xFFF1E5AC),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Card Title
                Text(
                  data.title,
                  style: const TextStyle(
                    color: Color(0xFFFDFBF7),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  data.hint,
                  style: const TextStyle(
                    color: Color(0xFFC5CEE0),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Highlights Chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final h in data.highlights)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF080D1F).withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          h,
                          style: const TextStyle(
                            color: Color(0xFFEDE8DC),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
