import js from '@eslint/js';
import boundaries from 'eslint-plugin-boundaries';
import eslintConfigPrettier from 'eslint-config-prettier';
import tseslint from 'typescript-eslint';

export default [
  { ignores: ['dist/**', 'node_modules/**', 'prisma/**'] },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    files: ['src/**/*.ts'],
    plugins: { boundaries },
    settings: {
      'boundaries/elements': [
        {
          type: 'module-public',
          pattern: 'src/modules/*/index.ts',
          mode: 'file',
          capture: ['module'],
        },
        { type: 'module', pattern: 'src/modules/*', capture: ['module'] },
        { type: 'platform', pattern: 'src/platform' },
        { type: 'edge', pattern: 'src/edge' },
        { type: 'shared', pattern: 'src/shared' },
        { type: 'config', pattern: 'src/config' },
      ],
    },
    rules: {
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],
      'boundaries/element-types': [
        'error',
        {
          default: 'disallow',
          rules: [
            { from: 'module', allow: ['module', 'shared', 'platform', 'edge', 'config'] },
            { from: 'module-public', allow: ['module', 'shared', 'platform', 'edge', 'config'] },
            { from: 'edge', allow: ['edge', 'shared', 'platform', 'config', 'module-public'] },
            { from: 'platform', allow: ['platform', 'shared', 'config'] },
            { from: 'shared', allow: ['shared'] },
            { from: 'config', allow: ['config', 'shared'] },
          ],
        },
      ],
      'boundaries/entry-point': [
        'error',
        {
          default: 'allow',
          rules: [{ target: 'module', allow: 'index.ts' }],
        },
      ],
    },
  },
  eslintConfigPrettier,
];
