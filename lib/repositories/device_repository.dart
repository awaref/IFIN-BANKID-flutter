import 'package:bankid_app/core/utils/app_logger.dart';
import 'package:bankid_app/services/device_api.dart';
import 'package:flutter/foundation.dart';

class DeviceRepository {
  final DeviceApi _deviceApi;
  bool _isRegisteredInSession = false;
  bool _isTrustedInSession = false;

  DeviceRepository({required DeviceApi deviceApi}) : _deviceApi = deviceApi;

  Future<void> registerDevice({
    required String authToken,
    VoidCallback? onUnauthorized,
  }) async {
    if (_isRegisteredInSession) {
      AppLogger.log(
        "Device already registered in this session. Skipping registration.",
      );
      return;
    }
    await _deviceApi.registerDevice(authToken: authToken);
    _isRegisteredInSession = true;
  }

  Future<bool> trustDevice({required String authToken}) async {
    if (_isTrustedInSession) {
      AppLogger.log("Device already trusted in this session. Skipping trust.");
      return true;
    }
    final ok = await _deviceApi.trustDevice(authToken: authToken);
    if (ok) _isTrustedInSession = true;
    return ok;
  }

  void resetRegistrationStatus() {
    _isRegisteredInSession = false;
    _isTrustedInSession = false;
  }
}
