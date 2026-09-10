# Implementation Plan: TOTP Authenticator

**Branch**: `003-totp-authenticator` | **Date**: 2026-09-02 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/003-totp-authenticator/spec.md`

## Summary

Build a standalone TOTP authenticator module inside the existing BankID Flutter mobile application. The module stores third-party TOTP accounts, generates RFC 6238-compliant rotating verification codes offline, and provides QR-scan / manual account setup, secure encrypted storage, encrypted backup/import, biometric app lock, search, drag-and-drop reorder, clipboard copy with auto-clear, and light/dark/system theming. The authenticator is accessed from the existing Settings screen and is fully self-contained — it does not alter any existing BankID authentication or login flows.

## Technical Context

**Language/Version**: Dart 3.x / Flutter SDK ^3.9.2

**Primary Dependencies** (existing in pubspec.yaml):
- `provider` ^6.1.2 — state management
- `flutter_secure_storage` ^10.0.0 — encrypted key-value storage (Android Keystore / iOS Keychain)
- `local_auth` ^3.0.0 — biometric / PIN authentication
- `mobile_scanner` ^7.1.4 — camera-based QR code scanning
- `permission_handler` ^12.0.1 — runtime camera permission
- `shared_preferences` ^2.5.4 — non-sensitive user settings

**New Dependencies** (to add):
- `otp` — RFC 6238 / RFC 4226 TOTP/HOTP generation with SHA1/SHA256/SHA512 support
- `base32` — Base32 encoding/decoding for TOTP secrets
- `pointycastle` — AES-GCM authenticated encryption + PBKDF2 key derivation for backup files
- `uuid` — unique account identifiers

**Storage**: `flutter_secure_storage` for encrypted account data at rest (secrets + metadata serialized as JSON, encrypted by platform keystore). `shared_preferences` for non-sensitive settings only (theme, app lock timeout, clipboard clear duration).

**Testing**: `flutter_test` + `test_api` + `mockito` (all already in dev_dependencies)

**Target Platform**: Android (minSdk 24) and iOS

**Project Type**: Mobile app — new feature module within existing Flutter application

**Performance Goals**: 60 fps countdown updates across 50+ accounts; search filtering < 1 second on 50 accounts

**Constraints**: Fully offline TOTP generation; no network calls from authenticator module; secrets never logged or transmitted; Android FLAG_SECURE on code-display screens

**Scale/Scope**: Single-user local storage; supports 100+ accounts; bilingual (English + Arabic) following existing localization patterns

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The project constitution contains only template placeholders — no concrete principles are defined. No constitution gates to evaluate. **PASS — no violations.**

## Project Structure

### Documentation (this feature)

```text
specs/003-totp-authenticator/
├── plan.md              # This file
├── research.md          # Phase 0 output — technology decisions
├── data-model.md        # Phase 1 output — entity definitions
├── quickstart.md        # Phase 1 output — validation guide
├── contracts/           # Phase 1 output — UI screen contracts
│   └── screens.md
└── tasks.md             # Phase 2 output (via /speckit-tasks)
```

### Source Code (repository root)

```text
lib/
├── main.dart                          # Existing — no changes
├── screens/
│   └── settings_screen.dart           # Modified — add Authenticator entry point
│
├── features/
│   └── authenticator/
│       ├── data/
│       │   ├── models/
│       │   │   └── totp_account.dart          # Account entity + JSON serialization
│       │   ├── repositories/
│       │   │   └── account_repository.dart    # CRUD, reorder, duplicate check
│       │   └── services/
│       │       ├── totp_service.dart           # RFC 6238 code generation
│       │       ├── otp_uri_parser.dart         # otpauth:// URI parse + validate
│       │       ├── backup_service.dart         # Encrypted export/import
│       │       ├── secure_storage_service.dart # flutter_secure_storage wrapper
│       │       └── clipboard_service.dart      # Copy + auto-clear timer
│       │
│       ├── domain/
│       │   └── totp_generator.dart            # Pure TOTP math (thin wrapper over otp pkg)
│       │
│       └── presentation/
│           ├── providers/
│           │   ├── authenticator_provider.dart  # Account list + TOTP state
│           │   ├── timer_provider.dart          # Single shared countdown tick
│           │   └── authenticator_settings_provider.dart  # App lock, theme, clipboard
│           ├── screens/
│           │   ├── authenticator_home_screen.dart
│           │   ├── add_account_screen.dart       # Manual entry form
│           │   ├── qr_scan_screen.dart            # Camera scanner
│           │   ├── account_preview_screen.dart    # Pre-save confirmation
│           │   ├── edit_account_screen.dart
│           │   └── authenticator_settings_screen.dart  # App lock, export, import, theme
│           └── widgets/
│               ├── totp_account_card.dart
│               ├── countdown_indicator.dart
│               └── search_bar.dart
│
├── core/
│   └── utils/
│       └── app_logger.dart            # Existing — no changes
│
├── services/
│   └── biometric_service.dart         # Existing — reused by authenticator app lock
│
└── providers/
    └── language_provider.dart          # Existing — reused for locale

test/
├── unit/
│   ├── totp_service_test.dart          # RFC 6238 test vectors
│   ├── otp_uri_parser_test.dart        # URI parsing edge cases
│   ├── backup_service_test.dart        # Encrypt/decrypt/corrupt/wrong-password
│   └── account_repository_test.dart    # CRUD + reorder + duplicate detection
└── widget/
    └── authenticator_home_test.dart    # Basic widget render test
```

**Structure Decision**: The authenticator is added as a feature module under `lib/features/authenticator/` following a layered data/domain/presentation split. This isolates new code from the existing flat `lib/screens/` + `lib/services/` layout. The only modification to existing code is adding a `ListTile` entry point in `settings_screen.dart`. Existing services (`biometric_service.dart`, `language_provider.dart`) are reused, not duplicated.

## Complexity Tracking

> No constitution violations to justify.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A       | N/A        | N/A                                  |
