import { Global, Module } from '@nestjs/common';
import { ReadinessGate } from './readiness.gate';

@Global()
@Module({
  providers: [ReadinessGate],
  exports: [ReadinessGate],
})
export class LifecycleModule {}
