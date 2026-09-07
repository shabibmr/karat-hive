import type { Review, User } from '@prisma/client';

export interface ReviewView {
  id: string;
  connectionId: string;
  authorType: 'CUSTOMER' | 'VENDOR';
  authorDisplayName?: string;
  rating: number;
  comment?: string;
  state: string;
  vendorResponse?: {
    text: string;
    state: string;
  };
  editableUntil: string;
  createdAt: string;
  publishedAt?: string;
}

export function presentReview(
  review: Review & {
    author?: User & {
      customerProfile?: { displayName: string } | null;
      vendorProfile?: { tradingName: string } | null;
    };
  },
  viewerUserId?: string,
): ReviewView | null {
  const isAuthor = viewerUserId && review.authorUserId === viewerUserId;

  // Counterparty sees it only when PUBLISHED (unless viewer is author)
  if (!isAuthor && review.state !== 'PUBLISHED') {
    return null;
  }

  let authorDisplayName: string | undefined;
  if (review.author?.customerProfile) {
    // Customer reviews attribute displayName only (FR-CUS-029 AC6)
    authorDisplayName = review.author.customerProfile.displayName;
  } else if (review.author?.vendorProfile) {
    authorDisplayName = review.author.vendorProfile.tradingName;
  }

  const vendorResponse =
    review.vendorResponse &&
    (isAuthor || review.vendorResponseState === 'PUBLISHED')
      ? {
          text: review.vendorResponse,
          state: review.vendorResponseState ?? 'PENDING_MODERATION',
        }
      : undefined;

  return {
    id: review.id,
    connectionId: review.connectionId,
    authorType: review.authorType,
    ...(authorDisplayName ? { authorDisplayName } : {}),
    rating: review.rating,
    ...(review.comment ? { comment: review.comment } : {}),
    state: review.state,
    ...(vendorResponse ? { vendorResponse } : {}),
    editableUntil: review.editableUntil.toISOString(),
    createdAt: review.createdAt.toISOString(),
    ...(review.publishedAt ? { publishedAt: review.publishedAt.toISOString() } : {}),
  };
}
