import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  final String baseUrl;
  final http.Client _client;
  final FlutterSecureStorage _storage;

  ApiService({
    required this.baseUrl,
    http.Client? client,
    FlutterSecureStorage? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> _handleError(http.Response response) async {
    if (response.statusCode == 401) {
      await _storage.delete(key: 'auth_token');
      throw ApiException('Unauthorized', statusCode: 401);
    }
    
    if (response.statusCode >= 400) {
      String message = 'Request failed with status: ${response.statusCode}';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body.containsKey('message')) {
          message = body['message'];
        }
      } catch (_) {}
      throw ApiException(message, statusCode: response.statusCode);
    }
  }

  Future<dynamic> get(String endpoint) async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      debugPrint('API GET Request: $baseUrl$endpoint');
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      debugPrint('API Response [${response.statusCode}]: ${response.body}');
      await _handleError(response);
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('API Error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body, String? token}) async {
    final authToken = token ?? await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };

    try {
      debugPrint('API POST Request: $baseUrl$endpoint');
      if (body != null) {
        final sanitizedBody = Map<String, dynamic>.from(body);
        if (endpoint.contains('login') && sanitizedBody.containsKey('password')) {
          sanitizedBody['password'] = '***';
        }
        debugPrint('Request Body: ${jsonEncode(sanitizedBody)}');
      }

      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      debugPrint('API Response [${response.statusCode}]: ${response.body}');
      await _handleError(response);
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('API Error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<dynamic> uploadKycDocuments({
    required String requestId,
    required String selfiePath,
    required String idDocumentPath,
    required String idDocumentType,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/kyc/requests/$requestId/documents');
    final request = http.MultipartRequest('POST', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';
    request.fields['id_document_type'] = idDocumentType;
    request.files.add(await http.MultipartFile.fromPath('selfie', selfiePath));
    request.files.add(await http.MultipartFile.fromPath('id_document', idDocumentPath));
    try {
      debugPrint('API Multipart POST: $baseUrl/kyc/requests/$requestId/documents');
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      debugPrint('API Response [${response.statusCode}]: ${response.body}');
      await _handleError(response);
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('API Error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }
}
