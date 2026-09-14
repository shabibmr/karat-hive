# Inspector Balram: Karat Hive Admin Portal Screen Audit

**Scope**: Platform Admin Web Portal (`apps/kh_admin`)  
**Categorisation**: Screen-by-Screen Inspection  
**Last Updated**: 2026-09-09  

---

## 1. Master Unit Checklist

| Unit ID | Unit Name | Mode / Surface | Status | Reference File |
|---|---|---|---|---|
| **ADM-S01** | Login with 2FA / Google SSO | Web Entry | ✅ Inspected | apps/kh_admin/lib/features/auth/presentation/login_screen.dart |
| **ADM-S02** | Dashboard & Metrics Snapshot | Web Dashboard | ✅ Inspected | apps/kh_admin/lib/features/dashboard/presentation/dashboard_screen.dart |
| **ADM-S03** | Customer List | Web Management | ✅ Inspected | apps/kh_admin/lib/features/customers/presentation/customer_list_screen.dart |
| **ADM-S04** | Customer Detail | Web Detail | ✅ Inspected | apps/kh_admin/lib/features/customers/presentation/customer_detail_screen.dart |
| **ADM-S05** | Vendor List | Web Management | ✅ Inspected | apps/kh_admin/lib/features/vendors/presentation/vendor_list_screen.dart |
| **ADM-S06** | Vendor Detail | Web Detail | ✅ Inspected | apps/kh_admin/lib/features/vendors/presentation/vendor_detail_screen.dart |
| **ADM-S07** | Verification Queue & Doc Reviewer | Web Queue & Review | 🟡 In Inspection (Current) | apps/kh_admin/lib/features/verification/presentation/verification_screen.dart |
| **ADM-S08** | Request List | Web Management | ⏳ Queued (Pre-fetched) | apps/kh_admin/lib/features/requests/presentation/request_list_screen.dart |
| **ADM-S09** | Request Detail | Web Detail | ⏳ Queued (Pre-fetched) | apps/kh_admin/lib/features/requests/presentation/request_detail_screen.dart |
| **ADM-S10** | Offer List | Web Management | ⏳ Queued | apps/kh_admin/lib/features/offers/presentation/offer_list_screen.dart |
| **ADM-S11** | Offer Detail | Web Detail | ⏳ Queued | apps/kh_admin/lib/features/offers/presentation/offer_detail_screen.dart |
| **ADM-S12** | Connection List | Web Management | ⏳ Queued | apps/kh_admin/lib/features/connections/presentation/connection_list_screen.dart |
| **ADM-S13** | Connection Detail | Web Detail | ⏳ Queued | apps/kh_admin/lib/features/connections/presentation/connection_detail_screen.dart |
| **ADM-S14** | Category Management | Web Taxonomy | ⏳ Queued | apps/kh_admin/lib/features/taxonomy/presentation/category_management_screen.dart |
| **ADM-S15** | Region Management | Web Taxonomy | ⏳ Queued | apps/kh_admin/lib/features/taxonomy/presentation/region_management_screen.dart |
| **ADM-S16** | Review Moderation Queue | Web Queue & Review | ⏳ Queued | apps/kh_admin/lib/features/moderation/presentation/moderation_screen.dart |
| **ADM-S17** | Reports & Analytics | Web Analytics | ⏳ Queued | apps/kh_admin/lib/features/reports/presentation/reports_screen.dart |
| **ADM-S18** | Announcement Composer | Web Tool | ⏳ Queued | apps/kh_admin/lib/features/announcements/presentation/announcements_screen.dart |
| **ADM-S19** | Platform Settings | Web Settings | ⏳ Queued | apps/kh_admin/lib/features/settings/presentation/platform_settings_screen.dart |
| **ADM-S20** | Gold Rate Configuration | Web Pricing | ⏳ Deferred (AD-API-09) | apps/kh_admin/lib/features/gold_rates/presentation/gold_rates_screen.dart |
| **ADM-S21** | Abuse Report Queue | Web Queue & Review | ⏳ Queued | apps/kh_admin/lib/features/abuse/presentation/abuse_screen.dart |
| **ADM-S22** | Audit Log Viewer | Web Compliance | ⏳ Queued | apps/kh_admin/lib/features/audit/presentation/audit_screen.dart |
| **ADM-S23** | Admin User Management | Web Auth & RBAC | ⏳ Queued | apps/kh_admin/lib/features/admin_users/presentation/admin_users_screen.dart |

---

## 2. Unit Decisions & Discrepancies Log

### Unit ADM-S07: Verification Queue & Document Reviewer
- **Target Files**:
  - Presentation: `apps/kh_admin/lib/features/verification/presentation/verification_screen.dart`
  - Queue List: `apps/kh_admin/lib/features/verification/presentation/verification_queue_list.dart`
  - Detail Pane: `apps/kh_admin/lib/features/verification/presentation/verification_detail_pane.dart`
  - Dialogs: `apps/kh_admin/lib/features/verification/presentation/verification_dialogs.dart`
  - Controller: `apps/kh_admin/lib/features/verification/controller/verification_controller.dart`
  - Repository: `apps/kh_admin/lib/features/verification/repository/verification_repository.dart`
  - Backend: `backend/src/modules/admin/controller/admin-vendor.controller.ts`, `backend/src/modules/admin/application/admin-vendor.service.ts`
- **Phase 1 Inspection (UI / Surface)**:
  - Header displays item count + "OLDEST FIRST" status chip + refresh button.
  - Split master-detail layout: Queue table on left (40%), Detail review pane on right (60%).
  - Queue List columns: Business Name & Trading Name, Trade Licence Number, Waiting Age (warning tone if >= 48h), Status chip (`PENDING`).
  - Detail Pane Sections:
    1. Declared Business Profile: Legal name, Licence number, Expiry date, Address, Contact Person & Phone, Email, Categories, Regions.
    2. Uploaded KYC Documents: List of documents with MIME type icon, filename, verified chip, and "View" button with loading state.
    3. Action Bar CTAs: "Request More Info", "Reject Verification", "Approve Verification".
- **Phase 2 Inspection (Functions & Business Rules)**:
  - **API Contract**:
    - `GET /v1/admin/verification-queue`: Oldest-first (`createdAt: 'asc'`).
    - `GET /v1/admin/vendors/:id`: Unmasked vendor profile + KYC documents + user info.
    - `GET /v1/admin/vendors/:id/documents/:docId/url`: Generates signed S3/R2 download URL and writes `VENDOR_DOCUMENT_VIEWED` audit log.
    - `POST /v1/admin/vendors/:id/verify`: Requires rationale. Auto-activates if categories and regions exist (`vendor.eligibility.changed` emitted).
    - `POST /v1/admin/vendors/:id/reject`: Requires rationale and reason message to vendor.
    - `POST /v1/admin/vendors/:id/request-info`: Requires message to vendor explaining missing details.
