import { Injectable } from '@nestjs/common';

/** UTC clock. Clients offset from `meta.serverTime` (C-07, Architecture §13). */
@Injectable()
export class Clock {
  now(): Date {
    return new Date();
  }

  nowIso(): string {
    return this.now().toISOString();
  }
}
