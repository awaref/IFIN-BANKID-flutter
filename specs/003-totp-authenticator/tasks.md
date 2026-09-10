# Tasks: TOTP Authenticator

**Input**: Design documents from `specs/003-totp-authenticator/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/screens.md, quickstart.md

**Tests**: Included — spec FR-053 through FR-056 explicitly require tests for TOTP generation, URI parsing, storage, and backup.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add new dependencies and create the feature module directory scaffold

- [X] T001 Add `otp_auth: ^1.0.1`, `pointycastle: ^3.9.1`, and `uuid: ^4.5.1` to dependencies in pubspec.yaml and run `flutter pub get`
- [X] T002 Create feature directory scaffold under lib/features/authenticator/ with data/models/, data/repositories/, data/services/, domain/, presentation/providers/, presentation/screens/, and presentation/widgets/ subdirectories
- [X] T003 [P] Create test directory scaffold under test/unit/ and test/widget/ for authenticator tests

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core model, services, and repository that ALL user stories depend on

**CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Implement `TotpAccount` model with all fields (id, issuer, accountName, secret, algorithm, digits, period, sortOrder, createdAt, updatedAt), JSON serialization (toJson/fromJson), Algorithm enum, and validation logic in lib/features/authenticator/data/models/totp_account.dart
- [X] T005 [P] Implement `SecureStorageService` wrapping `flutter_secure_storage` with methods to read/write the JSON account list under key `totp_accounts` in lib/features/authenticator/data/services/secure_storage_service.dart
- [X] T006 [P] Implement `TotpService` wrapping `otp_auth` TOTP class with `generateCode(TotpAccount account, int epochSeconds)` returning formatted string, and `remainingSeconds(int period, int epochSeconds)` in lib/features/authenticator/data/services/totp_service.dart
- [X] T007 [P] Implement `OtpUriParser` with `parse(String uri)` returning a `TotpAccount` (unsaved), validating otpauth://totp/ scheme, secret, algorithm, digits, period, URL-encoded labels, and rejecting non-TOTP/malformed URIs with typed exceptions in lib/features/authenticator/data/services/otp_uri_parser.dart
- [X] T008 Implement `AccountRepository` with CRUD methods (getAll, add, update, delete), duplicate secret detection, reorder, and sortOrder management, backed by `SecureStorageService` in lib/features/authenticator/data/repositories/account_repository.dart
- [X] T009 [P] Implement `TimerProvider` (ChangeNotifier) with a 1-second `Timer.periodic` broadcasting current epoch second, start/stop lifecycle methods in lib/features/authenticator/presentation/providers/timer_provider.dart

**Checkpoint**: Foundation ready — all core services and model available for user stories

---

## Phase 3: User Story 1 — Add and View TOTP Accounts (Priority: P1) MVP

**Goal**: Users can add accounts via QR scan or manual entry and view live rotating TOTP codes on the home screen

**Independent Test**: Add one account manually, verify displayed code matches known TOTP value for the same secret and time window; scan a QR code, confirm preview, and verify code on home screen

### Tests for User Story 1

- [X] T010 [P] [US1] Write TOTP generation unit tests with RFC 6238 test vectors for SHA1/SHA256/SHA512, 6-digit and 8-digit codes, 30s and 60s periods, and period boundary edge cases in test/unit/totp_service_test.dart
- [X] T011 [P] [US1] Write OTPAuth URI parser unit tests covering valid URIs, missing secret, invalid algorithm, invalid digits, invalid period, URL-encoded account names, issuer handling, HOTP rejection, and non-otpauth string rejection in test/unit/otp_uri_parser_test.dart

### Implementation for User Story 1

- [X] T012 [US1] Implement `AuthenticatorProvider` (ChangeNotifier) with account list state, loadAccounts, addAccount (with duplicate check), and notifyListeners, wired to `AccountRepository` and `TotpService` in lib/features/authenticator/presentation/providers/authenticator_provider.dart
- [X] T013 [P] [US1] Implement `TotpAccountCard` widget displaying issuer, account name, formatted TOTP code (XXX XXX / XXXX XXXX), countdown text, and `CountdownIndicator` linear progress bar in lib/features/authenticator/presentation/widgets/totp_account_card.dart
- [X] T014 [P] [US1] Implement `CountdownIndicator` widget showing linear progress bar (remainingSeconds / period) with smooth animation in lib/features/authenticator/presentation/widgets/countdown_indicator.dart
- [X] T015 [US1] Implement `AuthenticatorHomeScreen` with AppBar (title, add button), empty state with CTA, list of `TotpAccountCard` widgets consuming `AuthenticatorProvider` and `TimerProvider`, and Android FLAG_SECURE via platform channel on init/dispose in lib/features/authenticator/presentation/screens/authenticator_home_screen.dart
- [X] T016 [US1] Implement `AddAccountScreen` with two options (Scan QR Code navigating to QrScanScreen, Manual Entry inline form with account name, issuer, secret, algorithm dropdown, digits dropdown, period fields, defaults SHA1/6/30, Base32 normalization, validation, and duplicate check) in lib/features/authenticator/presentation/screens/add_account_screen.dart
- [X] T017 [US1] Implement `QrScanScreen` with MobileScanner camera preview, viewfinder overlay, permission handling (request + denied state with settings link and manual fallback), barcode detection routing through OtpUriParser, error messages for invalid/unsupported/malformed QR codes, and navigation to AccountPreviewScreen on success in lib/features/authenticator/presentation/screens/qr_scan_screen.dart
- [X] T018 [US1] Implement `AccountPreviewScreen` displaying parsed account details (issuer, account name, algorithm, digits, period), live code preview via TotpService, duplicate check, Add Account button saving to repository and popping to home, and Cancel button in lib/features/authenticator/presentation/screens/account_preview_screen.dart
- [X] T019 [US1] Add authenticator entry point ListTile to the Account Settings section of the existing settings screen, with localized title and navigation to AuthenticatorHomeScreen in lib/screens/settings_screen.dart
- [X] T020 [US1] Add English localization strings for authenticator (screen titles, button labels, error messages, empty state) to lib/l10n/app_en.arb
- [X] T021 [US1] Add Arabic localization strings for authenticator (matching all English keys) to lib/l10n/app_ar.arb
- [X] T022 [US1] Regenerate localization Dart files by running `flutter gen-l10n` and verify generated output in lib/l10n/app_localizations.dart, lib/l10n/app_localizations_en.dart, lib/l10n/app_localizations_ar.dart

**Checkpoint**: User Story 1 complete — users can add accounts via manual entry or QR scan and view live rotating codes. MVP is functional.

---

## Phase 4: User Story 2 — Secure Account Management (Priority: P2)

**Goal**: Users can search, copy codes, edit, delete, and reorder accounts with secure storage guarantees

**Independent Test**: Create multiple accounts, search/filter by issuer, copy a code and verify clipboard + snackbar, edit an account's metadata, delete with confirmation, drag-and-drop reorder, close/reopen and verify persisted order and data

### Tests for User Story 2

- [X] T023 [P] [US2] Write account repository unit tests for save, load, update, delete, reorder (sortOrder swap), and duplicate secret detection using mocked SecureStorageService in test/unit/account_repository_test.dart

### Implementation for User Story 2

- [X] T024 [US2] Implement `ClipboardService` with copyCode(String code) that copies numeric code only (never secret) to clipboard, shows platform feedback, starts auto-clear Timer (default 30s, configurable), cancels previous timer on new copy, and clearClipboard() method in lib/features/authenticator/data/services/clipboard_service.dart
- [X] T025 [US2] Implement `SearchBar` widget with text field filtering by issuer, accountName, and email substring match, clear button, and toggle visibility in lib/features/authenticator/presentation/widgets/search_bar.dart
- [X] T026 [US2] Add search state (query string, filtered list computed from accounts), copyCode method (delegating to ClipboardService with snackbar feedback), deleteAccount method (with confirmation dialog showing issuer + account name), and updateAccount method to AuthenticatorProvider in lib/features/authenticator/presentation/providers/authenticator_provider.dart
- [X] T027 [US2] Implement `EditAccountScreen` with form pre-populated from existing TotpAccount, same fields and validation as AddAccountScreen, secret uniqueness re-check on change, save updating via repository, and cancel navigation in lib/features/authenticator/presentation/screens/edit_account_screen.dart
- [X] T028 [US2] Add search bar toggle, copy-on-tap for TotpAccountCard (wired to ClipboardService via provider), edit button navigating to EditAccountScreen, delete button showing confirmation AlertDialog (issuer + account name + destructive styling), and ReorderableListView with onReorder callback persisting new sortOrder via provider to the AuthenticatorHomeScreen in lib/features/authenticator/presentation/screens/authenticator_home_screen.dart
- [X] T029 [US2] Add copy button, edit button, and delete button to TotpAccountCard widget with appropriate callbacks in lib/features/authenticator/presentation/widgets/totp_account_card.dart

**Checkpoint**: User Stories 1 AND 2 complete — full account lifecycle (add, view, search, copy, edit, delete, reorder) works independently

---

## Phase 5: User Story 3 — Backup, Restore, and App Lock (Priority: P3)

**Goal**: Users can protect the authenticator with biometric/PIN lock, export encrypted backups, import backups on new devices, and customize appearance

**Independent Test**: Enable app lock and verify biometric gate on reopen; export encrypted backup with password, import on clean state, verify all accounts restored; try wrong password and verify safe failure; toggle theme modes

### Tests for User Story 3

- [X] T030 [P] [US3] Write backup service unit tests for export (produces valid envelope with version/format/kdf/salt/nonce/ciphertext/tag), import with correct password (restores all accounts and order), import with wrong password (failure, no data modified), corrupted ciphertext (integrity check fails), and invalid JSON format (rejection) in test/unit/backup_service_test.dart

### Implementation for User Story 3

- [X] T031 [US3] Implement `BackupService` with exportAccounts(List<TotpAccount> accounts, String password) using PBKDF2-HMAC-SHA256 (200k iterations, 16-byte salt) key derivation and AES-256-GCM (12-byte nonce, 128-bit tag) authenticated encryption via pointycastle, producing JSON envelope per data-model.md EncryptedBackup schema, and importAccounts(String encryptedJson, String password) decrypting and returning List<TotpAccount> with validation, throwing typed exceptions for wrong password / corrupted / invalid format in lib/features/authenticator/data/services/backup_service.dart
- [X] T032 [US3] Implement `AuthenticatorSettingsProvider` (ChangeNotifier) managing app lock timeout (never/onLaunch/after1Min/after5Min), clipboard clear duration, theme mode (light/dark/system), and last-backgrounded timestamp, persisted in SharedPreferences with `authenticator_` prefix keys in lib/features/authenticator/presentation/providers/authenticator_settings_provider.dart
- [X] T033 [US3] Implement app lock gate logic in AuthenticatorHomeScreen using WidgetsBindingObserver.didChangeAppLifecycleState to record background timestamp, check timeout on resume, and show BiometricService.authenticate() prompt before revealing content; handle biometric unavailable with PIN/passcode fallback in lib/features/authenticator/presentation/screens/authenticator_home_screen.dart
- [X] T034 [US3] Implement `AuthenticatorSettingsScreen` with sections: Security (app lock timeout radio group), Clipboard (auto-clear duration dropdown: 15s/30s/60s/Disabled), Appearance (theme radio: Light/Dark/System), Backup (Export button triggering password dialog → BackupService.export → share/save file, Import button triggering file picker → password dialog → BackupService.import → merge with duplicate skip → success/error feedback) in lib/features/authenticator/presentation/screens/authenticator_settings_screen.dart
- [X] T035 [US3] Add settings gear/icon button to AuthenticatorHomeScreen AppBar navigating to AuthenticatorSettingsScreen in lib/features/authenticator/presentation/screens/authenticator_home_screen.dart
- [X] T036 [US3] Wire theme mode from AuthenticatorSettingsProvider to the authenticator screen tree so light/dark/system selection takes effect with polished modern styling and smooth transitions in lib/features/authenticator/presentation/screens/authenticator_home_screen.dart
- [X] T037 [US3] Add English localization strings for backup (export/import labels, password dialog, success/error messages), app lock (timeout options, biometric prompt), theme (mode labels), and settings screen titles to lib/l10n/app_en.arb
- [X] T038 [US3] Add Arabic localization strings matching all new English keys from T037 to lib/l10n/app_ar.arb
- [X] T039 [US3] Regenerate localization Dart files by running `flutter gen-l10n` and verify generated output in lib/l10n/app_localizations.dart, lib/l10n/app_localizations_en.dart, lib/l10n/app_localizations_ar.dart

**Checkpoint**: All three user stories complete — authenticator is fully functional with add/view/manage/backup/lock/theme

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Security hardening, final quality, and cross-story improvements

- [X] T040 Implement Android FLAG_SECURE platform channel (MethodChannel) with setSecureFlag/clearSecureFlag methods callable from Dart, and wire into AuthenticatorHomeScreen init/dispose lifecycle in android/app/src/main/kotlin/.../MainActivity.kt and lib/features/authenticator/data/services/secure_flag_service.dart
- [X] T041 Audit all authenticator Dart files to ensure no TOTP secrets or generated codes appear in print(), debugPrint(), AppLogger.log(), or analytics calls; remove or guard any debug output
- [X] T042 [P] Write basic widget test for AuthenticatorHomeScreen rendering with mock providers (verifies empty state, one-account card display, countdown text) in test/widget/authenticator_home_test.dart
- [X] T043 Register all authenticator providers (AuthenticatorProvider, TimerProvider, AuthenticatorSettingsProvider) in the widget tree, either via MultiProvider in the authenticator entry point or scoped within AuthenticatorHomeScreen, ensuring proper lifecycle (TimerProvider start/stop) in lib/features/authenticator/presentation/screens/authenticator_home_screen.dart
- [X] T044 End-to-end manual validation following quickstart.md scenarios V5 through V10 on a physical Android device (manual account entry, QR scan, app lock, export/import, search/reorder, security audit with adb logcat)
- [X] T045 Review and clean up all authenticator code: remove unused imports, ensure consistent formatting, verify no TODO placeholders remain, confirm localization keys are complete for both languages

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 completion — BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Phase 2 completion
- **User Story 2 (Phase 4)**: Depends on Phase 2 completion; integrates with US1 components (AuthenticatorProvider, HomeScreen) but is independently testable
- **User Story 3 (Phase 5)**: Depends on Phase 2 completion; integrates with US1/US2 components but is independently testable
- **Polish (Phase 6)**: Depends on all three user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Phase 2 — No dependencies on other stories
- **User Story 2 (P2)**: Can start after Phase 2 — Extends US1's AuthenticatorProvider and HomeScreen but can be tested independently with mock data
- **User Story 3 (P3)**: Can start after Phase 2 — Uses AccountRepository from foundational layer; independent of US2 management features

### Within Each User Story

- Tests written FIRST, must FAIL before implementation
- Models/services before providers
- Providers before screens
- Screens before integration/wiring
- Localization after screens (needs final key inventory)

### Parallel Opportunities

- **Phase 1**: T002 and T003 can run in parallel
- **Phase 2**: T005, T006, T007, T009 can all run in parallel (different files, only T004 model is shared)
- **Phase 3**: T010 and T011 (tests) in parallel; T013 and T014 (widgets) in parallel; T020 and T021 (localization) in parallel
- **Phase 4**: T023 (test) can run in parallel with US1 implementation
- **Phase 5**: T030 (test) can run in parallel with US2 implementation; T037 and T038 in parallel
- **Phase 6**: T040 and T042 in parallel

---

## Parallel Example: User Story 1

```text
# Tests (parallel):
T010: TOTP generation RFC 6238 test vectors in test/unit/totp_service_test.dart
T011: OTPAuth URI parser tests in test/unit/otp_uri_parser_test.dart

# Widgets (parallel, after provider T012):
T013: TotpAccountCard widget in lib/features/authenticator/presentation/widgets/totp_account_card.dart
T014: CountdownIndicator widget in lib/features/authenticator/presentation/widgets/countdown_indicator.dart

# Localization (parallel):
T020: English strings in lib/l10n/app_en.arb
T021: Arabic strings in lib/l10n/app_ar.arb
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T003)
2. Complete Phase 2: Foundational (T004–T009)
3. Complete Phase 3: User Story 1 (T010–T022)
4. **STOP and VALIDATE**: Run `flutter test test/unit/totp_service_test.dart` and `flutter test test/unit/otp_uri_parser_test.dart`; manually test on device per quickstart.md V5–V6
5. Deploy/demo if ready — users can add accounts and view codes

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → **MVP!** (add + view codes)
3. Add User Story 2 → Test independently → Full management (search, copy, edit, delete, reorder)
4. Add User Story 3 → Test independently → Production-grade (backup, app lock, theme)
5. Polish → Security-hardened, cleaned, validated

### Parallel Team Strategy

With multiple developers after Phase 2 completes:
- **Developer A**: User Story 1 (T010–T022) — core TOTP + screens
- **Developer B**: User Story 3 backup service (T030–T031) — encryption logic can be built independently
- **Developer C**: User Story 2 tests (T023) + clipboard service (T024) — management utilities
- Stories integrate cleanly because they share the foundational model and repository layer

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [Story] label maps task to specific user story for traceability
- Each user story is independently completable and testable
- Tests must FAIL before implementing corresponding service
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- The spec explicitly requires tests (FR-053–FR-056) so test tasks are included in US1, US2, and US3
