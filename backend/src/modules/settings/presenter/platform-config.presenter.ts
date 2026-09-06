export type MediaLimits = {
  maxRequestImages: number;
  maxOfferImages: number;
  maxImageBytes: number;
  maxKycBytes: number;
  acceptedImageTypes: string[];
};

export type LegalConfig = {
  termsUrl: string;
  privacyUrl: string;
  currentTermsVersion?: string;
  currentPrivacyVersion?: string;
};

export type SupportConfig = {
  contactUrl: string;
};

export type PlatformConfigResponse = {
  requestLifetimeHours: number;
  offerValidityHours: number[];
  defaultOfferValidityHours: number;
  bullionMinimumAed: string;
  maxConcurrentLiveRequests: number;
  maxOfferRevisions: number;
  requestExpiryWarningHours: number;
  karatList: (string | number)[];
  karats: (string | number)[];
  maxRequestImages: number;
  maxOfferImages: number;
  maxImageBytes: number;
  acceptedImageTypes: string[];
  mediaLimits: MediaLimits;
  media: MediaLimits;
  legal: LegalConfig;
  support: SupportConfig;
  supportContactUrl: string;
  subscriptionContactUrl: string;
};
