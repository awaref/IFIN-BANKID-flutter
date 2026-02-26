import 'dart:convert';
import 'dart:io';
import 'package:bankid_app/models/signature.dart';
import 'package:bankid_app/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SignatureService {
  final ApiService apiService;

  SignatureService({required this.apiService});

  Future<List<SignatureItem>> getSignatures({
    int page = 1,
    int perPage = 15,
  }) async {
    return apiService.get<List<SignatureItem>>(
      '/signatures?page=$page&per_page=$perPage',
      (json) {
        if (json['data'] is List) {
          return (json['data'] as List)
              .map((item) => SignatureItem.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  Future<SignatureItem?> getSignature(String id) async {
    try {
      final response = await apiService.get<Map<String, dynamic>>(
        '/signatures/$id',
        (json) => json,
      );
      final data = response['signature'] ?? response;
      return SignatureItem.fromJson(data);
    } catch (e) {
      debugPrint('ERROR: getSignature failed: $e');
      return null;
    }
  }

  Future<SignatureItem> createSignature({
    required String name,
    required String type,
    String? textValue,
    File? imageFile,
    String? filePath,
    bool isDefault = false,
  }) async {
    final Map<String, String> fields = {
      'name': name,
      'type': type,
      'is_default': isDefault ? '1' : '0',
    };

    if (type == 'text' && textValue != null) {
      fields['text_value'] = textValue;
    }

    final List<http.MultipartFile> files = [];
    if ((type == 'image_upload' || type == 'svg') && (imageFile != null || filePath != null)) {
      files.add(
        await http.MultipartFile.fromPath('image', imageFile?.path ?? filePath!),
      );
    } else if (type == 'image_handwriting' && (imageFile != null || filePath != null)) {
      // Backend expects image_data as a base64 string for handwriting signatures
      final file = imageFile ?? File(filePath!);
      final bytes = await file.readAsBytes();
      fields['image_data'] = 'data:image/png;base64,${base64Encode(bytes)}';
    }

    try {
      debugPrint('DEBUG: createSignature sending fields: $fields');
      final response = await apiService.postMultipart(
        '/signatures',
        fields: fields,
        files: files,
      );
      debugPrint('DEBUG: createSignature response: $response');

      final data = response['signature'] ?? response;
      return SignatureItem.fromJson(data);
    } catch (e) {
      debugPrint('ERROR: createSignature failed: $e');
      rethrow;
    }
  }

  Future<void> deleteSignature(String id) async {
    await apiService.delete('/signatures/$id');
  }

  Future<SignatureItem> setDefaultSignature(String id) async {
    final response = await apiService.post<Map<String, dynamic>>(
      '/signatures/$id/set-default',
      {}, // Empty body as per API expectation for setting default
      (json) => json,
    );
    final data = response['signature'] ?? response;
    return SignatureItem.fromJson(data);
  }
}
