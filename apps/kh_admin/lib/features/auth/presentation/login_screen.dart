import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/design/theme/kh_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Admin Login Screen (ADM-S01)
/// Authenticates Platform Administrators with email and password.
/// Styled with Art-Deco geometric card frame and Karat Hive sapphire/gold design tokens.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  static final RegExp _emailRegExp = RegExp(
    r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$',
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      await ref.read(sessionControllerProvider.notifier).loginWithPassword(
            email,
            password,
          );
      // Navigation is handled reactively by GoRouter via RouterNotifier listening to SessionController
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _resolveErrorMessage(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _resolveErrorMessage(Object error) {
    final l10n = AppLocalizations.of(context);

    if (error is ApiException) {
      if (error.code == 'ACCOUNT_LOCKED' || error.statusCode == 423) {
        return l10n?.errorAccountLocked ??
            'Your administrative account has been temporarily locked due to consecutive failed login attempts. Please wait 30 minutes or contact security.';
      }
      if (error.code == 'UNAUTHENTICATED' || error.statusCode == 401) {
        return l10n?.errorInvalidCredentials ??
            'Invalid administrative credentials. Please check your email and password.';
      }
      if (error.statusCode >= 500 && error.statusCode < 600) {
        return l10n?.errorServerUnavailable ??
            'Administrative service unavailable. Please check your connection and try again.';
      }
      if (error.message.isNotEmpty) {
        return error.message;
      }
    }

    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return l10n?.errorServerUnavailable ??
            'Administrative service unavailable. Please check your connection and try again.';
      }
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic> &&
          responseData['error'] is Map<String, dynamic>) {
        final err = responseData['error'] as Map<String, dynamic>;
        final code = err['code']?.toString();
        if (code == 'ACCOUNT_LOCKED') {
          return l10n?.errorAccountLocked ??
              'Your administrative account has been temporarily locked due to consecutive failed login attempts. Please wait 30 minutes or contact security.';
        }
        if (code == 'UNAUTHENTICATED') {
          return l10n?.errorInvalidCredentials ??
              'Invalid administrative credentials. Please check your email and password.';
        }
        return err['message']?.toString() ?? (l10n?.errorUnknown ?? 'An unexpected error occurred.');
      }
    }

    final errorString = error.toString().toLowerCase();
    if (errorString.contains('account_locked') || errorString.contains('locked')) {
      return l10n?.errorAccountLocked ??
          'Your administrative account has been temporarily locked due to consecutive failed login attempts. Please wait 30 minutes or contact security.';
    }
    if (errorString.contains('unauthenticated') || errorString.contains('invalid credentials')) {
      return l10n?.errorInvalidCredentials ??
          'Invalid administrative credentials. Please check your email and password.';
    }
    if (errorString.contains('unavailable') || errorString.contains('connection')) {
      return l10n?.errorServerUnavailable ??
          'Administrative service unavailable. Please check your connection and try again.';
    }

    return l10n?.errorUnknown ?? 'An unexpected error occurred. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kh.colors;
    final typography = context.kh.typography;
    final spacing = context.kh.spacing;
    final shapes = context.kh.shapes;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: DecoratedBox(
              // Outer Art-Deco layered frame
              decoration: BoxDecoration(
                color: colors.backgroundElevated,
                borderRadius: shapes.roundedMd,
                border: Border.all(
                  color: colors.borderStandard,
                  width: shapes.cardBorderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: colors.gold400.withValues(alpha: 0.05),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: shapes.roundedMd,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Art-Deco metallic top accent line
                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: colors.goldMetallicGradient,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.xl,
                        vertical: spacing.xxl,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Art-Deco Brand Mark & Heading
                            Center(
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: colors.sapphire700,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colors.gold400.withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.diamond_outlined,
                                  size: 32,
                                  color: colors.goldPrimary,
                                ),
                              ),
                            ),
                            SizedBox(height: spacing.md),
                            Center(
                              child: Text(
                                'KARAT HIVE',
                                style: typography.headline.copyWith(
                                  color: colors.goldPrimary,
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(height: spacing.xxs),
                            Center(
                              child: Text(
                                'Administrative Portal',
                                style: typography.bodySmall.copyWith(
                                  color: colors.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            SizedBox(height: spacing.xs),
                            Center(
                              child: Text(
                                l10n?.loginInstructions ??
                                    'Please sign in with your administrative credentials.',
                                textAlign: TextAlign.center,
                                style: typography.caption.copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                            ),
                            SizedBox(height: spacing.xl),

                            // Error banner (if any)
                            if (_errorMessage != null) ...[
                              Container(
                                key: const Key('login-error-banner'),
                                padding: EdgeInsets.all(spacing.md),
                                decoration: BoxDecoration(
                                  color: colors.error.withValues(alpha: 0.12),
                                  borderRadius: shapes.roundedSm,
                                  border: Border.all(
                                    color: colors.error.withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 20,
                                      color: colors.error,
                                    ),
                                    SizedBox(width: spacing.sm),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: typography.bodySmall.copyWith(
                                          color: colors.cream100,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: spacing.lg),
                            ],

                            // Email input field
                            Text(
                              l10n?.emailLabel ?? 'Admin Email',
                              style: typography.label.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                            SizedBox(height: spacing.xs),
                            TextFormField(
                              key: const Key('login-email-field'),
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              enabled: !_isSubmitting,
                              style: typography.body.copyWith(
                                color: colors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: l10n?.emailHint ?? 'admin@karathive.ae',
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  size: 20,
                                  color: colors.textMuted,
                                ),
                              ),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) {
                                  return l10n?.emailRequired ?? 'Admin email is required';
                                }
                                if (!_emailRegExp.hasMatch(text)) {
                                  return l10n?.emailInvalid ?? 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: spacing.lg),

                            // Password input field
                            Text(
                              l10n?.passwordLabel ?? 'Password',
                              style: typography.label.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                            SizedBox(height: spacing.xs),
                            TextFormField(
                              key: const Key('login-password-field'),
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              enabled: !_isSubmitting,
                              style: typography.body.copyWith(
                                color: colors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: l10n?.passwordHint ?? 'Enter your password',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  size: 20,
                                  color: colors.textMuted,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                    color: colors.textMuted,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                final text = value ?? '';
                                if (text.isEmpty) {
                                  return l10n?.passwordRequired ?? 'Password is required';
                                }
                                if (text.length < 8) {
                                  return l10n?.passwordTooShort ??
                                      'Password must be at least 8 characters';
                                }
                                return null;
                              },
                            ),

                            // TODO ADM-S01 2FA: In subsequent release, insert Authenticator TOTP 6-digit input here when required by backend.

                            SizedBox(height: spacing.xl),

                            // Authenticate submit button
                            ElevatedButton(
                              key: const Key('login-submit-button'),
                              onPressed: _isSubmitting ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, spacing.buttonHeight + 8),
                              ),
                              child: _isSubmitting
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          colors.sapphire900,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      l10n?.signInButton ?? 'Authenticate & Enter Portal',
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
