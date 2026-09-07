import { Controller, Get, HttpCode, HttpStatus, Param, Post, Query } from '@nestjs/common';
import { z } from 'zod';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { zodQuery } from '../../../edge/validation/zod-validation.pipe';
import { NotificationService } from '../application/notification.service';

const listNotificationsQuerySchema = z.object({
  unread: z.coerce.boolean().optional(),
  limit: z.coerce.number().int().min(1).max(50).optional(),
  cursor: z.string().uuid().optional(),
});

@Controller('v1/notifications')
export class NotificationController {
  constructor(private readonly service: NotificationService) {}

  @Get()
  async listNotifications(
    @Viewer() viewer: ViewerContext,
    @Query(zodQuery(listNotificationsQuerySchema))
    query: z.infer<typeof listNotificationsQuerySchema>,
  ) {
    return this.service.listNotifications(viewer, query);
  }

  @Get('unread-count')
  async getUnreadCount(@Viewer() viewer: ViewerContext) {
    const data = await this.service.getUnreadCount(viewer);
    return { data };
  }

  @Post(':id/read')
  @HttpCode(HttpStatus.OK)
  async markAsRead(@Viewer() viewer: ViewerContext, @Param('id') notificationId: string) {
    const data = await this.service.markAsRead(viewer, notificationId);
    return { data };
  }

  @Post('read-all')
  @HttpCode(HttpStatus.OK)
  async markAllAsRead(@Viewer() viewer: ViewerContext) {
    const data = await this.service.markAllAsRead(viewer);
    return { data };
  }
}
