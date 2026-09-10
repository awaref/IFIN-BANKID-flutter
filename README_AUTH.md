## Authentication Flow

The application supports two authentication flows:

1.  **Existing Onboarding Flow**:
    -   Accessible if the user's National ID is not found in the system.
    -   Entry point: `OnboardingFlow` widget.

2.  **New National ID Verification Flow**:
    -   Entry point: `NationalIdVerificationScreen`.
    -   Accessible after Language Selection.
    -   Verifies National ID against `/api/v1/auth/login/national-id`.
    -   If verified, proceeds to `PinBiometricsScreen` for authentication.
    -   If not verified, redirects to the **Existing Onboarding Flow**.

3.  **Animated QR Code Authentication Flow**:
    -   **Device trust**: On login/startup the app calls `POST /devices/register` (even without FCM) and `POST /devices/{id}/trust` after PIN/biometric enrollment. The same `device_id` is sent on every QR call.
    -   **Scanning**: `MobileScanner` in `QrScannerScreen` decodes plain-text animated payloads matching `bankid.<uuid>.<seconds>.<hmac>`.
    -   **Validation**: Local regex check; legacy static tokens show an "outdated QR" message without calling the API.
    -   **Scan API**: `POST /qr/scan` with `{ qr_payload, device_id, biometric_verified: false }`.
    -   **Response**: `approval_ref`, `intent` (`auth`|`sign`), `user_visible_data`, `expires_at`, `relying_party`.
    -   **Approval**: `QrAuthScreen` requires local biometric / device PIN, then `POST /qr/approve` with `{ approval_ref, device_id, biometric_verified: true }`.
    -   **Reject / Cancel**: `POST /qr/reject` with `{ approval_ref, device_id }`.
    -   **Same-device**: Deep link `ifinbankid:///?autostarttoken=<uuid>` → `GET /qr/autostart/{token}?device_id=...` → same confirm screen (no camera).
    -   **Error Handling**: Distinct copy for expired/replayed QR, untrusted device, account KYC (403), network/500 retry.

### Key Components

-   **Services**:
    -   `ApiService`: Handles generic HTTP requests with Bearer token support and error handling.
    -   `AuthRepository`: QR scan / approve / reject / autostart + auth.
    -   `DeviceService` / `DeviceApi`: Stable secure `device_id`, register, trust.
    -   `QrPayloadParser`: Animated payload validation.
    -   `AutostartLinkService`: `app_links` handler for `ifinbankid://`.
-   **State Management**:
    -   `AuthProvider`: Manages the state of authentication (status, user info) using `Provider`.
-   **Screens**:
    -   `NationalIdVerificationScreen`: Input for National ID.
    -   `PinBiometricsScreen`: Biometric/PIN authentication.
    -   `QrScannerScreen`: Scans and validates animated QR payloads.
    -   `QrAuthScreen`: Displays relying party / intent and handles approval/rejection.
