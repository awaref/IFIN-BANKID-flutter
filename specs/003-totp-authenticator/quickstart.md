# Quickstart Validation Guide: TOTP Authenticator

**Feature**: 003-totp-authenticator | **Date**: 2026-09-02

This guide documents how to validate the authenticator feature end-to-end. It covers prerequisites, setup, runnable test scenarios, and expected outcomes.

## Prerequisites

- Flutter SDK ^3.9.2 installed
- Android device/emulator (minSdk 24) or iOS device/simulator
- Project cloned and dependencies resolved

## Setup

### 1. Add new dependencies

Add to `pubspec.yaml` under `dependencies`:

```yaml
otp_auth: ^1.0.1
pointycastle: ^3.9.1
uuid: ^4.5.1
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run existing tests (sanity check)

```bash
flutter test
```

All existing tests should pass before proceeding.

## Validation Scenarios

### V1: TOTP Code Generation (Unit Test)

**What it proves**: RFC 6238 compliance — codes match official test vectors.

**Run**:
```bash
flutter test test/unit/totp_service_test.dart
```

**Expected outcome**: All test cases pass, including:
- SHA1 / 6-digit / 30s period → matches RFC 6238 Appendix B vectors
- SHA256 / 8-digit / 30s period → matches RFC 6238 vectors
- SHA512 / 8-digit / 30s period → matches RFC 6238 vectors
- Custom period (60s) → correct time-step division
- Edge case: code at period boundary (t=0, t=30, t=59)

Reference: [data-model.md](data-model.md) for TotpAccount field definitions.

---

### V2: OTPAuth URI Parsing (Unit Test)

**What it proves**: Correct parsing of standard `otpauth://` URIs from real services.

**Run**:
```bash
flutter test test/unit/otp_uri_parser_test.dart
```

**Expected outcome**: All test cases pass, including:
- `otpauth://totp/Google:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Google` → issuer "Google", account "user@example.com", defaults SHA1/6/30
- URI with explicit `algorithm=SHA256&digits=8&period=60`
- URL-encoded account names (`%40` for `@`)
- Missing secret → rejection error
- Invalid algorithm → rejection error
- `otpauth://hotp/...` → rejection (unsupported type)
- Completely non-otpauth string → rejection

---

### V3: Account Storage CRUD (Unit Test)

**What it proves**: Accounts persist correctly through secure storage round-trips.

**Run**:
```bash
flutter test test/unit/account_repository_test.dart
```

**Expected outcome**:
- Save → load returns identical fields (issuer, accountName, secret, algorithm, digits, period, sortOrder)
- Update fields → re-load reflects changes
- Delete → account no longer in load results
- Reorder (swap sortOrder) → persisted correctly
- Duplicate secret detection → second save rejected

Reference: [data-model.md](data-model.md) for storage layout.

---

### V4: Backup Encrypt/Decrypt (Unit Test)

**What it proves**: Encrypted backup round-trip with correct password restores all data; wrong password fails safely.

**Run**:
```bash
flutter test test/unit/backup_service_test.dart
```

**Expected outcome**:
- Export 3 accounts → encrypted JSON file with version, format, kdf, salt, nonce, ciphertext, tag fields
- Import with correct password → 3 accounts restored with matching fields and order
- Import with wrong password → decryption failure, no data modified
- Import corrupted file (tampered ciphertext) → integrity check fails
- Import invalid JSON → format rejection

Reference: [data-model.md](data-model.md) for EncryptedBackup schema.

---

### V5: Manual Account Entry (On-Device)

**What it proves**: End-to-end manual add flow works on a real device.

**Steps**:
1. Open app → navigate to Settings → tap "Authenticator"
2. Tap (+) → select "Manual Entry"
3. Enter:
   - Account name: `test@example.com`
   - Issuer: `TestService`
   - Secret: `JBSWY3DPEHPK3PXP`
   - Algorithm: SHA1
   - Digits: 6
   - Period: 30
4. Tap "Add Account"
5. Verify account card appears with issuer "TestService", name "test@example.com"
6. Verify code matches a known TOTP generator (e.g., Google Authenticator with same secret)
7. Wait for countdown to reach 0 → verify code changes automatically
8. Tap code → verify "Code copied" snackbar and clipboard contains 6-digit code

**Expected outcome**: Code displayed matches any standard TOTP app using the same secret. Countdown refreshes smoothly.

Reference: [contracts/screens.md](contracts/screens.md) SC-03 for form fields.

---

### V6: QR Code Scan (On-Device)

**What it proves**: Camera-based QR scan correctly parses otpauth URIs.

**Prerequisites**: A QR code encoding `otpauth://totp/GitHub:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=GitHub` (generate at any QR code generator site).

**Steps**:
1. Authenticator home → tap (+) → "Scan QR Code"
2. Grant camera permission if prompted
3. Point camera at the QR code
4. Verify preview shows: Issuer "GitHub", Account "user@example.com", SHA1, 6 digits, 30s
5. Tap "Add Account"
6. Verify account appears on home screen with correct code

**Expected outcome**: Scanned account generates matching codes.

---

### V7: App Lock (On-Device)

**What it proves**: Biometric/PIN lock gates access to authenticator.

**Steps**:
1. Authenticator settings → set App Lock to "On app launch"
2. Minimize the app (send to background)
3. Reopen the app
4. Verify biometric/PIN prompt appears before accounts are visible
5. Authenticate successfully → accounts visible
6. Change setting to "Never" → verify no lock on next reopen

**Expected outcome**: Lock gate engages according to configured timeout.

---

### V8: Export & Import (On-Device)

**What it proves**: Encrypted backup round-trip on real device.

**Steps**:
1. Add 2+ accounts
2. Settings → "Export accounts" → enter password "TestPass123!"
3. Save file
4. Settings → "Import accounts" → pick the exported file → enter "TestPass123!"
5. Verify all accounts present with correct codes
6. Try import with wrong password "wrong" → verify error, no changes

**Expected outcome**: Correct password restores all accounts; wrong password fails cleanly.

---

### V9: Search & Reorder (On-Device)

**What it proves**: Search filtering and drag-and-drop reorder work and persist.

**Steps**:
1. Add 3+ accounts with different issuers
2. Tap search → type first issuer name → verify only matching account shown
3. Clear search → all accounts visible
4. Long-press and drag first account to last position
5. Close and reopen authenticator → verify new order persisted

**Expected outcome**: Search filters correctly; reorder persists across restarts.

---

### V10: Security Audit (On-Device, Android)

**What it proves**: Secrets are not exposed in logs, screenshots, or debug output.

**Steps**:
1. Connect Android device via ADB
2. Add an account
3. Run `adb logcat | grep -i "JBSWY3DPEHPK3PXP"` (the secret)
4. Verify zero matches
5. Attempt screenshot on authenticator home screen → verify it is blocked (black screen or system denial)

**Expected outcome**: Zero secret exposure in logs; screenshot prevention active.

---

### V11: Public TOTP Tester Interop (elogic TestAuthenticator)

**What it proves**: BankID codes match a standard authenticator for the fixed public test seed, and isolates clock skew vs app bugs.

**Tester**: [https://elogic.synology.me/TestAuthenticator/](https://elogic.synology.me/TestAuthenticator/) ([source](https://github.com/KashifMushtaq/AuthenticatorTest))

**Caveats**:
- The page mentions “PIN + Code” for MFA demos; the **Test TOTP** form validates a **plain 6-digit** code only — do not prefix a PIN.
- The site uses a **fixed** seed (QR and validator share it) and a **±1** time-step window (±30s). Device or host clock skew beyond that fails validation even when codes are correct.
- Fixed Base32 secret (manual-entry control): `65TV7MIRZ5FV5MX24NVVXXD3MG7UDGPD` (SHA1 / 6 digits / 30s).
- Prefer **tap-to-copy** over typing. In Arabic (RTL), manually reading a spaced code like `850 705` can look like `705 850` and produce a swapped failure such as `705850`. TOTP digits are forced LTR in the UI.

**Steps (on-device A/B)**:
1. Enable automatic network time on the phone.
2. Scan the same site QR into Google or Microsoft Authenticator **and** BankID (or Manual Entry with the secret above).
3. When the countdown shows more than 5 seconds remaining, compare the two 6-digit codes — they must match.
4. Tap-to-copy from BankID and paste into the site’s **TOTP for Testing** field (digits only; no spaces).

**Interpretation**:

| Result | Conclusion |
|--------|------------|
| Google matches BankID; site still fails | Site/host clock or site bug — not BankID |
| Google passes site; BankID differs | App bug — investigate parse/generation |
| Both fail site | Clock skew (device or server) |

**Automated coverage**: `flutter test test/unit/totp_service_test.dart test/unit/otp_uri_parser_test.dart` includes the elogic URI parse and HMAC vector `848226` at `t=1111111111`.

---

## Run All Unit Tests

```bash
flutter test test/unit/
```

All unit tests (V1–V4, plus elogic interop vectors in V11) must pass. On-device scenarios (V5–V11) require manual execution on Android/iOS device.
