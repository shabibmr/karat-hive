// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendor_verification_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VendorVerificationDetail _$VendorVerificationDetailFromJson(
  Map<String, dynamic> json,
) {
  return _VendorVerificationDetail.fromJson(json);
}

/// @nodoc
mixin _$VendorVerificationDetail {
  String get id => throw _privateConstructorUsedError;
  String get legalBusinessName => throw _privateConstructorUsedError;
  String get tradeLicenceNumber => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateFromJson)
  DateTime get licenceExpiryDate => throw _privateConstructorUsedError;
  String get businessAddress => throw _privateConstructorUsedError;
  String get contactPersonName => throw _privateConstructorUsedError;
  String get businessEmail => throw _privateConstructorUsedError;
  List<VendorDocumentDetail> get documents =>
      throw _privateConstructorUsedError;
  List<String> get categories => throw _privateConstructorUsedError;
  List<String> get regions => throw _privateConstructorUsedError;
  String? get tradingName => throw _privateConstructorUsedError;
  String? get mobileNumber => throw _privateConstructorUsedError;
  double? get oldestWaitingHours => throw _privateConstructorUsedError;
  DateTime? get submittedAt => throw _privateConstructorUsedError;

  /// Serializes this VendorVerificationDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VendorVerificationDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VendorVerificationDetailCopyWith<VendorVerificationDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VendorVerificationDetailCopyWith<$Res> {
  factory $VendorVerificationDetailCopyWith(
    VendorVerificationDetail value,
    $Res Function(VendorVerificationDetail) then,
  ) = _$VendorVerificationDetailCopyWithImpl<$Res, VendorVerificationDetail>;
  @useResult
  $Res call({
    String id,
    String legalBusinessName,
    String tradeLicenceNumber,
    @JsonKey(fromJson: _dateFromJson) DateTime licenceExpiryDate,
    String businessAddress,
    String contactPersonName,
    String businessEmail,
    List<VendorDocumentDetail> documents,
    List<String> categories,
    List<String> regions,
    String? tradingName,
    String? mobileNumber,
    double? oldestWaitingHours,
    DateTime? submittedAt,
  });
}

/// @nodoc
class _$VendorVerificationDetailCopyWithImpl<
  $Res,
  $Val extends VendorVerificationDetail
>
    implements $VendorVerificationDetailCopyWith<$Res> {
  _$VendorVerificationDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VendorVerificationDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? legalBusinessName = null,
    Object? tradeLicenceNumber = null,
    Object? licenceExpiryDate = null,
    Object? businessAddress = null,
    Object? contactPersonName = null,
    Object? businessEmail = null,
    Object? documents = null,
    Object? categories = null,
    Object? regions = null,
    Object? tradingName = freezed,
    Object? mobileNumber = freezed,
    Object? oldestWaitingHours = freezed,
    Object? submittedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            legalBusinessName: null == legalBusinessName
                ? _value.legalBusinessName
                : legalBusinessName // ignore: cast_nullable_to_non_nullable
                      as String,
            tradeLicenceNumber: null == tradeLicenceNumber
                ? _value.tradeLicenceNumber
                : tradeLicenceNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            licenceExpiryDate: null == licenceExpiryDate
                ? _value.licenceExpiryDate
                : licenceExpiryDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            businessAddress: null == businessAddress
                ? _value.businessAddress
                : businessAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            contactPersonName: null == contactPersonName
                ? _value.contactPersonName
                : contactPersonName // ignore: cast_nullable_to_non_nullable
                      as String,
            businessEmail: null == businessEmail
                ? _value.businessEmail
                : businessEmail // ignore: cast_nullable_to_non_nullable
                      as String,
            documents: null == documents
                ? _value.documents
                : documents // ignore: cast_nullable_to_non_nullable
                      as List<VendorDocumentDetail>,
            categories: null == categories
                ? _value.categories
                : categories // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            regions: null == regions
                ? _value.regions
                : regions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            tradingName: freezed == tradingName
                ? _value.tradingName
                : tradingName // ignore: cast_nullable_to_non_nullable
                      as String?,
            mobileNumber: freezed == mobileNumber
                ? _value.mobileNumber
                : mobileNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            oldestWaitingHours: freezed == oldestWaitingHours
                ? _value.oldestWaitingHours
                : oldestWaitingHours // ignore: cast_nullable_to_non_nullable
                      as double?,
            submittedAt: freezed == submittedAt
                ? _value.submittedAt
                : submittedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VendorVerificationDetailImplCopyWith<$Res>
    implements $VendorVerificationDetailCopyWith<$Res> {
  factory _$$VendorVerificationDetailImplCopyWith(
    _$VendorVerificationDetailImpl value,
    $Res Function(_$VendorVerificationDetailImpl) then,
  ) = __$$VendorVerificationDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String legalBusinessName,
    String tradeLicenceNumber,
    @JsonKey(fromJson: _dateFromJson) DateTime licenceExpiryDate,
    String businessAddress,
    String contactPersonName,
    String businessEmail,
    List<VendorDocumentDetail> documents,
    List<String> categories,
    List<String> regions,
    String? tradingName,
    String? mobileNumber,
    double? oldestWaitingHours,
    DateTime? submittedAt,
  });
}

/// @nodoc
class __$$VendorVerificationDetailImplCopyWithImpl<$Res>
    extends
        _$VendorVerificationDetailCopyWithImpl<
          $Res,
          _$VendorVerificationDetailImpl
        >
    implements _$$VendorVerificationDetailImplCopyWith<$Res> {
  __$$VendorVerificationDetailImplCopyWithImpl(
    _$VendorVerificationDetailImpl _value,
    $Res Function(_$VendorVerificationDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VendorVerificationDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? legalBusinessName = null,
    Object? tradeLicenceNumber = null,
    Object? licenceExpiryDate = null,
    Object? businessAddress = null,
    Object? contactPersonName = null,
    Object? businessEmail = null,
    Object? documents = null,
    Object? categories = null,
    Object? regions = null,
    Object? tradingName = freezed,
    Object? mobileNumber = freezed,
    Object? oldestWaitingHours = freezed,
    Object? submittedAt = freezed,
  }) {
    return _then(
      _$VendorVerificationDetailImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        legalBusinessName: null == legalBusinessName
            ? _value.legalBusinessName
            : legalBusinessName // ignore: cast_nullable_to_non_nullable
                  as String,
        tradeLicenceNumber: null == tradeLicenceNumber
            ? _value.tradeLicenceNumber
            : tradeLicenceNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        licenceExpiryDate: null == licenceExpiryDate
            ? _value.licenceExpiryDate
            : licenceExpiryDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        businessAddress: null == businessAddress
            ? _value.businessAddress
            : businessAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        contactPersonName: null == contactPersonName
            ? _value.contactPersonName
            : contactPersonName // ignore: cast_nullable_to_non_nullable
                  as String,
        businessEmail: null == businessEmail
            ? _value.businessEmail
            : businessEmail // ignore: cast_nullable_to_non_nullable
                  as String,
        documents: null == documents
            ? _value._documents
            : documents // ignore: cast_nullable_to_non_nullable
                  as List<VendorDocumentDetail>,
        categories: null == categories
            ? _value._categories
            : categories // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        regions: null == regions
            ? _value._regions
            : regions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        tradingName: freezed == tradingName
            ? _value.tradingName
            : tradingName // ignore: cast_nullable_to_non_nullable
                  as String?,
        mobileNumber: freezed == mobileNumber
            ? _value.mobileNumber
            : mobileNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        oldestWaitingHours: freezed == oldestWaitingHours
            ? _value.oldestWaitingHours
            : oldestWaitingHours // ignore: cast_nullable_to_non_nullable
                  as double?,
        submittedAt: freezed == submittedAt
            ? _value.submittedAt
            : submittedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VendorVerificationDetailImpl implements _VendorVerificationDetail {
  const _$VendorVerificationDetailImpl({
    required this.id,
    required this.legalBusinessName,
    required this.tradeLicenceNumber,
    @JsonKey(fromJson: _dateFromJson) required this.licenceExpiryDate,
    required this.businessAddress,
    required this.contactPersonName,
    required this.businessEmail,
    final List<VendorDocumentDetail> documents = const <VendorDocumentDetail>[],
    final List<String> categories = const <String>[],
    final List<String> regions = const <String>[],
    this.tradingName,
    this.mobileNumber,
    this.oldestWaitingHours,
    this.submittedAt,
  }) : _documents = documents,
       _categories = categories,
       _regions = regions;

  factory _$VendorVerificationDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$VendorVerificationDetailImplFromJson(json);

  @override
  final String id;
  @override
  final String legalBusinessName;
  @override
  final String tradeLicenceNumber;
  @override
  @JsonKey(fromJson: _dateFromJson)
  final DateTime licenceExpiryDate;
  @override
  final String businessAddress;
  @override
  final String contactPersonName;
  @override
  final String businessEmail;
  final List<VendorDocumentDetail> _documents;
  @override
  @JsonKey()
  List<VendorDocumentDetail> get documents {
    if (_documents is EqualUnmodifiableListView) return _documents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_documents);
  }

  final List<String> _categories;
  @override
  @JsonKey()
  List<String> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  final List<String> _regions;
  @override
  @JsonKey()
  List<String> get regions {
    if (_regions is EqualUnmodifiableListView) return _regions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_regions);
  }

  @override
  final String? tradingName;
  @override
  final String? mobileNumber;
  @override
  final double? oldestWaitingHours;
  @override
  final DateTime? submittedAt;

  @override
  String toString() {
    return 'VendorVerificationDetail(id: $id, legalBusinessName: $legalBusinessName, tradeLicenceNumber: $tradeLicenceNumber, licenceExpiryDate: $licenceExpiryDate, businessAddress: $businessAddress, contactPersonName: $contactPersonName, businessEmail: $businessEmail, documents: $documents, categories: $categories, regions: $regions, tradingName: $tradingName, mobileNumber: $mobileNumber, oldestWaitingHours: $oldestWaitingHours, submittedAt: $submittedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VendorVerificationDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.legalBusinessName, legalBusinessName) ||
                other.legalBusinessName == legalBusinessName) &&
            (identical(other.tradeLicenceNumber, tradeLicenceNumber) ||
                other.tradeLicenceNumber == tradeLicenceNumber) &&
            (identical(other.licenceExpiryDate, licenceExpiryDate) ||
                other.licenceExpiryDate == licenceExpiryDate) &&
            (identical(other.businessAddress, businessAddress) ||
                other.businessAddress == businessAddress) &&
            (identical(other.contactPersonName, contactPersonName) ||
                other.contactPersonName == contactPersonName) &&
            (identical(other.businessEmail, businessEmail) ||
                other.businessEmail == businessEmail) &&
            const DeepCollectionEquality().equals(
              other._documents,
              _documents,
            ) &&
            const DeepCollectionEquality().equals(
              other._categories,
              _categories,
            ) &&
            const DeepCollectionEquality().equals(other._regions, _regions) &&
            (identical(other.tradingName, tradingName) ||
                other.tradingName == tradingName) &&
            (identical(other.mobileNumber, mobileNumber) ||
                other.mobileNumber == mobileNumber) &&
            (identical(other.oldestWaitingHours, oldestWaitingHours) ||
                other.oldestWaitingHours == oldestWaitingHours) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    legalBusinessName,
    tradeLicenceNumber,
    licenceExpiryDate,
    businessAddress,
    contactPersonName,
    businessEmail,
    const DeepCollectionEquality().hash(_documents),
    const DeepCollectionEquality().hash(_categories),
    const DeepCollectionEquality().hash(_regions),
    tradingName,
    mobileNumber,
    oldestWaitingHours,
    submittedAt,
  );

  /// Create a copy of VendorVerificationDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VendorVerificationDetailImplCopyWith<_$VendorVerificationDetailImpl>
  get copyWith =>
      __$$VendorVerificationDetailImplCopyWithImpl<
        _$VendorVerificationDetailImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VendorVerificationDetailImplToJson(this);
  }
}

abstract class _VendorVerificationDetail implements VendorVerificationDetail {
  const factory _VendorVerificationDetail({
    required final String id,
    required final String legalBusinessName,
    required final String tradeLicenceNumber,
    @JsonKey(fromJson: _dateFromJson) required final DateTime licenceExpiryDate,
    required final String businessAddress,
    required final String contactPersonName,
    required final String businessEmail,
    final List<VendorDocumentDetail> documents,
    final List<String> categories,
    final List<String> regions,
    final String? tradingName,
    final String? mobileNumber,
    final double? oldestWaitingHours,
    final DateTime? submittedAt,
  }) = _$VendorVerificationDetailImpl;

  factory _VendorVerificationDetail.fromJson(Map<String, dynamic> json) =
      _$VendorVerificationDetailImpl.fromJson;

  @override
  String get id;
  @override
  String get legalBusinessName;
  @override
  String get tradeLicenceNumber;
  @override
  @JsonKey(fromJson: _dateFromJson)
  DateTime get licenceExpiryDate;
  @override
  String get businessAddress;
  @override
  String get contactPersonName;
  @override
  String get businessEmail;
  @override
  List<VendorDocumentDetail> get documents;
  @override
  List<String> get categories;
  @override
  List<String> get regions;
  @override
  String? get tradingName;
  @override
  String? get mobileNumber;
  @override
  double? get oldestWaitingHours;
  @override
  DateTime? get submittedAt;

  /// Create a copy of VendorVerificationDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VendorVerificationDetailImplCopyWith<_$VendorVerificationDetailImpl>
  get copyWith => throw _privateConstructorUsedError;
}

VendorDocumentDetail _$VendorDocumentDetailFromJson(Map<String, dynamic> json) {
  return _VendorDocumentDetail.fromJson(json);
}

/// @nodoc
mixin _$VendorDocumentDetail {
  String get id => throw _privateConstructorUsedError;
  String get documentType => throw _privateConstructorUsedError;
  DateTime get uploadedAt => throw _privateConstructorUsedError;
  String? get fileName => throw _privateConstructorUsedError;
  String? get mimeType => throw _privateConstructorUsedError;
  int? get sizeBytes => throw _privateConstructorUsedError;
  DateTime? get expiryDate => throw _privateConstructorUsedError;
  bool get verified => throw _privateConstructorUsedError;

  /// Serializes this VendorDocumentDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VendorDocumentDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VendorDocumentDetailCopyWith<VendorDocumentDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VendorDocumentDetailCopyWith<$Res> {
  factory $VendorDocumentDetailCopyWith(
    VendorDocumentDetail value,
    $Res Function(VendorDocumentDetail) then,
  ) = _$VendorDocumentDetailCopyWithImpl<$Res, VendorDocumentDetail>;
  @useResult
  $Res call({
    String id,
    String documentType,
    DateTime uploadedAt,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
    DateTime? expiryDate,
    bool verified,
  });
}

/// @nodoc
class _$VendorDocumentDetailCopyWithImpl<
  $Res,
  $Val extends VendorDocumentDetail
>
    implements $VendorDocumentDetailCopyWith<$Res> {
  _$VendorDocumentDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VendorDocumentDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? documentType = null,
    Object? uploadedAt = null,
    Object? fileName = freezed,
    Object? mimeType = freezed,
    Object? sizeBytes = freezed,
    Object? expiryDate = freezed,
    Object? verified = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            documentType: null == documentType
                ? _value.documentType
                : documentType // ignore: cast_nullable_to_non_nullable
                      as String,
            uploadedAt: null == uploadedAt
                ? _value.uploadedAt
                : uploadedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            fileName: freezed == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String?,
            mimeType: freezed == mimeType
                ? _value.mimeType
                : mimeType // ignore: cast_nullable_to_non_nullable
                      as String?,
            sizeBytes: freezed == sizeBytes
                ? _value.sizeBytes
                : sizeBytes // ignore: cast_nullable_to_non_nullable
                      as int?,
            expiryDate: freezed == expiryDate
                ? _value.expiryDate
                : expiryDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            verified: null == verified
                ? _value.verified
                : verified // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VendorDocumentDetailImplCopyWith<$Res>
    implements $VendorDocumentDetailCopyWith<$Res> {
  factory _$$VendorDocumentDetailImplCopyWith(
    _$VendorDocumentDetailImpl value,
    $Res Function(_$VendorDocumentDetailImpl) then,
  ) = __$$VendorDocumentDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String documentType,
    DateTime uploadedAt,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
    DateTime? expiryDate,
    bool verified,
  });
}

/// @nodoc
class __$$VendorDocumentDetailImplCopyWithImpl<$Res>
    extends _$VendorDocumentDetailCopyWithImpl<$Res, _$VendorDocumentDetailImpl>
    implements _$$VendorDocumentDetailImplCopyWith<$Res> {
  __$$VendorDocumentDetailImplCopyWithImpl(
    _$VendorDocumentDetailImpl _value,
    $Res Function(_$VendorDocumentDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VendorDocumentDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? documentType = null,
    Object? uploadedAt = null,
    Object? fileName = freezed,
    Object? mimeType = freezed,
    Object? sizeBytes = freezed,
    Object? expiryDate = freezed,
    Object? verified = null,
  }) {
    return _then(
      _$VendorDocumentDetailImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        documentType: null == documentType
            ? _value.documentType
            : documentType // ignore: cast_nullable_to_non_nullable
                  as String,
        uploadedAt: null == uploadedAt
            ? _value.uploadedAt
            : uploadedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        fileName: freezed == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String?,
        mimeType: freezed == mimeType
            ? _value.mimeType
            : mimeType // ignore: cast_nullable_to_non_nullable
                  as String?,
        sizeBytes: freezed == sizeBytes
            ? _value.sizeBytes
            : sizeBytes // ignore: cast_nullable_to_non_nullable
                  as int?,
        expiryDate: freezed == expiryDate
            ? _value.expiryDate
            : expiryDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        verified: null == verified
            ? _value.verified
            : verified // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VendorDocumentDetailImpl implements _VendorDocumentDetail {
  const _$VendorDocumentDetailImpl({
    required this.id,
    required this.documentType,
    required this.uploadedAt,
    this.fileName,
    this.mimeType,
    this.sizeBytes,
    this.expiryDate,
    this.verified = false,
  });

  factory _$VendorDocumentDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$VendorDocumentDetailImplFromJson(json);

  @override
  final String id;
  @override
  final String documentType;
  @override
  final DateTime uploadedAt;
  @override
  final String? fileName;
  @override
  final String? mimeType;
  @override
  final int? sizeBytes;
  @override
  final DateTime? expiryDate;
  @override
  @JsonKey()
  final bool verified;

  @override
  String toString() {
    return 'VendorDocumentDetail(id: $id, documentType: $documentType, uploadedAt: $uploadedAt, fileName: $fileName, mimeType: $mimeType, sizeBytes: $sizeBytes, expiryDate: $expiryDate, verified: $verified)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VendorDocumentDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.documentType, documentType) ||
                other.documentType == documentType) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.sizeBytes, sizeBytes) ||
                other.sizeBytes == sizeBytes) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.verified, verified) ||
                other.verified == verified));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    documentType,
    uploadedAt,
    fileName,
    mimeType,
    sizeBytes,
    expiryDate,
    verified,
  );

  /// Create a copy of VendorDocumentDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VendorDocumentDetailImplCopyWith<_$VendorDocumentDetailImpl>
  get copyWith =>
      __$$VendorDocumentDetailImplCopyWithImpl<_$VendorDocumentDetailImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VendorDocumentDetailImplToJson(this);
  }
}

abstract class _VendorDocumentDetail implements VendorDocumentDetail {
  const factory _VendorDocumentDetail({
    required final String id,
    required final String documentType,
    required final DateTime uploadedAt,
    final String? fileName,
    final String? mimeType,
    final int? sizeBytes,
    final DateTime? expiryDate,
    final bool verified,
  }) = _$VendorDocumentDetailImpl;

  factory _VendorDocumentDetail.fromJson(Map<String, dynamic> json) =
      _$VendorDocumentDetailImpl.fromJson;

  @override
  String get id;
  @override
  String get documentType;
  @override
  DateTime get uploadedAt;
  @override
  String? get fileName;
  @override
  String? get mimeType;
  @override
  int? get sizeBytes;
  @override
  DateTime? get expiryDate;
  @override
  bool get verified;

  /// Create a copy of VendorDocumentDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VendorDocumentDetailImplCopyWith<_$VendorDocumentDetailImpl>
  get copyWith => throw _privateConstructorUsedError;
}
