import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// Renamed stubs — real screens live alongside this file.
class OffersListStubScreen extends StatelessWidget {
  const OffersListStubScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    return KhScaffold(
      title: 'Offers',
      body: Center(child: Text('CUS-S11 · $requestId')),
    );
  }
}

class OfferComparisonStubScreen extends StatelessWidget {
  const OfferComparisonStubScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    return KhScaffold(
      title: 'Compare',
      body: Center(child: Text('CUS-S12 · $requestId')),
    );
  }
}

class OfferDetailStubScreen extends StatelessWidget {
  const OfferDetailStubScreen({super.key, required this.offerId});

  final String offerId;

  @override
  Widget build(BuildContext context) {
    return KhScaffold(
      title: 'Offer',
      body: Center(child: Text('CUS-S13 · $offerId')),
    );
  }
}

class AcceptOfferStubScreen extends StatelessWidget {
  const AcceptOfferStubScreen({super.key, required this.offerId});

  final String offerId;

  @override
  Widget build(BuildContext context) {
    return KhScaffold(
      title: 'Mark as interested',
      body: Center(child: Text('CUS-S14 · $offerId')),
    );
  }
}
