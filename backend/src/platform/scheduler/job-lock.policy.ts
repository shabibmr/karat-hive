export function canAcquireJobLock(args: {
  now: Date;
  requester: string;
  existing: { owner: string; leasedUntil: Date } | null;
}): boolean {
  if (args.existing === null) return true;
  return args.existing.leasedUntil.getTime() <= args.now.getTime();
}
