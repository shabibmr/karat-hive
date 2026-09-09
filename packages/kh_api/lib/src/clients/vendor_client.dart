import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

class VendorClient {
  const VendorClient(this._client);
  final KhApiClient _client;

  Future<Result<VendorMe>> vendorMe() => _vendorMe('GET', '/v1/me/vendor');

  /// Safe + BR-004 profile fields. Do not send legal-identity keys from VEN-S15
  /// safe-edit (CP6-B02.2); those land behind the B02.4 warning flow.
  Future<Result<VendorMe>> patchProfile({
    String? tradingName,
    String? description,
    String? contactPersonName,
    String? businessEmail,
    String? legalBusinessName,
    String? tradeLicenceNumber,
    String? businessAddress,
  }) =>
      _vendorMe('PATCH', '/v1/me/vendor', body: {
        if (tradingName != null) 'tradingName': tradingName,
        if (description != null) 'description': description,
        if (contactPersonName != null) 'contactPersonName': contactPersonName,
        if (businessEmail != null) 'businessEmail': businessEmail,
        if (legalBusinessName != null) 'legalBusinessName': legalBusinessName,
        if (tradeLicenceNumber != null) 'tradeLicenceNumber': tradeLicenceNumber,
        if (businessAddress != null) 'businessAddress': businessAddress,
      });

  Future<Result<List<VendorDocument>>> documents() async {
    final r = await _client.send('GET', '/v1/me/vendor/documents');
    return r.when(
      ok: (d) => Ok(((d as List?) ?? const [])
          .map((e) => VendorDocument.fromJson(e as Map<String, dynamic>))
          .toList(growable: false)),
      err: Err.new,
    );
  }

  Future<Result<List<VendorDocument>>> attachDocument({
    required String documentType,
    required String mediaKey,
    String? expiryDate,
  }) async {
    final r = await _client.send('POST', '/v1/me/vendor/documents', body: {
      'documentType': documentType,
      'mediaKey': mediaKey,
      if (expiryDate != null) 'expiryDate': expiryDate,
    });
    return r.when(
      ok: (d) => Ok(((d as List?) ?? const [])
          .map((e) => VendorDocument.fromJson(e as Map<String, dynamic>))
          .toList(growable: false)),
      err: Err.new,
    );
  }

  Future<Result<VendorMe>> setCategories(List<String> ids) =>
      _vendorMe('PUT', '/v1/me/vendor/categories', body: {'categoryIds': ids});

  Future<Result<VendorMe>> setRegions(List<String> ids) =>
      _vendorMe('PUT', '/v1/me/vendor/regions', body: {'regionIds': ids});

  Future<Result<VendorMe>> setAvailability({bool? awayMode, Object? businessHours}) =>
      _vendorMe('PATCH', '/v1/me/vendor/availability', body: {
        if (awayMode != null) 'awayMode': awayMode,
        if (businessHours != null) 'businessHours': businessHours,
      });

  Future<Result<VendorMe>> resubmit() =>
      _vendorMe('POST', '/v1/me/vendor/resubmit');

  Future<Result<VendorMe>> _vendorMe(
    String method,
    String path, {
    Object? body,
  }) async {
    final r = await _client.send(method, path, body: body);
    return r.when(
      ok: (d) => Ok(VendorMe.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }
}
