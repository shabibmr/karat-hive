import 'package:kh_core/kh_core.dart';

enum CustomerRegisterStep { details, otp, submitting, done }

class CustomerRegisterFormState {
  const CustomerRegisterFormState({
    this.step = CustomerRegisterStep.details,
    this.displayName = '',
    this.email = '',
    this.mobileNumber = '',
    this.preferredLanguage = 'en',
    this.acceptTerms = false,
    this.acceptPrivacy = false,
    this.challengeId,
    this.mobileVerified = false,
    this.busy = false,
    this.failure,
  });

  final CustomerRegisterStep step;
  final String displayName;
  final String email;
  final String mobileNumber;
  final String preferredLanguage;
  final bool acceptTerms;
  final bool acceptPrivacy;
  final String? challengeId;
  final bool mobileVerified;
  final bool busy;
  final Failure? failure;

  bool get detailsComplete =>
      displayName.trim().isNotEmpty &&
      displayName.trim().length <= 100 &&
      mobileNumber.length >= 8 &&
      acceptTerms &&
      acceptPrivacy;

  CustomerRegisterFormState copyWith({
    CustomerRegisterStep? step,
    String? displayName,
    String? email,
    String? mobileNumber,
    String? preferredLanguage,
    bool? acceptTerms,
    bool? acceptPrivacy,
    String? challengeId,
    bool? mobileVerified,
    bool? busy,
    Failure? failure,
    bool clearFailure = false,
  }) =>
      CustomerRegisterFormState(
        step: step ?? this.step,
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        mobileNumber: mobileNumber ?? this.mobileNumber,
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
        acceptTerms: acceptTerms ?? this.acceptTerms,
        acceptPrivacy: acceptPrivacy ?? this.acceptPrivacy,
        challengeId: challengeId ?? this.challengeId,
        mobileVerified: mobileVerified ?? this.mobileVerified,
        busy: busy ?? this.busy,
        failure: clearFailure ? null : (failure ?? this.failure),
      );
}
