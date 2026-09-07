import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import { z } from 'zod';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { zodBody } from '../../../edge/validation/zod-validation.pipe';
import { AbuseService } from '../application/abuse.service';

const createAbuseReportSchema = z.object({
  entityType: z.enum([
    'REQUEST',
    'OFFER',
    'CONNECTION',
    'REVIEW',
    'VENDOR',
    'CUSTOMER',
  ]),
  entityId: z.string().uuid(),
  category: z.string().trim().min(1).max(64),
  description: z.string().trim().min(1).max(2000),
});

@Controller('v1/abuse-reports')
export class AbuseController {
  constructor(private readonly service: AbuseService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async submitReport(
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(createAbuseReportSchema))
    body: z.infer<typeof createAbuseReportSchema>,
  ) {
    const data = await this.service.submitReport(viewer, body);
    return { data };
  }
}
