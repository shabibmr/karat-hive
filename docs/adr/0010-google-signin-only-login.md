# Google Sign-In is the only marketplace login

Customers and Vendors sign in with Google only. The backend checks the Google ID token, then issues its own short-lived access token and refresh token. Google is not a one-time “publish gate” on top of a different login.

**Why.** The Flutter apps already send a Google token. Product confirmed on 6 September 2026: Google Sign-In is the only login for marketplace users. Phone OTP is no longer a login. Email/password is no longer a login for Customers and Vendors.

**What this does not decide.** Admin login (password + 2FA vs Google) is still open. Phone OTP may still be used later to prove a mobile number for WhatsApp Talk — that is not a login.

**What the code must stop doing.** Creating a Vendor shop automatically on the first Google request. A new Google user must pick Customer or Vendor and accept terms before an account exists.

**Considered options.** Keep OTP/password as login and use Google only as a publish check (`BR-001` as written). Rejected. Use Google as an extra login next to OTP/password. Rejected — Product said Google is the only login.

**Follow-up docs.** SRS `BR-001`, Architecture-Backend §14.1/§14.3, and the API list §8 still describe the old model. They need a later rewrite. Until then this ADR and [`Backend-Gap-Tasks.md`](../Backend-Gap-Tasks.md) G2-D01 are the working rule for login.
