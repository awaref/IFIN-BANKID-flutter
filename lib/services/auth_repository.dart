import 'package:flutter/foundation.dart';
import 'package:bankid_app/services/api_service.dart';
import 'package:bankid_app/services/biometric_service.dart';
import 'package:bankid_app/models/qr_models.dart';

class AuthRepository {
  final ApiService _api;
  final BiometricService _biometric;

  AuthRepository({
    required ApiService apiService,
    BiometricService? biometricService,
  }) : _api = apiService,
       _biometric = biometricService ?? BiometricService();

  // ================= NATIONAL ID CHECK =================

  Future<bool> verifyNationalId(String nationalId) async {
    try {
      final result = await _api.post<Map<String, dynamic>>(
        '/auth/check-national-id',
        {'national_id': nationalId},
        (json) => json,
      );

      return result['exists'] == true || result['status'] == 'success';
    } on ApiException catch (e) {
      if (e.statusCode == 404) return false;
      rethrow;
    }
  }

  // ================= BIOMETRIC LOGIN =================

  /// Returns true if the device has biometrics enrolled AND we have stored
  /// tokens (meaning the user previously logged in with a password), AND
  /// the user has explicitly enabled biometric login in settings.
  Future<bool> canLoginWithBiometric() async {
    final hasToken = await _api.getPublicToken() != null;
    if (!hasToken) return false;

    final isEnabled = await _biometric.isBiometricEnabledByUser();
    if (!isEnabled) return false;

    return _biometric.isBiometricAvailable();
  }

  /// Shows the system biometric prompt. On success, calls /auth/refresh to
  /// obtain a fresh access_token without requiring the user's password.
  /// Returns true if the full flow (local + backend) succeeds.
  Future<bool> loginWithBiometric() async {
    debugPrint('DEBUG: loginWithBiometric: starting biometric prompt');

    // Step 1 — local biometric check
    final authenticated = await _biometric.authenticate(
      reason: 'Authenticate to access your account',
    );

    if (!authenticated) {
      debugPrint('DEBUG: loginWithBiometric: biometric failed or cancelled');
      return false;
    }

    // Step 2 — use stored refresh_token to get a new access_token
    final refreshToken = await _api.getStoredRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      debugPrint('DEBUG: loginWithBiometric: no refresh token stored');
      return false;
    }

    final success = await _api.refreshWithToken(refreshToken);
    debugPrint('DEBUG: loginWithBiometric: backend refresh success=$success');
    return success;
  }

  // ================= LOGIN =================

  Future<bool> loginWithPassword(String password) async {
    final tokens = await _api.post<Map<String, dynamic>>('/auth/login', {
      'password': password,
    }, (json) => json);
    debugPrint('DEBUG: loginWithPassword API response: $tokens');

    await _storeTokens(tokens);
    return true;
  }

  Future<bool> loginWithNationalId(String nationalId, String password) async {
    final tokens = await _api.post<Map<String, dynamic>>(
      '/auth/login/national-id',
      {'national_id': nationalId, 'password': password},
      (json) => json,
    );
    debugPrint('DEBUG: loginWithNationalId API response: $tokens');

    await _storeTokens(tokens);
    return true;
  }

  Future<bool> registerUser(Map<String, dynamic> data) async {
    final result = await _api.post<Map<String, dynamic>>(
      '/auth/register',
      data,
      (json) => json,
    );
    debugPrint('DEBUG: registerUser API response: $result');

    if (result.containsKey('access_token')) {
      await _storeTokens(result);
      return true;
    }

    // fallback auto-login
    if (data.containsKey('national_id') && data.containsKey('password')) {
      await loginWithNationalId(data['national_id'], data['password']);
      return true;
    }
    return false;
  }

  Future<void> _storeTokens(Map<String, dynamic> json) async {
    final accessToken = json['access_token'] ?? json['token'];
    final refreshToken = json['refresh_token'];

    if (accessToken == null) {
      debugPrint(
        'DEBUG: _storeTokens: Access token is null from API response.',
      );
      throw ApiException('Authentication failed: no access token.');
    }
    debugPrint(
      'DEBUG: _storeTokens: Saving access token: ${accessToken != null ? 'exists' : 'null'}, Refresh token: ${refreshToken != null ? 'exists' : 'null'}',
    );

    await _api.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken ?? '',
    );
  }

  // ================= USER =================

  Future<Map<String, dynamic>> fetchCurrentUser() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/auth/me',
      (json) => json,
    );
    debugPrint('DEBUG: fetchCurrentUser response: $response');
    return response;
  }

  // ================= QR AUTH =================

  Future<QrScanResponse> scanQrCode(String code) {
    return _api.post<QrScanResponse>('/qr/scan', {
      'qr_code': code,
    }, (json) => QrScanResponse.fromJson(json));
  }

  Future<QrApproveResponse> approveQrAuth(String sessionToken) {
    return _api.post<QrApproveResponse>('/qr/approve', {
      'session_token': sessionToken,
    }, (json) => QrApproveResponse.fromJson(json));
  }

  Future<QrRejectResponse> rejectQrAuth(String sessionToken) {
    return _api.post<QrRejectResponse>('/qr/reject', {
      'session_token': sessionToken,
    }, (json) => QrRejectResponse.fromJson(json));
  }

  // ================= KYC =================

  Future<String> initiateKyc({String? token}) async {
    final result = await _api.post<Map<String, dynamic>>(
      '/kyc/initiate',
      token != null ? {'token': token} : {},
      (json) => json,
    );

    final kyc = result['kyc_request'];
    if (kyc == null) {
      throw ApiException('Invalid KYC response.');
    }

    final id = kyc['id'] ?? kyc['uuid'] ?? kyc['request_id'];
    if (id == null) {
      throw ApiException('KYC request ID missing.');
    }

    return id.toString();
  }

  Future<void> uploadKycDocuments({
    required String requestId,
    required String selfiePath,
    required String idDocumentPath,
    required String idDocumentType,
  }) {
    return _api.uploadKycDocuments(
      endpoint: '/kyc/documents',
      requestId: requestId,
      selfiePath: selfiePath,
      idDocumentPath: idDocumentPath,
      idDocumentType: idDocumentType,
    );
  }

  Future<Map<String, dynamic>> getKycRequest(String id) {
    return _api.get<Map<String, dynamic>>('/kyc/requests/$id', (json) => json);
  }

  // ================= LOGOUT =================

  Future<void> logout() async {
    try {
      await _api.delete('/auth/logout');
    } finally {
      await _api.clearTokens();
    }
  }

  Future<void> deleteToken() async {
    await _api.clearTokens();
  }

  Future<String?> getAccessToken() async {
    return await _api.getPublicToken();
  }

  Future<String?> getToken() async {
    return await _api.getPublicToken();
  }
}
