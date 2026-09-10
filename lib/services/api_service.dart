// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:bankid_app/models/contract.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:bankid_app/core/utils/app_logger.dart';

// class ApiException implements Exception {
//   final String message;
//   final int? statusCode;
//   ApiException(this.message, {this.statusCode});
//   @override
//   String toString() => message;
// }

// class NetworkException extends ApiException {
//   NetworkException(super.message);
// }

// class UnauthorizedException extends ApiException {
//   UnauthorizedException(super.message) : super(statusCode: 401);
// }

// class ValidationException extends ApiException {
//   final Map<String, dynamic> errors;
//   ValidationException(super.message, this.errors) : super(statusCode: 422);
// }

// class ServerException extends ApiException {
//   ServerException(super.message, {super.statusCode});
// }

// class ApiService {
//   final VoidCallback? onSessionExpired;
//   bool ignoreSessionExpired = false;
//   final String baseUrl;
//   final http.Client _client;
//   final FlutterSecureStorage _storage;

//   ApiService({
//     required this.baseUrl,
//     this.onSessionExpired,
//     http.Client? client,
//     FlutterSecureStorage? storage,
//   }) : _client = client ?? http.Client(),
//        _storage = storage ?? const FlutterSecureStorage();

//   // ================= TOKEN MANAGEMENT =================

//   Future<String?> _getAccessToken() async {
//     final token = await _storage.read(key: 'access_token');
//     _log('Retrieved access token: ${token != null ? 'exists' : 'null'}');
//     return token;
//   }

//   Future<String?> _getRefreshToken() async {
//     final token = await _storage.read(key: 'refresh_token');
//     _log('Retrieved refresh token: ${token != null ? 'exists' : 'null'}');
//     return token;
//   }

//   Future<void> saveTokens({
//     required String accessToken,
//     required String refreshToken,
//   }) async {
//     await _storage.write(key: 'access_token', value: accessToken);
//     await _storage.write(key: 'refresh_token', value: refreshToken);
//     _log('Tokens saved: Access token ${'exists'}, Refresh token ${'exists'}');
//   }

//   Future<void> clearTokens() async {
//     await _storage.deleteAll();
//     _log('Tokens cleared.');
//   }

//   // ================= LOGGER =================

//   void _log(String message) {
//     if (kDebugMode) AppLogger.log('[ApiService] $message');
//   }

//   Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
//     return headers.map((key, value) {
//       if (key.toLowerCase() == 'authorization') {
//         return MapEntry(key, 'Bearer *****');
//       }
//       return MapEntry(key, value);
//     });
//   }

//   dynamic _sanitizeBody(dynamic body) {
//     if (body is Map) {
//       return body.map((key, value) {
//         if (key.toString().toLowerCase().contains('password') ||
//             key.toString().toLowerCase().contains('token') ||
//             key.toString().toLowerCase() == 'selfie' ||
//             key.toString().toLowerCase() == 'id_document') {
//           return MapEntry(key, '*****');
//         }
//         return MapEntry(key, value);
//       });
//     }
//     return body;
//   }

//   void _logRequest(
//     String method,
//     Uri uri,
//     Map<String, String> headers,
//     dynamic body,
//   ) {
//     if (!kDebugMode) return;
//     final requestId = DateTime.now().millisecondsSinceEpoch.toString();
//     _log('--- REQUEST START ($requestId) ---');
//     _log('Method: $method');
//     _log('URL: $uri');
//     _log('Headers: ${_sanitizeHeaders(headers)}');
//     if (body != null) {
//       _log('Body: ${_sanitizeBody(body)}');
//     }
//     _log('Timestamp: ${DateTime.now().toIso8601String()}');
//     _log('--- REQUEST END ($requestId) ---');
//   }

//   void _logResponse(
//     String method,
//     Uri uri,
//     http.Response response,
//     int durationMs,
//   ) {
//     if (!kDebugMode) return;
//     final requestId = DateTime.now().millisecondsSinceEpoch
//         .toString(); // Simplified correlation
//     final status = response.statusCode;
//     final level = status >= 200 && status < 300 ? 'DEBUG' : 'ERROR';

//     _log('--- RESPONSE START ($requestId) ---');
//     _log('Level: $level');
//     _log('Method: $method');
//     _log('URL: $uri');
//     _log('Status Code: $status');
//     _log('Duration: ${durationMs}ms');
//     _log('Headers: ${response.headers}');
//     try {
//       // Try to parse as JSON for cleaner logging, otherwise raw string
//       final jsonBody = jsonDecode(response.body);
//       _log('Body: ${_sanitizeBody(jsonBody)}');
//     } catch (_) {
//       _log('Body: ${response.body}');
//     }
//     _log('--- RESPONSE END ($requestId) ---');
//   }

//   // ================= CORE REQUEST HANDLER =================

//   Future<T> _safeRequest<T>(Future<T> Function() request) async {
//     try {
//       return await request();
//     } on SocketException catch (e) {
//       _log('SocketException: $e');
//       throw NetworkException('No internet connection.');
//     } on TimeoutException catch (e) {
//       _log('TimeoutException: $e');
//       throw NetworkException('Request timed out.');
//     } catch (e) {
//       _log('Unexpected error: $e');
//       if (e is ApiException) rethrow;
//       throw ApiException('Unexpected error: $e');
//     }
//   }

//   Future<http.Response> _sendRequest(
//     String method,
//     String endpoint, {
//     Map<String, dynamic>? body,
//     bool retrying = false,
//   }) async {
//     final accessToken = await _getAccessToken();

//     final headers = {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//       if (accessToken != null) 'Authorization': 'Bearer $accessToken',
//     };

//     final uri = Uri.parse('$baseUrl$endpoint');
//     final startTime = DateTime.now();

//     _logRequest(method, uri, headers, body);

//     late http.Response response;

//     switch (method) {
//       case 'GET':
//         response = await _client.get(uri, headers: headers);
//         break;
//       case 'POST':
//         response = await _client.post(
//           uri,
//           headers: headers,
//           body: body != null ? jsonEncode(body) : null,
//         );
//         break;
//       case 'DELETE':
//         response = await _client.delete(uri, headers: headers);
//         break;
//       default:
//         throw ApiException('Unsupported HTTP method');
//     }

//     final duration = DateTime.now().difference(startTime).inMilliseconds;
//     _logResponse(method, uri, response, duration);

//     if (response.statusCode == 401 && !retrying) {
//       final refreshed = await _refreshToken();
//       if (refreshed) {
//         return _sendRequest(method, endpoint, body: body, retrying: true);
//       } else {
//         await clearTokens();
//         if (!ignoreSessionExpired) {
//           onSessionExpired?.call();
//         }
//         throw UnauthorizedException('Session expired. Please login again.');
//       }
//     }

//     if (response.statusCode >= 500) {
//       throw ServerException(
//         'Server error. Please try again later.',
//         statusCode: response.statusCode,
//       );
//     }

//     if (response.statusCode >= 400) {
//       _handleClientError(response);
//     }

//     return response;
//   }

//   Map<String, dynamic> _handleClientError(http.Response response) {
//     String message = 'Request failed';
//     Map<String, dynamic> errors = {};

//     try {
//       final decoded = jsonDecode(response.body);
//       if (decoded is Map<String, dynamic>) {
//         message = decoded['message'] ?? message;
//         errors = decoded['errors'] ?? {};
//       }
//     } catch (_) {}

//     if (response.statusCode == 422 || errors.isNotEmpty) {
//       throw ValidationException(message, errors);
//     }

//     throw ApiException(message, statusCode: response.statusCode);
//   }

//   // ================= REFRESH TOKEN =================

//   Future<bool> _refreshToken() async {
//     final refreshToken = await _getRefreshToken();
//     if (refreshToken == null) return false;

//     _log('Attempting to refresh token with refresh token: $refreshToken');

//     try {
//       final response = await _client.post(
//         Uri.parse('$baseUrl/auth/refresh'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'refresh_token': refreshToken}),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         await saveTokens(
//           accessToken: data['access_token'],
//           refreshToken: data['refresh_token'],
//         );
//         _log('Token refreshed successfully');
//         return true;
//       } else if (response.statusCode == 401) {
//         _log(
//           'Refresh token rejected by server (401 Unauthorized). Body: ${response.body}',
//         );
//       } else {
//         _log(
//           'Token refresh failed with status code: ${response.statusCode}. Body: ${response.body}',
//         );
//       }
//     } catch (e) {
//       _log('Token refresh failed with exception: $e');
//     }

//     return false;
//   }

//   // ================= PUBLIC METHODS =================

//   Future<http.Response> _authenticatedGet(
//     Uri uri, {
//     bool retrying = false,
//   }) async {
//     final accessToken = await _getAccessToken();

//     final headers = {
//       if (accessToken != null) 'Authorization': 'Bearer $accessToken',
//     };

//     final startTime = DateTime.now();
//     _logRequest('GET', uri, headers, null);

//     late http.Response response;
//     response = await _client.get(uri, headers: headers);

//     final duration = DateTime.now().difference(startTime).inMilliseconds;
//     _logResponse('GET', uri, response, duration);

//     if (response.statusCode == 401 && !retrying) {
//       final refreshed = await _refreshToken();
//       if (refreshed) {
//         return _authenticatedGet(uri, retrying: true);
//       } else {
//         await clearTokens();
//         if (!ignoreSessionExpired) {
//           onSessionExpired?.call();
//         }
//         throw UnauthorizedException('Session expired. Please login again.');
//       }
//     }

//     if (response.statusCode >= 500) {
//       throw ServerException(
//         'Server error. Please try again later.',
//         statusCode: response.statusCode,
//       );
//     }

//     if (response.statusCode >= 400) {
//       _handleClientError(response);
//     }

//     return response;
//   }

//   Future<T> get<T>(
//     String endpoint,
//     T Function(Map<String, dynamic>) fromJson,
//   ) async {
//     return _safeRequest(() async {
//       final response = await _sendRequest('GET', endpoint);
//       return fromJson(jsonDecode(response.body));
//     });
//   }

//   Future<T> post<T>(
//     String endpoint,
//     Map<String, dynamic> body,
//     T Function(Map<String, dynamic>) fromJson,
//   ) async {
//     return _safeRequest(() async {
//       final response = await _sendRequest('POST', endpoint, body: body);
//       return fromJson(jsonDecode(response.body));
//     });
//   }

//   Future<void> delete(String endpoint) async {
//     await _safeRequest(() async {
//       await _sendRequest('DELETE', endpoint);
//     });
//   }

//   Future<Uint8List> getBytes(String url) async {
//     return _safeRequest(() async {
//       final response = await _authenticatedGet(Uri.parse(url));
//       return response.bodyBytes;
//     });
//   }

//   Future<Map<String, dynamic>> postMultipart(
//     String endpoint, {
//     Map<String, String>? fields,
//     List<http.MultipartFile>? files,
//   }) async {
//     return _safeRequest(() async {
//       final accessToken = await _getAccessToken();
//       final uri = Uri.parse('$baseUrl$endpoint');
//       final request = http.MultipartRequest('POST', uri)
//         ..headers.addAll({
//           'Accept': 'application/json',
//           if (accessToken != null) 'Authorization': 'Bearer $accessToken',
//         });

//       if (fields != null) {
//         request.fields.addAll(fields);
//       }
//       if (files != null) {
//         request.files.addAll(files);
//       }

//       final bodyDescription = {
//         'fields': fields,
//         'files': files?.map((f) => 'File: ${f.field} (${f.filename})').toList(),
//       };

//       final startTime = DateTime.now();
//       _logRequest('POST', uri, request.headers, bodyDescription);

//       final streamedResponse = await _client.send(request);
//       final response = await http.Response.fromStream(streamedResponse);

//       final duration = DateTime.now().difference(startTime).inMilliseconds;
//       _logResponse('POST', uri, response, duration);

//       if (response.statusCode >= 500) {
//         throw ServerException(
//           'Server error. Please try again later.',
//           statusCode: response.statusCode,
//         );
//       }

//       if (response.statusCode >= 400) {
//         _handleClientError(response);
//       }

//       return jsonDecode(response.body);
//     });
//   }

//   Future<List<Contract>> fetchContracts({String? status}) async {
//     String endpoint = '/contracts';
//     if (status != null) {
//       endpoint += '?status=$status';
//     }
//     return get<List<Contract>>(endpoint, (json) {
//       if (json['data'] is List) {
//         return (json['data'] as List)
//             .map((item) => Contract.fromJson(item as Map<String, dynamic>))
//             .toList();
//       }
//       return [];
//     });
//   }

//   Future<Contract> fetchContractById(String id) async {
//     return get<Contract>('/contracts/$id', (json) {
//       if (json['data'] is Map<String, dynamic>) {
//         return Contract.fromJson(json['data'] as Map<String, dynamic>);
//       }
//       return Contract.fromJson(json);
//     });
//   }

//   Future<Map<String, dynamic>> signContract(
//     String id,
//     Map<String, dynamic> data,
//   ) async {
//     return _safeRequest(() async {
//       final response = await _sendRequest(
//         'POST',
//         '/contracts/$id/sign',
//         body: data,
//       );
//       return jsonDecode(response.body);
//     });
//   }

//   Future<Map<String, dynamic>> rejectContract(String id, String reason) async {
//     return _safeRequest(() async {
//       final response = await _sendRequest(
//         'POST',
//         '/contracts/$id/reject',
//         body: {'reason': reason},
//       );
//       return jsonDecode(response.body);
//     });
//   }

//   Future<String?> getPublicToken() async {
//     return _getAccessToken();
//   }

//   /// Exposes the stored refresh token — used by biometric login flow.
//   Future<String?> getStoredRefreshToken() async {
//     return _getRefreshToken();
//   }

//   /// Calls /auth/refresh with the given [refreshToken] and saves new tokens.
//   /// Returns true on success.
//   Future<bool> refreshWithToken(String refreshToken) async {
//     try {
//       final response = await _client.post(
//         Uri.parse('$baseUrl/auth/refresh'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'refresh_token': refreshToken}),
//       );

//       _log('refreshWithToken status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         await saveTokens(
//           accessToken: data['access_token'],
//           refreshToken: data['refresh_token'] ?? refreshToken,
//         );
//         _log('Token refreshed via biometric successfully');
//         return true;
//       }
//       return false;
//     } catch (e) {
//       _log('refreshWithToken failed: $e');
//       return false;
//     }
//   }

//   Future<Map<String, dynamic>> uploadKycDocuments({
//     required String endpoint,
//     required String requestId,
//     required String selfiePath,
//     required String idDocumentPath,
//     required String idDocumentType,
//   }) async {
//     return _safeRequest(() async {
//       final accessToken = await _getAccessToken();
//       final uri = Uri.parse('$baseUrl$endpoint');
//       final request = http.MultipartRequest('POST', uri)
//         ..headers.addAll({
//           'Accept': 'application/json',
//           if (accessToken != null) 'Authorization': 'Bearer $accessToken',
//         })
//         ..fields['request_id'] = requestId
//         ..fields['id_document_type'] = idDocumentType
//         ..files.add(await http.MultipartFile.fromPath('selfie', selfiePath))
//         ..files.add(
//           await http.MultipartFile.fromPath('id_document', idDocumentPath),
//         );

//       final bodyDescription = {
//         'fields': request.fields,
//         'files': request.files
//             .map((f) => 'File: ${f.field} (${f.filename})')
//             .toList(),
//       };

//       final startTime = DateTime.now();
//       _logRequest('POST', uri, request.headers, bodyDescription);

//       final streamedResponse = await _client.send(request);
//       final response = await http.Response.fromStream(streamedResponse);

//       final duration = DateTime.now().difference(startTime).inMilliseconds;
//       _logResponse('POST', uri, response, duration);

//       if (response.statusCode >= 500) {
//         throw ServerException(
//           'Server error. Please try again later.',
//           statusCode: response.statusCode,
//         );
//       }

//       if (response.statusCode >= 400) {
//         return _handleClientError(response);
//       }

//       return jsonDecode(response.body);
//     });
//   }
//   // ================= BIOMETRIC SESSION UNLOCK =================

//   /// Unlocks session using stored refresh token after biometric authentication
//   Future<bool> biometricUnlockSession() async {
//     final refreshToken = await _getRefreshToken();

//     if (refreshToken == null) {
//       _log('Biometric unlock failed: No refresh token stored.');
//       return false;
//     }

//     try {
//       final success = await refreshWithToken(refreshToken);

//       if (success) {
//         _log('Session unlocked successfully via biometric.');
//         return true;
//       }

//       _log('Biometric unlock failed: refresh token rejected.');
//       return false;
//     } catch (e) {
//       _log('Biometric unlock exception: $e');
//       return false;
//     }
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:bankid_app/core/utils/app_logger.dart';
import 'package:bankid_app/models/contract.dart';

/// =====================
/// EXCEPTIONS
/// =====================

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message) : super(statusCode: 401);
}

class ValidationException extends ApiException {
  final Map<String, dynamic> errors;

  ValidationException(super.message, this.errors) : super(statusCode: 422);
}

class ServerException extends ApiException {
  ServerException(super.message, {super.statusCode});
}

/// =====================
/// API SERVICE (PRODUCTION VERSION)
/// =====================

class ApiService {
  final String baseUrl;
  final http.Client _client;
  final FlutterSecureStorage _storage;
  final VoidCallback? onSessionExpired;

  bool ignoreSessionExpired = false;

  /// 🔒 prevents multiple refresh calls at once
  Completer<void>? _refreshCompleter;

  ApiService({
    required this.baseUrl,
    this.onSessionExpired,
    http.Client? client,
    FlutterSecureStorage? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  // =========================
  // STORAGE
  // =========================

  Future<String?> _getAccessToken() =>
      _storage.read(key: 'access_token');

  Future<String?> _getRefreshToken() =>
      _storage.read(key: 'refresh_token');

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  // =========================
  // LOGGING
  // =========================

  void _log(String msg) {
    if (kDebugMode) AppLogger.log('[ApiService] $msg');
  }

  // =========================
  // SAFE EXECUTOR (RETRY)
  // =========================

  Future<T> _safe<T>(Future<T> Function() task) async {
    int retries = 0;

    while (true) {
      try {
        return await task();
      } on SocketException {
        if (retries++ >= 2) {
          throw NetworkException('No internet connection');
        }
        await Future.delayed(const Duration(seconds: 2));
      } on TimeoutException {
        if (retries++ >= 2) {
          throw NetworkException('Request timeout');
        }
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException('Unexpected error: $e');
      }
    }
  }

  // =========================
  // HEADERS
  // =========================

  Future<Map<String, String>> _headers() async {
    final token = await _getAccessToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // =========================
  // CORE REQUEST
  // =========================

  Future<http.Response> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool retrying = false,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _headers();
    final start = DateTime.now();

    _log('➡️ $method $uri');

    http.Response response;

    switch (method) {
      case 'GET':
        response = await _client
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 30));
        break;

      case 'POST':
        response = await _client
            .post(uri, headers: headers, body: jsonEncode(body))
            .timeout(const Duration(seconds: 30));
        break;

      case 'DELETE':
        response = await _client
            .delete(uri, headers: headers)
            .timeout(const Duration(seconds: 30));
        break;

      default:
        throw ApiException('Unsupported method');
    }

    _log('⬅️ ${response.statusCode} (${DateTime.now().difference(start).inMilliseconds}ms)');

    // =========================
    // AUTH HANDLING (REFRESH)
    // =========================

    if (response.statusCode == 401 && !retrying) {
      final refreshed = await _refreshToken();

      if (refreshed) {
        return _request(method, endpoint, body: body, retrying: true);
      }

      await clearTokens();

      if (!ignoreSessionExpired) {
        onSessionExpired?.call();
      }

      throw UnauthorizedException('Session expired');
    }

    // =========================
    // SERVER ERROR
    // =========================

    if (response.statusCode >= 500) {
      throw ServerException('Server error', statusCode: response.statusCode);
    }

    // =========================
    // CLIENT ERROR
    // =========================

    if (response.statusCode >= 400) {
      _handleError(response);
    }

    return response;
  }

  // =========================
  // ERROR HANDLER
  // =========================

  void _handleError(http.Response response) {
    String message = 'Request failed';
    Map<String, dynamic> errors = {};

    try {
      final data = jsonDecode(response.body);
      message = data['message'] ?? message;
      errors = data['errors'] ?? {};
    } catch (_) {}

    if (response.statusCode == 422 || errors.isNotEmpty) {
      throw ValidationException(message, errors);
    }

    throw ApiException(message, statusCode: response.statusCode);
  }

  // =========================
  // REFRESH TOKEN (LOCKED)
  // =========================

  Future<bool> _refreshToken() async {
    if (_refreshCompleter != null) {
      await _refreshCompleter!.future;
      return true;
    }

    _refreshCompleter = Completer();

    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _client.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        );

        _refreshCompleter!.complete();
        return true;
      }

      _refreshCompleter!.complete();
      return false;
    } catch (e) {
      _refreshCompleter?.completeError(e);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  // =========================
  // PUBLIC API METHODS
  // =========================

  Future<T> get<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    return _safe(() async {
      final res = await _request('GET', endpoint);
      return fromJson(jsonDecode(res.body));
    });
  }

  Future<T> post<T>(
    String endpoint,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    return _safe(() async {
      final res = await _request('POST', endpoint, body: body);
      return fromJson(jsonDecode(res.body));
    });
  }

  Future<void> delete(String endpoint) async {
    await _safe(() async {
      await _request('DELETE', endpoint);
    });
  }

  Future<Uint8List> getBytes(String url) async {
    return _safe(() async {
      final res = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));

      return res.bodyBytes;
    });
  }

  // =========================
  // TOKEN HELPERS
  // =========================

  Future<String?> getPublicToken() => _getAccessToken();

  Future<String?> getStoredRefreshToken() => _getRefreshToken();

  Future<bool> refreshWithToken(String refreshToken) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'] ?? refreshToken,
        );
        return true;
      }
      return false;
    } catch (e) {
      _log('refreshWithToken failed: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
  }) async {
    return _safe(() async {
      final accessToken = await _getAccessToken();
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        });

      if (fields != null) request.fields.addAll(fields);
      if (files != null) request.files.addAll(files);

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          return postMultipart(endpoint, fields: fields, files: files);
        }
        await clearTokens();
        if (!ignoreSessionExpired) onSessionExpired?.call();
        throw UnauthorizedException('Session expired');
      }

      if (response.statusCode >= 500) {
        throw ServerException('Server error', statusCode: response.statusCode);
      }

      if (response.statusCode >= 400) {
        _handleError(response);
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    });
  }

  Future<List<Contract>> fetchContracts({String? status}) async {
    var endpoint = '/contracts';
    if (status != null) endpoint += '?status=$status';

    return get<List<Contract>>(endpoint, (json) {
      if (json['data'] is List) {
        return (json['data'] as List)
            .map((item) => Contract.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    });
  }

  Future<Contract> fetchContractById(String id) async {
    return get<Contract>('/contracts/$id', (json) {
      if (json['data'] is Map<String, dynamic>) {
        return Contract.fromJson(json['data'] as Map<String, dynamic>);
      }
      return Contract.fromJson(json);
    });
  }

  Future<Map<String, dynamic>> signContract(
    String id,
    Map<String, dynamic> data,
  ) async {
    return _safe(() async {
      final res = await _request('POST', '/contracts/$id/sign', body: data);
      return jsonDecode(res.body) as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> rejectContract(
    String id,
    String reason,
  ) async {
    return _safe(() async {
      final res = await _request(
        'POST',
        '/contracts/$id/reject',
        body: {'reason': reason},
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> uploadKycDocuments({
    required String endpoint,
    required String requestId,
    required String selfiePath,
    required String idDocumentPath,
    required String idDocumentType,
  }) async {
    return postMultipart(
      endpoint,
      fields: {
        'request_id': requestId,
        'id_document_type': idDocumentType,
      },
      files: [
        await http.MultipartFile.fromPath('selfie', selfiePath),
        await http.MultipartFile.fromPath('id_document', idDocumentPath),
      ],
    );
  }
}