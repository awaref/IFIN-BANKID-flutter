# UI Screen Contracts: TOTP Authenticator

**Feature**: 003-totp-authenticator | **Date**: 2026-09-02

This document defines the UI contracts — screen responsibilities, inputs, outputs, navigation, and user-visible state — for the authenticator module.

---

## SC-01: Settings Entry Point (modification)

**Screen**: `SettingsScreen` (existing)

**Change**: Add a `ListTile` in the "Account Settings" section that navigates to `AuthenticatorHomeScreen`.

| Element | Detail |
|---------|--------|
| Icon | Shield/key authenticator icon |
| Title | Localized "Authenticator" / "المصادقة" |
| Action | `Navigator.push → AuthenticatorHomeScreen` |

---

## SC-02: Authenticator Home Screen

**Route**: `/authenticator`
**File**: `authenticator_home_screen.dart`

### Inputs
- Account list from `AuthenticatorProvider`
- Current epoch second from `TimerProvider`
- Search query (local state)

### Layout

| Zone | Content |
|------|---------|
| AppBar | Title "Authenticator", search toggle, add (+) action button |
| Search bar | Text field filtering accounts by issuer, account name, email (visible on toggle) |
| Body | `ReorderableListView` of `TotpAccountCard` widgets |
| Empty state | Illustration + "No accounts yet" + "Add account" CTA button |

### TotpAccountCard (widget contract)

| Element | Source | Interaction |
|---------|--------|-------------|
| Issuer | `account.issuer` | — |
| Account name | `account.accountName` | — |
| TOTP code | `totpService.generateCode(account, currentEpoch)` formatted as `XXX XXX` (6-digit) or `XXXX XXXX` (8-digit) | Tap → copy to clipboard + snackbar "Code copied" |
| Countdown text | `account.period - (currentEpoch % account.period)` seconds | — |
| Progress indicator | Linear progress `remainingSeconds / period` | — |
| Copy button | Icon button | Same as code tap |
| Edit button | Icon button | `Navigator.push → EditAccountScreen(account)` |
| Delete button | Icon button | Show delete confirmation dialog |

### Navigation Out
- (+) button → `AddAccountScreen` (bottom sheet or screen with QR/Manual tabs)
- Edit → `EditAccountScreen`
- Settings gear (optional) → `AuthenticatorSettingsScreen`

### Security
- Android: `FLAG_SECURE` set on init, cleared on dispose
- App lock gate checked on `didChangeAppLifecycleState(resumed)`

---

## SC-03: Add Account Screen

**Route**: `/authenticator/add`
**File**: `add_account_screen.dart`

### Tabs / Options
1. **Scan QR Code** → navigates to `QrScanScreen`
2. **Manual Entry** → inline form

### Manual Entry Form

| Field | Widget | Validation | Default |
|-------|--------|------------|---------|
| Account name | `TextFormField` | Required, non-empty | — |
| Issuer | `TextFormField` | Required, non-empty | — |
| Secret key | `TextFormField` (obscurable) | Required, valid Base32 after normalization | — |
| Algorithm | `DropdownButtonFormField` | SHA1, SHA256, SHA512 | SHA1 |
| Digits | `DropdownButtonFormField` | 6, 8 | 6 |
| Period | `TextFormField` (numeric) | Positive integer | 30 |

### Outputs
- Valid input → `AccountPreviewScreen` or inline preview with "Add Account" button
- Duplicate secret detected → error message, no save

### Navigation Out
- Back → `AuthenticatorHomeScreen`
- Successful add → `AuthenticatorHomeScreen` (pop to root of authenticator)

---

## SC-04: QR Scan Screen

**Route**: `/authenticator/scan`
**File**: `qr_scan_screen.dart`

### Inputs
- Camera permission status

### Layout

| Zone | Content |
|------|---------|
| Camera preview | Full-screen `MobileScanner` with viewfinder overlay |
| Instruction text | "Point your camera at a QR code" |
| Permission denied state | Explanation + "Open Settings" button + "Enter manually" fallback |

### Scan Handling

| Result | Action |
|--------|--------|
| Valid `otpauth://totp/...` | Parse → navigate to `AccountPreviewScreen` |
| Valid `otpauth://hotp/...` or other | Show error: "Unsupported OTP type. Only TOTP is supported." |
| Non-otpauth QR | Show error: "Invalid QR code for authenticator setup." |
| Malformed URI / bad secret | Show error: "Could not read account from QR code." |

### Navigation Out
- Successful scan → `AccountPreviewScreen`
- Back → `AddAccountScreen`

---

## SC-05: Account Preview Screen

**Route**: `/authenticator/preview`
**File**: `account_preview_screen.dart`

### Inputs
- Parsed `TotpAccount` (not yet saved)

### Layout

| Element | Content |
|---------|---------|
| Issuer | Parsed value |
| Account name | Parsed value |
| Algorithm | SHA1 / SHA256 / SHA512 |
| Digits | 6 or 8 |
| Period | N seconds |
| Live code preview | Generated from parsed data to confirm it works |
| "Add Account" button | Primary CTA |
| "Cancel" button | Secondary |

### Outputs
- "Add Account" → save to repository → pop to `AuthenticatorHomeScreen`
- Duplicate detected → error inline, "Add Account" button disabled
- "Cancel" → pop back

---

## SC-06: Edit Account Screen

**Route**: `/authenticator/edit/:id`
**File**: `edit_account_screen.dart`

### Inputs
- Existing `TotpAccount` loaded by ID

### Form
Same fields as Manual Entry (SC-03), pre-populated with current values.

### Outputs
- Save → validate → update in repository → pop back
- If secret changed, re-check duplicate uniqueness
- Cancel → pop back without changes

---

## SC-07: Delete Confirmation Dialog

**Type**: `AlertDialog` (modal)

### Content

| Element | Detail |
|---------|--------|
| Title | "Delete account?" |
| Body | Issuer + account name + "This will permanently remove this authenticator account." |
| Cancel button | Dismiss dialog |
| Delete button | Red/destructive style → remove from repository → dismiss → refresh list |

---

## SC-08: Authenticator Settings Screen

**Route**: `/authenticator/settings`
**File**: `authenticator_settings_screen.dart`

### Sections

| Section | Items |
|---------|-------|
| **Security** | App lock timeout (radio: Never / On launch / After 1 min / After 5 min) |
| **Clipboard** | Auto-clear duration (dropdown: 15s / 30s / 60s / Disabled) |
| **Appearance** | Theme (radio: Light / Dark / System) |
| **Backup** | Export accounts (button) → export flow |
| **Backup** | Import accounts (button) → file picker → password prompt → import flow |

### Export Flow
1. Tap "Export accounts"
2. Enter and confirm backup password (dialog with two password fields)
3. Encrypt accounts → save file via share sheet or file picker
4. Success toast

### Import Flow
1. Tap "Import accounts"
2. Pick `.json` backup file
3. Enter backup password (dialog)
4. Decrypt → validate → show summary (N accounts to import)
5. Confirm → merge into storage (skip duplicates) → success toast
6. Wrong password → error message, no data modified
7. Corrupted/invalid file → error message, no data modified

---

## SC-09: App Lock Gate Screen

**Type**: Overlay / interceptor (not a routable screen)

### Behavior
- Displayed when `AuthenticatorSettingsProvider` determines lock is required
- Shows biometric prompt via `BiometricService.authenticate()`
- On success → reveal authenticator content
- On failure → retry button + device PIN/passcode fallback
- If biometric unavailable → device PIN/passcode only

---

## Navigation Map

```
SettingsScreen
  └── AuthenticatorHomeScreen
        ├── AddAccountScreen
        │     ├── QrScanScreen → AccountPreviewScreen → (pop to Home)
        │     └── Manual form → AccountPreviewScreen → (pop to Home)
        ├── EditAccountScreen → (pop to Home)
        ├── DeleteConfirmationDialog → (dismiss, refresh)
        └── AuthenticatorSettingsScreen
              ├── Export flow (dialogs)
              └── Import flow (file picker + dialogs)
```
