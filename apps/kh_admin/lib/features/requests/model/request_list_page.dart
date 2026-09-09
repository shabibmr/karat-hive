import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/requests/model/request_list_item.dart';

/// Cursor-paginated slice of the admin request list (TR-S1-13).
typedef RequestListPage = Paginated<RequestListItem>;
