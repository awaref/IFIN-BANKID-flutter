
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

### Key Components

-   **Services**:
    -   `ApiService`: Handles generic HTTP requests with Bearer token support and error handling.
    -   `AuthRepository`: Manages authentication logic (verifying National ID).
-   **State Management**:
    -   `AuthProvider`: Manages the state of authentication (status, user info) using `Provider`.
-   **Screens**:
    -   `NationalIdVerificationScreen`: Input for National ID.
    -   `PinBiometricsScreen`: Biometric/PIN authentication.
