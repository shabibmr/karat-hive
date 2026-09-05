import 'package:kh_core/kh_core.dart';

enum RegisterStep { details, otp, submitting, done }

class RegisterFormState {
  const RegisterFormState({
    this.step = RegisterStep.details,
    this.mobileNumber = '',
    this.legalBusinessName = '',
    this.tradingName = '',
    this.tradeLicenceNumber = '',
    this.licenceExpiryDate = '',
    this.businessAddress = '',
    this.contactPersonName = '',
    this.businessEmail = '',
    this.regionId,
    this.categoryIds = const [],
    this.servedRegionIds = const [],
    this.challengeId,
    this.busy = false,
    this.failure,
  });

  final RegisterStep step;
  final String mobileNumber;
  final String legalBusinessName;
  final String tradingName;
  final String tradeLicenceNumber;
  final String licenceExpiryDate;
  final String businessAddress;
  final String contactPersonName;
  final String businessEmail;
  final String? regionId;
  final List<String> categoryIds;
  final List<String> servedRegionIds;
  final String? challengeId;
  final bool busy;
  final Failure? failure;

  bool get detailsComplete =>
      mobileNumber.length >= 8 &&
      legalBusinessName.isNotEmpty &&
      tradingName.isNotEmpty &&
      tradeLicenceNumber.isNotEmpty &&
      licenceExpiryDate.isNotEmpty &&
      businessAddress.isNotEmpty &&
      contactPersonName.isNotEmpty &&
      businessEmail.contains('@') &&
      regionId != null &&
      categoryIds.isNotEmpty &&
      servedRegionIds.isNotEmpty;

  Map<String, dynamic> toRegisterBody() => {
        'challengeId': challengeId,
        'legalBusinessName': legalBusinessName,
        'tradingName': tradingName,
        'tradeLicenceNumber': tradeLicenceNumber,
        'licenceExpiryDate': licenceExpiryDate,
        'businessAddress': businessAddress,
        'contactPersonName': contactPersonName,
        'businessEmail': businessEmail,
        'regionId': regionId,
        'categoryIds': categoryIds,
        'servedRegionIds': servedRegionIds,
        'termsVersion': '1.0',
        'privacyVersion': '1.0',
      };

  RegisterFormState copyWith({
    RegisterStep? step,
    String? mobileNumber,
    String? legalBusinessName,
    String? tradingName,
    String? tradeLicenceNumber,
    String? licenceExpiryDate,
    String? businessAddress,
    String? contactPersonName,
    String? businessEmail,
    String? regionId,
    List<String>? categoryIds,
    List<String>? servedRegionIds,
    String? challengeId,
    bool? busy,
    Failure? failure,
    bool clearFailure = false,
  }) =>
      RegisterFormState(
        step: step ?? this.step,
        mobileNumber: mobileNumber ?? this.mobileNumber,
        legalBusinessName: legalBusinessName ?? this.legalBusinessName,
        tradingName: tradingName ?? this.tradingName,
        tradeLicenceNumber: tradeLicenceNumber ?? this.tradeLicenceNumber,
        licenceExpiryDate: licenceExpiryDate ?? this.licenceExpiryDate,
        businessAddress: businessAddress ?? this.businessAddress,
        contactPersonName: contactPersonName ?? this.contactPersonName,
        businessEmail: businessEmail ?? this.businessEmail,
        regionId: regionId ?? this.regionId,
        categoryIds: categoryIds ?? this.categoryIds,
        servedRegionIds: servedRegionIds ?? this.servedRegionIds,
        challengeId: challengeId ?? this.challengeId,
        busy: busy ?? this.busy,
        failure: clearFailure ? null : (failure ?? this.failure),
      );
}
