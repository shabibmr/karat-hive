import { Module } from '@nestjs/common';
import { AuditModule } from '../audit';
import { NotificationsModule } from '../notifications';
import { GoldRateService } from './application/gold-rate.service';
import { AdminGoldRateController } from './controller/admin-gold-rate.controller';
import { GoldRateController } from './controller/gold-rate.controller';
import { GoldRateRepository } from './repository/gold-rate.repository';

@Module({
  imports: [AuditModule, NotificationsModule],
  controllers: [GoldRateController, AdminGoldRateController],
  providers: [GoldRateRepository, GoldRateService],
  exports: [GoldRateService],
})
export class GoldRateModule {}
