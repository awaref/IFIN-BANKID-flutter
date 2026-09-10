# Research: TOTP Authenticator

**Feature**: 003-totp-authenticator | **Date**: 2026-09-02

## R1: TOTP Generation Library

**Decision**: Use `otp_auth` (^1.0.1) as the single TOTP + URI + Base32 library.

**Rationale**: `otp_auth` provides a unified API covering all three needs:
- `TOTP` class — RFC 6238 code generation with `now()`, `at(DateTime)`, `verify()`, and `remaining` (seconds until expiry). Supports SHA1, SHA256, SHA512 via `OTPAlgorithm`. Configurable `digits` (6/8) and `period`.
- `OTPUri` class — parses and builds `otpauth://` URIs with `parse()`, `extractSecret()`, `toTOTP()`. Handles issuer, account label, algorithm, digits, period.
- `Base32` class — built-in RFC 4648 Base32 codec with `encode()` and `decode()`.
- Validated against official RFC 4226 Appendix D and RFC 6238 Appendix B test vectors.
- Pure Dart, single dependency (`crypto`), MIT licensed.

**Alternatives considered**:
- `dart_dash_otp` (^2.0.0) — More feature-rich (constant-time verify, drift window, `fromUri`), but heavier API surface. Would also work well; `otp_auth` chosen for simplicity and because its `OTPUri` class returns structured issuer/account metadata needed for UI.
- `totp_generator` — Lower-level, no URI parsing or Base32 built-in, would require additional packages.
- Rolling custom TOTP — Rejected per spec requirement to use well-maintained implementations rather than writing crypto primitives.

## R2: Secure Storage

**Decision**: Use existing `flutter_secure_storage` (^10.0.0, already in pubspec.yaml).

**Rationale**: flutter_secure_storage encrypts data at rest using:
- Android: EncryptedSharedPreferences backed by Android Keystore (AES-256-GCM)
- iOS: Keychain Services with kSecAttrAccessibleWhenUnlockedThisDeviceOnly

Account data (including secrets) will be serialized as a JSON list and stored under a single key. The `flutter_secure_storage` layer handles all platform encryption transparently.

**Alternatives considered**:
- `sqflite` + `sqlcipher_flutter_libs` — Encrypted SQLite. More complex setup, overkill for a flat list of ≤100 accounts. Rejected for unnecessary complexity.
- `hive` with encryption — Community package with native encryption option, but flutter_secure_storage is already a dependency and uses hardware-backed keystores.

## R3: Backup Encryption

**Decision**: Use `pointycastle` for AES-256-GCM + PBKDF2-HMAC-SHA256.

**Rationale**: pointycastle is a mature, pure-Dart port of Bouncy Castle providing:
- `GCMBlockCipher(AESEngine())` — AES-256-GCM authenticated encryption (confidentiality + integrity + authentication in one pass)
- `PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))` — PBKDF2-HMAC-SHA256 key derivation from user password
- `FortunaRandom` — cryptographically secure random number generation for salts and nonces

Backup format (JSON envelope):
```json
{
  "version": 1,
  "format": "bankid-totp-backup",
  "kdf": {
    "algorithm": "PBKDF2-HMAC-SHA256",
    "iterations": 200000,
    "keyBits": 256
  },
  "salt": "<base64-16-bytes>",
  "nonce": "<base64-12-bytes>",
  "ciphertext": "<base64>",
  "tag": "<base64-16-bytes>"
}
```

Parameters:
- 200,000 PBKDF2 iterations (standard recommendation for mobile)
- 16-byte random salt
- 12-byte random nonce (IV)
- 128-bit authentication tag

**Alternatives considered**:
- `cryptography` package — Higher-level API, but adds platform channel dependencies. pointycastle is pure Dart and gives full control over parameters.
- `encrypt` package — Convenience wrapper, but limited control over GCM parameters and PBKDF2. Not suitable for production security.

## R4: Base32 Decoding / Secret Normalization

**Decision**: Use `otp_auth`'s built-in `Base32` class for standard decoding. Add a thin normalization layer for manual entry that strips spaces, hyphens, and uppercases input before decoding.

**Rationale**: Standard `otpauth://` URIs always contain uppercase Base32 without separators. Manual entry may include lowercase, spaces, or hyphens. Normalization:
1. `input.replaceAll(RegExp(r'[\s\-]'), '')` — remove whitespace and hyphens
2. `input.toUpperCase()` — case-insensitive
3. Validate with `Base32.decode()` — throws on invalid characters

**Alternatives considered**:
- Separate `base32` package (^2.2.0) — works but redundant since `otp_auth` bundles Base32.
- `convertlib` — high-performance but overkill for small TOTP secrets.

## R5: Unique Account Identifiers

**Decision**: Use `uuid` package (latest) for generating v4 UUIDs per account.

**Rationale**: Each account needs a stable unique ID for CRUD operations, reordering, and backup referencing. UUID v4 is standard, collision-free for local use, and does not leak creation time.

**Alternatives considered**:
- Timestamp-based IDs — simpler but potential collisions if two accounts added in same millisecond.
- Incrementing integers — fragile after delete/reorder operations; UUIDs are more robust.

## R6: QR Code Scanning

**Decision**: Use existing `mobile_scanner` (^7.1.4, already in pubspec.yaml).

**Rationale**: Already integrated in the existing `qr_scanner_screen.dart`. Supports Android CameraX and iOS AVFoundation. The authenticator QR scanner will follow the same pattern but route decoded barcodes through `OTPUri.parse()` instead of the existing API-based QR auth flow.

**Alternatives considered**: None needed — dependency already present and proven in the project.

## R7: Biometric / App Lock

**Decision**: Reuse existing `BiometricService` (wraps `local_auth` ^3.0.0) and `shared_preferences` for lock timeout setting.

**Rationale**: `BiometricService` already provides `authenticate()`, `isBiometricAvailable()`, and `isBiometricEnabledByUser()`. The authenticator app lock adds a timeout dimension (never / launch / 1 min / 5 min) stored in `shared_preferences`. The lock gate checks `DateTime.now() - lastBackgroundedTimestamp > timeout` on resume.

**Alternatives considered**: None needed — existing service covers the requirement.

## R8: Timer / Countdown Architecture

**Decision**: Use a single `TimerProvider` (ChangeNotifier) with a 1-second `Timer.periodic` that broadcasts the current epoch second. Each account card computes remaining seconds from `epoch % period`.

**Rationale**: A single timer source avoids N independent timers for N accounts. Listeners rebuild only the countdown widget and code display, not the entire list. Using `DateTime.now().millisecondsSinceEpoch ~/ 1000` as the time source correctly handles clock changes on next tick.

**Alternatives considered**:
- `StreamController` with `Stream.periodic` — functionally similar but ChangeNotifier integrates naturally with Provider.
- Per-account timers — wasteful; N timers for N accounts with identical period alignment.

## R9: Screenshot Prevention (Android)

**Decision**: Set `FLAG_SECURE` on `Window` for screens displaying TOTP codes using `FlutterWindowManager` or native platform channel.

**Rationale**: Android's `WindowManager.LayoutParams.FLAG_SECURE` prevents screenshots and screen recording. Can be set via a simple method channel call on screen init and cleared on dispose. iOS screenshot prevention is explicitly out of scope per spec FR-048.

**Alternatives considered**:
- `flutter_windowmanager` package — convenient, but a simple MethodChannel is lightweight and avoids an extra dependency for a single flag.

## R10: State Management

**Decision**: Use `Provider` (^6.1.2, already in pubspec.yaml) with ChangeNotifier-based providers.

**Rationale**: The existing app exclusively uses Provider. Adding a different state management solution would fragment the codebase. Three providers:
- `AuthenticatorProvider` — account list CRUD, duplicate check, reorder, search
- `TimerProvider` — shared 1-second tick for countdown
- `AuthenticatorSettingsProvider` — app lock timeout, clipboard clear duration, theme

**Alternatives considered**:
- Riverpod — more modern, but introducing it for one feature creates inconsistency.
- Bloc — heavier boilerplate, not used elsewhere in the project.

## R11: Clipboard Auto-Clear

**Decision**: After copying a code, start a `Timer` for the configured duration (default 30s). On expiry, call `Clipboard.setData(ClipboardData(text: ''))`. Cancel the timer if user copies a new code before expiry.

**Rationale**: Simple, testable approach. The timer lives in `ClipboardService` and is reset on each copy. Settings store the duration in `shared_preferences`.

**Alternatives considered**:
- Platform-specific clipboard APIs — unnecessary; Flutter's clipboard API is sufficient for clearing.

## R12: Drag-and-Drop Reorder

**Decision**: Use Flutter's built-in `ReorderableListView` widget.

**Rationale**: `ReorderableListView` provides native drag-and-drop reorder with `onReorder` callback. On reorder, update each account's `sortOrder` field and persist to secure storage. No additional packages needed.

**Alternatives considered**:
- `flutter_reorderable_list` — third-party package, unnecessary when built-in widget suffices.

## Summary of New Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `otp_auth` | ^1.0.1 | TOTP generation, OTPAuth URI parsing, Base32 codec |
| `pointycastle` | ^3.9.1 | AES-256-GCM encryption + PBKDF2 key derivation for backups |
| `uuid` | ^4.5.1 | Unique account identifiers |

All other required capabilities are covered by existing dependencies in pubspec.yaml.
