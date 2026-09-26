# Complete Removal of Category Taxonomy Entity

Category taxonomy entity is completely removed from the system architecture, domain rules, data model, and user interfaces.

**Context.** Previously, taxonomy included Request Type, Category, and Region. Vendor matching and marketplace eligibility previously incorporated category matching and regional eligibility gates, which added administrative overhead, friction during vendor onboarding, and unnecessary complexity to request creation and notification routing.

**Decision.**
1. **Category Taxonomy Removal**: The Category taxonomy entity is removed entirely from the codebase, database schema, APIs, and administrative workflows.
2. **Simplified Matching Rule**: Request notification and vendor marketplace matching depend **only** on Vendor status (`VERIFIED` + `ACTIVE`) and an active **Type Subscription** for the Request's Request Type.
3. **Region as Display/Filter Only**: Region is retained solely as a flat display and filter taxonomy for buyers and vendors, not as a mandatory matching or eligibility gate.
4. **Unconditional Vendor Activation**: Vendor activation depends unconditionally on achieving `VERIFIED` status (KYC approval), without requiring category selection or setup steps.

**Consequences.**
- **Data Model**: `category` and `vendor_category` tables and `request.category_id` foreign key column are removed from the physical schema.
- **Rules & Logic**: Vendor marketplace eligibility (BR-002) is simplified to `VERIFIED + ACTIVE + active Type Subscription for Request's type`.
- **System Specifications**: SRS revised to v1.5; FR-SYS-002, FR-VEN-025, FR-VEN-031 updated to remove category constraints.
- **User Interfaces**: Request creation forms, vendor onboarding wizards, catalog/feed filters, and admin taxonomy management UI screens remove all category pickers and references.
- **APIs**: Category CRUD and vendor-category assignment endpoints are removed; request creation payloads no longer include `category_id`.
