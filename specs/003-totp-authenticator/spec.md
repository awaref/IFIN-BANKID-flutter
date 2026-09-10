# Feature Specification: TOTP Authenticator

**Feature Branch**: `003-totp-authenticator`

**Created**: 2026-09-02

**Status**: Draft

**Input**: User description: "Build a complete Authenticator inside my app similar to Google Authenticator and Microsoft Authenticator. The app itself is an authenticator that stores TOTP accounts and generates rotating verification codes. It should NOT be an MFA login system for another application."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Add and View TOTP Accounts (Priority: P1)

A user wants to store third-party service accounts (e.g., Google, Microsoft, GitHub) in the app and see live, rotating verification codes they can use to sign in elsewhere.

**Why this priority**: Without the ability to add accounts and generate correct codes, the product delivers no core value. This is the minimum viable authenticator.

**Independent Test**: Can be fully tested by adding one account manually or via QR scan, returning to the home screen, and verifying the displayed code matches a known-good TOTP value for the same secret and time window.

**Acceptance Scenarios**:

1. **Given** the user is on the authenticator home screen with no accounts, **When** they choose to add an account manually with a valid secret, issuer, and account name, **Then** the account appears on the home screen with a correctly formatted code and countdown.
2. **Given** the user opens the QR scanner, **When** they scan a valid `otpauth://totp/...` QR code, **Then** they see a preview of issuer, account name, algorithm, digits, and period before confirming save.
3. **Given** one or more saved accounts, **When** the user views the authenticator home screen, **Then** each account shows issuer, account identifier, current code, visual countdown, and remaining seconds until refresh.
4. **Given** a saved account with a 30-second period, **When** the countdown reaches zero, **Then** the code refreshes automatically for all accounts simultaneously without requiring user interaction.
5. **Given** the device clock changes (manual adjustment or timezone change), **When** the user returns to the authenticator home screen, **Then** displayed codes reflect the corrected time within one refresh cycle.
6. **Given** an account with a given secret already exists, **When** the user attempts to add another account with the same secret (via QR scan or manual entry), **Then** the add operation is blocked with a clear message and no duplicate is saved.

---

### User Story 2 - Secure Account Management (Priority: P2)

A user wants to organize, edit, delete, search, and copy codes from their accounts while trusting that secrets remain protected on the device.

**Why this priority**: Account management and secure handling of secrets are essential for daily use and user trust once core code generation works.

**Independent Test**: Can be fully tested by creating multiple accounts, searching/filtering them, reordering them, editing one account's metadata, copying a code, and deleting an account with confirmation — verifying persisted order and data integrity after app restart.

**Acceptance Scenarios**:

1. **Given** multiple saved accounts, **When** the user searches by issuer, account name, or email/username, **Then** only matching accounts are shown.
2. **Given** a saved account, **When** the user taps the current TOTP code, **Then** only the numeric code (not the secret) is copied to the clipboard and visual "Code copied" feedback is shown.
3. **Given** a saved account, **When** the user edits account name, issuer, secret, algorithm, digits, or period and saves, **Then** the updated configuration is persisted and reflected in code generation.
4. **Given** a saved account, **When** the user initiates delete and confirms, **Then** the account is permanently removed after showing issuer and account identifier in the confirmation dialog.
5. **Given** multiple saved accounts, **When** the user reorders accounts via drag and drop, **Then** the new order persists across app restarts.
6. **Given** a saved account, **When** the app is closed and reopened, **Then** the secret and account metadata load successfully from secure storage without exposure in logs or plain-text storage.

---

### User Story 3 - Backup, Restore, and App Lock (Priority: P3)

A user wants to protect the app from unauthorized access, migrate accounts to a new device via encrypted backup, and customize appearance — without relying on network connectivity.

**Why this priority**: These capabilities are required for a production-grade, privacy-focused authenticator but depend on core account storage and code generation being in place first.

**Independent Test**: Can be fully tested by enabling app lock, exporting an encrypted backup with a password, importing it on a clean install (or after clearing data), verifying all accounts and order are restored, and confirming TOTP codes match pre-export values.

**Acceptance Scenarios**:

1. **Given** the user enables app lock "On app launch", **When** they open the app, **Then** biometric authentication, Face ID/Touch ID, or device PIN/passcode (where supported) is required before accounts are visible.
2. **Given** app lock is set to "After 5 minutes", **When** the app has been in background for more than 5 minutes, **Then** re-authentication is required before viewing accounts.
3. **Given** one or more saved accounts, **When** the user exports accounts with a password, **Then** the backup file is encrypted and does not contain plaintext secrets.
4. **Given** a valid encrypted backup file and correct password, **When** the user imports accounts, **Then** issuer, account name, secret, algorithm, digits, period, and account order are restored after validation.
5. **Given** an encrypted backup and incorrect password, **When** the user attempts import, **Then** import fails safely with a clear error and no existing accounts are modified.
6. **Given** the user selects light mode, dark mode, or system theme in settings, **When** they navigate the authenticator, **Then** the interface reflects the chosen theme with a polished, modern appearance.

---

### Edge Cases

- What happens when a scanned QR code is not an `otpauth://` URI? → Show a clear invalid-QR error; do not save anything.
- What happens when the QR code uses an unsupported OTP type (e.g., `otpauth://hotp/...` or non-TOTP schemes)? → Reject with an explicit unsupported-type message.
- What happens when the URI is missing a secret or contains a malformed Base32 secret? → Reject with validation error; handle common manual formatting variations (spaces, hyphens, mixed case) only during manual entry normalization.
- What happens when algorithm, digits, or period are outside supported ranges? → Reject invalid values; supported algorithms are SHA1, SHA256, and SHA512; supported digits are 6 and 8; period must be a positive integer with 30 seconds as default when omitted.
- What happens when the user attempts to add a duplicate account? → Block the add operation if the secret matches an existing account; show a clear error explaining the account already exists. The user must delete the existing entry before re-adding.
- What happens when the device has no camera permission? → Explain why permission is needed and guide the user to grant it or use manual entry.
- What happens when the device clock is significantly wrong? → Codes may be invalid for external services; the app continues generating codes based on device time and refreshes correctly after clock correction.
- What happens when import encounters a corrupted or tampered backup? → Reject import entirely; do not partially modify existing accounts.
- What happens when biometric hardware is unavailable but app lock is enabled? → Fall back to device PIN/passcode where the platform supports it; never simulate or fake biometric success.
- What happens when the user has many accounts (50+)? → Home screen remains responsive; search and scroll perform acceptably without visible stutter during countdown updates.

## Requirements *(mandatory)*

### Functional Requirements

#### Scope and Purpose

- **FR-001**: System MUST function as a standalone TOTP authenticator that stores accounts and generates time-based one-time passwords for use with external services.
- **FR-002**: System MUST NOT implement MFA login or second-factor verification flows for signing into this application or any other application.
- **FR-003**: System MUST operate fully offline for TOTP generation after accounts are added; no network connection is required to display or copy codes.

#### Adding Accounts

- **FR-004**: System MUST allow users to add accounts by scanning QR codes containing standard `otpauth://totp/` URIs using the device camera.
- **FR-005**: System MUST allow users to add accounts manually via a form with fields: Account name, Issuer, Secret key, Algorithm, Digits, and Period.
- **FR-006**: System MUST parse and validate the following URI parameters: `secret`, `issuer`, account label (from URI path), `algorithm`, `digits`, and `period`.
- **FR-007**: System MUST apply these defaults when parameters are omitted: Algorithm SHA1, Digits 6, Period 30 seconds.
- **FR-008**: System MUST support algorithms SHA1, SHA256, and SHA512 for TOTP generation per RFC 6238.
- **FR-009**: System MUST support 6-digit and 8-digit codes according to each account's configuration.
- **FR-010**: System MUST validate URIs and manual input before saving; malformed or incomplete entries MUST be rejected with user-readable errors.
- **FR-011**: System MUST show an account preview (issuer, account name, algorithm, digits, period) after QR scan and before final save.
- **FR-012**: System MUST handle URL-encoded account names and issuer values in `otpauth` URIs correctly.
- **FR-013**: System MUST reject unsupported OTP types (non-TOTP `otpauth` schemes) with a clear message.
- **FR-014**: System MUST normalize manually entered secrets by accepting common Base32 formatting variations (spaces, hyphens, case insensitivity) before validation.
- **FR-014a**: System MUST block adding an account when its secret matches an existing account's secret, regardless of issuer or account name, and MUST display a clear error message.

#### TOTP Code Generation

- **FR-015**: System MUST generate TOTP codes compatible with RFC 6238 using `TOTP = HOTP(secret, floor(currentUnixTime / period))` where `HOTP = HMAC(algorithm, secret, counter)`.
- **FR-016**: System MUST display for each account: issuer (or logo placeholder), account name/email/username, current code, countdown timer, and visual progress indicator.
- **FR-017**: System MUST refresh codes automatically at the end of each account's configured period.
- **FR-018**: System MUST update countdowns for all accounts simultaneously using a single time source.
- **FR-019**: System MUST NOT regenerate codes on every screen rebuild; codes MUST only change when the time counter advances to a new period or account configuration changes.
- **FR-020**: System MUST recalculate codes correctly after device clock or timezone changes.

#### Main Authenticator Screen

- **FR-021**: System MUST present accounts as card/list items showing issuer/logo placeholder, account identifier, current code, countdown, copy action, edit action, and delete action.
- **FR-022**: System MUST provide a dedicated QR scanner screen with camera preview, permission handling, invalid-QR detection, unsupported-type detection, account preview, and save confirmation flow.
- **FR-023**: System MUST provide search/filter across issuer, account name, and email/username fields.

#### Copy Behavior

- **FR-024**: System MUST copy only the current numeric TOTP code (never the secret) when the user taps the code or copy control.
- **FR-025**: System MUST provide immediate visual feedback (e.g., "Code copied") after a successful copy.
- **FR-026**: System MUST clear the clipboard automatically 30 seconds after copying a TOTP code by default; users MUST be able to configure this duration in settings.

#### Account Management

- **FR-027**: System MUST allow editing of account name, issuer, secret, algorithm, digits, and period for existing accounts.
- **FR-028**: System MUST require explicit confirmation before deleting an account, displaying issuer and account identifier in the confirmation dialog.
- **FR-029**: System MUST allow drag-and-drop reordering of accounts on the home screen.
- **FR-030**: System MUST persist account display order securely alongside account data.

#### Secure Storage

- **FR-031**: System MUST encrypt sensitive account data at rest using platform-backed secure storage (e.g., hardware-backed keystore on Android, secure enclave/keychain on iOS).
- **FR-032**: System MUST NOT store TOTP secrets in unencrypted shared preferences, plain JSON files, unencrypted SQLite, logs, analytics, or debug output.
- **FR-033**: System MUST NOT print, log, or transmit secret keys or generated OTP codes.

#### Import and Export

- **FR-034**: System MUST provide Settings entries for "Export accounts" and "Import accounts".
- **FR-035**: System MUST export backups in an encrypted format protected by a user-provided password; plaintext secret export MUST NOT be the default.
- **FR-036**: System MUST use strong password-based key derivation and authenticated encryption for backups.
- **FR-037**: Backup MUST include sufficient data to restore: issuer, account name, secret, algorithm, digits, period, and account ordering.
- **FR-038**: System MUST validate backup integrity and format before modifying existing accounts during import.
- **FR-039**: System MUST fail safely on wrong password, corrupted backup, or invalid backup format without partial data loss of existing accounts.

#### App Lock

- **FR-040**: System MUST offer optional app lock with settings: Never, On app launch, After 1 minute, After 5 minutes.
- **FR-041**: System MUST support platform-native biometric authentication on Android and Face ID/Touch ID on iOS, with device PIN/passcode fallback where supported.
- **FR-042**: System MUST NOT implement simulated or fake biometric authentication.

#### Appearance

- **FR-043**: System MUST support light mode, dark mode, and system theme selection.
- **FR-044**: System MUST deliver a polished, modern interface with smooth transitions appropriate to a security-focused productivity app.

#### Security and Privacy

- **FR-045**: System MUST NOT send secrets or account metadata to any server.
- **FR-046**: System MUST NOT include account information in analytics or crash reporting payloads.
- **FR-047**: System MUST minimize sensitive data retained in memory and clear temporary sensitive buffers where practical.
- **FR-048**: System MUST prevent screenshots and screen recording on Android where platform APIs allow, for screens displaying active TOTP codes. iOS screenshot blocking is out of scope for this feature unless added in a future revision.
- **FR-049**: System MUST handle app lifecycle events securely (background/foreground) in conjunction with app lock timeouts.
- **FR-050**: System MUST use cryptographically secure randomness for any security-sensitive operations (e.g., backup encryption salts/nonces).

#### Integration with Existing Application

- **FR-051**: System MUST be integrated as a self-contained authenticator module within the existing mobile application, separate from any existing flows that help users configure external authenticator apps for login.
- **FR-052**: System MUST be accessible from an entry point in the existing Settings menu; selecting it navigates to the authenticator home screen without altering existing primary navigation or login flows.

#### Quality and Verification

- **FR-053**: TOTP generation MUST be verifiable against official RFC 6238 test vectors for SHA1, SHA256, and SHA512 across 6-digit, 8-digit, and varying period configurations.
- **FR-054**: URI parsing MUST be covered by tests for valid URIs, invalid URIs, missing secrets, invalid algorithms, invalid digits, invalid periods, URL-encoded labels, and issuer handling.
- **FR-055**: Storage operations MUST be covered by tests for save, load, update, delete, and reorder.
- **FR-056**: Backup operations MUST be covered by tests for export, encrypt, decrypt, import, wrong password, corrupted backup, and invalid format.

### Key Entities

- **Authenticator Account**: A TOTP credential belonging to an external service. Attributes: unique identifier, issuer, account name/label, secret (encrypted at rest), algorithm (SHA1/SHA256/SHA512), digit count (6 or 8), period in seconds, display order index, created/updated timestamps (optional metadata for management).
- **TOTP Code (ephemeral)**: The current time-based one-time password derived from an account's secret and configuration; never persisted or logged.
- **Encrypted Backup**: A password-protected, authenticated archive containing one or more authenticator accounts and their display order, suitable for cross-device migration.
- **App Lock Settings**: User preferences defining when re-authentication is required (never, launch, 1-minute idle, 5-minute idle) and reliance on platform biometrics/PIN.
- **Theme Preference**: User selection among light, dark, or system appearance.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can add an account via QR scan or manual entry and see a valid TOTP code within 30 seconds of opening the add-account flow.
- **SC-002**: Generated codes match RFC 6238 reference vectors and real-world services (Google, Microsoft, GitHub, GitLab, Discord, AWS) in 100% of automated test cases using known test secrets.
- **SC-003**: Countdown timers for all displayed accounts remain synchronized within 1 second of each other during continuous 5-minute observation.
- **SC-004**: After adding 20 accounts, 95% of search queries return matching results in under 1 second from keystroke to filtered list.
- **SC-005**: Account order, metadata, and code correctness persist correctly across 100 consecutive app restart cycles in automated storage tests.
- **SC-006**: Encrypted backup round-trip (export then import with correct password) restores 100% of accounts with matching codes in automated tests; wrong-password imports fail with zero modifications to existing accounts in 100% of test cases.
- **SC-007**: When app lock is enabled, unauthenticated users cannot view account list or codes in 100% of tested lock scenarios.
- **SC-008**: Zero instances of secret keys or OTP codes appear in application logs, analytics events, or network traffic during security audit test runs.
- **SC-009**: Users can copy a code and receive confirmation feedback within 1 second of tapping the code.
- **SC-010**: 90% of usability test participants successfully add an account, copy a code, and reorder accounts without assistance on first attempt.

## Assumptions

- The feature targets the existing iOS and Android mobile application; desktop and web are out of scope unless explicitly added later.
- Only TOTP (`otpauth://totp/`) is in scope; HOTP, Steam Guard, and proprietary OTP schemes are excluded.
- The authenticator module coexists with existing BankID/digital identity features but does not replace or alter login/MFA enrollment flows for this app.
- English and Arabic localization will follow the same patterns as the existing application (bilingual support assumed based on current app localization).
- Camera and biometric hardware availability varies by device; graceful degradation uses manual entry and PIN fallback respectively.
- Issuer logo display uses placeholders initially; fetching remote logos is out of scope unless added in a future feature.
- Clipboard auto-clear defaults to 30 seconds and is user-configurable in settings.
- Duplicate accounts are blocked when the secret matches an existing account, regardless of issuer or account label.
- The authenticator is accessed from a Settings menu entry; it does not replace the existing home or primary navigation structure.
- Performance targets follow standard mobile app expectations: smooth scrolling and countdown updates on mid-range devices from the last 3 years.

## Dependencies

- Device camera access for QR scanning.
- Platform secure storage and biometric APIs.
- Device system clock accuracy for TOTP validity with external services (the app cannot correct server-side clock skew).
- Existing application shell for navigation, localization infrastructure, and settings framework.

## Out of Scope

- MFA/2FA verification during login to this or any other application.
- Cloud sync of accounts across devices (local encrypted backup/import only).
- Push notifications related to TOTP codes.
- Remote account provisioning from servers.
- Plaintext export of secrets by default.
- Custom/non-standard OTP algorithms outside SHA1, SHA256, and SHA512.
