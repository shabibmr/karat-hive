import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

class DashboardClient {
  const DashboardClient(this._client);
  final KhApiClient _client;

  Future<Result<VendorDashboard>> getDashboard() async {
    final r = await _client.send('GET', '/v1/me/dashboard');
    return r.when(
      ok: (d) => Ok(VendorDashboard.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }
}
