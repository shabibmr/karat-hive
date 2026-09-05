import { SetMetadata } from '@nestjs/common';

export const ALLOW_SUSPENDED_KEY = 'kh:allow-suspended';
export const AllowSuspended = () => SetMetadata(ALLOW_SUSPENDED_KEY, true);
