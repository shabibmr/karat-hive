import type { Media } from '@prisma/client';

export type MediaRef = {
  key: string;
  state: Media['state'];
  purpose: Media['purpose'];
  contentType: string;
  byteSize: number;
};

export type UploadIntent = {
  key: string;
  uploadUrl: string;
  requiredHeaders: Record<string, string>;
  maxBytes: number;
  expiresAt: string;
};

export function presentMediaRef(media: Media): MediaRef {
  return {
    key: media.key,
    state: media.state,
    purpose: media.purpose,
    contentType: media.contentType,
    byteSize: media.byteSize,
  };
}
