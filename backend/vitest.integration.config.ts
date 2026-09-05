import swc from 'unplugin-swc';
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    include: ['test/integration/**/*.spec.ts', 'test/masking/**/*.integration.spec.ts'],
    environment: 'node',
    fileParallelism: false,
    hookTimeout: 30_000,
    testTimeout: 30_000,
  },
  plugins: [swc.vite()],
});
