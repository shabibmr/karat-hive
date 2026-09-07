import { Module } from '@nestjs/common';
import { OutboxModule } from '../../platform/outbox/outbox.module';
import { AuditModule } from '../audit';
import { MediaConsumer } from './application/media.consumer';
import { MediaProcessingService } from './application/media-processing.service';
import { MediaService } from './application/media.service';
import { MediaController } from './controller/media.controller';
import { MediaRepository } from './repository/media.repository';

@Module({
  imports: [AuditModule, OutboxModule],
  controllers: [MediaController],
  providers: [MediaService, MediaRepository, MediaProcessingService, MediaConsumer],
  exports: [MediaService],
})
export class MediaModule {}
