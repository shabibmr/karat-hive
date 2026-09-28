import { Logger } from '@nestjs/common';

/**
 * Dev-only per-phase timing logs (docs/Request-Perf-Logging-Plan.md).
 *
 * Reads `PERF_LOG` directly from the environment rather than via DI so any
 * service, guard, or interceptor can time itself without a constructor
 * change — this is a diagnostics tool, not application behaviour. Silent
 * (near-zero overhead) unless `PERF_LOG=true`.
 */
const enabled = process.env.PERF_LOG === 'true';

const logger = new Logger('Perf');

export class PerfTimer {
  private readonly start = process.hrtime.bigint();
  private last = this.start;
  private readonly laps: Array<[string, number]> = [];

  constructor(
    private readonly flow: string,
    private readonly context: Record<string, string | number | undefined> = {},
  ) {}

  /** Records the elapsed time (ms) since the previous lap (or start) under `label`. */
  lap(label: string): void {
    if (!enabled) return;
    const now = process.hrtime.bigint();
    this.laps.push([label, msBetween(this.last, now)]);
    this.last = now;
  }

  /** Logs one summary line: flow, total ms, every lap, and any extra fields. */
  done(extra: Record<string, string | number | undefined> = {}): void {
    if (!enabled) return;
    const total = msBetween(this.start, process.hrtime.bigint());
    const fields = { ...this.context, ...extra };
    const fieldsStr = Object.entries(fields)
      .filter(([, v]) => v !== undefined)
      .map(([k, v]) => `${k}=${v}`)
      .join(' ');
    const lapsStr = this.laps.map(([label, ms]) => `${label}=${ms}ms`).join(' ');
    logger.log(
      `${this.flow} total=${total}ms${lapsStr ? ` ${lapsStr}` : ''}${fieldsStr ? ` ${fieldsStr}` : ''}`,
    );
  }
}

function msBetween(startNs: bigint, endNs: bigint): number {
  return Number(endNs - startNs) / 1_000_000;
}

export const perfLogEnabled = enabled;
