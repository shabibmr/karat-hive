import { Module } from '@nestjs/common';
import { AuditModule } from '../audit';
import { Clock } from '../../shared/clock';
import { ConnectionController } from './controller/connection.controller';
import { ConnectionService } from './application/connection.service';
import { ConnectionRepository } from './repository/connection.repository';

@Module({
  imports: [AuditModule],
  controllers: [ConnectionController],
  providers: [ConnectionService, ConnectionRepository, Clock],
  exports: [ConnectionService, ConnectionRepository],
})
export class ConnectionsModule {}
