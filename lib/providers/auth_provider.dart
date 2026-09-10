import 'package:flutter/foundation.dart';
import 'package:bankid_app/services/auth_repository.dart';
import 'package:bankid_app/repositories/device_repository.dart';
import 'package:bankid_app/services/api_service.dart';
import 'package:bankid_app/services/biometric_service.dart';
import 'package:bankid_app/config.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;
  final DeviceRepository _deviceRepository;

  AuthProvider(
    this._deviceRepository, {
    AuthRepository? authRepository,
  }) : _authRepository = authRepository ??
            AuthRepository(
              apiService: ApiService(baseUrl: AppConfig.baseUrl),
            );

  AuthRepository get authRepository => _authRepository;

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  bool _isNationalIdVerified = false;
  bool _profileLoaded = false;

  String? _nationalId;
  String? _selectedPhoneNumber;
  String? _firstName;
  String? _lastName;
  String? _gender;
  String? _dateOfBirth;
  String? _nationality;
  String? _dateOfIssue;
  String? _dateOfExpiry;
  String? _pin;
  String? _email;
  String? _username;
  String? _kycRequestId;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isNationalIdVerified => _isNationalIdVerified;
  bool get profileLoaded => _profileLoaded;
  String? get nationalId => _nationalId;
  String? get selectedPhoneNumber => _selectedPhoneNumber;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get gender => _gender;
  String? get dateOfBirth => _dateOfBirth;
  String? get nationality => _nationality;
  String? get dateOfIssue => _dateOfIssue;
  String? get dateOfExpiry => _dateOfExpiry;
  String? get pin => _pin;
  String? get email => _email;
  String? get username => _username;
  String? get kycRequestId => _kycRequestId;

  void _setState(AuthStatus status, {String? error}) {
    _status = status;
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> _registerDeviceIfNeeded() async {
    final token = await _authRepository.getToken();
    if (token == null) return;

    await _deviceRepository.registerDevice(authToken: token);
  }

  /// Register then trust the device (after PIN / biometric enrollment).
  Future<void> trustDeviceIfNeeded() async {
    final token = await _authRepository.getToken();
    if (token == null) return;

    await _deviceRepository.registerDevice(authToken: token);
    await _deviceRepository.trustDevice(authToken: token);
  }

  /// On session restore: trust if PIN or biometric is already enrolled.
  Future<void> _trustIfAlreadyEnrolled() async {
    final token = await _authRepository.getToken();
    if (token == null) return;

    final hasPin = _pin != null && _pin!.isNotEmpty;
    final biometricEnabled =
        await BiometricService().isBiometricEnabledByUser();
    if (hasPin || biometricEnabled) {
      await _deviceRepository.trustDevice(authToken: token);
    }
  }

  Future<bool> checkNationalId(String nationalId) async {
    _setState(AuthStatus.loading);

    try {
      final exists = await _authRepository.verifyNationalId(nationalId);
      _nationalId = nationalId;
      _isNationalIdVerified = exists;
      _setState(AuthStatus.initial);
      return exists;
    } catch (e) {
      _setState(AuthStatus.error, error: e.toString());
      return false;
    }
  }

  Future<bool> loginWithPassword(String password) async {
    return _login(() => _authRepository.loginWithPassword(password));
  }

  Future<bool> loginWithNationalId(String nationalId, String password) async {
    return _login(
      () => _authRepository.loginWithNationalId(nationalId, password),
    );
  }

  Future<bool> _login(Future<void> Function() action) async {
    _setState(AuthStatus.loading);

    try {
      await action();
      await _registerDeviceIfNeeded();
      await _trustIfAlreadyEnrolled();
      _setState(AuthStatus.authenticated);
      return true;
    } on ApiException catch (e) {
      _setState(AuthStatus.error, error: e.message);
      return false;
    } catch (e) {
      _setState(AuthStatus.error, error: e.toString());
      return false;
    }
  }

  Future<bool> canLoginWithBiometric() =>
      _authRepository.canLoginWithBiometric();

  Future<bool> loginWithBiometric() async {
    _setState(AuthStatus.loading);

    try {
      final success = await _authRepository.loginWithBiometric();
      if (success) {
        await _registerDeviceIfNeeded();
        await _trustIfAlreadyEnrolled();
      }
      _setState(
        success ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      );
      return success;
    } catch (e) {
      _setState(AuthStatus.error, error: e.toString());
      return false;
    }
  }

  Future<bool> registerUser(Map<String, dynamic> data) async {
    _setState(AuthStatus.loading);

    try {
      final success = await _authRepository.registerUser(data);
      if (success) {
        await _registerDeviceIfNeeded();
        await _trustIfAlreadyEnrolled();
      }
      _setState(
        success ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      );
      return success;
    } catch (e) {
      _setState(AuthStatus.error, error: e.toString());
      return false;
    }
  }

  Future<bool> loadCurrentUser() async {
    _setState(AuthStatus.loading);

    try {
      final data = await _authRepository.fetchCurrentUser();
      _updateUserData(data['user'] ?? data);
      _profileLoaded = true;
      await _registerDeviceIfNeeded();
      await _trustIfAlreadyEnrolled();
      _setState(AuthStatus.initial);
      return true;
    } catch (e) {
      _setState(AuthStatus.error, error: e.toString());
      return false;
    }
  }

  Future<bool> fetchKycRequest(String id) async {
    _setState(AuthStatus.loading);

    try {
      final data = await _authRepository.getKycRequest(id);
      _updateUserData(data);
      _setState(AuthStatus.initial);
      return true;
    } catch (e) {
      _setState(AuthStatus.error, error: e.toString());
      return false;
    }
  }

  Future<String?> initiateKyc({String? token}) async {
    _setState(AuthStatus.loading);

    try {
      final id = await _authRepository.initiateKyc(token: token);
      _kycRequestId = id;
      _setState(AuthStatus.initial);
      return id;
    } catch (e) {
      _setState(AuthStatus.error, error: e.toString());
      return null;
    }
  }

  void setSelectedPhoneNumber(String? phone) {
    _selectedPhoneNumber = phone;
    notifyListeners();
  }

  void setIdentityData({
    String? firstName,
    String? lastName,
    String? gender,
    String? dateOfBirth,
    String? nationality,
    String? dateOfIssue,
    String? dateOfExpiry,
    String? email,
  }) {
    _firstName = firstName ?? _firstName;
    _lastName = lastName ?? _lastName;
    _gender = gender ?? _gender;
    _dateOfBirth = dateOfBirth ?? _dateOfBirth;
    _nationality = nationality ?? _nationality;
    _dateOfIssue = dateOfIssue ?? _dateOfIssue;
    _dateOfExpiry = dateOfExpiry ?? _dateOfExpiry;
    _email = email ?? _email;
    notifyListeners();
  }

  void setPin(String pin) {
    _pin = pin;
    notifyListeners();
    // Fire-and-forget trust after local PIN enrollment
    trustDeviceIfNeeded();
  }

  void setNationalId(String id) {
    _nationalId = id;
    notifyListeners();
  }

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authRepository.deleteToken();
    _deviceRepository.resetRegistrationStatus();
    _setState(AuthStatus.unauthenticated);
    _isNationalIdVerified = false;
    _profileLoaded = false;
    _nationalId = null;
    _selectedPhoneNumber = null;
    _firstName = null;
    _lastName = null;
    _gender = null;
    _dateOfBirth = null;
    _nationality = null;
    _dateOfIssue = null;
    _dateOfExpiry = null;
    _pin = null;
    _email = null;
    _username = null;
    _kycRequestId = null;
  }

  void reset() {
    _status = AuthStatus.initial;
    _errorMessage = null;
    _isNationalIdVerified = false;
    _profileLoaded = false;
    _nationalId = null;
    _selectedPhoneNumber = null;
    _firstName = null;
    _lastName = null;
    _gender = null;
    _dateOfBirth = null;
    _nationality = null;
    _dateOfIssue = null;
    _dateOfExpiry = null;
    _pin = null;
    _email = null;
    _username = null;
    _kycRequestId = null;
    notifyListeners();
  }

  void _updateUserData(Map<String, dynamic> data) {
    _firstName =
        (data['first_name'] ?? data['firstName'])?.toString() ?? _firstName;
    _lastName = (data['last_name'] ?? data['lastName'])?.toString() ?? _lastName;
    _gender = data['gender']?.toString() ?? _gender;
    _dateOfBirth =
        (data['date_of_birth'] ?? data['dateOfBirth'] ?? data['dob'])
                ?.toString() ??
            _dateOfBirth;
    _nationality = data['nationality']?.toString() ?? _nationality;
    _dateOfIssue =
        (data['date_of_issue'] ?? data['dateOfIssue'])?.toString() ??
            _dateOfIssue;
    _dateOfExpiry =
        (data['date_of_expiry'] ?? data['dateOfExpiry'])?.toString() ??
            _dateOfExpiry;
    _nationalId =
        (data['national_id'] ?? data['nationalId'])?.toString() ?? _nationalId;
    _email = data['email']?.toString() ?? _email;
  }
}
