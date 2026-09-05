import { Module } from '@nestjs/common';
import { JobLockService } from './job-lock.service';
import { SchedulerService } from './scheduler.service';

@Module({
  providers: [JobLockService, SchedulerService],
  exports: [JobLockService, SchedulerService],
})
export class SchedulerModule {}
