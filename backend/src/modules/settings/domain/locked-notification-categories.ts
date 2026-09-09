 * Preference categories that cannot be disabled (FR-CUS-032 AC4, FR-SYS-008 AC2,
 * API-Route-Inventory §9). Key matches notification.plans / dispatcher `category: 'security'`.
 *
 * NOTE: This list is duplicated in `packages/kh_ui_domain/lib/src/notification_preference_matrix.dart`
 * (`kLockedNotificationCategories`) by design. This supports instant offline UI rendering while
 * allowing the backend to enforce the business invariant independently.
 */
export const LOCKED_NOTIFICATION_CATEGORIES = new Set<string>(['security']);

export function isLockedNotificationCategory(category: string): boolean {
  return LOCKED_NOTIFICATION_CATEGORIES.has(category);
}
