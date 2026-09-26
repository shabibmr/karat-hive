import 'dart:math';
import 'dart:typed_data';

import 'package:kh_core/kh_core.dart';

import 'customer_completion_form.dart';

enum RegisterStep { details, otp, submitting, done }

/// Unique stand-in until KYC supplies the real trade licence (VO-02).
/// Must stay under backend max length (50) and keep the `PENDING_` prefix.
String provisionalTradeLicenceNumber([Random? random]) {
  final r = random ?? Random.secure();
  final hex = List.generate(16, (_) => r.nextInt(16).toRadixString(16)).join();
  return 'PENDING_$hex';
}

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
    this.logoBytes,
    this.logoContentType,
    this.addressBuilding = '',
    this.addressShopUnit = '',
    this.businessAddress = '',
    this.gpsCoordinates = '',
    this.whatsAppNumber = '',
    this.businessEmail = '',
    this.googleEmailLocked = false,
    this.regionId,
    this.servedRegionIds = const [],
    this.challengeId,
    this.firebaseIdToken = '',
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
  final Uint8List? logoBytes;
  final String? logoContentType;
  final String addressBuilding;
  final String addressShopUnit;
  final String businessAddress;
  final String gpsCoordinates;
  final String whatsAppNumber;
  final String businessEmail;
  /// True when [businessEmail] came from Google sign-in — must not be edited.
  final bool googleEmailLocked;
  final String? regionId;
  final List<String> servedRegionIds;
  final String? challengeId;
  /// Firebase ID token from Google-first login (`adr/0010`). Bound on register.
  final String firebaseIdToken;
  final bool termsAccepted;
  final bool busy;
  final Failure? failure;

  bool get step1Complete =>
      contactPersonName.trim().isNotEmpty &&
      CustomerCompletionForm.looksLikeE164(mobileNumber) &&
      (!googleEmailLocked || businessEmail.trim().isNotEmpty);

  bool get step2Complete => tradingName.trim().isNotEmpty;

  bool get step3Complete => regionId != null && fullAddress.isNotEmpty;

  bool get step4Complete =>
      CustomerCompletionForm.looksLikeE164(whatsAppNumber) &&
      businessEmail.trim().isNotEmpty &&
      termsAccepted;

  bool get detailsComplete =>
      step1Complete && step2Complete && step3Complete && step4Complete;

  String get fullAddress {
    if (businessAddress.trim().isNotEmpty) return businessAddress.trim();
    final parts = [
      if (addressShopUnit.trim().isNotEmpty) 'Shop/Unit: ${addressShopUnit.trim()}',
      if (addressBuilding.trim().isNotEmpty) addressBuilding.trim(),
      if (gpsCoordinates.trim().isNotEmpty) 'GPS: ${gpsCoordinates.trim()}',
    ];
    return parts.join(', ');
  }

  Map<String, dynamic> toRegisterBody() {
    final email = businessEmail.trim();
    final address = fullAddress;
    return {
      if (challengeId != null) 'challengeId': challengeId,
      if (firebaseIdToken.isNotEmpty) 'firebaseToken': firebaseIdToken,
      // Temporary: typed mobile without OTP while SMS send is deferred.
      'mobileNumber': CustomerCompletionForm.normalizeMobile(mobileNumber),
      'legalBusinessName':
          legalBusinessName.isNotEmpty ? legalBusinessName : tradingName,
      'tradingName': tradingName,
      'website': website,
      'tradeLicenceNumber': tradeLicenceNumber.isNotEmpty
          ? tradeLicenceNumber
          : provisionalTradeLicenceNumber(),
      // Placeholder until KYC patches the real expiry (VO-03).
      'licenceExpiryDate':
          licenceExpiryDate.isNotEmpty ? licenceExpiryDate : '2028-01-01',
      'businessAddress': address,
      'contactPersonName': contactPersonName,
      'businessEmail': email,
      if (CustomerCompletionForm.looksLikeE164(whatsAppNumber))
        'contactWhatsApp':
            CustomerCompletionForm.normalizeMobile(whatsAppNumber),
      'regionId': regionId,
      'servedRegionIds': servedRegionIds.isNotEmpty
          ? servedRegionIds
          : [if (regionId != null) regionId!],
      'termsVersion': '1.0',
      'privacyVersion': '1.0',
    };
  }

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
    Uint8List? logoBytes,
    String? logoContentType,
    String? addressBuilding,
    String? addressShopUnit,
    String? businessAddress,
    String? gpsCoordinates,
    String? whatsAppNumber,
    String? businessEmail,
    bool? googleEmailLocked,
    String? regionId,
    List<String>? servedRegionIds,
    String? challengeId,
    String? firebaseIdToken,
    bool? termsAccepted,
    bool? busy,
    Failure? failure,
    bool clearFailure = false,
    bool clearLogo = false,
  }) {
    final locked = googleEmailLocked ?? this.googleEmailLocked;
    return RegisterFormState(
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
      logoPath: clearLogo ? null : (logoPath ?? this.logoPath),
      logoBytes: clearLogo ? null : (logoBytes ?? this.logoBytes),
      logoContentType:
          clearLogo ? null : (logoContentType ?? this.logoContentType),
      addressBuilding: addressBuilding ?? this.addressBuilding,
      addressShopUnit: addressShopUnit ?? this.addressShopUnit,
      businessAddress: businessAddress ?? this.businessAddress,
      gpsCoordinates: gpsCoordinates ?? this.gpsCoordinates,
      whatsAppNumber: whatsAppNumber ?? this.whatsAppNumber,
      // Once locked to Google, ignore later edits (auth identity).
      businessEmail: locked && this.businessEmail.isNotEmpty
          ? this.businessEmail
          : (businessEmail ?? this.businessEmail),
      googleEmailLocked: locked,
      regionId: regionId ?? this.regionId,
      servedRegionIds: servedRegionIds ?? this.servedRegionIds,
      challengeId: challengeId ?? this.challengeId,
      firebaseIdToken: firebaseIdToken ?? this.firebaseIdToken,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      busy: busy ?? this.busy,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}
