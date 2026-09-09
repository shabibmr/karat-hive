import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_exception.dart';
import 'package:kh_admin/core/auth/dev_auth.dart';
import 'package:kh_admin/core/auth/session_controller.dart';
import 'package:kh_admin/core/auth/session_state.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/firebase/firebase_init.dart';
import 'package:kh_admin/features/auth/presentation/login_screen.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

class _MockSessionController extends StateNotifier<SessionState>
    implements SessionController {
  _MockSessionController()
      : super(const SessionState(status: SessionStatus.unauthenticated));

  String? submittedEmail;
  String? submittedPassword;
  Object? errorToThrow;

  @override
  Future<void> init() async {}

  @override
  Future<void> login(String email, String password) async {
    submittedEmail = email;
    submittedPassword = password;
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    state = state.copyWith(status: SessionStatus.authenticated);
  }

  @override
  Future<void> loginWithPassword(String email, String password) =>
      login(email, password);

  @override
  Future<void> logout({bool broadcast = true}) async {
    state = const SessionState(status: SessionStatus.unauthenticated);
  }

  @override
  Future<bool> silentRefresh() async => true;
}

void main() {
  late _MockSessionController mockSessionController;

  setUp(() {
    mockSessionController = _MockSessionController();
  });

  Widget createLoginScreenWidget({
    bool devAutoLogin = true,
    FirebaseInitState firebaseInit =
        const FirebaseInitState(status: FirebaseInitStatus.initialized),
  }) {
    return ProviderScope(
      overrides: [
        sessionControllerProvider.overrideWith((ref) => mockSessionController),
        devAuthConfigProvider.overrideWithValue(
          DevAuthConfig(autoLogin: devAutoLogin, email: '', password: ''),
        ),
        firebaseInitStateProvider.overrideWith((ref) => firebaseInit),
      ],
      child: MaterialApp(
        theme: buildKhAdminTheme(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LoginScreen(),
      ),
    );
  }

  testWidgets('renders Karat Hive Art-Deco branding and input form fields',
      (tester) async {
    await tester.pumpWidget(createLoginScreenWidget());
    await tester.pumpAndSettle();

    expect(find.text('KARAT HIVE'), findsOneWidget);
    expect(find.text('Administrative Portal'), findsOneWidget);
    expect(find.byKey(const Key('login-email-field')), findsOneWidget);
    expect(find.byKey(const Key('login-password-field')), findsOneWidget);
    expect(find.byKey(const Key('login-submit-button')), findsOneWidget);
    expect(find.text('Authenticate & Enter Portal'), findsOneWidget);
  });

  testWidgets('validates required email and password fields on submit',
      (tester) async {
    await tester.pumpWidget(createLoginScreenWidget());
    await tester.pumpAndSettle();

    // Tap submit without entering data
    await tester.tap(find.byKey(const Key('login-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Admin email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(mockSessionController.submittedEmail, isNull);
  });

  testWidgets('validates email format and password minimum length (8 chars)',
      (tester) async {
    await tester.pumpWidget(createLoginScreenWidget());
    await tester.pumpAndSettle();

    // Enter invalid email and short password
    await tester.enterText(
        find.byKey(const Key('login-email-field')), 'notanemail');
    await tester.enterText(
        find.byKey(const Key('login-password-field')), '12345');
    await tester.tap(find.byKey(const Key('login-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email address'), findsOneWidget);
    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    expect(mockSessionController.submittedEmail, isNull);
  });

  testWidgets('submits valid credentials via loginWithPassword',
      (tester) async {
    await tester.pumpWidget(createLoginScreenWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('login-email-field')), 'admin@karathive.ae');
    await tester.enterText(
        find.byKey(const Key('login-password-field')), 'SecretAdminPassword123!');
    await tester.tap(find.byKey(const Key('login-submit-button')));
    await tester.pumpAndSettle();

    expect(mockSessionController.submittedEmail, 'admin@karathive.ae');
    expect(mockSessionController.submittedPassword, 'SecretAdminPassword123!');
    expect(find.byKey(const Key('login-error-banner')), findsNothing);
  });

  testWidgets('renders ACCOUNT_LOCKED error alert banner when account is locked',
      (tester) async {
    mockSessionController.errorToThrow = const ApiException(
      statusCode: 423,
      code: 'ACCOUNT_LOCKED',
      message: 'Account locked due to 3 failed attempts',
    );

    await tester.pumpWidget(createLoginScreenWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('login-email-field')), 'admin@karathive.ae');
    await tester.enterText(
        find.byKey(const Key('login-password-field')), 'SecretAdminPassword123!');
    await tester.tap(find.byKey(const Key('login-submit-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-error-banner')), findsOneWidget);
    expect(
      find.textContaining('temporarily locked due to consecutive failed login attempts'),
      findsOneWidget,
    );
  });

  testWidgets('renders UNAUTHENTICATED error alert for bad credentials',
      (tester) async {
    mockSessionController.errorToThrow = const ApiException(
      statusCode: 401,
      code: 'UNAUTHENTICATED',
      message: 'Invalid credentials provided',
    );

    await tester.pumpWidget(createLoginScreenWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('login-email-field')), 'admin@karathive.ae');
    await tester.enterText(
        find.byKey(const Key('login-password-field')), 'WrongPassword123!');
    await tester.tap(find.byKey(const Key('login-submit-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-error-banner')), findsOneWidget);
    expect(
      find.textContaining('Invalid administrative credentials'),
      findsOneWidget,
    );
  });

  testWidgets('renders server unavailable error alert for HTTP 503 error',
      (tester) async {
    mockSessionController.errorToThrow = const ApiException(
      statusCode: 503,
      code: 'SERVICE_UNAVAILABLE',
      message: 'Backend server unavailable',
    );

    await tester.pumpWidget(createLoginScreenWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('login-email-field')), 'admin@karathive.ae');
    await tester.enterText(
        find.byKey(const Key('login-password-field')), 'ValidPassword123!');
    await tester.tap(find.byKey(const Key('login-submit-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-error-banner')), findsOneWidget);
    expect(
      find.textContaining('Administrative service unavailable'),
      findsOneWidget,
    );
  });

  testWidgets(
      'renders only Google Sign-In button when devAutoLogin is false (production mode)',
      (tester) async {
    await tester.pumpWidget(createLoginScreenWidget(devAutoLogin: false));
    await tester.pumpAndSettle();

    expect(find.text('KARAT HIVE'), findsOneWidget);
    expect(find.text('Administrative Portal'), findsOneWidget);
    expect(find.byKey(const Key('login-google-button')), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.byKey(const Key('login-email-field')), findsNothing);
    expect(find.byKey(const Key('login-password-field')), findsNothing);
    expect(find.byKey(const Key('login-submit-button')), findsNothing);
    expect(find.text('OR'), findsNothing);
  });

  testWidgets(
      'blocks Google Sign-In and displays error when Firebase init fails in prod mode (TR-S4-19)',
      (tester) async {
    await tester.pumpWidget(
      createLoginScreenWidget(
        devAutoLogin: false,
        firebaseInit: const FirebaseInitState(
          status: FirebaseInitStatus.failed,
          error: 'Firebase mock init failed',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-error-banner')), findsOneWidget);
    expect(
      find.textContaining('Authentication service unavailable: Firebase initialization failed'),
      findsOneWidget,
    );

    // Google Sign-In button is disabled (onPressed == null)
    final button = tester.widget<OutlinedButton>(
      find.byKey(const Key('login-google-button')),
    );
    expect(button.onPressed, isNull);
  });
}
