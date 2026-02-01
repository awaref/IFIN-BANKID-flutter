import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Represents the result of a Malaa phone number lookup.
class MalaaPhoneNumbersResult {
  final List<String> numbers;
  final String? error;
  final int? statusCode;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? dateOfBirth;
  final String? nationality;
  final String? dateOfIssue;
  final String? dateOfExpiry;
  final String? email;

  bool get isSuccess => error == null;

  const MalaaPhoneNumbersResult({
    required this.numbers,
    this.error,
    this.statusCode,
    this.firstName,
    this.lastName,
    this.gender,
    this.dateOfBirth,
    this.nationality,
    this.dateOfIssue,
    this.dateOfExpiry,
    this.email,
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
        final id = _extractIdentityFields(decoded);
        return MalaaPhoneNumbersResult(
          numbers: [],
          error: 'No numbers found',
          statusCode: response.statusCode,
          firstName: id['first_name'],
          lastName: id['last_name'],
          gender: id['gender'],
          dateOfBirth: id['date_of_birth'],
          nationality: id['nationality'],
          dateOfIssue: id['date_of_issue'],
          dateOfExpiry: id['date_of_expiry'],
          email: id['email'],
        );
      }

      final id = _extractIdentityFields(decoded);
      return MalaaPhoneNumbersResult(
        numbers: numbers,
        statusCode: response.statusCode,
        firstName: id['first_name'],
        lastName: id['last_name'],
        gender: id['gender'],
        dateOfBirth: id['date_of_birth'],
        nationality: id['nationality'],
        dateOfIssue: id['date_of_issue'],
        dateOfExpiry: id['date_of_expiry'],
        email: id['email'],
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

  Map<String, String?> _extractIdentityFields(dynamic json) {
    String? firstName;
    String? lastName;
    String? gender;
    String? dateOfBirth;
    String? nationality;
    String? dateOfIssue;
    String? dateOfExpiry;
    String? latinName;
    String? email;

    void consider(String key, dynamic value) {
      final k = key.toLowerCase();
      if (value == null) return;
      final v = value is String ? value.trim() : value.toString().trim();
      if (v.isEmpty) return;
      // Names: prefer explicit first/last; then Name_1_En/Name_2_En; capture latinName for fallback
      if ((k.contains('firstname') || k == 'first_name') && (firstName == null)) firstName = v;
      if ((k.contains('lastname') || k == 'last_name') && (lastName == null)) lastName = v;
      if (k == 'name_1_en' && (firstName == null)) firstName = v;
      if (k == 'name_2_en' && (lastName == null)) lastName = v;
      if (k == 'latinname' && latinName == null) latinName = v;
      // Gender: prefer English description, then Arabic description, then code/value
      if (k.contains('gender_desc_en')) {
        gender = v;
      } else if (k.contains('gender_desc_ar') && gender == null) {
        gender = v;
      } else if (k == 'gender' && gender == null) {
        gender = v;
      }
      if (dateOfBirth == null && (k.contains('dateofbirth') || k == 'dob' || k == 'date_of_birth')) dateOfBirth = v;
      // Nationality: prefer English description, then Arabic description, then code/value
      if (k.contains('nationality_desc_en')) {
        nationality = v;
      } else if (k.contains('nationality_desc_ar') && nationality == null) {
        nationality = v;
      } else if (k == 'nationality' && nationality == null) {
        nationality = v;
      } else if (k.contains('nationality_code') && nationality == null) {
        nationality = v;
      }
      if (dateOfIssue == null && (k.contains('issuedate') || k == 'date_of_issue')) dateOfIssue = v;
      if (dateOfExpiry == null && (k.contains('expirydate') || k == 'date_of_expiry')) dateOfExpiry = v;
      if (email == null && (k == 'email' || k.contains('emailaddress'))) email = v;
    }

    void walk(dynamic node) {
      if (node is Map) {
        node.forEach((key, value) {
          consider(key.toString(), value);
          walk(value);
        });
      } else if (node is List) {
        for (final item in node) {
          walk(item);
        }
      }
    }

    walk(json);
    // Fallback: split latinName into first/last if needed
    if ((firstName == null || lastName == null) && latinName != null) {
      final parts = latinName!.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
      if (parts.isNotEmpty && firstName == null) firstName = parts.first;
      if (parts.length > 1 && lastName == null) lastName = parts.sublist(1).join(' ');
    }
    return {
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'nationality': nationality,
      'date_of_issue': dateOfIssue,
      'date_of_expiry': dateOfExpiry,
      'email': email,
    };
  }
}
