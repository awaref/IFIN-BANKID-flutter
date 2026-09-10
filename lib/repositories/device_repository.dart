import 'package:bankid_app/core/utils/app_logger.dart';
import 'package:bankid_app/services/device_api.dart';
import 'package:flutter/foundation.dart'; // Required for VoidCallback

class DeviceRepository {
  final DeviceApi _deviceApi;
  bool _isRegisteredInSession = false;

  DeviceRepository({required DeviceApi deviceApi}) : _deviceApi = deviceApi;

  Future<void> registerDevice({required String authToken, VoidCallback? onUnauthorized}) async {
    if (_isRegisteredInSession) {
      AppLogger.log("Device already registered in this session. Skipping registration.");
      return;
    }
    await _deviceApi.registerDevice(authToken: authToken);
    _isRegisteredInSession = true;
  }

  void resetRegistrationStatus() {
    _isRegisteredInSession = false;
  }
}
