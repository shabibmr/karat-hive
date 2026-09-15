import 'package:kh_core/kh_core.dart';

enum RegisterStep { details, otp, submitting, done }

class RegisterFormState {
  const RegisterFormState({
    this.wizardStep = 1,
    this.step = RegisterStep.details,
    this.contactPersonName = '',
    this.mobileNumber = '',
    this.designation = '',
    this.tradingName = '',
    this.legalBusinessName = '',
    this.website = '',
    this.tradeLicenceNumber = '',
    this.licenceExpiryDate = '',
    this.logoPath,
    this.addressBuilding = '',
    this.addressShopUnit = '',
    this.businessAddress = '',
    this.gpsCoordinates = '',
    this.whatsAppNumber = '',
    this.businessEmail = '',
    this.regionId,
    this.categoryIds = const [],
    this.servedRegionIds = const [],
    this.challengeId,
    this.termsAccepted = false,
    this.busy = false,
    this.failure,
  });

  final int wizardStep;
  final RegisterStep step;
  final String contactPersonName;
  final String mobileNumber;
  final String designation;
  final String tradingName;
  final String legalBusinessName;
  final String website;
  final String tradeLicenceNumber;
  final String licenceExpiryDate;
  final String? logoPath;
  final String addressBuilding;
  final String addressShopUnit;
  final String businessAddress;
  final String gpsCoordinates;
  final String whatsAppNumber;
  final String businessEmail;
  final String? regionId;
  final List<String> categoryIds;
  final List<String> servedRegionIds;
  final String? challengeId;
  final bool termsAccepted;
  final bool busy;
  final Failure? failure;

  bool get step1Complete =>
      contactPersonName.trim().isNotEmpty &&
      mobileNumber.trim().length >= 8;

  bool get step2Complete => tradingName.trim().isNotEmpty;

  bool get step3Complete => regionId != null;

  bool get step4Complete =>
      whatsAppNumber.trim().length >= 8 && termsAccepted;

  bool get detailsComplete =>
      step1Complete && step2Complete && step3Complete && step4Complete;

  String get fullAddress {
    if (businessAddress.isNotEmpty) return businessAddress;
    final parts = [
      if (addressShopUnit.isNotEmpty) 'Shop/Unit: $addressShopUnit',
      if (addressBuilding.isNotEmpty) addressBuilding,
      if (gpsCoordinates.isNotEmpty) 'GPS: $gpsCoordinates',
    ];
    return parts.join(', ');
  }

  Map<String, dynamic> toRegisterBody() => {
        if (challengeId != null) 'challengeId': challengeId,
        // Temporary: typed mobile without OTP while SMS send is deferred.
        'mobileNumber': mobileNumber,
        'legalBusinessName': legalBusinessName.isNotEmpty ? legalBusinessName : tradingName,
        'tradingName': tradingName,
        'website': website,
        'tradeLicenceNumber': tradeLicenceNumber.isNotEmpty ? tradeLicenceNumber : 'PENDING_UPLOAD',
        'licenceExpiryDate': licenceExpiryDate.isNotEmpty ? licenceExpiryDate : '2028-01-01',
        'businessAddress': fullAddress.isNotEmpty ? fullAddress : 'UAE',
        'contactPersonName': contactPersonName,
        'businessEmail': businessEmail.isNotEmpty ? businessEmail : '${tradingName.toLowerCase().replaceAll(RegExp(r'\s+'), '')}@karathive.ae',
        'regionId': regionId,
        'categoryIds': categoryIds,
        'servedRegionIds': servedRegionIds.isNotEmpty ? servedRegionIds : (regionId != null ? [regionId!] : <String>[]),
        'termsVersion': '1.0',
        'privacyVersion': '1.0',
      };

  RegisterFormState copyWith({
    int? wizardStep,
    RegisterStep? step,
    String? contactPersonName,
    String? mobileNumber,
    String? designation,
    String? tradingName,
    String? legalBusinessName,
    String? website,
    String? tradeLicenceNumber,
    String? licenceExpiryDate,
    String? logoPath,
    String? addressBuilding,
    String? addressShopUnit,
    String? businessAddress,
    String? gpsCoordinates,
    String? whatsAppNumber,
    String? businessEmail,
    String? regionId,
    List<String>? categoryIds,
    List<String>? servedRegionIds,
    String? challengeId,
    bool? termsAccepted,
    bool? busy,
    Failure? failure,
    bool clearFailure = false,
  }) =>
      RegisterFormState(
        wizardStep: wizardStep ?? this.wizardStep,
        step: step ?? this.step,
        contactPersonName: contactPersonName ?? this.contactPersonName,
        mobileNumber: mobileNumber ?? this.mobileNumber,
        designation: designation ?? this.designation,
        tradingName: tradingName ?? this.tradingName,
        legalBusinessName: legalBusinessName ?? this.legalBusinessName,
        website: website ?? this.website,
        tradeLicenceNumber: tradeLicenceNumber ?? this.tradeLicenceNumber,
        licenceExpiryDate: licenceExpiryDate ?? this.licenceExpiryDate,
        logoPath: logoPath ?? this.logoPath,
        addressBuilding: addressBuilding ?? this.addressBuilding,
        addressShopUnit: addressShopUnit ?? this.addressShopUnit,
        businessAddress: businessAddress ?? this.businessAddress,
        gpsCoordinates: gpsCoordinates ?? this.gpsCoordinates,
        whatsAppNumber: whatsAppNumber ?? this.whatsAppNumber,
        businessEmail: businessEmail ?? this.businessEmail,
        regionId: regionId ?? this.regionId,
        categoryIds: categoryIds ?? this.categoryIds,
        servedRegionIds: servedRegionIds ?? this.servedRegionIds,
        challengeId: challengeId ?? this.challengeId,
        termsAccepted: termsAccepted ?? this.termsAccepted,
        busy: busy ?? this.busy,
        failure: clearFailure ? null : (failure ?? this.failure),
      );
}
