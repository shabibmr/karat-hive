import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../app/session/session_controller.dart';

/// In-memory flag: Guest tapped Publish and must finish auth without losing create.
class PendingPublishIntent extends Notifier<bool> {
  @override
  bool build() => false;

  void setPending() => state = true;

  void clearPending() => state = false;
}

final pendingPublishIntentProvider =
    NotifierProvider<PendingPublishIntent, bool>(PendingPublishIntent.new);

/// Vendor login drops guest publish intent (GL-16 / GL-61). Idempotent.
void clearPendingPublishIfVendor(
  SessionState session,
  bool pending,
  void Function() clear, {
  void Function()? resetCreate,
}) {
  if (pending && session is SignedIn && session.isVendor) {
    resetCreate?.call();
    clear();
  }
}

/// Local-only, disk-backed snapshot of a Guest's in-progress create draft
/// (GL-57…GL-63): enough to rebuild [RequestCreateState] after a cold app
/// restart so a pending auto-publish can still complete once the user signs
/// in. Never sent to the server — the server draft (if any) is tracked
/// separately via `draftId`.
class PendingPublishDraftSnapshot {
  const PendingPublishDraftSnapshot({
    required this.fields,
    required this.mediaKeys,
    required this.expiresAt,
  });

  /// Raw field map mirroring the subset of [RequestCreateState] worth
  /// restoring (requestType, direction, region, specs, budget…).
  final Map<String, dynamic> fields;

  /// Server-side media keys only — local bytes/paths are not persisted
  /// (guest-picked images must be re-attached after a cold restart).
  final List<String> mediaKeys;

  final DateTime expiresAt;

  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'fields': fields,
        'mediaKeys': mediaKeys,
        'expiresAt': expiresAt.toIso8601String(),
      };

  static PendingPublishDraftSnapshot? fromJson(Map<String, dynamic> json) {
    final expiresRaw = json['expiresAt'] as String?;
    final expiresAt = expiresRaw == null ? null : DateTime.tryParse(expiresRaw);
    if (expiresAt == null) return null;
    return PendingPublishDraftSnapshot(
      fields: Map<String, dynamic>.from(json['fields'] as Map? ?? const {}),
      mediaKeys: (json['mediaKeys'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(growable: false),
      expiresAt: expiresAt,
    );
  }
}

/// Persists a [PendingPublishDraftSnapshot] as a small JSON file so it
/// survives an app cold-boot. Mirrors `packages/kh_media`'s
/// `PendingUploadCache` convention (temp dir + JSON manifest); failures are
/// treated as "nothing to restore" by callers, never fatal.
class PendingPublishDraftStore {
  PendingPublishDraftStore({Directory? baseDir}) : _baseDirOverride = baseDir;

  final Directory? _baseDirOverride;
  static const _fileName = 'pending_publish_draft.json';

  Future<File> _file() async {
    final override = _baseDirOverride;
    final dir = override ?? await getTemporaryDirectory();
    if (!await dir.exists()) await dir.create(recursive: true);
    return File('${dir.path}/$_fileName');
  }

  Future<void> save(PendingPublishDraftSnapshot snapshot) async {
    final f = await _file();
    await f.writeAsString(jsonEncode(snapshot.toJson()), flush: true);
  }

  Future<PendingPublishDraftSnapshot?> load() async {
    final f = await _file();
    if (!await f.exists()) return null;
    final raw = await f.readAsString();
    if (raw.trim().isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return PendingPublishDraftSnapshot.fromJson(
      Map<String, dynamic>.from(decoded),
    );
  }

  Future<void> clear() async {
    final f = await _file();
    if (await f.exists()) await f.delete();
  }
}

final pendingPublishDraftStoreProvider = Provider<PendingPublishDraftStore>(
  (ref) => PendingPublishDraftStore(),
);
