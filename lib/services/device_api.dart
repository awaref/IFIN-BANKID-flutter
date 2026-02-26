import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bankid_app/services/device_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Import for VoidCallback

import 'package:bankid_app/config.dart';

class DeviceApi {
  final DeviceService _deviceService = DeviceService();
  final String _baseUrl = AppConfig.baseUrl;
  final VoidCallback? onUnauthorized;

  DeviceApi({this.onUnauthorized});Future<void> registerDevice({
    required String authToken,
  }) async {
    final deviceId = await _deviceService.getDeviceId();
    final pushToken = await _deviceService.getFcmToken();
    final appVersion = await _deviceService.getAppVersion();
    final deviceModel = await _deviceService.getDeviceModel();
    final deviceName = await _deviceService.getDeviceName();

    if (pushToken == null) {
      debugPrint("FCM push token is null. Device registration skipped. Will retry later.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/devices/register'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "device_id": deviceId,
          "device_name": deviceName,
          "platform": Platform.isAndroid ? "android" : "ios",
        "push_token": pushToken,
        "app_version": appVersion,
        "device_model": deviceModel,
      }),
      );

      if (response.statusCode == 201) {
        debugPrint("Device registered successfully.");
      } else if (response.statusCode == 401) {
        debugPrint("Device registration failed: Unauthorized (401). Force logging out.");
        onUnauthorized?.call();
      } else if (response.statusCode == 422) {
        debugPrint("Device registration failed: Validation error (422) - ${response.body}");
      } else {
        debugPrint("Device registration failed: Unexpected error ${response.statusCode} - ${response.body}");
      }
    } on SocketException {
      debugPrint("Device registration failed: No internet connection. Will retry later.");
    } catch (e) {
      debugPrint("Device registration failed: An unexpected error occurred - $e");
    }
  }
}