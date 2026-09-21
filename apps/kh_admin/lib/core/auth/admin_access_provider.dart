import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/auth/admin_role.dart';
import 'package:kh_admin/core/auth/session_controller.dart';

final adminAccessProvider = Provider<AdminAccess?>((ref) {
  final role = ref.watch(
    sessionControllerProvider.select((state) => state.admin?.role),
  );
  return role == null ? null : AdminAccess(role);
});
