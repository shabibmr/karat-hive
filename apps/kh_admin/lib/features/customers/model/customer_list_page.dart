import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/customers/model/customer_list_item.dart';

/// Cursor-paginated slice of the admin customer list.
typedef CustomerListPage = Paginated<CustomerListItem>;
