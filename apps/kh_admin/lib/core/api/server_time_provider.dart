import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stores the latest server timestamp captured from backend API responses.
///
/// TR-S0-21: updated whenever an API response envelope contains `meta.serverTime` or `serverTime`.
final StateProvider<DateTime?> serverTimeProvider =
    StateProvider<DateTime?>((ref) => null);
