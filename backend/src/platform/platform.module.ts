import { Global, Module } from '@nestjs/common';
import { ENV, type Env } from '../config/env';
import { ConsoleOtpSender } from './adapters/sms/console-otp-sender';
import { ScryptPasswordHasher } from './adapters/crypto/scrypt-password-hasher';
import { LocalDiskStorageAdapter } from './adapters/storage/local-disk-storage.adapter';
import { SupabaseStorageAdapter } from './adapters/storage/supabase-storage.adapter';
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
      useFactory: (env: Env) =>
        env.NODE_ENV === 'test' ? new LocalDiskStorageAdapter() : new SupabaseStorageAdapter(env),
    },
  ],
  exports: [OTP_SENDER, PASSWORD_HASHER, OBJECT_STORAGE],
})
export class PlatformModule {}
