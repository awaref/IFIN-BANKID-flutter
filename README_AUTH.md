
## Authentication Flow

The application supports two authentication flows:

1.  **Existing Onboarding Flow**:
    -   Accessible if the user's National ID is not found in the system.
    -   Entry point: `OnboardingFlow` widget.

2.  **New National ID Verification Flow**:
    -   Entry point: `NationalIdVerificationScreen`.
    -   Accessible after Language Selection.
    -   Verifies National ID against `http://ifin-bankid-backend.test/api/v1/auth/login/national-id`.
    -   If verified, proceeds to `PinBiometricsScreen` for authentication.
    -   If not verified, redirects to the **Existing Onboarding Flow**.

3.  **QR Code Authentication Flow**:
    -   **Scanning**: Uses `MobileScanner` in `QrScannerScreen` to capture QR codes.
    -   **Validation**: Sends the scanned code to `/qr/scan`.
    -   **Response**: Expects a `session_token` and optional `partner_website` info.
    -   **Approval**: User approves/rejects on `QrAuthScreen` via `/qr/approve` or `/qr/reject`.
    -   **Error Handling**:
        -   Detailed error messages for Network, Session Expiration (404), and Server Errors (500).
        -   Retry mechanisms and visual feedback.

### Key Components

-   **Services**:
    -   `ApiService`: Handles generic HTTP requests with Bearer token support and error handling.
    -   `AuthRepository`: Manages authentication logic (verifying National ID).
-   **State Management**:
    -   `AuthProvider`: Manages the state of authentication (status, user info) using `Provider`.
-   **Screens**:
    -   `NationalIdVerificationScreen`: Input for National ID.
    -   `PinBiometricsScreen`: Biometric/PIN authentication.
    -   `QrScannerScreen`: Scans and validates QR codes.
    -   `QrAuthScreen`: Displays partner info and handles approval/rejection.
