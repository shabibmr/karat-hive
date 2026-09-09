/// Central route path dictionary for Karat Hive Admin Portal.
///
/// TR-S4-21: Replaces duplicated magic strings between `kAdminNavItems`,
/// `GoRoute` table, and feature drill-down handlers.
abstract final class AdminRoutes {
  static const dashboard = '/';
  static const login = '/login';
  static const contractMismatch = '/contract-mismatch';

  // Primary verticals
  static const customers = '/customers';
  static const customerDetail = ':id';

  static const vendors = '/vendors';
  static const vendorDetail = ':id';

  static const verification = '/verification';

  static const requests = '/requests';
  static const requestDetail = ':id';

  static const offers = '/offers';
  static const offerDetail = ':id';

  static const connections = '/connections';
  static const connectionDetail = ':id';

  // Taxonomy
  static const categories = '/taxonomy/categories';
  static const regions = '/taxonomy/regions';

  // Operations & Governance
  static const moderation = '/moderation';
  static const reports = '/reports';
  static const announcements = '/announcements';
  static const settings = '/settings';
  static const abuse = '/abuse';
  static const audit = '/audit';
  static const adminUsers = '/admin-users';

  // Helper builders for deep-links
  static String customer(String id) => '$customers/$id';
  static String vendor(String id) => '$vendors/$id';
  static String request(String id) => '$requests/$id';
  static String offer(String id) => '$offers/$id';
  static String connection(String id) => '$connections/$id';
}
