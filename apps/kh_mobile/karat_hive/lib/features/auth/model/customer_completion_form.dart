import 'package:kh_core/kh_core.dart';

enum CompletionStep { details, code, submitting, done }

/// Flow-scoped state for the CFE-10 new-user completion step (`CUS-S01`).
/// Back-navigation between the details and code sub-steps never loses input
/// (Architecture-Frontend §6.2).
class CustomerCompletionForm {
  const CustomerCompletionForm({
    this.firebaseIdToken = '',
    this.displayName = '',
    this.mobileNumber = '',
    this.email,
    this.termsAccepted = false,
    this.step = CompletionStep.details,
    this.challengeId,
    this.busy = false,
    this.failure,
  });

  final String firebaseIdToken;
  final String displayName;
  final String mobileNumber;
  final String? email;
  final bool termsAccepted;
  final CompletionStep step;
  final String? challengeId;
  final bool busy;
  final Failure? failure;

  bool get detailsComplete =>
      displayName.trim().isNotEmpty &&
      _looksLikeE164(mobileNumber) &&
      termsAccepted;

  bool get canSubmitCode =>
      termsAccepted && (challengeId?.isNotEmpty ?? false) && !busy;

  static bool _looksLikeE164(String v) {
    final t = v.trim();
    return RegExp(r'^\+[1-9]\d{6,14}$').hasMatch(t);
  }

  CustomerCompletionForm copyWith({
    String? firebaseIdToken,
    String? displayName,
    String? mobileNumber,
    String? email,
    bool? termsAccepted,
    CompletionStep? step,
    String? challengeId,
    bool? busy,
    Failure? failure,
    bool clearFailure = false,
  }) =>
      CustomerCompletionForm(
        firebaseIdToken: firebaseIdToken ?? this.firebaseIdToken,
        displayName: displayName ?? this.displayName,
        mobileNumber: mobileNumber ?? this.mobileNumber,
        email: email ?? this.email,
        termsAccepted: termsAccepted ?? this.termsAccepted,
        step: step ?? this.step,
        challengeId: challengeId ?? this.challengeId,
        busy: busy ?? this.busy,
        failure: clearFailure ? null : (failure ?? this.failure),
      );
}
