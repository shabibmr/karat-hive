import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kh_design_system/kh_design_system.dart';

import '../../../app/guards.dart';
import '../../../app/session/session_controller.dart';

class WrongAccountScreen extends ConsumerWidget {
  const WrongAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final role = session is AuthRejected ? session.failure.details['actualRole'] : null;
    final roleName = switch (role) {
      'ADMIN' => 'Admin',
      'VENDOR' => 'Vendor',
      'CUSTOMER' => 'Customer',
      _ => 'another',
    };

    return KhScaffold(
      title: 'Wrong account',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'This account is registered as a $roleName account and cannot be used in this mobile application.',
            ),
            const SizedBox(height: 16),
            KhButton(
              label: 'Back to login',
              onPressed: () async {
                await ref.read(sessionProvider.notifier).signOut();
                if (context.mounted) context.go(AppGuards.customerOnboarding);
              },
            ),
          ],
        ),
      ),
    );
  }
}
