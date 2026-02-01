import 'package:flutter/foundation.dart';
import 'package:bankid_app/services/api_service.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository({required ApiService apiService}) : _apiService = apiService;

  Future<bool> verifyNationalId(String nationalId) async {
    try {
      final response = await _apiService.post(
        '/auth/check-national-id',
        body: {'national_id': nationalId},
      );
      if (response is Map<String, dynamic>) {
        final exists = response['exists'] == true || response['status'] == 'success';
        debugPrint('AuthRepository: National ID exists? $exists');
        return exists;
      }
      return false;
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) {
        return false;
      }
      rethrow;
    }
  }

  Future<bool> loginWithPassword(String password) async {
    final response = await _apiService.post(
      '/auth/login',
      body: {'password': password},
    );

    if (response is Map<String, dynamic>) {
      final token = response['token'] ?? response['access_token'];
      if (token is String && token.isNotEmpty) {
        await _apiService.saveToken(token);
        return true;
      }
    }

    return false;
  }

  Future<bool> loginWithNationalId(String nationalId, String password) async {
    final response = await _apiService.post(
      '/auth/login/national-id',
      body: {
        'national_id': nationalId,
        'password': password,
      },
    );

    if (response is Map<String, dynamic>) {
      final token = response['token'] ?? response['access_token'];
      if (token is String && token.isNotEmpty) {
        await _apiService.saveToken(token);
        return true;
      }
    }

    return false;
  }

  Future<bool> registerUser(Map<String, dynamic> data) async {
    final response = await _apiService.post(
      '/auth/register',
      body: data,
    );

    if (response is Map<String, dynamic>) {
      final token = response['token'] ?? response['access_token'];
      if (token is String && token.isNotEmpty) {
        await _apiService.saveToken(token);
        return true;
      }

      // Fallback: Try to login if registration didn't return a token
      if (data.containsKey('national_id') && data.containsKey('password')) {
        debugPrint('AuthRepository: No token in register response, attempting auto-login...');
        return await loginWithNationalId(data['national_id'], data['password']);
      }
    }

    return false;
  }

  Future<String?> initiateKyc({String? token}) async {
    final response = await _apiService.post('/kyc/initiate', token: token);
    if (response is Map<String, dynamic>) {
      final kyc = response['kyc_request'];
      if (kyc is Map<String, dynamic>) {
        final id = kyc['id'] ?? kyc['uuid'] ?? kyc['request_id'];
        if (id is String && id.isNotEmpty) {
          return id;
        } else if (id is int) {
          return id.toString();
        }
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchCurrentUser() async {
    final response = await _apiService.get('/auth/me');
    if (response is Map<String, dynamic>) {
      final user = response['user'];
      if (user is Map<String, dynamic>) {
        return Map<String, dynamic>.from(user);
      }
      return Map<String, dynamic>.from(response);
    }
    return null;
  }

  Future<Map<String, dynamic>?> getKycRequest(String id) async {
    final response = await _apiService.get('/kyc/requests/$id');
    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }
}
