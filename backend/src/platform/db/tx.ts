import { Prisma } from '@prisma/client';
import { PrismaService } from './prisma.service';

export type DbTx = Prisma.TransactionClient;

export function withTx<T>(prisma: PrismaService, fn: (tx: DbTx) => Promise<T>): Promise<T> {
  return prisma.$transaction(fn);
}
