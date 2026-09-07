import { Module } from '@nestjs/common';
import { OutboxModule } from '../../platform/outbox/outbox.module';
import { NotificationDispatcher } from './application/notification.dispatcher';
import { NotificationService } from './application/notification.service';
import { NotificationController } from './controller/notification.controller';
import { DeviceController } from './controller/device.controller';
import { NotificationRepository } from './repository/notification.repository';

@Module({
  imports: [OutboxModule],
  controllers: [NotificationController, DeviceController],
  providers: [NotificationRepository, NotificationService, NotificationDispatcher],
  exports: [NotificationService, NotificationRepository],
})
export class NotificationsModule {}
