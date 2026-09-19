import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';

/// Service to dynamically retrieve remote environment configuration from Firestore.
class FirestoreConfigService {
  FirestoreConfigService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Fetches the remote API base URL for the given [flavor] from `app_config/environment`.
  ///
  /// Times out after [timeout] (default 3 seconds) and returns `null` on failure,
  /// allowing the application to safely fall back to static environment defines.
  Future<String?> fetchRemoteApiBaseUrl(
    Flavor flavor, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    try {
      final docSnapshot = await _firestore
          .collection('app_config')
          .doc('environment')
          .get()
          .timeout(timeout);

      if (!docSnapshot.exists) {
        debugPrint('[FirestoreConfigService] app_config/environment does not exist.');
        return null;
      }

      final data = docSnapshot.data();
      if (data == null) return null;

      return parseApiBaseUrlForFlavor(data, flavor.name);
    } on TimeoutException {
      debugPrint('[FirestoreConfigService] Timed out fetching remote environment config.');
      return null;
    } catch (e) {
      debugPrint('[FirestoreConfigService] Error fetching remote environment config: $e');
      return null;
    }
  }

  /// Extracts the URL for a given flavor string from the document data map.
  /// Supports:
  /// 1. Flat flavor key: `api_base_url_dev`, `api_base_url_prod`, etc.
  /// 2. Nested map/string: `data['dev']` or `data['dev']['api_base_url']`
  /// 3. Global fallback: `data['api_base_url']`
  static String? parseApiBaseUrlForFlavor(Map<String, dynamic> data, String flavorName) {
    final lowerFlavor = flavorName.toLowerCase().trim();

    // 1. Check flat key: e.g. api_base_url_dev
    final flatKey = 'api_base_url_$lowerFlavor';
    if (data[flatKey] != null && data[flatKey].toString().trim().isNotEmpty) {
      return data[flatKey].toString().trim();
    }

    // 2. Check nested key: e.g. dev: "https://..." or dev: { api_base_url: "https://..." }
    final flavorValue = data[lowerFlavor];
    if (flavorValue is String && flavorValue.trim().isNotEmpty) {
      return flavorValue.trim();
    } else if (flavorValue is Map && flavorValue['api_base_url'] != null) {
      final url = flavorValue['api_base_url'].toString().trim();
      if (url.isNotEmpty) return url;
    }

    // 3. Fallback to global api_base_url if provided
    if (data['api_base_url'] != null && data['api_base_url'].toString().trim().isNotEmpty) {
      return data['api_base_url'].toString().trim();
    }

    return null;
  }
}

final firestoreConfigServiceProvider = Provider<FirestoreConfigService>((ref) {
  return FirestoreConfigService();
});
