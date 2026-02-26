import 'package:bankid_app/config.dart';
import 'package:flutter/foundation.dart';

enum SignatureType { text, imageUpload, imageHandwriting, svg }

class SignatureItem {
  final String id;
  final String name;
  final SignatureType type;
  final String? textValue;
  final String? imageUrl;
  final String? filePath; // Local path if available
  final bool isDefault;
  final DateTime createdAt;

  SignatureItem({
    required this.id,
    required this.name,
    required this.type,
    this.textValue,
    this.imageUrl,
    this.filePath,
    this.isDefault = false,
    required this.createdAt,
  });

  SignatureItem copyWith({
    String? id,
    String? name,
    SignatureType? type,
    String? textValue,
    String? imageUrl,
    String? filePath,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return SignatureItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      textValue: textValue ?? this.textValue,
      imageUrl: imageUrl ?? this.imageUrl,
      filePath: filePath ?? this.filePath,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'text_value': textValue,
        'image_url': imageUrl,
        'file_path': filePath,
        'is_default': isDefault,
        'created_at': createdAt.toIso8601String(),
      };

  static SignatureItem fromJson(Map<String, dynamic> json) {
    try {
      String? imageUrl = json['image_url'] ?? json['imageUrl'] ?? json['image_path'] ?? json['image_data'];
      
      // If imageUrl is a raw base64 string (no data: prefix but very long), add the prefix
      if (imageUrl != null && !imageUrl.startsWith('http') && !imageUrl.startsWith('data:') && imageUrl.length > 500) {
        imageUrl = 'data:image/png;base64,$imageUrl';
      }
      
      if (imageUrl != null && !imageUrl.startsWith('http') && !imageUrl.startsWith('data:')) {
        // Remove leading slash if present to avoid double slashes
        var cleanPath = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
        
        // If path starts with public/, remove it as storage link usually points to storage/app/public
        if (cleanPath.startsWith('public/')) {
          cleanPath = cleanPath.substring(7);
        }
        
        // Handle the case where the backend returns 'storage/signatures/...'
        if (cleanPath.startsWith('storage/')) {
          cleanPath = cleanPath.substring(8);
        }

        // If the clean path doesn't start with 'signatures/' and isn't a direct file name,
        // it might be a raw path from the backend that needs to be prefixed correctly.
        // However, usually Laravel returns paths relative to storage/app/public.
        
        imageUrl = '${AppConfig.storageUrl}/$cleanPath';
        
        // Final fallback: if there's still a double /storage/ in the URL, clean it up
        if (imageUrl.contains('/storage/storage/')) {
          imageUrl = imageUrl.replaceFirst('/storage/storage/', '/storage/');
        }
      }

      // Debugging print to help identify image loading issues
      debugPrint('DEBUG: SignatureItem fromJson - id: ${json['id']}, type: ${json['type']}, imageUrl: $imageUrl');

      return SignatureItem(
        id: json['id'].toString(),
        name: json['name'] ?? json['title'] ?? '',
        type: SignatureType.values.firstWhere(
          (e) => e.name == (json['type'] ?? 'imageUpload'),
          orElse: () {
            if (json['type'] == 'image_upload') return SignatureType.imageUpload;
            if (json['type'] == 'image_handwriting') return SignatureType.imageHandwriting;
            return SignatureType.imageUpload;
          },
        ),
        textValue: json['text_value'] ?? json['textValue'],
        imageUrl: imageUrl,
        filePath: json['file_path'] ?? json['filePath'],
        isDefault: json['is_default'] == 1 || json['is_default'] == true || json['isDefault'] == true,
        createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      debugPrint('ERROR: Failed to parse SignatureItem: $e. JSON: $json');
      // Return a dummy item so the list doesn't break
      return SignatureItem(
        id: 'error',
        name: 'Error Parsing',
        type: SignatureType.text,
        textValue: 'Error',
        createdAt: DateTime.now(),
      );
    }
  }
}
