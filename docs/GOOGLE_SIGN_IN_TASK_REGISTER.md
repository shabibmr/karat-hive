# Google Sign-In Implementation Task Register

This task register converts `docs/GOOGLE_SIGN_IN_IMPLEMENTATION_PLAN.md` into concrete implementation tasks.

## Phase 0 — Repository and contract preparation

### GSI-001 — Review existing authentication contracts
- [ ] Inspect auth controller routes.
- [ ] Inspect existing API error-code definitions.
- [ ] Inspect registration DTOs and validation.
- [ ] Inspect `RegistrationService.registerCustomer()`.
- [ ] Inspect session response types.
- [ ] Inspect Flutter authentication API client and error mapping.
- [ ] Confirm the exact existing Google sign-in endpoint used by the Flutter app.
- [ ] Document any required contract changes before coding.

**Done when:** The exact backend and Flutter authentication paths are documented and no assumptions remain about endpoint names or DTO shapes.

### GSI-002 — Review database constraints
- [ ] Inspect User uniqueness constraints.
- [ ] Inspect OAuthBinding uniqueness constraints.
- [ ] Inspect CustomerProfile required fields.
- [ ] Inspect registration terms/privacy requirements.
- [ ] Inspect mobile-number format requirements.
- [ ] Identify all Prisma errors that can occur during Google registration.

**Done when:** The registration implementation has a complete list of required fields and database constraints.

---

# Phase 1 — Backend error contract

### GSI-003 — Add REGISTRATION_REQUIRED error code
- [ ] Add `REGISTRATION_REQUIRED` to the existing error-code system.
- [ ] Follow existing naming and serialization conventions.
- [ ] Ensure the error is safe to expose to the client.

**Done when:** Backend can consistently represent a valid authenticated identity that has no Karat Hive account.

### GSI-004 — Add registration-required API exception
- [ ] Create/reuse the appropriate domain/API exception mechanism.
- [ ] Include provider information where the API contract supports it.
- [ ] Do not expose Firebase tokens or raw sensitive credentials.
- [ ] Use the HTTP status convention selected by the existing API architecture.

**Done when:** Controllers can return a structured registration-required response.

### GSI-005 — Add error serialization tests
- [ ] Test `REGISTRATION_REQUIRED` serialization.
- [ ] Verify response shape.
- [ ] Verify no sensitive Firebase information is returned.
- [ ] Verify global exception handling produces the expected HTTP response.

**Done when:** API clients can reliably identify this condition.

---

# Phase 2 — Existing Google login flow

### GSI-006 — Update OAuthAccountService
Modify `createSessionFromFirebase()`.

- [ ] Preserve Firebase token verification.
- [ ] Preserve existing OAuth binding lookup.
- [ ] Preserve deleted-user protection.
- [ ] Preserve verified-email account linking.
- [ ] Preserve phone account linking.
- [ ] Replace the final generic `UNAUTHENTICATED` error for a valid unregistered Google identity with `REGISTRATION_REQUIRED`.
- [ ] Ensure no user is created during the login request.

**Done when:** A valid new Google identity reaches the registration-required state instead of receiving a generic authentication failure.

### GSI-007 — Normalize email matching
- [ ] Review how emails are stored.
- [ ] Normalize incoming Firebase email consistently.
- [ ] Ensure lookup and registration use the same normalization.
- [ ] Add tests for casing and whitespace.

**Done when:** Equivalent email representations do not cause incorrect account lookup results.

### GSI-008 — Review phone account linking
- [ ] Confirm Firebase phone claims are trusted only when appropriately verified.
- [ ] Confirm E.164 normalization.
- [ ] Ensure an unverified phone cannot automatically link to an existing account.
- [ ] Add positive and negative tests.

**Done when:** Phone-based account linking meets the intended security model.

---

# Phase 3 — Google registration endpoint

### GSI-009 — Define Google registration DTO
- [ ] Define the request DTO.
- [ ] Include Firebase ID token.
- [ ] Include only additional fields actually required by customer registration.
- [ ] Add validation.
- [ ] Do not accept Firebase UID/email as trusted client fields.
- [ ] Add DTO tests.

**Done when:** The request contract is minimal and validated.

### GSI-010 — Add Google registration controller endpoint
- [ ] Add the endpoint using existing auth controller conventions.
- [ ] Wire request validation.
- [ ] Call the application service.
- [ ] Return the standard SessionBundle response.
- [ ] Map known domain errors to API responses.

**Done when:** Flutter has a documented endpoint for completing Google registration.

### GSI-011 — Implement Google registration application flow
- [ ] Verify Firebase ID token with `FirebaseTokenService`.
- [ ] Require appropriate verified identity information.
- [ ] Extract UID, email, name, picture, and phone from verified claims.
- [ ] Hash Firebase UID using the existing hashing utility.
- [ ] Check whether an OAuth binding already exists.
- [ ] Check whether the email/mobile already belongs to another account.
- [ ] Invoke the existing customer-registration business logic.
- [ ] Create the Google OAuth binding.
- [ ] Create audit information.
- [ ] Issue the Karat Hive session.

**Done when:** A new Google user can complete registration in one backend flow.

### GSI-012 — Make Google registration transactional
- [ ] Put User creation inside the existing transaction abstraction.
- [ ] Create CustomerProfile in the same transaction.
- [ ] Create OAuthBinding in the same transaction.
- [ ] Create required audit records transactionally.
- [ ] Verify rollback when any required operation fails.
- [ ] Verify no partial account remains after rollback.

**Done when:** Account creation is all-or-nothing.

---

# Phase 4 — Duplicate and concurrency protection

### GSI-013 — Handle Prisma unique constraint failures
- [ ] Identify relevant Prisma P2002 cases.
- [ ] Map duplicate email to a controlled API error.
- [ ] Map duplicate mobile to a controlled API error.
- [ ] Map duplicate OAuth subject to a controlled API error.
- [ ] Avoid returning raw Prisma errors.

**Done when:** Expected uniqueness conflicts never become uncontrolled 500 responses.

### GSI-014 — Handle concurrent Google registration
- [ ] Create a test with two registration requests using the same Firebase identity.
- [ ] Verify only one account is created.
- [ ] Verify only one OAuth binding exists.
- [ ] Verify the losing request receives a controlled response.
- [ ] Verify no orphaned profile/account remains.

**Done when:** Double taps, retries, and concurrent requests are safe.

---

# Phase 5 — Backend security

### GSI-015 — Protect Firebase identity fields
- [ ] Never trust client-provided Firebase UID.
- [ ] Never trust client-provided email for account identity.
- [ ] Never trust client-provided email verification status.
- [ ] Never trust client-provided Google subject.
- [ ] Derive identity from the verified Firebase token.

**Done when:** Client input cannot impersonate another Google identity.

### GSI-016 — Review automatic email linking
- [ ] Require verified Firebase email.
- [ ] Confirm matching email belongs to an active Karat Hive user.
- [ ] Prevent linking to deleted users.
- [ ] Ensure OAuth binding is created atomically.
- [ ] Add security tests.

**Done when:** Existing-account linking cannot be triggered by an unverified email.

### GSI-017 — Review token and credential logging
- [ ] Search new and existing authentication logs.
- [ ] Ensure Firebase ID tokens are never logged.
- [ ] Ensure access tokens are never logged.
- [ ] Ensure refresh tokens are never logged.
- [ ] Ensure sensitive request headers are not logged.

**Done when:** Authentication secrets are absent from application logs.

---

# Phase 6 — Flutter authentication handling

### GSI-018 — Map REGISTRATION_REQUIRED in API client
- [ ] Add the new error code to Flutter's API error model.
- [ ] Parse the structured response.
- [ ] Distinguish it from authentication failures.
- [ ] Add client-side tests.

**Done when:** Flutter can reliably detect the onboarding state.

### GSI-019 — Update Google sign-in flow
- [ ] Perform Google Sign-In.
- [ ] Authenticate with Firebase.
- [ ] Obtain Firebase ID token.
- [ ] Call the existing Karat Hive session endpoint.
- [ ] Handle successful session response.
- [ ] Handle `REGISTRATION_REQUIRED`.
- [ ] Handle actual authentication failures.
- [ ] Preserve Firebase state when onboarding is required.

**Done when:** Existing and new Google users follow different correct paths.

### GSI-020 — Add Google registration/onboarding screen
- [ ] Create the registration screen using existing UI architecture.
- [ ] Display verified Google information where appropriate.
- [ ] Collect required registration fields.
- [ ] Validate mobile number.
- [ ] Handle terms/privacy acceptance.
- [ ] Submit registration to backend.
- [ ] Display controlled validation errors.
- [ ] Display duplicate-account errors.
- [ ] Display retryable server errors.

**Done when:** A new Google user can complete required onboarding from the Flutter app.

### GSI-021 — Complete session after registration
- [ ] Store the returned access token/session using existing auth infrastructure.
- [ ] Store refresh token using existing secure storage mechanism.
- [ ] Update authenticated state.
- [ ] Refresh/load current-user data if required.
- [ ] Navigate to the authenticated application.
- [ ] Prevent unnecessary second Google login.

**Done when:** Google registration ends with the user fully authenticated.

---

# Phase 7 — Backend unit tests

### GSI-022 — FirebaseTokenService tests
- [ ] Valid token.
- [ ] Expired token.
- [ ] Invalid signature.
- [ ] Wrong issuer.
- [ ] Wrong audience.
- [ ] Missing subject.
- [ ] Missing optional claims.
- [ ] Unverified email.

### GSI-023 — OAuthAccountService tests
- [ ] Existing OAuth binding.
- [ ] Existing verified email.
- [ ] Existing verified phone.
- [ ] Deleted account.
- [ ] Missing user behind binding.
- [ ] New unregistered Google identity.
- [ ] `REGISTRATION_REQUIRED` response.
- [ ] No account creation during login.

### GSI-024 — Google registration service tests
- [ ] Valid registration.
- [ ] Invalid Firebase token.
- [ ] Missing required registration fields.
- [ ] Existing OAuth binding.
- [ ] Existing email.
- [ ] Existing mobile.
- [ ] Successful transaction.
- [ ] Transaction rollback.
- [ ] Session creation.

### GSI-025 — Exception handling tests
- [ ] Prisma unique violation.
- [ ] Database failure.
- [ ] Transaction failure.
- [ ] Audit failure.
- [ ] Session creation failure.
- [ ] Verify errors remain controlled by the API boundary.

---

# Phase 8 — End-to-end tests

### GSI-026 — Existing Google user E2E
Test:

```
Google
 -> Firebase
 -> Karat Hive session
 -> Existing OAuth binding
 -> Session
 -> /me
```

**Done when:** Existing Google users can log in without regression.

### GSI-027 — Existing user email-link E2E
Test:

```
Google
 -> Firebase
 -> Verified email match
 -> OAuth binding created
 -> Session
 -> /me
```

**Done when:** Existing Karat Hive users can safely connect their Google account.

### GSI-028 — New Google user E2E
Test:

```
Google
 -> Firebase
 -> Session endpoint
 -> REGISTRATION_REQUIRED
 -> Registration screen
 -> Google registration endpoint
 -> User/Profile/OAuthBinding
 -> Session
 -> /me
```

**Done when:** The complete first-time Google registration journey succeeds.

### GSI-029 — Subsequent Google login E2E
Test:

```
Same Google account
 -> Firebase
 -> Session endpoint
 -> Existing OAuth binding
 -> Session
```

**Done when:** The newly-created account uses the normal login path on subsequent attempts.

### GSI-030 — Duplicate registration E2E
- [ ] Submit registration twice.
- [ ] Submit requests concurrently.
- [ ] Verify one account only.
- [ ] Verify one OAuth binding only.
- [ ] Verify controlled response for duplicate attempt.

---

# Phase 9 — Regression testing

### GSI-031 — Existing authentication regression suite
- [ ] Email/password authentication if applicable.
- [ ] Existing registration flow.
- [ ] Refresh-token flow.
- [ ] Logout/revocation flow.
- [ ] `/me`.
- [ ] Deleted-account handling.
- [ ] Existing OAuth providers if any.

**Done when:** Google changes do not break unrelated authentication functionality.

### GSI-032 — Run backend quality checks
- [ ] TypeScript compilation.
- [ ] ESLint.
- [ ] Unit tests.
- [ ] Integration tests.
- [ ] E2E tests.
- [ ] Prisma validation/generation if required.
- [ ] Existing CI checks.

### GSI-033 — Run Flutter quality checks
- [ ] Dart analyzer.
- [ ] Flutter tests.
- [ ] Authentication Bloc tests.
- [ ] API client tests.
- [ ] Registration screen tests.
- [ ] Existing authentication regression tests.

---

# Phase 10 — Documentation

### GSI-034 — Update API documentation
- [ ] Document the existing Google session endpoint.
- [ ] Document `REGISTRATION_REQUIRED`.
- [ ] Document Google registration endpoint.
- [ ] Document request/response DTOs.
- [ ] Document error codes.
- [ ] Document authentication/linking behavior.

### GSI-035 — Update developer documentation
- [ ] Document Google authentication architecture.
- [ ] Document first-time Google onboarding.
- [ ] Document account-linking security rules.
- [ ] Document testing requirements.
- [ ] Link this task register to the implementation plan.

---

# Phase 11 — Final verification

### GSI-036 — Production-readiness review
- [ ] Verify no raw Firebase tokens are logged.
- [ ] Verify no raw Prisma exceptions are exposed.
- [ ] Verify transaction boundaries.
- [ ] Verify database uniqueness constraints.
- [ ] Verify account-linking security.
- [ ] Verify deleted-account behavior.
- [ ] Verify retry/concurrency behavior.
- [ ] Verify session issuance.
- [ ] Verify refresh-token behavior.
- [ ] Verify monitoring/logging.

### GSI-037 — Final acceptance test

Run the following complete scenarios:

1. Existing Google-linked customer logs in.
2. Existing customer with matching verified Google email logs in and becomes linked.
3. New Google user receives registration-required state.
4. New user completes registration.
5. User receives a valid session immediately.
6. User can call `/me`.
7. User signs in again with Google.
8. Second login goes directly through OAuth binding.
9. Duplicate registration is rejected safely.
10. Invalid Firebase token remains an authentication error.
11. Database failure does not create a partial account.
12. No authentication secrets appear in logs.

**Done when:** All scenarios pass and the implementation plan acceptance criteria are satisfied.

---

# Suggested Execution Order

The implementation should be performed in this order:

```
GSI-001
  |
GSI-002
  |
GSI-003 -> GSI-005
  |
GSI-006 -> GSI-008
  |
GSI-009 -> GSI-012
  |
GSI-013 -> GSI-017
  |
GSI-018 -> GSI-021
  |
GSI-022 -> GSI-025
  |
GSI-026 -> GSI-030
  |
GSI-031 -> GSI-033
  |
GSI-034 -> GSI-035
  |
GSI-036 -> GSI-037
```

## Definition of Done

The Google Sign-In implementation is complete only when:

- A valid new Google identity is no longer reported as `UNAUTHENTICATED`.
- New users can complete registration from Flutter.
- User, customer profile, and OAuth binding creation is atomic.
- A session is issued immediately after successful registration.
- Subsequent Google logins work through the OAuth binding.
- Account linking is restricted to appropriately verified identities.
- Duplicate/concurrent registration is safe.
- Expected database errors are converted to controlled API errors.
- Backend and Flutter automated tests pass.
- Existing authentication flows continue to work.
