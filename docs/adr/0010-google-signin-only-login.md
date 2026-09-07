# Google Sign-In is the only login

Customer, Vendor, and Admin all sign in with Google only. The backend checks the Google ID token, then issues its own short-lived access token and refresh token. Google is not a one-time “publish gate” on top of a different login.

**Why.** The Flutter apps already send a Google token. Product confirmed on 6 September 2026: Google Sign-In is the only login. Phone OTP is not a login. Email/password is not a login. Platform 2FA (one-time codes on top of a password) is not used.

**Admin still cannot self-register.** A new Google user is never created as Admin. An Admin account is created by an existing Admin (or by seed). That person then signs in with Google. A random Google account cannot become Admin.

**Phone OTP** may still be used later to prove a mobile number for WhatsApp Talk. That is not a login.

**What the code must stop doing.** Creating a Vendor shop automatically on the first Google request. A new Google user must pick Customer or Vendor and accept terms before an account exists. Password login and Admin 2FA routes are leftover and should be removed after the Google session path works.

**Considered options.** Keep OTP/password as login and use Google only as a publish check (`BR-001` as written). Rejected. Use Google as an extra login next to OTP/password. Rejected. Keep Admin on email + password + 2FA. Rejected — Product said Admins use Google only (6 September 2026).

**Follow-up docs.** SRS `BR-001`, `FR-ADM-001`, `NFR-012` (password + 2FA), Architecture-Backend §14.1/§14.3, and the API list §8 still describe the old model. They need a later rewrite. Until then this ADR and [`Backend-Gap-Tasks.md`](../Backend-Gap-Tasks.md) G2-D01 / G2-D06 are the working rule for login.
