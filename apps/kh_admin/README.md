# Karat Hive Admin Portal

Flutter Web Admin Portal (`pubspec.yaml` name: `kh_admin`) for the 23 `ADM-S*` screens in [`ui-screens/admin/`](../../ui-screens/admin/).

```bash
flutter run -d chrome --dart-define=KH_API_BASE=http://localhost:3000
```

The backend API is the NestJS monolith in `backend/` (`npm run start:dev` on port 3000). Sign-in is Google Sign-In only (`docs/adr/0010`).

`kh_admin` sits outside the Melos workspace: run `dart analyze` and `flutter test` from this folder. It keeps its own theme in `lib/core/design/theme/` and does not depend on `kh_design_system`.
