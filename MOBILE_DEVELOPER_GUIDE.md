# Mobile Developer Guide — BankID Animated QR Login

What the IFIN BankID **mobile app** team must implement to support the new animated QR authentication flow.

Related API contract: [`mobile-bankid-qr-contract.md`](./mobile-bankid-qr-contract.md)

Backend PR: animated QR + OIDC (clean replace of the old static QR APIs).

---

## 1. Goal (what the app must do)

1. User opens a partner site (e.g. Tayseer) on desktop → sees a QR that **changes every second**.
2. User opens **our** BankID app → scans that QR.
3. App shows **who is asking** (relying party) and optional visible text.
4. User confirms with biometrics / security code.
5. Desktop session logs in. App shows success.

Same-device path: user taps **Open BankID** on the phone browser → deep link opens the app (no camera scan).

---

## 2. Breaking changes (old → new)

| Area | Old (remove) | New (implement) |
|------|--------------|-----------------|
| QR content | Raw `session_token` string | Full animated payload: `bankid.<uuid>.<seconds>.<hmac>` |
| Scan body | `{ "qr_code": "..." }` | `{ "qr_payload": "...", "device_id": "..." }` |
| After scan | Use `session_token` | Use `approval_ref` (never use / expect `order_ref`) |
| Approve body | `{ "session_token": "..." }` | `{ "approval_ref": "...", "device_id": "..." }` |
| Reject body | `{ "session_token": "..." }` | `{ "approval_ref": "...", "device_id": "..." }` |
| Device | Optional / ignored | **Required**: registered + **trusted** + active |
| Timing | Static QR valid ~5 min | Each frame ~1s; send scan ASAP after camera decode |

Old endpoints paths stay the same (`/api/v1/qr/scan|approve|reject`) but **request/response shapes changed**. Old clients will break.

---

## 3. Work checklist

### A. Device trust (blocker)

- [ ] On first launch / login, call `POST /api/v1/devices/register` with a stable `device_id` (platform ID).
- [ ] After local PIN / biometric enrollment, call `POST /api/v1/devices/{id}/trust`.
- [ ] Persist `device_id` securely and send it on **every** scan / approve / reject.
- [ ] If backend returns 404 with “device not trusted”, show: *This device is not trusted. Re-register / trust this device.*

Without a trusted device, scan always fails.

### B. QR scanner

- [ ] Decode the QR as **plain text** (do not assume a URL).
- [ ] Accept payloads matching:  
  `^[a-z0-9]+\.[0-9a-f-]{36}\.[0-9]+\.[0-9a-f]{64}$` (prefix default `bankid`).
- [ ] Send the **entire string** as `qr_payload` — do not strip prefix, do not recompute HMAC.
- [ ] Scan quickly after decode (frames expire / are single-use; stale frames fail).
- [ ] If decode looks like the old raw token (no dots / not 4 segments), show: *This QR is outdated. Ask the website to refresh.*

### C. Scan → confirm UI

- [ ] `POST /api/v1/qr/scan` with bearer token + `qr_payload` + `device_id`.
- [ ] On success, store `approval_ref` in memory only (short-lived).
- [ ] Show confirmation screen:
  - Relying party name / domain / logo (`relying_party`)
  - Intent: `auth` → “Log in” / `sign` → “Sign”
  - `user_visible_data` when present (signing text)
  - Expiry (`expires_at`)
- [ ] Require local biometric (or PIN) before calling approve.
- [ ] Approve: `POST /api/v1/qr/approve` with `approval_ref`, `device_id`, `biometric_verified: true`.
- [ ] Reject: `POST /api/v1/qr/reject` with `approval_ref`, `device_id` (Cancel button).
- [ ] Success / failure UX copy (see §5).

### D. Same-device deep link

- [ ] Register URL scheme / App Links for: `ifinbankid://`  
  (confirm final scheme with backend env `QR_AUTH_AUTOSTART_SCHEME`).
- [ ] Handle: `ifinbankid:///?autostarttoken=<uuid>`
- [ ] **Current backend gap:** there is no `GET /api/v1/qr/autostart/{token}` yet.  
  For v1 you can:
  - Open app and prompt user to scan, **or**
  - Coordinate with backend to add an autostart lookup endpoint before shipping same-device UX.
- [ ] Do not block QR-scan login on autostart if the lookup API is not ready.

### E. Auth / account gates

- [ ] User must be logged into the app (Keycloak access token).
- [ ] Account must be valid (KYC / ID). If API returns 403 `account.valid`, route to KYC / ID renewal — same as today.
- [ ] Refresh token before scan if access token is near expiry.

### F. Remove old code

- [ ] Delete any logic that treats QR content as `session_token`.
- [ ] Remove requests that send `qr_code` / `session_token` for auth QR.
- [ ] Update analytics / crash breadcrumbs field names.

### G. QA / acceptance

- [ ] Desktop shows QR that visibly changes every second; scan succeeds.
- [ ] Waiting ~2+ minutes then scanning an old screenshot fails with a clear error.
- [ ] Untrusted device cannot scan.
- [ ] Approve logs the user into the partner site (desktop completes).
- [ ] Reject leaves desktop in failed / cancelled state.
- [ ] Sign intent shows `user_visible_data` when provided.
- [ ] Offline / 500 errors show retry messaging.

---

## 4. API reference (mobile only)

Base: `/api/v1`  
Auth header: `Authorization: Bearer <access_token>`

### 4.1 Scan

`POST /qr/scan`

```http
Content-Type: application/json

{
  "qr_payload": "bankid.67df3917-fa0d-44e5-b327-edcc928297f8.12.a9e5ec59...",
  "device_id": "ios-vendor-id-or-android-id",
  "biometric_verified": false
}
```

**200**

```json
{
  "approval_ref": "AbCd...",
  "intent": "auth",
  "user_visible_data": null,
  "expires_at": "2026-03-26T12:05:00+00:00",
  "relying_party": {
    "id": "...",
    "name": "Tayseer",
    "domain": "tayseer.example",
    "logo_url": null
  },
  "requires_approval": true
}
```

**404** — invalid / expired / replayed QR, or device not trusted  
**401** — not logged in  
**403** — account invalid  

### 4.2 Approve

`POST /qr/approve`

```json
{
  "approval_ref": "AbCd...",
  "device_id": "ios-vendor-id-or-android-id",
  "biometric_verified": true
}
```

**200**

```json
{
  "message": "Authentication approved",
  "order": {
    "status": "complete",
    "intent": "auth",
    "completed_at": "..."
  }
}
```

### 4.3 Reject

`POST /qr/reject`

```json
{
  "approval_ref": "AbCd...",
  "device_id": "ios-vendor-id-or-android-id"
}
```

**200** `{ "message": "Authentication rejected" }`

### 4.4 Device (required before first scan)

`POST /devices/register` — register / upsert device  
`POST /devices/{id}/trust` — mark trusted (after local PIN/biometric setup)

Use the same `device_id` string everywhere.

---

## 5. Suggested UI copy

| Situation | Message |
|-----------|---------|
| After scan (`intent=auth`) | **Log in to {relying_party.name}?** |
| After scan (`intent=sign`) | **Sign for {relying_party.name}?** + show `user_visible_data` |
| Approve success | Identification completed. You can return to the website. |
| Reject | Cancelled. |
| 404 on scan | Could not use this QR. It may be expired or already used. Ask the website to show a new code. |
| Device not trusted | This device is not trusted. Complete device setup and try again. |
| 403 account | Your account needs verification before you can use BankID login. |

---

## 6. Recommended app flow

```
[Camera / deep link]
        │
        ▼
 Parse qr_payload (full string)
        │
        ▼
 POST /qr/scan  { qr_payload, device_id }
        │
        ├─ 404/403 → error screen
        │
        ▼
 Confirmation screen
   - RP name / logo
   - intent + user_visible_data
   - local biometric
        │
        ├─ Cancel → POST /qr/reject
        │
        ▼
 POST /qr/approve { approval_ref, device_id, biometric_verified: true }
        │
        ▼
 Success screen
```

---

## 7. Security rules for the app

1. Never log full `qr_payload` or `approval_ref` in production analytics.
2. Do not store `approval_ref` on disk; keep in memory until approve/reject/timeout.
3. Always bind approve/reject to the **same** `device_id` used at scan.
4. Prefer Face ID / fingerprint immediately before approve.
5. Do not try to “fix” a stale QR by editing `seconds` — backend will reject HMAC / freshness.

---

## 8. Out of scope for mobile (backend / web)

- Rendering / animating the QR on the website  
- OIDC `/oauth2/authorize` + `/token` (partner / web)  
- Partner `collect` polling  

Mobile only handles scan → confirm → approve/reject (and deep link when ready).

---

## 9. Backend follow-ups to request if needed

If same-device login is required for launch, ask backend for:

- `GET /api/v1/qr/autostart/{autostart_token}` → returns the same shape as scan success (`approval_ref`, relying party, etc.), requiring bearer + trusted `device_id`.

Until that exists, ship **QR scan** as the primary path.

---

## 10. Definition of done

Mobile work is done when:

1. Old `qr_code` / `session_token` auth path is removed.
2. Animated QR scan → approve works end-to-end against a partner hosted login page.
3. Trusted-device enforcement is enforced in UX.
4. Sign intent displays `user_visible_data`.
5. QA checklist in §3.G passes on iOS and Android.
