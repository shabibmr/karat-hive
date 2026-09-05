import swc from 'unplugin-swc';
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    include: ['src/**/*.spec.ts', 'test/masking/**/*.spec.ts'],
    exclude: ['**/*.integration.spec.ts'],
    environment: 'node',
  },
  plugins: [swc.vite()],
});
