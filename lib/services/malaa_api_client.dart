import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Represents the result of a Malaa phone number lookup.
class MalaaPhoneNumbersResult {
  final List<String> numbers;
  final String? error;
  final int? statusCode;

  bool get isSuccess => error == null;

  const MalaaPhoneNumbersResult({
    required this.numbers,
    this.error,
    this.statusCode,
  });
}

/// Client for interacting with the Malaa eKYC API.
class MalaaApiClient {
  final http.Client _client;

  MalaaApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const int _int32Max = 2147483647;

  Future<MalaaPhoneNumbersResult> fetchPhoneNumbers({
    required String civilNumber,
  }) async {
    final cleaned = civilNumber.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length < 6) {
      return const MalaaPhoneNumbersResult(
        numbers: [],
        error: 'Invalid civil number',
      );
    }

    final parsed = int.tryParse(cleaned);
    if (parsed == null || parsed > _int32Max) {
      return const MalaaPhoneNumbersResult(
        numbers: [],
        error: 'Civil number exceeds Int32 range',
      );
    }

    final uri = Uri.parse(
      'http://bankadapter-oman.ifin-services.com/api/v2/Tayseer/MalaaEkyc',
    );

    final bodyMap = {
      'civilNumber': parsed,
      'mobileNumber': null,
      'mobileCheck': false,
      'companyName': null,
    };

    final body = jsonEncode(bodyMap);
    debugPrint('🔵 Malaa Request Body: $body');

    try {
      final response = await _client
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('🟢 Malaa HTTP Status: ${response.statusCode}');
      debugPrint('🔵 Response body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return MalaaPhoneNumbersResult(
          numbers: [],
          error: _extractApiError(response.body) ?? 'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
        debugPrint('🔵 First decode, type: ${decoded.runtimeType}');
        
        // Handle double-encoded JSON (response is a JSON string containing another JSON string)
        if (decoded is String) {
          debugPrint('🔵 Response is double-encoded, decoding again...');
          decoded = jsonDecode(decoded);
          debugPrint('🔵 Second decode, type: ${decoded.runtimeType}');
        }
        
        if (decoded is List && decoded.isNotEmpty) {
          debugPrint('🔵 List detected, taking first element');
          decoded = decoded[0];
        }
        
        debugPrint('🔵 Top-level keys: ${decoded is Map ? decoded.keys : "Not a map"}');

        if (decoded is! Map<String, dynamic>) {
          debugPrint('⚠ Response is not a Map, converting to empty map');
          decoded = <String, dynamic>{};
        }

        // 🔹 Safely decode EncryptObject
        decoded['Data'] ??= {};
        debugPrint('🔵 Data type: ${decoded['Data'].runtimeType}');
        debugPrint('🔵 Data keys: ${decoded['Data'] is Map ? decoded['Data'].keys : "Not a map"}');
        
        final encryptStr = decoded['Data']['EncryptObject'];
        debugPrint('🔵 EncryptObject type: ${encryptStr.runtimeType}');
        
        if (encryptStr != null) {
          debugPrint('🔵 EncryptObject first 200 chars: ${encryptStr.toString().substring(0, encryptStr.toString().length > 200 ? 200 : encryptStr.toString().length)}');
        }

        if (encryptStr is String && encryptStr.trim().isNotEmpty) {
          try {
            // First try normal decode
            decoded['Data']['EncryptObject'] = jsonDecode(encryptStr);
            debugPrint('✅ Successfully decoded EncryptObject');
          } catch (e) {
            debugPrint('⚠ Failed to decode EncryptObject (single-escaped): $e');
            // Sometimes it's double-escaped
            try {
              final doubleDecoded = jsonDecode(encryptStr);
              if (doubleDecoded is String) {
                decoded['Data']['EncryptObject'] = jsonDecode(doubleDecoded);
                debugPrint('✅ Successfully decoded double-escaped EncryptObject');
              }
            } catch (e2) {
              debugPrint('⚠ Failed to decode EncryptObject (double-escaped): $e2');
              decoded['Data']['EncryptObject'] = {};
            }
          }
        } else {
          debugPrint('⚠ EncryptObject is not a valid string');
          decoded['Data']['EncryptObject'] = {};
        }
      } catch (e) {
        debugPrint('⚠ JSON Decoding Error: $e');
        return MalaaPhoneNumbersResult(
          numbers: [],
          error: 'Invalid response format',
          statusCode: response.statusCode,
        );
      }

      // API returned success:false
      if (decoded['success'] == false) {
        return MalaaPhoneNumbersResult(
          numbers: [],
          error: decoded['message']?.toString() ?? 'Business error',
          statusCode: response.statusCode,
        );
      }

      // 🔹 Extract mobile numbers from both Data and EncryptObject
      debugPrint('🔵 Starting extraction from entire response...');
      final allNumbers = _extractMobileNumbers(decoded);
      debugPrint('🔵 All numbers found: $allNumbers');
      
      debugPrint('🔵 Starting extraction from Data...');
      final dataNumbers = _extractMobileNumbers(decoded['Data']);
      debugPrint('🔵 Data numbers: $dataNumbers');
      
      debugPrint('🔵 Starting extraction from EncryptObject...');
      final encryptNumbers = _extractMobileNumbers(decoded['Data']['EncryptObject']);
      debugPrint('🔵 EncryptObject numbers: $encryptNumbers');
      
      final numbers = <String>{
        ...allNumbers,
        ...dataNumbers,
        ...encryptNumbers,
      }.toList();

      debugPrint('🟢 Found ${numbers.length} mobile numbers: $numbers');

      if (numbers.isEmpty) {
        return MalaaPhoneNumbersResult(
          numbers: [],
          error: 'No numbers found',
          statusCode: response.statusCode,
        );
      }

      return MalaaPhoneNumbersResult(
        numbers: numbers,
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      return const MalaaPhoneNumbersResult(
        numbers: [],
        error: 'Request timed out',
      );
    } on http.ClientException {
      return const MalaaPhoneNumbersResult(
        numbers: [],
        error: 'Network error',
      );
    } catch (e) {
      debugPrint('⚠ Unexpected Malaa Error: $e');
      return const MalaaPhoneNumbersResult(
        numbers: [],
        error: 'Unexpected error',
      );
    }
  }

  String? _extractApiError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        return decoded['message']?.toString() ??
            decoded['error']?.toString() ??
            decoded['detail']?.toString();
      }
    } catch (_) {}
    return null;
  }

  List<String> _extractMobileNumbers(dynamic json) {
    final result = <String>{};

    void walk(dynamic node) {
      if (node is Map) {
        node.forEach((key, value) {
          final k = key.toString().toLowerCase();

          // Match any field containing "mobilenumber" or "mobile_number"
          if ((k.contains('mobilenumber') || k.contains('mobile_number')) &&
              value is String &&
              value.trim().isNotEmpty) {
            result.add(value.trim());
            debugPrint('📱 Found mobile in key "$key": $value');
          }

          // Handle ExtraInfo array with EKYCMobileNumbers
          if (k == 'extrainfo' && value is List) {
            for (final item in value) {
              if (item is Map &&
                  item['Key'] == 'EKYCMobileNumbers' &&
                  item['Value'] is String) {
                final parts = (item['Value'] as String)
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty);
                result.addAll(parts);
                debugPrint('📱 Found numbers in ExtraInfo: $parts');
              }
            }
          }

          walk(value);
        });
      } else if (node is List) {
        for (var item in node) {
          walk(item);
        }
      }
    }

    walk(json);
    return result.toList();
  }
}