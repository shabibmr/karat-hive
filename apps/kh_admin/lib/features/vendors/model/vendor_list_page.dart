import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/vendors/model/vendor_list_item.dart';

/// Cursor-paginated slice of the admin vendor list (TR-S1-13).
typedef VendorListPage = Paginated<VendorListItem>;
