import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

class OffersListScreen extends StatelessWidget {
  const OffersListScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    return KhScaffold(
      title: 'Offers',
      body: Center(child: Text('CUS-S11 · $requestId')),
    );
  }
}

class OfferComparisonScreen extends StatelessWidget {
  const OfferComparisonScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    return KhScaffold(
      title: 'Compare',
      body: Center(child: Text('CUS-S12 · $requestId')),
    );
  }
}

class OfferDetailScreen extends StatelessWidget {
  const OfferDetailScreen({super.key, required this.offerId});

  final String offerId;

  @override
  Widget build(BuildContext context) {
    return KhScaffold(
      title: 'Offer',
      body: Center(child: Text('CUS-S13 · $offerId')),
    );
  }
}

class AcceptOfferScreen extends StatelessWidget {
  const AcceptOfferScreen({super.key, required this.offerId});

  final String offerId;

  @override
  Widget build(BuildContext context) {
    return KhScaffold(
      title: 'Mark as interested',
      body: Center(child: Text('CUS-S14 · $offerId')),
    );
  }
}
