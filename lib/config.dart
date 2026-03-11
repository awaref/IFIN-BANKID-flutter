import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get _baseUrl {
    final url = dotenv.env['BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception(
        'BASE_URL not found in .env file. Please ensure .env exists and contains BASE_URL.',
      );
    }
    return url;
  }

  static String get baseUrl => '$_baseUrl/api/v1';
  static String get rootUrl => _baseUrl;
  static String get storageUrl => _baseUrl;
}
