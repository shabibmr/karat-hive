import { Module } from '@nestjs/common';
import { OutboxClaimer } from './outbox.claimer';
import { OutboxDispatcher } from './outbox.dispatcher';

@Module({
  providers: [OutboxClaimer, OutboxDispatcher],
  exports: [OutboxClaimer, OutboxDispatcher],
})
export class OutboxModule {}
