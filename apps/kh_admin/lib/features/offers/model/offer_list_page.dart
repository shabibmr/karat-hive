import 'package:kh_admin/core/list/paginated.dart';
import 'package:kh_admin/features/offers/model/offer_list_item.dart';

/// Cursor-paginated slice of the admin offers list (TR-S1-13).
typedef OfferListPage = Paginated<OfferListItem>;
