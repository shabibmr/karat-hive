import { Module } from '@nestjs/common';
import { OutboxModule } from '../../platform/outbox/outbox.module';
import { AuditModule } from '../audit';
import { ReviewConsumer } from './application/review.consumer';
import { ReviewService } from './application/review.service';
import { ReviewController } from './controller/review.controller';
import { ReviewRepository } from './repository/review.repository';

@Module({
  imports: [AuditModule, OutboxModule],
  controllers: [ReviewController],
  providers: [ReviewRepository, ReviewService, ReviewConsumer],
  exports: [ReviewService, ReviewRepository],
})
export class ReviewsModule {}
