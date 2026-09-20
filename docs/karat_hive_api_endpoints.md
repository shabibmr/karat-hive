# Karat Hive Application — Complete API Endpoint Inventory & Request/Response Payloads

> **Scope**: Complete master reference of all REST API endpoints used across the **Karat Hive** ecosystem, including the Customer & Vendor mobile applications (`apps/kh_mobile`), the Admin web portal (`apps/kh_admin`), the shared API client package (`packages/kh_api`), and the backend NestJS services (`backend`).
> 
> For each endpoint, this document details the HTTP Method, Route Path, Authentication/Role permissions, URL Parameters, Code-Generated Sample Request Payload (JSON), and Sample Response Structure.

---

## 1. Network Architecture & Global Conventions

### 1.1 Base URL & Path Prefix
* **Base URL**: Configurable via `--dart-define=KH_API_BASE` (e.g. `https://api.karathive.ae` or `https://algoray.cloud/kh_api`).
* **Path Prefix**: All domain and administrative endpoints are versioned under `/v1/`.
* **Health/Readiness**: Root-level paths `/health` and `/ready`.

### 1.2 Headers & Content-Type
* **Content-Type**: `application/json; charset=utf-8` on all JSON request bodies.
* **Authorization**: `Bearer <accessToken>` for authenticated endpoints.
* **Idempotency**: `Idempotency-Key: <uuid>` on state-mutating requests (`POST`, `PUT`, `PATCH`).
* **Localization**: `Accept-Language: en | ar` (overridden by user profile `preferredLanguage`).

### 1.3 Envelope Standard
* **Success Envelope**:
  ```json
  {
    "data": { ... },
    "meta": {
      "requestId": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
      "serverTime": "2026-09-20T03:30:00.000Z",
      "nextCursor": null
    }
  }
  ```
* **Error Envelope**:
  ```json
  {
    "error": {
      "code": "VALIDATION_FAILED",
      "message": "Invalid input provided.",
      "details": [
        { "field": "budgetMin", "message": "budgetMin must be a positive decimal string" }
      ]
    },
    "meta": {
      "requestId": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
      "serverTime": "2026-09-20T03:30:00.000Z"
    }
  }
  ```

---

## 2. API Endpoint Master Summary Table

| # | HTTP Method | Endpoint URL | Module / Domain | Allowed Roles | Request Body? |
|---|---|---|---|---|---|
| 1 | `POST` | `/v1/auth/otp/request` | Auth & Sessions | Public | **Yes** |
| 2 | `POST` | `/v1/auth/otp/verify` | Auth & Sessions | Public | **Yes** |
| 3 | `POST` | `/v1/auth/register/customer` | Auth & Sessions | Public / Token | **Yes** |
| 4 | `POST` | `/v1/auth/register/vendor` | Auth & Sessions | Public / Token | **Yes** |
| 5 | `POST` | `/v1/auth/register/admin` | Auth & Sessions | Admin | **Yes** |
| 6 | `POST` | `/v1/auth/google/session` | Auth & Sessions | Public | **Yes** |
| 7 | `POST` | `/v1/auth/firebase/session` | Auth & Sessions | Public | **Yes** |
| 8 | `POST` | `/v1/auth/login/password` | Auth & Sessions | Public | **Yes** |
| 9 | `POST` | `/v1/auth/refresh` | Auth & Sessions | Public (Refresh Token) | **Yes** |
| 10 | `POST` | `/v1/auth/logout` | Auth & Sessions | Authenticated | **Yes** |
| 11 | `GET` | `/v1/auth/sessions` | Auth & Sessions | Authenticated | *No* |
| 12 | `DELETE` | `/v1/auth/sessions/{id}` | Auth & Sessions | Authenticated | *No* |
| 13 | `POST` | `/v1/auth/password` | Auth & Sessions | Authenticated | **Yes** |
| 14 | `GET` | `/v1/me` | User Identity | Customer, Vendor, Admin | *No* |
| 15 | `PATCH` | `/v1/me` | User Identity | Customer, Vendor | **Yes** |
| 16 | `POST` | `/v1/me/mobile/change` | User Identity | Customer, Vendor | **Yes** |
| 17 | `POST` | `/v1/me/deactivate` | User Identity | Customer, Vendor | *No* |
| 18 | `POST` | `/v1/me/deletion-requests` | User Identity | Customer, Vendor | *No* |
| 19 | `POST` | `/v1/me/deletion-requests/{id}/confirm` | User Identity | Customer, Vendor | **Yes** |
| 20 | `GET` | `/v1/me/settings` | Settings | Customer, Vendor | *No* |
| 21 | `PATCH` | `/v1/me/settings` | Settings | Customer, Vendor | **Yes** |
| 22 | `GET` | `/v1/me/subscriptions` | Subscriptions | Vendor | *No* |
| 23 | `GET` | `/v1/me/vendor` | Vendor Profile | Vendor | *No* |
| 24 | `PATCH` | `/v1/me/vendor` | Vendor Profile | Vendor | **Yes** |
| 25 | `GET` | `/v1/me/vendor/documents` | Vendor KYC | Vendor | *No* |
| 26 | `POST` | `/v1/me/vendor/documents` | Vendor KYC | Vendor | **Yes** |
| 27 | `PUT` | `/v1/me/vendor/categories` | Vendor Taxonomy | Vendor | **Yes** |
| 28 | `PUT` | `/v1/me/vendor/regions` | Vendor Taxonomy | Vendor | **Yes** |
| 29 | `PATCH` | `/v1/me/vendor/availability` | Vendor Profile | Vendor | **Yes** |
| 30 | `POST` | `/v1/me/vendor/resubmit` | Vendor Profile | Vendor | *No* |
| 31 | `GET` | `/v1/me/dashboard` | Vendor Analytics | Vendor | *No* |
| 32 | `GET` | `/v1/me/vendor/performance` | Vendor Analytics | Vendor | *No* |
| 33 | `GET` | `/v1/me/vendor/performance/export` | Vendor Analytics | Vendor | *No* |
| 34 | `POST` | `/v1/requests` | Requests | Customer | **Yes** |
| 35 | `GET` | `/v1/me/requests` | Requests | Customer | *No* (Query) |
| 36 | `GET` | `/v1/requests/{id}` | Requests | Customer, Vendor | *No* |
| 37 | `PATCH` | `/v1/requests/{id}` | Requests | Customer | **Yes** |
| 38 | `POST` | `/v1/requests/{id}/publish` | Requests | Customer | *No* |
| 39 | `POST` | `/v1/requests/{id}/cancel` | Requests | Customer | **Yes** |
| 40 | `POST` | `/v1/requests/{id}/duplicate` | Requests | Customer | *No* |
| 41 | `GET` | `/v1/requests/{id}/offers` | Requests / Offers | Customer | *No* |
| 42 | `POST` | `/v1/requests/{id}/offers` | Requests / Offers | Vendor | **Yes** |
| 43 | `GET` | `/v1/matches` | Matching Feed | Vendor | *No* (Query) |
| 44 | `POST` | `/v1/matches/{requestId}/viewed` | Matching Feed | Vendor | *No* |
| 45 | `GET` | `/v1/filter-presets` | Filter Presets | Vendor | *No* |
| 46 | `POST` | `/v1/filter-presets` | Filter Presets | Vendor | **Yes** |
| 47 | `PATCH` | `/v1/filter-presets/{id}` | Filter Presets | Vendor | **Yes** |
| 48 | `DELETE` | `/v1/filter-presets/{id}` | Filter Presets | Vendor | *No* |
| 49 | `GET` | `/v1/me/offers` | Offers | Vendor | *No* (Query) |
| 50 | `GET` | `/v1/offers/{id}` | Offers | Customer, Vendor | *No* |
| 51 | `POST` | `/v1/offers/{id}/revise` | Offers | Vendor | **Yes** |
| 52 | `POST` | `/v1/offers/{id}/withdraw` | Offers | Vendor | **Yes** |
| 53 | `POST` | `/v1/offers/{id}/accept` | Offers | Customer | *No* |
| 54 | `POST` | `/v1/offers/{id}/decline` | Offers | Customer | **Yes** |
| 55 | `GET` | `/v1/offers/{id}/vendor-rating` | Offers | Customer | *No* |
| 56 | `POST` | `/v1/offers/{id}/viewed` | Offers | Customer | *No* |
| 57 | `GET` | `/v1/me/connections` | Connections | Customer, Vendor | *No* (Query) |
| 58 | `GET` | `/v1/connections/{id}` | Connections | Customer, Vendor | *No* |
| 59 | `POST` | `/v1/connections/{id}/close` | Connections | Customer, Vendor | **Yes** |
| 60 | `POST` | `/v1/connections/{id}/contact-events` | Connections | Customer, Vendor | **Yes** |
| 61 | `POST` | `/v1/connections/{id}/reviews` | Reviews | Customer | **Yes** |
| 62 | `GET` | `/v1/me/reviews` | Reviews | Customer, Vendor | *No* (Query) |
| 63 | `GET` | `/v1/reviews/{id}` | Reviews | Customer, Vendor, Admin | *No* |
| 64 | `PATCH` | `/v1/reviews/{id}` | Reviews | Customer | **Yes** |
| 65 | `POST` | `/v1/reviews/{id}/withdraw` | Reviews | Customer | *No* |
| 66 | `POST` | `/v1/reviews/{id}/response` | Reviews | Vendor | **Yes** |
| 67 | `POST` | `/v1/reviews/{id}/flag` | Reviews | Customer, Vendor | **Yes** |
| 68 | `GET` | `/v1/notifications` | Notifications | Authenticated | *No* (Query) |
| 69 | `GET` | `/v1/notifications/unread-count` | Notifications | Authenticated | *No* |
| 70 | `POST` | `/v1/notifications/{id}/read` | Notifications | Authenticated | *No* |
| 71 | `POST` | `/v1/notifications/read-all` | Notifications | Authenticated | *No* |
| 72 | `POST` | `/v1/devices` | Devices / Push | Authenticated | **Yes** |
| 73 | `DELETE` | `/v1/devices/{id}` | Devices / Push | Authenticated | *No* |
| 74 | `POST` | `/v1/abuse-reports` | Trust & Safety | Customer, Vendor | **Yes** |
| 75 | `GET` | `/v1/categories` | Taxonomy | Public | *No* |
| 76 | `GET` | `/v1/regions` | Taxonomy | Public | *No* |
| 77 | `GET` | `/v1/gold-rates` | Reference Rates | Authenticated | *No* |
| 78 | `GET` | `/v1/platform-config` | Config | Public | *No* |
| 79 | `POST` | `/v1/media/upload-intent` | Media Upload | Authenticated | **Yes** |
| 80 | `POST` | `/v1/media/{key}/complete` | Media Upload | Authenticated | *No* |
| 81 | `GET` | `/v1/media/{key}` | Media Fetch | Authenticated | *No* |
| 82 | `GET` | `/v1/admin/dashboard` | Admin Dashboard | Admin | *No* |
| 83 | `GET` | `/v1/admin/verification-queue` | Admin KYC | Admin | *No* (Query) |
| 84 | `GET` | `/v1/admin/vendors` | Admin Vendors | Admin | *No* (Query) |
| 85 | `GET` | `/v1/admin/vendors/{id}` | Admin Vendors | Admin | *No* |
| 86 | `GET` | `/v1/admin/vendors/{id}/documents/{docId}/url` | Admin Vendors | Admin | *No* |
| 87 | `POST` | `/v1/admin/vendors/{id}/verify` | Admin Vendors | Admin | **Yes** |
| 88 | `POST` | `/v1/admin/vendors/{id}/reject` | Admin Vendors | Admin | **Yes** |
| 89 | `POST` | `/v1/admin/vendors/{id}/request-info` | Admin Vendors | Admin | **Yes** |
| 90 | `POST` | `/v1/admin/vendors/{id}/suspend` | Admin Vendors | Admin | **Yes** |
| 91 | `POST` | `/v1/admin/vendors/{id}/reactivate` | Admin Vendors | Admin | **Yes** |
| 92 | `POST` | `/v1/admin/vendors/{id}/deactivate` | Admin Vendors | Admin | **Yes** |
| 93 | `GET` | `/v1/admin/vendors/{id}/subscriptions` | Admin Subscriptions | Admin | *No* |
| 94 | `POST` | `/v1/admin/vendors/{id}/subscriptions` | Admin Subscriptions | Admin | **Yes** |
| 95 | `DELETE` | `/v1/admin/vendors/{id}/subscriptions/{requestType}` | Admin Subscriptions | Admin | *No* |
| 96 | `GET` | `/v1/admin/customers` | Admin Customers | Admin | *No* (Query) |
| 97 | `GET` | `/v1/admin/customers/{id}` | Admin Customers | Admin | *No* |
| 98 | `POST` | `/v1/admin/customers/{id}/suspend` | Admin Customers | Admin | **Yes** |
| 99 | `POST` | `/v1/admin/customers/{id}/reactivate` | Admin Customers | Admin | **Yes** |
| 100 | `POST` | `/v1/admin/customers/{id}/erasure` | Admin Customers | Admin | **Yes** |
| 101 | `GET` | `/v1/admin/requests` | Admin Requests | Admin | *No* (Query) |
| 102 | `GET` | `/v1/admin/requests/{id}` | Admin Requests | Admin | *No* |
| 103 | `POST` | `/v1/admin/requests/{id}/remove` | Admin Requests | Admin | **Yes** |
| 104 | `GET` | `/v1/admin/offers` | Admin Offers | Admin | *No* (Query) |
| 105 | `GET` | `/v1/admin/offers/{id}` | Admin Offers | Admin | *No* |
| 106 | `GET` | `/v1/admin/connections` | Admin Connections | Admin | *No* (Query) |
| 107 | `GET` | `/v1/admin/connections/{id}` | Admin Connections | Admin | *No* |
| 108 | `POST` | `/v1/admin/connections/{id}/close` | Admin Connections | Admin | **Yes** |
| 109 | `GET` | `/v1/admin/reviews` | Admin Reviews | Admin | *No* (Query) |
| 110 | `GET` | `/v1/admin/reviews/{id}` | Admin Reviews | Admin | *No* |
| 111 | `POST` | `/v1/admin/reviews/{id}/approve` | Admin Reviews | Admin | **Yes** |
| 112 | `POST` | `/v1/admin/reviews/{id}/reject` | Admin Reviews | Admin | **Yes** |
| 113 | `POST` | `/v1/admin/reviews/{id}/redact` | Admin Reviews | Admin | **Yes** |
| 114 | `GET` | `/v1/admin/abuse-reports` | Admin Abuse | Admin | *No* (Query) |
| 115 | `GET` | `/v1/admin/abuse-reports/{id}` | Admin Abuse | Admin | *No* |
| 116 | `POST` | `/v1/admin/abuse-reports/{id}/resolve` | Admin Abuse | Admin | **Yes** |
| 117 | `POST` | `/v1/admin/abuse-reports/{id}/dismiss` | Admin Abuse | Admin | **Yes** |
| 118 | `GET` | `/v1/admin/categories` | Admin Taxonomy | Admin | *No* |
| 119 | `POST` | `/v1/admin/categories` | Admin Taxonomy | Admin | **Yes** |
| 120 | `PATCH` | `/v1/admin/categories/{id}` | Admin Taxonomy | Admin | **Yes** |
| 121 | `POST` | `/v1/admin/categories/{id}/deactivate` | Admin Taxonomy | Admin | *No* |
| 122 | `GET` | `/v1/admin/regions` | Admin Taxonomy | Admin | *No* |
| 123 | `POST` | `/v1/admin/regions` | Admin Taxonomy | Admin | **Yes** |
| 124 | `PATCH` | `/v1/admin/regions/{id}` | Admin Taxonomy | Admin | **Yes** |
| 125 | `POST` | `/v1/admin/regions/{id}/deactivate` | Admin Taxonomy | Admin | *No* |
| 126 | `GET` | `/v1/admin/gold-rates` | Admin Rates | Admin | *No* |
| 127 | `POST` | `/v1/admin/gold-rates` | Admin Rates | Admin | **Yes** |
| 128 | `GET` | `/v1/admin/settings` | Admin Settings | Admin | *No* |
| 129 | `PATCH` | `/v1/admin/settings/{key}` | Admin Settings | Admin | **Yes** |
| 130 | `GET` | `/v1/admin/admins` | Admin Staff | Admin | *No* |
| 131 | `POST` | `/v1/admin/admins/{id}/suspend` | Admin Staff | Admin | **Yes** |
| 132 | `POST` | `/v1/admin/admins/{id}/revoke` | Admin Staff | Admin | **Yes** |
| 133 | `GET` | `/v1/admin/announcements` | Admin Broadcast | Admin | *No* |
| 134 | `POST` | `/v1/admin/announcements` | Admin Broadcast | Admin | **Yes** |
| 135 | `POST` | `/v1/admin/announcements/{id}/cancel` | Admin Broadcast | Admin | *No* |
| 136 | `GET` | `/v1/admin/audit-log` | Admin Audit | Admin | *No* (Query) |
| 137 | `POST` | `/v1/admin/audit-log` | Admin Audit | Admin | **Yes** |
| 138 | `GET` | `/v1/admin/exports` | Admin Exports | Admin | *No* |
| 139 | `POST` | `/v1/admin/exports` | Admin Exports | Admin | **Yes** |
| 140 | `GET` | `/v1/admin/exports/{id}` | Admin Exports | Admin | *No* |
| 141 | `GET` | `/v1/admin/reports/{name}` | Admin Analytics | Admin | *No* (Query) |
| 142 | `GET` | `/v1/admin/{collection}/{id}/notes` | Admin Notes | Admin | *No* |
| 143 | `POST` | `/v1/admin/{collection}/{id}/notes` | Admin Notes | Admin | **Yes** |
| 144 | `GET` | `/health` | System Status | Public | *No* |
| 145 | `GET` | `/ready` | System Status | Public | *No* |
| 146 | `POST` | `/v1/dev/vendors/{id}/verify` | Dev Helper | Dev / Admin | *No* |
| 147 | `POST` | `/v1/dev/requests/seed` | Dev Helper | Dev / Admin | **Yes** |

---

## 3. Module Details, Endpoints & JSON Payloads

---

### 3.1 Authentication & Session Management

#### 3.1.1 Request OTP Challenge
* **Endpoint**: `POST /v1/auth/otp/request`
* **Access**: Public / Unauthenticated
* **Description**: Requests an SMS OTP challenge for mobile registration, login, or mobile number update.
* **Request Payload**:
  ```json
  {
    "mobileNumber": "+971501234567",
    "purpose": "LOGIN"
  }
  ```
  *(Allowed `purpose` values: `REGISTRATION`, `LOGIN`, `MOBILE_CHANGE`)*
* **Response Sample**:
  ```json
  {
    "data": {
      "challengeId": "chl_7c9e6679-7425-40de-944b-e07fc1f90ae7",
      "expiresAt": "2026-09-20T03:35:00.000Z",
      "resendAfterSeconds": 60
    }
  }
  ```

#### 3.1.2 Verify OTP Challenge
* **Endpoint**: `POST /v1/auth/otp/verify`
* **Access**: Public / Unauthenticated
* **Description**: Verifies the SMS OTP code sent to the user's phone.
* **Request Payload**:
  ```json
  {
    "challengeId": "chl_7c9e6679-7425-40de-944b-e07fc1f90ae7",
    "code": "849201"
  }
  ```
* **Response Sample**:
  ```json
  {
    "data": {
      "verified": true,
      "challengeId": "chl_7c9e6679-7425-40de-944b-e07fc1f90ae7",
      "userExists": true,
      "session": {
        "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "refreshToken": "rft_4c9f1a23-88bb-4c22-91ef-001298aabbcc",
        "user": {
          "id": "usr_991823ab-cd45-4ef6-7890-abcdef123456",
          "role": "CUSTOMER",
          "displayName": "Fatima Al Mansoori",
          "preferredLanguage": "ar"
        }
      }
    }
  }
  ```

#### 3.1.3 Register Customer Account
* **Endpoint**: `POST /v1/auth/register/customer`
* **Access**: Public (requires verified `challengeId` or `firebaseToken`)
* **Description**: Completes Customer registration after mobile OTP verification or Google authentication.
* **Request Payload**:
  ```json
  {
    "challengeId": "chl_7c9e6679-7425-40de-944b-e07fc1f90ae7",
    "displayName": "Fatima Al Mansoori",
    "email": "fatima.almansoori@example.ae",
    "preferredLanguage": "ar",
    "defaultRegionId": "reg_dubai",
    "termsVersion": "2026-09-01",
    "privacyVersion": "2026-09-01"
  }
  ```
* **Response Sample**:
  ```json
  {
    "data": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "rft_99aa88bb-77cc-66dd-55ee-44ff33ee22dd",
      "user": {
        "id": "usr_c8301829-d591-49fa-9481-229048aab431",
        "role": "CUSTOMER",
        "displayName": "Fatima Al Mansoori",
        "email": "fatima.almansoori@example.ae",
        "preferredLanguage": "ar",
        "defaultRegionId": "reg_dubai"
      }
    }
  }
  ```

#### 3.1.4 Register Vendor Account
* **Endpoint**: `POST /v1/auth/register/vendor`
* **Access**: Public (requires verified `challengeId`)
* **Description**: Submits initial vendor business details to initiate onboarding & KYC.
* **Request Payload**:
  ```json
  {
    "challengeId": "chl_7c9e6679-7425-40de-944b-e07fc1f90ae7",
    "legalBusinessName": "Al Barakah Jewellers LLC",
    "tradingName": "Al Barakah Gold & Diamonds",
    "tradeLicenceNumber": "TL-DXB-987654",
    "phone": "+97142233445",
    "preferredLanguage": "en",
    "defaultRegionId": "reg_dubai",
    "termsVersion": "2026-09-01",
    "privacyVersion": "2026-09-01"
  }
  ```
* **Response Sample**:
  ```json
  {
    "data": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "rft_vendor_11223344-5566-7788-99aa-bbccddeeff00",
      "user": {
        "id": "usr_ven_01928374-abcd-4ef0-9876-fedcba098765",
        "role": "VENDOR",
        "displayName": "Al Barakah Gold & Diamonds",
        "preferredLanguage": "en"
      }
    }
  }
  ```

#### 3.1.5 Google / Firebase Session Exchange
* **Endpoint**: `POST /v1/auth/google/session` *(Alias: `POST /v1/auth/firebase/session`)*
* **Access**: Public / Unauthenticated
* **Description**: Exchanges a verified Google/Firebase ID token for a Karat Hive session bundle.
* **Request Payload**:
  ```json
  {
    "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6ImRiOWU4ZjFjNmE3YjgyZjYxMDY4..."
  }
  ```
* **Response Sample**:
  ```json
  {
    "data": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "rft_77889900-aabb-ccdd-eeff-001122334455",
      "user": {
        "id": "usr_991823ab-cd45-4ef6-7890-abcdef123456",
        "role": "CUSTOMER",
        "displayName": "Fatima Al Mansoori",
        "preferredLanguage": "ar"
      }
    }
  }
  ```

#### 3.1.6 Password Login
* **Endpoint**: `POST /v1/auth/login/password`
* **Access**: Public / Unauthenticated *(Used by Admin and Vendor fallback)*
* **Request Payload**:
  ```json
  {
    "email": "admin@karathive.ae",
    "password": "AdminSecurePassword#2026"
  }
  ```
* **Response Sample**:
  ```json
  {
    "data": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "rft_admin_88776655-4433-2211-00ff-eeddccbbaa99",
      "user": {
        "id": "usr_adm_00000001-0000-0000-0000-000000000001",
        "role": "ADMIN",
        "displayName": "Platform Operations Admin",
        "email": "admin@karathive.ae"
      }
    }
  }
  ```

#### 3.1.7 Token Refresh
* **Endpoint**: `POST /v1/auth/refresh`
* **Access**: Public (requires valid Refresh Token)
* **Request Payload**:
  ```json
  {
    "refreshToken": "rft_4c9f1a23-88bb-4c22-91ef-001298aabbcc"
  }
  ```
* **Response Sample**:
  ```json
  {
    "data": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "rft_5d0a2b34-99cc-5d33-02fa-112309bbccdd"
    }
  }
  ```

#### 3.1.8 Logout
* **Endpoint**: `POST /v1/auth/logout`
* **Access**: Authenticated
* **Request Payload**:
  ```json
  {
    "refreshToken": "rft_5d0a2b34-99cc-5d33-02fa-112309bbccdd"
  }
  ```
* **Response Sample**:
  ```json
  {
    "data": {
      "loggedOut": true
    }
  }
  ```

---

### 3.2 Current User & Profile Management (`/v1/me`)

#### 3.2.1 Get Authenticated User Profile
* **Endpoint**: `GET /v1/me`
* **Access**: Customer, Vendor, Admin
* **Request Payload**: *None*
* **Response Sample**:
  ```json
  {
    "data": {
      "id": "usr_c8301829-d591-49fa-9481-229048aab431",
      "role": "CUSTOMER",
      "mobileNumber": "+971501234567",
      "displayName": "Fatima Al Mansoori",
      "email": "fatima.almansoori@example.ae",
      "preferredLanguage": "ar",
      "defaultRegionId": "reg_dubai",
      "photoMediaKey": "media/users/avatar_9876.jpg",
      "isSuspended": false,
      "createdAt": "2026-09-01T10:00:00.000Z"
    }
  }
  ```

#### 3.2.2 Update Profile
* **Endpoint**: `PATCH /v1/me`
* **Access**: Customer, Vendor
* **Request Payload**:
  ```json
  {
    "displayName": "Fatima M. Al Mansoori",
    "email": "fatima.m@example.ae",
    "preferredLanguage": "ar",
    "defaultRegionId": "reg_dubai",
    "photoMediaKey": "media/users/avatar_new_9876.jpg"
  }
  ```
* **Response Sample**:
  ```json
  {
    "data": {
      "id": "usr_c8301829-d591-49fa-9481-229048aab431",
      "displayName": "Fatima M. Al Mansoori",
      "email": "fatima.m@example.ae",
      "preferredLanguage": "ar",
      "defaultRegionId": "reg_dubai",
      "photoMediaKey": "media/users/avatar_new_9876.jpg"
    }
  }
  ```

#### 3.2.3 Change Mobile Number
* **Endpoint**: `POST /v1/me/mobile/change`
* **Access**: Customer, Vendor
* **Request Payload**:
  ```json
  {
    "challengeId": "chl_verified_mobile_change_uuid"
  }
  ```
* **Response Sample**:
  ```json
  {
    "data": {
      "mobileNumber": "+971509998888",
      "updatedAt": "2026-09-20T03:30:00.000Z"
    }
  }
  ```

#### 3.2.4 User Settings & Preferences
* **Endpoint**: `GET /v1/me/settings` & `PATCH /v1/me/settings`
* **Access**: Customer, Vendor
* **PATCH Request Payload**:
  ```json
  {
    "pushEnabled": true,
    "smsEnabled": false,
    "whatsappEnabled": true,
    "emailEnabled": true,
    "matchAlerts": true,
    "offerAlerts": true,
    "connectionAlerts": true,
    "quietHoursEnabled": true,
    "quietHoursStartUtc": "20:00",
    "quietHoursEndUtc": "05:00"
  }
  ```
* **Response Sample**:
  ```json
  {
    "data": {
      "pushEnabled": true,
      "smsEnabled": false,
      "whatsappEnabled": true,
      "emailEnabled": true,
      "matchAlerts": true,
      "offerAlerts": true,
      "connectionAlerts": true,
      "quietHoursEnabled": true,
      "quietHoursStartUtc": "20:00",
      "quietHoursEndUtc": "05:00"
    }
  }
  ```

---

### 3.3 Vendor Profile, Onboarding & Analytics

#### 3.3.1 Get Vendor Profile
* **Endpoint**: `GET /v1/me/vendor`
* **Access**: Vendor
* **Request Payload**: *None*
* **Response Sample**:
  ```json
  {
    "data": {
      "id": "ven_01928374-abcd-4ef0-9876-fedcba098765",
      "legalBusinessName": "Al Barakah Jewellers LLC",
      "tradingName": "Al Barakah Gold & Diamonds",
      "tradeLicenceNumber": "TL-DXB-987654",
      "kycStatus": "VERIFIED",
      "acceptingRequests": true,
      "phone": "+97142233445",
      "address": "Shop 14, Ground Floor, Deira Gold Souk, Dubai",
      "googleMapsUrl": "https://maps.app.goo.gl/sampleDeiraGoldSouk",
      "whatsappNumber": "+971501239876",
      "categories": [
        { "id": "cat_bullion", "nameEn": "Gold Bullion & Bars", "nameAr": "سبائك الذهب" },
        { "id": "cat_coins", "nameEn": "Gold Coins", "nameAr": "عملات ذهبية" }
      ],
      "regions": [
        { "id": "reg_dubai", "nameEn": "Dubai", "nameAr": "دبي" }
      ],
      "connectionCount": 42,
      "rating": {
        "average": "4.9",
        "count": 28,
        "limitedHistory": false
      }
    }
  }
  ```

#### 3.3.2 Update Vendor Business Profile
* **Endpoint**: `PATCH /v1/me/vendor`
* **Access**: Vendor
* **Request Payload**:
  ```json
  {
    "tradingName": "Al Barakah Gold & Diamonds",
    "address": "Shop 14, Ground Floor, Deira Gold Souk, Dubai",
    "googleMapsUrl": "https://maps.app.goo.gl/sampleDeiraGoldSouk",
    "whatsappNumber": "+971501239876"
  }
  ```

#### 3.3.3 Upload KYC Document Record
* **Endpoint**: `POST /v1/me/vendor/documents`
* **Access**: Vendor
* **Request Payload**:
  ```json
  {
    "documentType": "TRADE_LICENCE",
    "mediaKey": "media/kyc/trade_licence_doc_998877.pdf",
    "validUntil": "2027-12-31"
  }
  ```

#### 3.3.4 Update Vendor Categories & Operating Regions
* **Endpoints**: `PUT /v1/me/vendor/categories` & `PUT /v1/me/vendor/regions`
* **Access**: Vendor
* **Categories Payload**:
  ```json
  {
    "categoryIds": ["cat_bullion", "cat_coins", "cat_bridal_sets"]
  }
  ```
* **Regions Payload**:
  ```json
  {
    "regionIds": ["reg_dubai", "reg_sharjah", "reg_abu_dhabi"]
  }
  ```

#### 3.3.5 Toggle Vendor Availability
* **Endpoint**: `PATCH /v1/me/vendor/availability`
* **Access**: Vendor
* **Request Payload**:
  ```json
  {
    "acceptingRequests": false
  }
  ```

#### 3.3.6 Vendor Home Dashboard Metrics
* **Endpoint**: `GET /v1/me/dashboard`
* **Access**: Vendor
* **Request Payload**: *None*
* **Response Sample**:
  ```json
  {
    "data": {
      "kycStatus": "VERIFIED",
      "acceptingRequests": true,
      "activeMatchesCount": 15,
      "pendingOffersCount": 4,
      "activeConnectionsCount": 7,
      "unreadNotificationsCount": 2,
      "performance": {
        "monthlyOffersSubmitted": 38,
        "monthlyOffersAccepted": 12,
        "conversionRate": "0.315",
        "averageResponseMinutes": 14.5
      }
    }
  }
  ```

---

### 3.4 Buying Requests (`/v1/requests` & `/v1/me/requests`)

#### 3.4.1 Create Request Draft
* **Endpoint**: `POST /v1/requests`
* **Access**: Customer
* **Description**: Creates a new jewellery buying intent / request.
* **Request Payload**:
  ```json
  {
    "requestType": "BUY",
    "direction": "BUY",
    "categoryId": "cat_bullion",
    "regionId": "reg_dubai",
    "notes": "Looking for 100g 24K PAMP Suisse gold bar with certificate and assay card",
    "weightGrams": "100.00",
    "weightIsApproximate": false,
    "purityKarat": "24K",
    "mintOrRefiner": "PAMP Suisse",
    "budgetMin": "32000.00",
    "budgetMax": "33500.00",
    "budgetIsFlexible": true,
    "gemstones": null,
    "mediaKeys": [
      "media/requests/ref_bar_front_100g.jpg"
    ]
  }
  ```
* **Response Sample**:
  ```json
  {
    "data": {
      "id": "req_11223344-5566-7788-99aa-bbccddeeff00",
      "reference": "KH-REQ-2026-00912",
      "requestType": "BUY",
      "direction": "BUY",
      "state": "DRAFT",
      "category": {
        "id": "cat_bullion",
        "nameEn": "Gold Bullion & Bars",
        "nameAr": "سبائك الذهب",
        "isActive": true,
        "displayOrder": 1
      },
      "region": {
        "id": "reg_dubai",
        "nameEn": "Dubai",
        "nameAr": "دبي",
        "isActive": true,
        "displayOrder": 1
      },
      "weightGrams": "100.00",
      "weightIsApproximate": false,
      "purityKarat": "24K",
      "mintOrRefiner": "PAMP Suisse",
      "budgetMin": "32000.00",
      "budgetMax": "33500.00",
      "budgetIsFlexible": true,
      "offerCount": 0,
      "media": [
        {
          "id": "med_998877",
          "key": "media/requests/ref_bar_front_100g.jpg",
          "displayOrder": 0,
          "purpose": "REQUEST_IMAGE"
        }
      ],
      "createdAt": "2026-09-20T03:30:00.000Z",
      "updatedAt": "2026-09-20T03:30:00.000Z"
    }
  }
  ```

#### 3.4.2 Publish Request
* **Endpoint**: `POST /v1/requests/{id}/publish`
* **Access**: Customer (Owner)
* **Request Payload**: *None*
* **Response Sample**:
  ```json
  {
    "data": {
      "id": "req_11223344-5566-7788-99aa-bbccddeeff00",
      "state": "PUBLISHED",
      "publishedAt": "2026-09-20T03:32:00.000Z",
      "expiresAt": "2026-09-27T03:32:00.000Z"
    }
  }
  ```

#### 3.4.3 Cancel Request
* **Endpoint**: `POST /v1/requests/{id}/cancel`
* **Access**: Customer (Owner)
* **Request Payload**:
  ```json
  {
    "reason": "PURCHASED_OFF_PLATFORM",
    "notes": "Found in local store"
  }
  ```

#### 3.4.4 Duplicate Request
* **Endpoint**: `POST /v1/requests/{id}/duplicate`
* **Access**: Customer (Owner)
* **Request Payload**: *None*

#### 3.4.5 List Customer Requests
* **Endpoint**: `GET /v1/me/requests?state=PUBLISHED&limit=20`
* **Access**: Customer
* **Request Payload**: *None (Query Params: `state`, `limit`, `cursor`)*

---

### 3.5 Matching Engine & Vendor Feed (`/v1/matches`, `/v1/filter-presets`)

#### 3.5.1 Get Matched Requests Feed
* **Endpoint**: `GET /v1/matches?categoryId=cat_bullion&regionId=reg_dubai&limit=20`
* **Access**: Vendor (with active Type Subscription)
* **Request Payload**: *None (Query Params: `categoryId`, `regionId`, `purityKarat`, `minBudget`, `maxBudget`, `cursor`, `limit`)*
* **Response Sample**:
  ```json
  {
    "data": [
      {
        "id": "req_11223344-5566-7788-99aa-bbccddeeff00",
        "reference": "KH-REQ-2026-00912",
        "requestType": "BUY",
        "category": { "id": "cat_bullion", "nameEn": "Gold Bullion & Bars", "nameAr": "سبائك الذهب" },
        "region": { "id": "reg_dubai", "nameEn": "Dubai", "nameAr": "دبي" },
        "weightGrams": "100.00",
        "purityKarat": "24K",
        "budgetMin": "32000.00",
        "budgetMax": "33500.00",
        "budgetIsFlexible": true,
        "notes": "Looking for 100g 24K PAMP Suisse gold bar",
        "expiresAt": "2026-09-27T03:32:00.000Z",
        "hasViewed": false,
        "hasSubmittedOffer": false
      }
    ],
    "meta": {
      "nextCursor": "eyJpZCI6InJlcV8xMTIyMzM0NCJ9"
    }
  }
  ```

#### 3.5.2 Mark Matched Request as Viewed
* **Endpoint**: `POST /v1/matches/{requestId}/viewed`
* **Access**: Vendor
* **Request Payload**: *None*

#### 3.5.3 Create Saved Filter Preset
* **Endpoint**: `POST /v1/filter-presets`
* **Access**: Vendor
* **Request Payload**:
  ```json
  {
    "name": "Dubai 24K Bullion Feed",
    "categoryIds": ["cat_bullion", "cat_coins"],
    "regionIds": ["reg_dubai"],
    "requestTypes": ["BUY"],
    "minBudget": "10000.00",
    "maxBudget": "150000.00"
  }
  ```

---

### 3.6 Offers (`/v1/offers`, `/v1/requests/{id}/offers`)

#### 3.6.1 Submit Offer (Vendor)
* **Endpoint**: `POST /v1/requests/{requestId}/offers`
* **Access**: Vendor
* **Request Payload**:
  ```json
  {
    "offeredPrice": "32850.00",
    "makingCharges": "150.00",
    "ratePerGram": "327.00",
    "validityHours": 24,
    "deliveryTimeframe": "Ready for same-day store pickup at Deira branch",
    "warrantyTerms": "Official PAMP assay certificate included + lifetime purity guarantee",
    "vendorNote": "Brand new 100g bar, sealed in original assay cert pack with unique serial number.",
    "mediaKeys": [
      "media/offers/bar_actual_photo_01.jpg"
    ]
  }
  ```
* **Response Sample**:
  ```json
  {
    "data": {
      "id": "off_99887766-5544-3322-1100-aabbccddeeff",
      "requestId": "req_11223344-5566-7788-99aa-bbccddeeff00",
      "state": "PENDING",
      "submittedAt": "2026-09-20T03:35:00.000Z",
      "expiresAt": "2026-09-21T03:35:00.000Z",
      "revisionCount": 0,
      "terms": {
        "offeredPrice": "32850.00",
        "makingCharges": "150.00",
        "ratePerGram": "327.00",
        "validityHours": 24,
        "deliveryTimeframe": "Ready for same-day store pickup at Deira branch",
        "warrantyTerms": "Official PAMP assay certificate included + lifetime purity guarantee",
        "vendorNote": "Brand new 100g bar, sealed in original assay cert pack with unique serial number."
      }
    }
  }
  ```

#### 3.6.2 Revise Offer (Vendor)
* **Endpoint**: `POST /v1/offers/{id}/revise`
* **Access**: Vendor (Owner)
* **Request Payload**:
  ```json
  {
    "offeredPrice": "32600.00",
    "makingCharges": "100.00",
    "ratePerGram": "325.00",
    "validityHours": 24,
    "vendorNote": "Special discounted rate applied."
  }
  ```

#### 3.6.3 Withdraw Offer (Vendor)
* **Endpoint**: `POST /v1/offers/{id}/withdraw`
* **Access**: Vendor (Owner)
* **Request Payload**:
  ```json
  {
    "reason": "ITEM_SOLD_OUT"
  }
  ```

#### 3.6.4 Accept Offer (Customer)
* **Endpoint**: `POST /v1/offers/{id}/accept`
* **Access**: Customer (Request Owner)
* **Description**: Accepting an offer locks the deal and automatically creates an unmasked Connection with WhatsApp Talk handoff.
* **Request Payload**: *None*
* **Response Sample**:
  ```json
  {
    "data": {
      "connectionId": "con_55443322-1100-9988-7766-554433221100",
      "state": "OPEN",
      "identityRevealedAt": "2026-09-20T03:40:00.000Z",
      "vendor": {
        "id": "ven_01928374-abcd-4ef0-9876-fedcba098765",
        "legalBusinessName": "Al Barakah Jewellers LLC",
        "tradingName": "Al Barakah Gold & Diamonds",
        "tradeLicenceNumber": "TL-DXB-987654",
        "phone": "+97142233445"
      },
      "talk": {
        "available": true,
        "waUrl": "https://wa.me/97142233445?text=Hello%20Al%20Barakah%2C%20regarding%20Offer%20KH-OFF-0012...",
        "phone": "+97142233445",
        "callUrl": "tel:+97142233445"
      }
    }
  }
  ```

#### 3.6.5 Decline Offer (Customer)
* **Endpoint**: `POST /v1/offers/{id}/decline`
* **Access**: Customer (Request Owner)
* **Request Payload**:
  ```json
  {
    "reason": "PRICE_TOO_HIGH"
  }
  ```

#### 3.6.6 Get Masked Vendor Rating Breakdown
* **Endpoint**: `GET /v1/offers/{id}/vendor-rating`
* **Access**: Customer
* **Request Payload**: *None*

---

### 3.7 Connections & Talk Handoff (`/v1/connections`, `/v1/me/connections`)

#### 3.7.1 Get Connection Detail
* **Endpoint**: `GET /v1/connections/{id}`
* **Access**: Customer or Vendor (Parties to Connection)
* **Request Payload**: *None*
* **Response Sample**:
  ```json
  {
    "data": {
      "id": "con_55443322-1100-9988-7766-554433221100",
      "offerId": "off_99887766-5544-3322-1100-aabbccddeeff",
      "requestId": "req_11223344-5566-7788-99aa-bbccddeeff00",
      "state": "OPEN",
      "identityRevealedAt": "2026-09-20T03:40:00.000Z",
      "vendor": {
        "id": "ven_01928374-abcd-4ef0-9876-fedcba098765",
        "legalBusinessName": "Al Barakah Jewellers LLC",
        "tradingName": "Al Barakah Gold & Diamonds",
        "tradeLicenceNumber": "TL-DXB-987654",
        "phone": "+97142233445",
        "connectionCount": 42
      },
      "talk": {
        "available": true,
        "waUrl": "https://wa.me/97142233445?text=...",
        "phone": "+97142233445",
        "callUrl": "tel:+97142233445"
      }
    }
  }
  ```

#### 3.7.2 Record Contact Event (WhatsApp Tap)
* **Endpoint**: `POST /v1/connections/{id}/contact-events`
* **Access**: Customer or Vendor
* **Request Payload**:
  ```json
  {
    "channel": "WHATSAPP",
    "clientTimestamp": "2026-09-20T03:41:00.000Z"
  }
  ```

#### 3.7.3 Close Connection
* **Endpoint**: `POST /v1/connections/{id}/close`
* **Access**: Customer or Vendor
* **Request Payload**:
  ```json
  {
    "outcome": "DEAL_COMPLETED",
    "feedback": "Customer visited store, paid AED 32,600 and collected the bullion bar."
  }
  ```

---

### 3.8 Reviews (`/v1/reviews`, `/v1/connections/{id}/reviews`)

#### 3.8.1 Submit Review for Completed Connection
* **Endpoint**: `POST /v1/connections/{connectionId}/reviews`
* **Access**: Customer
* **Request Payload**:
  ```json
  {
    "rating": 5,
    "comment": "Genuine PAMP bar sealed with cert. Very polite staff and swift handover in Deira Gold Souk!"
  }
  ```

#### 3.8.2 Vendor Response to Review
* **Endpoint**: `POST /v1/reviews/{id}/response`
* **Access**: Vendor (Subject of Review)
* **Request Payload**:
  ```json
  {
    "response": "Thank you for choosing Al Barakah Jewellers! We appreciate your trust."
  }
  ```

#### 3.8.3 Flag Review for Moderation
* **Endpoint**: `POST /v1/reviews/{id}/flag`
* **Access**: Customer or Vendor
* **Request Payload**:
  ```json
  {
    "reason": "ABUSIVE_OR_FALSE",
    "details": "Customer did not visit store; defamatory claims."
  }
  ```

---

### 3.9 Notifications & Devices

#### 3.9.1 Register Push Device Token
* **Endpoint**: `POST /v1/devices`
* **Access**: Authenticated (Customer, Vendor, Admin)
* **Request Payload**:
  ```json
  {
    "token": "fcm_token_dx992k_sample_abc1234567890xyz",
    "platform": "ANDROID",
    "appVersion": "1.0.4",
    "deviceModel": "Pixel 8 Pro"
  }
  ```

#### 3.9.2 Mark Notification as Read
* **Endpoint**: `POST /v1/notifications/{id}/read`
* **Access**: Authenticated
* **Request Payload**: *None*

#### 3.9.3 Mark All Notifications as Read
* **Endpoint**: `POST /v1/notifications/read-all`
* **Access**: Authenticated
* **Request Payload**: *None*

---

### 3.10 Abuse Reports (`/v1/abuse-reports`)

#### 3.10.1 Submit Abuse / Scam Report
* **Endpoint**: `POST /v1/abuse-reports`
* **Access**: Customer or Vendor
* **Request Payload**:
  ```json
  {
    "targetType": "VENDOR",
    "targetId": "ven_01928374-abcd-4ef0-9876-fedcba098765",
    "reason": "FRAUD_OR_MISREPRESENTATION",
    "details": "Vendor attempted to offer unofficial hallmark non-certified item contrary to agreed terms.",
    "evidenceMediaKeys": [
      "media/evidence/chat_screenshot_01.jpg"
    ]
  }
  ```

---

### 3.11 Media Pipeline (`/v1/media`)

#### 3.11.1 Create Upload Intent
* **Endpoint**: `POST /v1/media/upload-intent`
* **Access**: Authenticated
* **Request Payload**:
  ```json
  {
    "purpose": "REQUEST_ATTACHMENT",
    "contentType": "image/jpeg",
    "byteSize": 2450000,
    "filename": "necklace_front.jpg"
  }
  ```
* **Response Sample**:
  ```json
  {
    "data": {
      "key": "media/requests/req_image_99881122.jpg",
      "uploadUrl": "https://r2.cloudflarestorage.com/karathive/media/requests/req_image_99881122.jpg?X-Amz-Signature=...",
      "expiresAt": "2026-09-20T04:00:00.000Z"
    }
  }
  ```

#### 3.11.2 Complete Media Upload
* **Endpoint**: `POST /v1/media/{key}/complete`
* **Access**: Authenticated
* **Request Payload**: *None*

---

### 3.12 Taxonomy, Config & Gold Rates

#### 3.12.1 Get Categories Tree
* **Endpoint**: `GET /v1/categories`
* **Access**: Public
* **Request Payload**: *None*

#### 3.12.2 Get Operating Regions
* **Endpoint**: `GET /v1/regions`
* **Access**: Public
* **Request Payload**: *None*

#### 3.12.3 Get Current Gold Rates
* **Endpoint**: `GET /v1/gold-rates`
* **Access**: Authenticated
* **Request Payload**: *None*
* **Response Sample**:
  ```json
  {
    "data": {
      "timestamp": "2026-09-20T03:30:00.000Z",
      "currency": "AED",
      "unit": "GRAM",
      "rates": {
        "24K": "328.50",
        "22K": "304.25",
        "21K": "290.50",
        "18K": "249.00"
      },
      "source": "CENTRAL_BANK_MARKET_FEED"
    }
  }
  ```

#### 3.12.4 Get Platform Operational Config
* **Endpoint**: `GET /v1/platform-config`
* **Access**: Public
* **Request Payload**: *None*

---

### 3.13 Admin Operations (`/v1/admin/...`)

#### 3.13.1 Verification Decisions
* **Verify Vendor**: `POST /v1/admin/vendors/{id}/verify`
  ```json
  {
    "note": "Trade license verified with Dubai DED; premises inspected."
  }
  ```
* **Reject Vendor KYC**: `POST /v1/admin/vendors/{id}/reject`
  ```json
  {
    "reason": "Expired trade license; company name mismatch.",
    "note": "Document uploaded was expired on 2025-12-31."
  }
  ```
* **Request Additional Info**: `POST /v1/admin/vendors/{id}/request-info`
  ```json
  {
    "note": "Please upload a clearer copy of the trade license showing page 2 activities."
  }
  ```

#### 3.13.2 Vendor Lifecycle Operations
* **Suspend Vendor**: `POST /v1/admin/vendors/{id}/suspend`
  ```json
  {
    "reason": "POLICY_VIOLATION",
    "note": "Multiple unfulfilled verified accepted offers."
  }
  ```
* **Reactivate Vendor**: `POST /v1/admin/vendors/{id}/reactivate`
  ```json
  {
    "note": "Vendor resolved dispute and completed pending settlement."
  }
  ```

#### 3.13.3 Customer Account Management
* **Suspend Customer**: `POST /v1/admin/customers/{id}/suspend`
  ```json
  {
    "reason": "SUSPICIOUS_ACTIVITY",
    "note": "Spam buying requests posted across multiple regions."
  }
  ```
* **Process Customer Erasure (GDPR/Privacy)**: `POST /v1/admin/customers/{id}/erasure`
  ```json
  {
    "note": "Customer requested account erasure under Privacy Policy §12."
  }
  ```

#### 3.13.4 Request Takedown
* **Remove Request**: `POST /v1/admin/requests/{id}/remove`
  ```json
  {
    "reason": "PROHIBITED_GOODS",
    "note": "Item does not meet marketplace precious metal guidelines."
  }
  ```

#### 3.13.5 Review Moderation
* **Approve Review**: `POST /v1/admin/reviews/{id}/approve`
  ```json
  {
    "note": "Verified genuine customer feedback."
  }
  ```
* **Reject Review**: `POST /v1/admin/reviews/{id}/reject`
  ```json
  {
    "reason": "POLICY_VIOLATION",
    "note": "Contains external phone numbers and abusive text."
  }
  ```
* **Redact Review**: `POST /v1/admin/reviews/{id}/redact`
  ```json
  {
    "redactedComment": "Customer feedback regarding store experience [phone number redacted by admin].",
    "note": "Removed private phone number from review comment."
  }
  ```

#### 3.13.6 Abuse Report Resolution
* **Resolve Report**: `POST /v1/admin/abuse-reports/{id}/resolve`
  ```json
  {
    "actionTaken": "VENDOR_SUSPENDED",
    "note": "Confirmed counterfeit claim; vendor suspended pending investigation."
  }
  ```
* **Dismiss Report**: `POST /v1/admin/abuse-reports/{id}/dismiss`
  ```json
  {
    "reason": "UNSUBSTANTIATED",
    "note": "No evidence provided of wrongdoing."
  }
  ```

#### 3.13.7 Taxonomy Management (Categories & Regions)
* **Create Category**: `POST /v1/admin/categories`
  ```json
  {
    "nameEn": "Antique & Heritage Jewellery",
    "nameAr": "مجوهرات أثرية وتراثية",
    "icon": "heritage_ring",
    "displayOrder": 5,
    "isActive": true
  }
  ```
* **Update Category**: `PATCH /v1/admin/categories/{id}`
  ```json
  {
    "nameEn": "Heritage & Vintage Jewellery",
    "displayOrder": 4
  }
  ```
* **Create Region**: `POST /v1/admin/regions`
  ```json
  {
    "nameEn": "Ras Al Khaimah",
    "nameAr": "رأس الخيمة",
    "displayOrder": 6,
    "isActive": true
  }
  ```

#### 3.13.8 Manual Gold Rate Override
* **Set Gold Rate**: `POST /v1/admin/gold-rates`
  ```json
  {
    "purityKarat": "24K",
    "ratePerGram": "329.00",
    "currency": "AED",
    "overrideUntil": "2026-09-20T18:00:00.000Z"
  }
  ```

#### 3.13.9 Platform Settings
* **Update Setting**: `PATCH /v1/admin/settings/{key}`
  ```json
  {
    "value": "48"
  }
  ```

#### 3.13.10 Broadcast Announcements
* **Create Announcement**: `POST /v1/admin/announcements`
  ```json
  {
    "titleEn": "Scheduled Maintenance",
    "titleAr": "صيانة دورية مجدولة",
    "bodyEn": "The marketplace will undergo scheduled maintenance on Sunday from 2 AM to 4 AM GST.",
    "bodyAr": "ستخضع المنصة لصيانة دورية يوم الأحد من الساعة 2 إلى 4 صباحاً بتوقيت الإمارات.",
    "targetRole": "ALL",
    "scheduledAt": "2026-09-22T02:00:00.000Z"
  }
  ```

#### 3.13.11 Admin Audit Logging & Internal Notes
* **Record Audit View Event**: `POST /v1/admin/audit-log`
  ```json
  {
    "action": "CUSTOMER_DETAIL_VIEW",
    "targetType": "CUSTOMER",
    "targetId": "usr_c8301829-d591-49fa-9481-229048aab431",
    "metadata": {
      "screen": "ADM-S04",
      "reason": "KYC inquiry lookup"
    }
  }
  ```
* **Add Internal Note to Any Entity**: `POST /v1/admin/{collection}/{id}/notes`
  ```json
  {
    "note": "Spoke with vendor manager over phone; updated trade license copy promised by tomorrow morning."
  }
  ```

---

## 4. Verification & Validation Summary

All payload models above adhere strictly to:
1. **Decimal Monetary & Weight String Representations**: `budgetMin`, `budgetMax`, `offeredPrice`, `ratePerGram`, and `weightGrams` are encoded as strings (e.g., `"32850.00"`, `"100.00"`).
2. **Standard State Transitions**: Dedicated state-transition sub-resources (`/publish`, `/cancel`, `/accept`, `/withdraw`, `/close`, `/verify`, `/reject`).
3. **Data Protection & Identity Masking**: Vendor details remain completely masked until an offer is accepted by the customer, where an unmasked Connection with WhatsApp deep-link (`wa.me`) is returned.
