import { Module } from '@nestjs/common';
import { AuditModule } from '../audit';
import { MediaService } from './application/media.service';
import { MediaController } from './controller/media.controller';
import { MediaRepository } from './repository/media.repository';

@Module({
  imports: [AuditModule],
  controllers: [MediaController],
  providers: [MediaService, MediaRepository],
  exports: [MediaService],
})
export class MediaModule {}
