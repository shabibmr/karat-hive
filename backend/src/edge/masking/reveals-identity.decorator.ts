import { SetMetadata } from '@nestjs/common';

export const REVEALS_IDENTITY_KEY = 'kh:reveals-identity';

/** Architecture §9.2 layer 3. Opt a route out of the identity-key scan. */
export const RevealsIdentity = () => SetMetadata(REVEALS_IDENTITY_KEY, true);
