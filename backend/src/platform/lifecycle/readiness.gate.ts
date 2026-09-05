import { Injectable, BeforeApplicationShutdown } from '@nestjs/common';

/** Architecture §6: fail readiness immediately on SIGTERM. */
@Injectable()
export class ReadinessGate implements BeforeApplicationShutdown {
  private accepting = true;

  isAccepting(): boolean {
    return this.accepting;
  }

  beforeApplicationShutdown(): void {
    this.accepting = false;
  }
}
