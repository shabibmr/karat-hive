import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/auth/presentation/auth_role_hint.dart';
import 'package:kh_core/kh_core.dart';

void main() {
  test('vendor door is offered only when the account is VENDOR', () {
    expect(
      showsVendorDoor(const ForbiddenFailure(
        code: 'ACCOUNT_ROLE_MISMATCH',
        fieldErrors: {'userType': 'VENDOR'},
      )),
      isTrue,
    );
    expect(
      showsVendorDoor(const ConflictFailure(
        code: 'ACCOUNT_ROLE_CONFLICT',
        fieldErrors: {'userType': 'ADMIN'},
      )),
      isFalse,
    );
    expect(
      showsVendorDoor(const ForbiddenFailure(
        code: 'ACCOUNT_ROLE_MISMATCH',
        details: {'actualRole': 'VENDOR'},
      )),
      isTrue,
    );
    expect(
      showsVendorDoor(const ForbiddenFailure(
        code: 'ACCOUNT_ROLE_MISMATCH',
        details: {'actualRole': 'ADMIN'},
      )),
      isFalse,
    );
    expect(
      showsVendorDoor(const ForbiddenFailure(code: 'ACCOUNT_ROLE_MISMATCH')),
      isFalse,
    );
  });
}
