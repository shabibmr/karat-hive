import { Module } from '@nestjs/common';
import { MediaService } from './application/media.service';
import { MediaController } from './controller/media.controller';
import { MediaRepository } from './repository/media.repository';

@Module({
  controllers: [MediaController],
  providers: [MediaService, MediaRepository],
  exports: [MediaService],
})
export class MediaModule {}
