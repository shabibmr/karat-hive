import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { OutboxDispatcher } from '../../../platform/outbox/outbox.dispatcher';
import { MediaProcessingService } from './media-processing.service';

@Injectable()
export class MediaConsumer implements OnModuleInit {
  private readonly logger = new Logger(MediaConsumer.name);

  constructor(
    private readonly dispatcher: OutboxDispatcher,
    private readonly processing: MediaProcessingService,
  ) {}

  onModuleInit(): void {
    this.dispatcher.register('media.uploaded', 'media:process', async (event) => {
      await this.processing.processUploaded(event);
      this.logger.log(
        `Processed media.uploaded eventId=${event.id} aggregate=${event.aggregateId}`,
      );
    });
  }
}
