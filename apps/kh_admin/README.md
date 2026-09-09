# Karat Hive Admin Portal

Flutter Web Admin Portal (`pubspec.yaml` name: `kh_admin`). Checkpoint-1 ships ADM-S01 (login shell) plus ADM-S14/S15 taxonomy (categories and regions).

```bash
flutter run -d chrome --dart-define=KH_API_BASE=http://localhost:3000
```

The backend API is the NestJS monolith in `backend/` (`npm run start:dev` on port 3000). Sign-in is Google Sign-In; password credentials are not a Checkpoint-1 gate.

Inspection snapshot (not the plan of record): [`docs/inspection/REGISTER.md`](docs/inspection/REGISTER.md) (`ADM-INS-nn`). Flutter/Dart code-review snapshot (gaps + enhancements): [`docs/Admin-Flutter-Dart-Code-Review.md`](../../docs/Admin-Flutter-Dart-Code-Review.md).
