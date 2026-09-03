# Karat Hive — UI Screens Inventory

Screen-level field inventory derived from `docs/Requirements-Spec-v1.3.md` (Appendix C + §4 functional requirements + §6 entity dictionary). Domain language follows root `CONTEXT.md`.

**Not included:** visual design, layout, or implementation details.

**Related:** [Component & widget catalog](component-widgets.md) — shared vs individual widgets mapped to these screens.

---

## Counts

| User | Platform | Screens | Folder |
|---|---|---|---|
| **Customer** | Flutter mobile — Customer mode | 22 | [customer/](customer/) |
| **Vendor** | Flutter mobile — Vendor mode | 22 | [vendor/](vendor/) |
| **Platform Admin** | Flutter Web — Admin Portal (≥ 1280 px) | 23 | [admin/](admin/) |
| **Total** | | **67** | |

One mobile binary, two modes by account role (Customer **or** Vendor, not both). Admin is a separate build of the same Flutter codebase, targeting Web (SRS C-10).

---

## Conventions

Every screen file uses this template:

| Section | Content |
|---|---|
| Header | ID, name, user, platform, FR sources |
| Purpose | One sentence in domain language |
| Entry / exit | How the user arrives and leaves |
| Fields | Input / Display / Action / Filter / System |
| Validation & rules | Gates, masking, immutability |
| Empty / error / edge states | Where the SRS specifies them |
| Related screens | Sibling list/detail flows |

**Field kind**

| Kind | Meaning |
|---|---|
| **Input** | User-editable control |
| **Display** | Read-only data |
| **Action** | Button, deep link, or primary CTA |
| **Filter / Sort** | List controls |
| **System** | Computed chrome (reference, countdown, rate stamp) |

**Identity masking (BR-006):** pre-Acceptance screens show only masked labels (pseudonym, Region, rating). Real name, mobile, address appear only on Connection screens after Acceptance.

---

## Customer — `CUS-S01` … `CUS-S22`

| ID | Screen | File |
|---|---|---|
| CUS-S01 | Onboarding — mobile entry, OTP, one-time OAuth | [customer/CUS-S01-onboarding.md](customer/CUS-S01-onboarding.md) |
| CUS-S02 | Home — my Requests, quick-create entry | [customer/CUS-S02-home.md](customer/CUS-S02-home.md) |
| CUS-S03 | Request type selection | [customer/CUS-S03-request-type-selection.md](customer/CUS-S03-request-type-selection.md) |
| CUS-S04 | Create Request — Find An Ornament | [customer/CUS-S04-create-find-ornament.md](customer/CUS-S04-create-find-ornament.md) |
| CUS-S05 | Create Request — Sell Old Gold | [customer/CUS-S05-create-sell-old-gold.md](customer/CUS-S05-create-sell-old-gold.md) |
| CUS-S06 | Create Request — Gold Coins | [customer/CUS-S06-create-gold-coins.md](customer/CUS-S06-create-gold-coins.md) |
| CUS-S07 | Create Request — Gold Bullion | [customer/CUS-S07-create-gold-bullion.md](customer/CUS-S07-create-gold-bullion.md) |
| CUS-S08 | Image capture / gallery picker | [customer/CUS-S08-image-capture.md](customer/CUS-S08-image-capture.md) |
| CUS-S09 | Request review & publish | [customer/CUS-S09-request-review-publish.md](customer/CUS-S09-request-review-publish.md) |
| CUS-S10 | Request detail — my Request with Offer count | [customer/CUS-S10-request-detail.md](customer/CUS-S10-request-detail.md) |
| CUS-S11 | Offers list | [customer/CUS-S11-offers-list.md](customer/CUS-S11-offers-list.md) |
| CUS-S12 | Offer comparison (2–4 side by side) | [customer/CUS-S12-offer-comparison.md](customer/CUS-S12-offer-comparison.md) |
| CUS-S13 | Offer detail | [customer/CUS-S13-offer-detail.md](customer/CUS-S13-offer-detail.md) |
| CUS-S14 | Accept confirmation — irreversibility warning | [customer/CUS-S14-accept-confirmation.md](customer/CUS-S14-accept-confirmation.md) |
| CUS-S15 | Connection detail — revealed identity, Talk | [customer/CUS-S15-connection-detail.md](customer/CUS-S15-connection-detail.md) |
| CUS-S16 | Connections list | [customer/CUS-S16-connections-list.md](customer/CUS-S16-connections-list.md) |
| CUS-S17 | History | [customer/CUS-S17-history.md](customer/CUS-S17-history.md) |
| CUS-S18 | Leave review | [customer/CUS-S18-leave-review.md](customer/CUS-S18-leave-review.md) |
| CUS-S19 | Notification centre | [customer/CUS-S19-notification-centre.md](customer/CUS-S19-notification-centre.md) |
| CUS-S20 | Profile | [customer/CUS-S20-profile.md](customer/CUS-S20-profile.md) |
| CUS-S21 | Settings | [customer/CUS-S21-settings.md](customer/CUS-S21-settings.md) |
| CUS-S22 | Report abuse | [customer/CUS-S22-report-abuse.md](customer/CUS-S22-report-abuse.md) |

---

## Vendor — `VEN-S01` … `VEN-S22`

| ID | Screen | File |
|---|---|---|
| VEN-S01 | Registration — business details | [vendor/VEN-S01-registration.md](vendor/VEN-S01-registration.md) |
| VEN-S02 | KYC document upload | [vendor/VEN-S02-kyc-document-upload.md](vendor/VEN-S02-kyc-document-upload.md) |
| VEN-S03 | Awaiting Approval / rejected / more-info shell | [vendor/VEN-S03-awaiting-approval.md](vendor/VEN-S03-awaiting-approval.md) |
| VEN-S04 | Login | [vendor/VEN-S04-login.md](vendor/VEN-S04-login.md) |
| VEN-S05 | Dashboard | [vendor/VEN-S05-dashboard.md](vendor/VEN-S05-dashboard.md) |
| VEN-S06 | Available Requests feed | [vendor/VEN-S06-available-requests.md](vendor/VEN-S06-available-requests.md) |
| VEN-S07 | Request filters & saved presets | [vendor/VEN-S07-request-filters.md](vendor/VEN-S07-request-filters.md) |
| VEN-S08 | Request detail (masked Customer) | [vendor/VEN-S08-request-detail.md](vendor/VEN-S08-request-detail.md) |
| VEN-S09 | Submit Offer | [vendor/VEN-S09-submit-offer.md](vendor/VEN-S09-submit-offer.md) |
| VEN-S10 | Revise / withdraw Offer | [vendor/VEN-S10-revise-withdraw-offer.md](vendor/VEN-S10-revise-withdraw-offer.md) |
| VEN-S11 | My Offers — Pending / Accepted / Rejected–Expired | [vendor/VEN-S11-my-offers.md](vendor/VEN-S11-my-offers.md) |
| VEN-S12 | Connections list | [vendor/VEN-S12-connections-list.md](vendor/VEN-S12-connections-list.md) |
| VEN-S13 | Connection detail — revealed Customer, Talk / Call | [vendor/VEN-S13-connection-detail.md](vendor/VEN-S13-connection-detail.md) |
| VEN-S14 | Offer history & performance | [vendor/VEN-S14-offer-history.md](vendor/VEN-S14-offer-history.md) |
| VEN-S15 | Business profile | [vendor/VEN-S15-business-profile.md](vendor/VEN-S15-business-profile.md) |
| VEN-S16 | Categories, Regions, business hours | [vendor/VEN-S16-categories-regions.md](vendor/VEN-S16-categories-regions.md) |
| VEN-S17 | Notification centre | [vendor/VEN-S17-notification-centre.md](vendor/VEN-S17-notification-centre.md) |
| VEN-S18 | Settings | [vendor/VEN-S18-settings.md](vendor/VEN-S18-settings.md) |
| VEN-S19 | Leave customer feedback | [vendor/VEN-S19-leave-customer-feedback.md](vendor/VEN-S19-leave-customer-feedback.md) |
| VEN-S20 | My reviews & responses | [vendor/VEN-S20-my-reviews.md](vendor/VEN-S20-my-reviews.md) |
| VEN-S21 | Report abuse | [vendor/VEN-S21-report-abuse.md](vendor/VEN-S21-report-abuse.md) |
| VEN-S22 | Subscription by Request type | [vendor/VEN-S22-subscription.md](vendor/VEN-S22-subscription.md) |

---

## Platform Admin — `ADM-S01` … `ADM-S23`

| ID | Screen | File |
|---|---|---|
| ADM-S01 | Login with 2FA | [admin/ADM-S01-login.md](admin/ADM-S01-login.md) |
| ADM-S02 | Dashboard | [admin/ADM-S02-dashboard.md](admin/ADM-S02-dashboard.md) |
| ADM-S03 | Customer list | [admin/ADM-S03-customer-list.md](admin/ADM-S03-customer-list.md) |
| ADM-S04 | Customer detail | [admin/ADM-S04-customer-detail.md](admin/ADM-S04-customer-detail.md) |
| ADM-S05 | Vendor list | [admin/ADM-S05-vendor-list.md](admin/ADM-S05-vendor-list.md) |
| ADM-S06 | Vendor detail | [admin/ADM-S06-vendor-detail.md](admin/ADM-S06-vendor-detail.md) |
| ADM-S07 | Verification queue & document reviewer | [admin/ADM-S07-verification-queue.md](admin/ADM-S07-verification-queue.md) |
| ADM-S08 | Request list | [admin/ADM-S08-request-list.md](admin/ADM-S08-request-list.md) |
| ADM-S09 | Request detail | [admin/ADM-S09-request-detail.md](admin/ADM-S09-request-detail.md) |
| ADM-S10 | Offer list | [admin/ADM-S10-offer-list.md](admin/ADM-S10-offer-list.md) |
| ADM-S11 | Offer detail | [admin/ADM-S11-offer-detail.md](admin/ADM-S11-offer-detail.md) |
| ADM-S12 | Connection list | [admin/ADM-S12-connection-list.md](admin/ADM-S12-connection-list.md) |
| ADM-S13 | Connection detail | [admin/ADM-S13-connection-detail.md](admin/ADM-S13-connection-detail.md) |
| ADM-S14 | Category management | [admin/ADM-S14-category-management.md](admin/ADM-S14-category-management.md) |
| ADM-S15 | Region management | [admin/ADM-S15-region-management.md](admin/ADM-S15-region-management.md) |
| ADM-S16 | Review moderation queue | [admin/ADM-S16-review-moderation.md](admin/ADM-S16-review-moderation.md) |
| ADM-S17 | Reports & analytics | [admin/ADM-S17-reports-analytics.md](admin/ADM-S17-reports-analytics.md) |
| ADM-S18 | Announcement composer | [admin/ADM-S18-announcement-composer.md](admin/ADM-S18-announcement-composer.md) |
| ADM-S19 | Platform settings | [admin/ADM-S19-platform-settings.md](admin/ADM-S19-platform-settings.md) |
| ADM-S20 | Gold rate configuration | [admin/ADM-S20-gold-rate-configuration.md](admin/ADM-S20-gold-rate-configuration.md) |
| ADM-S21 | Abuse report queue | [admin/ADM-S21-abuse-report-queue.md](admin/ADM-S21-abuse-report-queue.md) |
| ADM-S22 | Audit log viewer | [admin/ADM-S22-audit-log.md](admin/ADM-S22-audit-log.md) |
| ADM-S23 | Admin user management | [admin/ADM-S23-admin-user-management.md](admin/ADM-S23-admin-user-management.md) |

---

## Known SRS tensions (documented on affected screens)

| Topic | Screens | Notes |
|---|---|---|
| Offer validity options | VEN-S09, ADM-S19 | FR-VEN-013: 12 / 24 / 48 h; entity `OFFER.validity_hours`: 24 / 48 / 72 / 168 |
| Dual-mode shell | Customer/Vendor README | One binary; mode by role |
| Admin on Flutter Web | ADM-S03…S12, ADM-S17, ADM-S22 | Flutter Web for the Admin Portal is confirmed (C-10, SRS v1.3) and the risk is accepted. Dense tables, keyboard-driven queue processing, and text selection are not free on a canvas-rendered web target; the data-grid build-or-buy (`AD-FE-12`) is still open. SRS §7.1, `NFR-023`, `adr/0006` |
| Object storage | CUS-S08, VEN-S02, ADM-S07, ADM-S09 | Provider resolved to Cloudflare R2 (S3-compatible), MinIO for local/CI. SRS C-13, §7.6, `adr/0008`. Production data-residency for KYC under `NFR-020` is an open infra item |

---

## Source

- `docs/Requirements-Spec-v1.3.md` — Appendix C, §4, §5, §6, §7.1  
- `docs/Requirements-Spec-v1.3.md` §2.5 (C-10–C-13) + `docs/adr/0006`, `0007`, `0008` — stack constraints  
- `CONTEXT.md` — ubiquitous language  
