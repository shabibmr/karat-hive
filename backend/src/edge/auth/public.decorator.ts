import { SetMetadata } from '@nestjs/common';

export const IS_PUBLIC_KEY = 'kh:isPublic';

/** Skip JWT ViewerContext. Still subject to rate limits. */
export const Public = (): MethodDecorator & ClassDecorator => SetMetadata(IS_PUBLIC_KEY, true);
