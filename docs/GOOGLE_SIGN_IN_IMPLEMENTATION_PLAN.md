# Google Sign-In / New User Onboarding Implementation Plan

## Objective

Fix the current Karat Hive Google sign-in flow so that a valid Firebase/Google identity that does not yet have a Karat Hive account is not incorrectly treated as an authentication failure.

The target behavior is:

```
Flutter
  |
  | Google Sign-In
  v
Firebase Authentication
  |
  | Firebase ID Token
  v
Karat Hive Backend
  |
  +-- Invalid Firebase token
  |      -> 401 UNAUTHENTICATED
  |
  +-- Existing OAuth binding
  |      -> Login -> Session
  |
  +-- Existing verified email
  |      -> Bind Google -> Login -> Session
  |
  +-- Existing verified phone
  |      -> Bind Google -> Login -> Session
  |
  +-- No Karat Hive account
         -> REGISTRATION_REQUIRED
              -> Flutter registration
              -> Create User + Profile + OAuth Binding
              -> Issue Session
```

## 1. Define the desired authentication behavior

Keep authentication and account creation separate.

The session/login flow should:

1. Verify the Firebase ID token.
2. Check for an existing Google OAuth binding.
3. If no binding exists, check for an existing user by verified email.
4. If no email match exists, check for an existing verified phone.
5. If no Karat Hive account exists, return a dedicated registration-required response.
6. Do not silently create an incomplete Karat Hive user during login.

### Required distinction

| Situation | Expected result |
|---|---|
| Invalid Firebase token | `UNAUTHENTICATED` |
| Expired Firebase token | `TOKEN_EXPIRED` |
| Existing Google binding | Login |
| Existing verified email | Link Google + Login |
| Existing verified phone | Link Google + Login |
| Valid Google identity with no Karat Hive account | `REGISTRATION_REQUIRED` |

---

## 2. Add a dedicated registration-required error

### Backend

Add an API/domain error code such as:

```
REGISTRATION_REQUIRED
```

The response should clearly indicate that the Google identity is valid but has no Karat Hive account.

Do not expose the raw Firebase ID token or other sensitive credentials.

Example response:

```json
{
  "code": "REGISTRATION_REQUIRED",
  "provider": "GOOGLE",
  "email": "user@example.com"
}
```

The exact response shape should follow the existing Karat Hive API error contract.

### Important

Do not use `UNAUTHENTICATED` for this case. A valid Google identity and a missing Karat Hive account are different states.

---

## 3. Change OAuthAccountService

Current behavior eventually throws:

```ts
throw new ApiException(
  HttpStatus.UNAUTHORIZED,
  ErrorCode.UNAUTHENTICATED,
);
```

when:

- Firebase authentication succeeded.
- No OAuth binding exists.
- No existing user matches the verified email.
- No existing user matches the verified phone.

Change this final branch to return/throw the new `REGISTRATION_REQUIRED` error.

Keep the existing behavior for invalid Firebase authentication.

---

## 4. Add a dedicated Google registration endpoint

Add an endpoint following the repository's existing auth controller conventions, for example:

```
POST /auth/register/google
```

The endpoint should accept the Firebase ID token and the additional information required by Karat Hive registration.

Example request:

```json
{
  "firebaseToken": "...",
  "mobileNumber": "...",
  "termsVersion": "...",
  "privacyVersion": "..."
}
```

The exact fields must be aligned with the existing `RegistrationService.registerCustomer()` contract and database requirements.

---

## 5. Verify Firebase identity server-side

The Google registration endpoint must never trust client-provided identity fields such as:

- Firebase UID
- Google subject
- email
- email verification status
- Google profile name

Instead:

```
firebaseToken
    |
    v
FirebaseTokenService.verify()
    |
    v
Verified Firebase claims
```

Use the verified claims for account creation and OAuth binding.

---

## 6. Reuse RegistrationService

Do not duplicate the existing customer-registration logic.

Reuse:

```
RegistrationService.registerCustomer(...)
```

where possible.

The Google registration flow should use the same business rules as normal customer registration.

The resulting account should contain:

- User
- CustomerProfile
- OAuthBinding
- Audit record

---

## 7. Make registration atomic

User creation, customer profile creation, OAuth binding, and audit operations must be performed transactionally.

Target structure:

```ts
await prisma.$transaction(async (tx) => {
  const user = await createUser(tx);

  await createCustomerProfile(tx, user);

  await tx.oauthBinding.create({
    data: {
      userId: user.id,
      provider: 'GOOGLE',
      subjectHash,
      boundAt: now,
    },
  });

  await audit.append(tx, ...);

  return user;
});
```

The implementation should reuse existing transaction abstractions where appropriate.

The transaction must prevent partial accounts such as:

```
User created
  -> Profile created
  -> OAuth binding fails
  -> Account cannot log in
```

---

## 8. Issue a session immediately after registration

After successful Google registration:

```
Create User
Create CustomerProfile
Create OAuthBinding
Create Audit
       |
       v
Issue access token
Issue refresh token
       |
       v
Return SessionBundle
```

The Flutter app should not need to perform Google login a second time.

Target experience:

```
Google -> Complete Registration -> Logged In
```

---

## 9. Handle duplicate and concurrent registration

The database must remain the final authority for uniqueness.

Verify uniqueness constraints for:

- User email
- User mobile number
- OAuthBinding subject hash
- OAuthBinding user + provider

Handle Prisma unique constraint errors explicitly and translate them to controlled API errors.

Do not allow raw Prisma errors to escape as uncontrolled 500 responses.

Test concurrent registration attempts for the same Google identity.

---

## 10. Normalize email and mobile numbers

Email matching should use a consistent normalization strategy.

At minimum, verify that registration and lookup use the same normalized representation, for example:

```ts
const email = claims.email?.trim().toLowerCase();
```

Mobile numbers should use the repository's canonical E.164 representation.

This prevents duplicate accounts caused by formatting differences.

---

## 11. Secure account linking

Automatic Google-to-existing-account linking must only occur when the identity claim is sufficiently verified.

For email:

```ts
claims.emailVerified === true
```

must remain mandatory before linking a Google identity to an existing email account.

Do not automatically link an unverified email.

Review the phone-linking path as well and ensure the Firebase phone claim is trusted only when it represents a verified Firebase phone authentication state.

---

## 12. Flutter changes

Update the Flutter authentication flow to distinguish three outcomes.

### Existing user

```
Google
  -> Firebase
  -> Backend
  -> 200 Session
  -> Open application
```

### New user

```
Google
  -> Firebase
  -> Backend
  -> REGISTRATION_REQUIRED
  -> Registration screen
```

### Authentication failure

```
Google
  -> Firebase
  -> Backend
  -> UNAUTHENTICATED / TOKEN_EXPIRED
  -> Authentication error
```

Do not treat `REGISTRATION_REQUIRED` as a generic login failure.

---

## 13. Flutter registration screen

When the backend returns `REGISTRATION_REQUIRED`:

1. Keep the Firebase authentication state available.
2. Navigate to a Google registration/completion screen.
3. Collect only information required by Karat Hive.
4. Use Google/Firebase claims for identity information.
5. Send the Firebase ID token plus required registration fields to the Google registration endpoint.
6. Store the returned Karat Hive session.
7. Navigate to the authenticated application.

Do not ask the user to re-enter information that can safely be obtained from verified Firebase claims.

---

## 14. Suggested Flutter result model

Model the result explicitly instead of relying on generic exceptions.

Example:

```dart
sealed class GoogleAuthResult {}

class GoogleLoginSuccess extends GoogleAuthResult {
  final Session session;

  GoogleLoginSuccess(this.session);
}

class GoogleRegistrationRequired extends GoogleAuthResult {
  final String? email;

  GoogleRegistrationRequired(this.email);
}

class GoogleAuthenticationFailed extends GoogleAuthResult {
  final String message;

  GoogleAuthenticationFailed(this.message);
}
```

Use the project's existing result/error architecture if one already exists.

---

## 15. Backend exception handling

Because the repository is also being audited for unhandled exceptions, include robust failure handling in this implementation.

Specifically:

- Catch and translate expected Prisma unique constraint failures.
- Do not leak raw Prisma errors.
- Ensure transaction failures roll back all account creation.
- Keep the global HTTP exception filter as the final HTTP boundary.
- Ensure registration audit failures cannot leave partially-created accounts.
- Do not log Firebase tokens, access tokens, or refresh tokens.

---

## 16. Logging and audit

Add structured events around the authentication lifecycle, following the repository's existing logging/audit conventions.

Recommended events:

```
GOOGLE_AUTH_VERIFIED
GOOGLE_ACCOUNT_FOUND
GOOGLE_ACCOUNT_LINKED
GOOGLE_REGISTRATION_REQUIRED
GOOGLE_REGISTRATION_STARTED
GOOGLE_REGISTRATION_COMPLETED
GOOGLE_REGISTRATION_FAILED
```

Do not log:

- Firebase ID tokens
- Refresh tokens
- Access tokens
- Other authentication secrets

Use the existing hashed Firebase subject approach when an identity needs to be correlated in logs.

---

## 17. Backend unit tests

Add tests for Firebase verification:

- Valid Firebase token.
- Expired token.
- Invalid signature.
- Wrong audience.
- Wrong issuer.
- Missing `sub`.
- Unverified email.

Add tests for existing accounts:

- Existing OAuth binding.
- Existing verified email.
- Existing verified phone.
- Deleted user.
- OAuth binding pointing to a missing/deleted user.

Add tests for new users:

- Valid Google identity with no Karat Hive account.
- Returns `REGISTRATION_REQUIRED`.
- Does not create a partial account.

Add registration tests:

- User created.
- CustomerProfile created.
- OAuthBinding created.
- Audit created.
- Session returned.
- Transaction rolls back when a required operation fails.

Add duplicate/race tests:

- Same Google account registered twice.
- Same email registered twice.
- Same mobile registered twice.
- Concurrent registration attempts.

Add security tests:

- Unverified email cannot automatically link.
- Client cannot override Firebase email.
- Client cannot override Firebase UID.
- Client cannot bind a Google identity to another user's account.

---

## 18. End-to-end integration test

Add a complete lifecycle test:

```
Firebase identity
      |
POST Google session
      |
REGISTRATION_REQUIRED
      |
POST Google registration
      |
200 Session
      |
GET /me
      |
Correct Customer
```

Then test the second login:

```
Same Firebase identity
      |
POST Google session
      |
200 Session
```

This proves that the newly-created OAuth binding is actually used by subsequent logins.

---

## 19. Database/schema review before implementation

Before modifying the registration code, verify:

```
User
  - email unique?
  - mobileNumber unique?
  - deleted users behavior?

OAuthBinding
  - subjectHash unique?
  - userId + provider unique?
  - provider enum?

CustomerProfile
  - required fields?

Registration
  - required terms/privacy fields?
  - required mobile number?
```

This determines the exact registration request and transaction implementation.

---

# Implementation Task Register

## Phase 1 — Backend API contract

- [ ] Add `REGISTRATION_REQUIRED` error code.
- [ ] Add appropriate domain/API exception.
- [ ] Change `OAuthAccountService.createSessionFromFirebase()`.
- [ ] Return registration-required when no Karat Hive account exists.
- [ ] Add unit tests.

## Phase 2 — Google registration

- [ ] Add Google registration endpoint.
- [ ] Verify Firebase token server-side.
- [ ] Reuse `RegistrationService.registerCustomer()`.
- [ ] Create User + CustomerProfile + OAuthBinding atomically.
- [ ] Create audit record.
- [ ] Issue session after successful registration.
- [ ] Handle unique constraint conflicts.
- [ ] Add rollback tests.

## Phase 3 — Security

- [ ] Verify Firebase email-linking requirements.
- [ ] Verify Firebase phone-linking requirements.
- [ ] Normalize email consistently.
- [ ] Normalize mobile numbers consistently.
- [ ] Verify OAuth binding uniqueness.
- [ ] Ensure client cannot override verified Firebase identity fields.
- [ ] Ensure sensitive tokens are never logged.

## Phase 4 — Flutter

- [ ] Map `REGISTRATION_REQUIRED`.
- [ ] Add registration-required authentication state/result.
- [ ] Add Google registration/completion screen.
- [ ] Preserve Firebase authentication state.
- [ ] Submit registration data to backend.
- [ ] Store returned Karat Hive session.
- [ ] Navigate directly into the application after successful registration.

## Phase 5 — Testing

- [ ] Firebase token tests.
- [ ] Existing-account login tests.
- [ ] New-account onboarding tests.
- [ ] Registration transaction tests.
- [ ] Duplicate registration tests.
- [ ] Concurrent registration tests.
- [ ] Account-linking security tests.
- [ ] End-to-end Google registration test.
- [ ] End-to-end subsequent Google login test.

# Acceptance Criteria

The implementation is complete when all of the following are true:

1. An existing Google-linked user can sign in normally.
2. An existing Karat Hive user with a verified matching Google email can be linked and signed in.
3. An existing Karat Hive user with a valid verified matching phone can be linked according to the project's phone-verification rules.
4. A valid new Google user receives `REGISTRATION_REQUIRED`, not `UNAUTHENTICATED`.
5. The Flutter app displays the registration flow for that case.
6. Completing registration creates User, CustomerProfile, OAuthBinding, and audit data atomically.
7. Registration immediately returns an authenticated session.
8. A second Google sign-in for the newly-created user goes directly through the normal login path.
9. Duplicate/concurrent registration cannot create duplicate accounts.
10. Invalid Firebase tokens still correctly produce authentication errors.
11. No Firebase/access/refresh tokens are written to logs.
12. All new failure paths are covered by automated tests.
