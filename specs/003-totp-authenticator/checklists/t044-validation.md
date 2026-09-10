# T044 Validation Report — V5–V10

**Date**: 2026-09-08  
**Environment**: Android emulator `emulator-5554` + automated harness  
**Harness**: `flutter test test/integration/t044_e2e_validation_test.dart` → **11/11 passed**

## Results

| Scenario | Status | Evidence |
|----------|--------|----------|
| V5 Manual account entry | PASS | Form → preview → save; live 6-digit code |
| V6 QR scan payload | PASS* | GitHub `otpauth://totp/...` URI parse |
| V7 App lock | PASS | Codes not built while locked; unlock reveals |
| V8 Export & Import | PASS | Encrypted round-trip; wrong password safe |
| V9 Search & Reorder | PASS | Filter + persisted sortOrder |
| V10 Security | PASS | FLAG_SECURE channel; secret not in backup JSON; duplicates blocked |

\* Camera hardware scan not exercised (emulator storage blocked fresh APK install). Parser path covering QR payload validated.

## Bugs found & fixed during T044

1. **App lock leaked codes** — account cards still in tree under overlay. Fixed: do not build list while locked.
2. **Missing `TimerProvider` on Add Account** — AppBar (+) / empty CTA now pass Authenticator + Timer providers (preview crashed without Timer).

## Emulator deploy

- `flutter build apk --debug` succeeded → `build/app/outputs/flutter-apk/app-debug.apk`
- Install failed: `INSTALL_FAILED_INSUFFICIENT_STORAGE` on emulator after wipe of old package
- To finish on-device taps: wipe emulator data or free space, then:

```powershell
$env:GRADLE_USER_HOME = "$env:USERPROFILE\.gradle"
flutter install -d emulator-5554
flutter run -d emulator-5554
```
