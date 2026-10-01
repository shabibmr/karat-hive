import { Global, Logger, Module } from '@nestjs/common';
import { ENV, type Env } from '../config/env';
import { ConsoleOtpSender } from './adapters/sms/console-otp-sender';
import { ScryptPasswordHasher } from './adapters/crypto/scrypt-password-hasher';
import { YahooGoldRateAdapter } from './adapters/gold-rate/yahoo-gold-rate.adapter';
import { LocalDiskStorageAdapter } from './adapters/storage/local-disk-storage.adapter';
import { OciS3StorageAdapter, ociS3Configured } from './adapters/storage/oci-s3-storage.adapter';
import { SupabaseStorageAdapter } from './adapters/storage/supabase-storage.adapter';
import { GOLD_RATE_FEED } from './ports/gold-rate.port';
import { PUSH_GATEWAY } from './ports/push.port';
import { RoutedPushAdapter } from './adapters/push/routed-push.adapter';
import { FcmPushAdapter } from './adapters/fcm/fcm-push.adapter';
import { ApnsPushAdapter } from './adapters/apns/apns-push.adapter';
import { OTP_SENDER } from './ports/otp-sender.port';
import { PASSWORD_HASHER } from './ports/password-hasher.port';
import { OBJECT_STORAGE } from './ports/storage.port';

/** Platform ports and their environment-selected adapters (Architecture-Backend §16). */
@Global()
@Module({
  providers: [
    { provide: OTP_SENDER, useClass: ConsoleOtpSender },
    { provide: PASSWORD_HASHER, useClass: ScryptPasswordHasher },
    {
      provide: OBJECT_STORAGE,
      inject: [ENV],
      useFactory: (env: Env) => selectObjectStorage(env),
    },
    { provide: GOLD_RATE_FEED, useClass: YahooGoldRateAdapter },
    FcmPushAdapter,
    ApnsPushAdapter,
    { provide: PUSH_GATEWAY, useClass: RoutedPushAdapter },
  ],
  exports: [OTP_SENDER, PASSWORD_HASHER, OBJECT_STORAGE, GOLD_RATE_FEED, PUSH_GATEWAY],
})
export class PlatformModule {}

const storageLog = new Logger('ObjectStorage');

/** Test uses local disk. Hosted objects use Oracle S3 when configured (`adr/0013`); otherwise Supabase. */
export function selectObjectStorage(env: Env) {
  if (env.NODE_ENV === 'test') return new LocalDiskStorageAdapter();
  if (ociS3Configured(env)) return new OciS3StorageAdapter(env);
  if (env.SUPABASE_URL && env.SUPABASE_SERVICE_ROLE_KEY) return new SupabaseStorageAdapter(env);
  storageLog.warn(
    'Neither OCI S3 nor Supabase credentials are set. Object storage falling back to LocalDiskStorageAdapter.',
  );
  return new LocalDiskStorageAdapter();
}
