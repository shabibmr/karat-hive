import { Body, Controller, Delete, Get, HttpCode, Param, Post, Res } from '@nestjs/common';
import type { FastifyReply } from 'fastify';
import { z } from 'zod';
import { Viewer } from '../../../edge/auth/viewer.decorator';
import type { ViewerContext } from '../../../edge/auth/viewer-context';
import { zodBody } from '../../../edge/validation/zod-validation.pipe';
import { MediaService } from '../application/media.service';
import type { MediaRef, UploadIntent } from '../presenter/media.presenter';

const uploadIntentSchema = z.object({
  purpose: z.enum([
    'REQUEST_IMAGE',
    'OFFER_IMAGE',
    'PROFILE_PHOTO',
    'VENDOR_LOGO',
    'VENDOR_SHOP_PHOTO',
    'KYC_DOCUMENT',
    'EXPORT_ARTEFACT',
  ]),
  contentType: z.string().min(1).max(100),
  byteSize: z.number().int().positive(),
});

@Controller('v1/media')
export class MediaController {
  constructor(private readonly media: MediaService) {}

  @Get(':key')
  async getMedia(
    @Param('key') key: string,
    @Res() reply: FastifyReply,
  ) {
    const result = await this.media.resolveMediaUrlOrStream(key);
    if (result.type === 'redirect') {
      return reply.redirect(result.url, 307);
    }
    return reply
      .header('Content-Type', result.contentType)
      .header('Cache-Control', 'public, max-age=3600')
      .send(result.buffer);
  }

  @Post('upload-intent')
  createIntent(
    @Viewer() viewer: ViewerContext,
    @Body(zodBody(uploadIntentSchema)) body: z.infer<typeof uploadIntentSchema>,
  ): Promise<UploadIntent> {
    return this.media.createIntent(viewer, body);
  }

  @Post(':key/complete')
  complete(@Viewer() viewer: ViewerContext, @Param('key') key: string): Promise<MediaRef> {
    return this.media.complete(viewer, key);
  }

  @Delete(':key')
  @HttpCode(204)
  async remove(@Viewer() viewer: ViewerContext, @Param('key') key: string): Promise<void> {
    await this.media.remove(viewer, key);
  }
}
