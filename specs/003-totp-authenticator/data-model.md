# Data Model: TOTP Authenticator

**Feature**: 003-totp-authenticator | **Date**: 2026-09-02

## Entities

### TotpAccount

The core entity representing a TOTP credential for an external service.

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| `id` | String (UUID v4) | Required, unique, immutable | Generated on creation |
| `issuer` | String | Required, non-empty, max 255 chars | e.g. "Google", "GitHub" |
| `accountName` | String | Required, non-empty, max 255 chars | e.g. "user@example.com" |
| `secret` | String (Base32) | Required, valid Base32, **encrypted at rest** | Never logged or transmitted |
| `algorithm` | Enum (SHA1, SHA256, SHA512) | Required, default SHA1 | Determines HMAC hash |
| `digits` | int | Required, 6 or 8, default 6 | Code length |
| `period` | int | Required, positive integer, default 30 | Seconds per code rotation |
| `sortOrder` | int | Required, non-negative | Display position, 0-indexed |
| `createdAt` | DateTime (ISO 8601) | Required, immutable | Set on creation |
| `updatedAt` | DateTime (ISO 8601) | Required | Updated on any edit |

**Validation rules**:
- `secret` must be valid Base32 after normalization (strip spaces, hyphens, uppercase)
- `algorithm` must be one of: SHA1, SHA256, SHA512
- `digits` must be exactly 6 or 8
- `period` must be > 0 (typical values: 30, 60)
- `secret` uniqueness enforced across all accounts (duplicate detection per FR-014a)

**Serialization**: JSON for both secure storage and backup.

```json
{
  "id": "a1b2c3d4-...",
  "issuer": "Google",
  "accountName": "user@example.com",
  "secret": "JBSWY3DPEHPK3PXP",
  "algorithm": "SHA1",
  "digits": 6,
  "period": 30,
  "sortOrder": 0,
  "createdAt": "2026-09-02T12:00:00Z",
  "updatedAt": "2026-09-02T12:00:00Z"
}
```

### AuthenticatorSettings

Non-sensitive user preferences stored in SharedPreferences (not encrypted).

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| `appLockTimeout` | Enum (never, onLaunch, after1Min, after5Min) | Required, default `never` | When to require authentication |
| `clipboardClearSeconds` | int | Required, 0 = disabled, default 30 | Auto-clear clipboard timer |
| `themeMode` | Enum (light, dark, system) | Required, default `system` | App appearance |

**Storage key prefix**: `authenticator_` in SharedPreferences.

### EncryptedBackup

The envelope format for exported backup files (`.json` file).

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| `version` | int | Required, currently `1` | Schema version for forward compatibility |
| `format` | String | Required, `"bankid-totp-backup"` | Format identifier |
| `kdf.algorithm` | String | `"PBKDF2-HMAC-SHA256"` | Key derivation function |
| `kdf.iterations` | int | `200000` | PBKDF2 iteration count |
| `kdf.keyBits` | int | `256` | Derived key length |
| `salt` | String (Base64) | 16 bytes random | PBKDF2 salt |
| `nonce` | String (Base64) | 12 bytes random | AES-GCM IV |
| `ciphertext` | String (Base64) | Variable length | Encrypted JSON payload |
| `tag` | String (Base64) | 16 bytes | GCM authentication tag |

**Plaintext payload** (before encryption):

```json
{
  "exportedAt": "2026-09-02T12:00:00Z",
  "accounts": [
    { /* TotpAccount JSON */ },
    { /* TotpAccount JSON */ }
  ]
}
```

Accounts are serialized in `sortOrder` sequence so ordering is preserved on import.

## Relationships

```
TotpAccount (0..*) ──stored-in──> SecureStorage (1)
TotpAccount (0..*) ──exported-to──> EncryptedBackup (0..1)
AuthenticatorSettings (1) ──stored-in──> SharedPreferences (1)
```

- A user has zero or more `TotpAccount` instances, all stored in a single encrypted secure-storage entry.
- An `EncryptedBackup` contains zero or more `TotpAccount` instances, ordered by `sortOrder`.
- `AuthenticatorSettings` is a singleton — one settings record per app installation.

## State Transitions

### TotpAccount Lifecycle

```
[Created] ──save──> [Active] ──edit──> [Active] ──delete──> [Removed]
                       │                                         │
                       └──export──> [In Backup]                  └── (permanent, no undo)
                                       │
                                       └──import──> [Active]
```

- **Created → Active**: Account passes validation (valid Base32 secret, supported algorithm/digits/period, no duplicate secret) and is persisted to secure storage.
- **Active → Active (edit)**: Any field except `id` and `createdAt` can be modified. `updatedAt` refreshed. Re-validates secret uniqueness if secret changed.
- **Active → Removed**: User confirms deletion. Account removed from secure storage. Irreversible.
- **Active → In Backup**: Account serialized into encrypted backup file. Original account unchanged.
- **In Backup → Active**: On import, accounts are decrypted, validated, and merged into secure storage. Duplicate secrets (matching existing active accounts) are skipped with a warning.

### App Lock State

```
[Unlocked] ──background──> [Timing] ──timeout expired──> [Locked]
                               │                             │
                               └──resume before timeout──> [Unlocked]
                                                             │
                                                             └──authenticate──> [Unlocked]
```

- `Locked` state requires biometric/PIN to transition to `Unlocked`.
- `never` timeout means the app never enters `Locked` from `Timing`.
- `onLaunch` timeout locks immediately on background.

## Storage Layout

### Secure Storage Keys

| Key | Content | Encryption |
|-----|---------|------------|
| `totp_accounts` | JSON array of TotpAccount objects | Platform keystore (AES-256-GCM on Android, Keychain on iOS) |

### SharedPreferences Keys

| Key | Type | Default |
|-----|------|---------|
| `authenticator_app_lock_timeout` | String (enum name) | `"never"` |
| `authenticator_clipboard_clear_seconds` | int | `30` |
| `authenticator_theme_mode` | String (enum name) | `"system"` |
| `authenticator_last_backgrounded` | int (epoch ms) | `0` |
