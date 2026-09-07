import { Module } from '@nestjs/common';
import { AuditModule } from '../audit';
import { ReviewRepository } from './repository/review.repository';
import { ReviewService } from './application/review.service';
import { ReviewController } from './controller/review.controller';

@Module({
  imports: [AuditModule],
  controllers: [ReviewController],
  providers: [ReviewRepository, ReviewService],
  exports: [ReviewService, ReviewRepository],
})
export class ReviewsModule {}
