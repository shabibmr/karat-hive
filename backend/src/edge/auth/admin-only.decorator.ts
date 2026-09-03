import { SetMetadata } from '@nestjs/common';

export const IS_ADMIN_ONLY_KEY = 'is_admin_only';
export const AdminOnly = () => SetMetadata(IS_ADMIN_ONLY_KEY, true);
