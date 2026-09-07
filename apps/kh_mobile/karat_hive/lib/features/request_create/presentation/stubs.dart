import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

class RequestTypeScreen extends StatelessWidget {
  const RequestTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KhScaffold(
      title: 'New request',
      body: Center(child: Text('CUS-S03')),
    );
  }
}

class CreateFindOrnamentScreen extends StatelessWidget {
  const CreateFindOrnamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KhScaffold(
      title: 'Find an ornament',
      body: Center(child: Text('CUS-S04')),
    );
  }
}

class CreateSellOldGoldScreen extends StatelessWidget {
  const CreateSellOldGoldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KhScaffold(
      title: 'Sell old gold',
      body: Center(child: Text('CUS-S05')),
    );
  }
}

class CreateGoldCoinsScreen extends StatelessWidget {
  const CreateGoldCoinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KhScaffold(
      title: 'Gold coins',
      body: Center(child: Text('CUS-S06')),
    );
  }
}

class CreateGoldBullionScreen extends StatelessWidget {
  const CreateGoldBullionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KhScaffold(
      title: 'Gold bullion',
      body: Center(child: Text('CUS-S07')),
    );
  }
}

class RequestImageCaptureScreen extends StatelessWidget {
  const RequestImageCaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KhScaffold(
      title: 'Images',
      body: Center(child: Text('CUS-S08')),
    );
  }
}

class RequestReviewPublishScreen extends StatelessWidget {
  const RequestReviewPublishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const KhScaffold(
      title: 'Review & publish',
      body: Center(child: Text('CUS-S09')),
    );
  }
}
