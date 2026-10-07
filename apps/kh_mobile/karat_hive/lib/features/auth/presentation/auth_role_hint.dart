import 'package:kh_core/kh_core.dart';

/// True when the server says the existing account is a Vendor.
///
/// Admin and any other role keep the error text and do not offer the vendor door.
bool showsVendorDoor(Failure failure) =>
    failure.fieldErrors['userType'] == 'VENDOR' || failure.details['actualRole'] == 'VENDOR';
