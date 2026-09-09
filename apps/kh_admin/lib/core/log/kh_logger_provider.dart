import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_admin/core/log/kh_logger.dart';

final khLoggerProvider = Provider<KhLogger>((ref) => const KhLogger());
