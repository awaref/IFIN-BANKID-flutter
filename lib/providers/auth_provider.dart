import 'package:flutter/foundation.dart';
import 'package:bankid_app/services/auth_repository.dart';
import 'package:bankid_app/services/api_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;
  
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  bool _isNationalIdVerified = false;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? 
            AuthRepository(
              apiService: ApiService(baseUrl: 'http://10.0.2.2/api/v1'),
            );

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isNationalIdVerified => _isNationalIdVerified;
  String? _nationalId;
  String? get nationalId => _nationalId;
  String? _selectedPhoneNumber;
  String? get selectedPhoneNumber => _selectedPhoneNumber;
  String? _firstName;
  String? _lastName;
  String? _gender;
  String? _dateOfBirth;
  String? _nationality;
  String? _dateOfIssue;
  String? _dateOfExpiry;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get gender => _gender;
  String? get dateOfBirth => _dateOfBirth;
  String? get nationality => _nationality;
  String? get dateOfIssue => _dateOfIssue;
  String? get dateOfExpiry => _dateOfExpiry;
  String? _pin;
  String? get pin => _pin;
  String? _email;
  String? get email => _email;
  String? _username;
  String? get username => _username;
  String? _kycRequestId;
  String? get kycRequestId => _kycRequestId;
  bool _profileLoaded = false;
  bool get profileLoaded => _profileLoaded;

  Future<bool> checkNationalId(String nationalId) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final exists = await _authRepository.verifyNationalId(nationalId);
      _status = AuthStatus.initial;
      _isNationalIdVerified = exists;
      _nationalId = exists ? nationalId : null;
      notifyListeners();
      return exists;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithPassword(String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authRepository.loginWithPassword(password);
      _status = success ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
      return success;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithNationalId(String nationalId, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authRepository.loginWithNationalId(nationalId, password);
      _status = success ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
      return success;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
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

  Future<bool> registerUser(Map<String, dynamic> data) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authRepository.registerUser(data);
      _status = success ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
      return success;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void setPin(String pin) {
    _pin = pin;
    notifyListeners();
  }

  void setNationalId(String id) {
    _nationalId = id;
    notifyListeners();
  }
  
  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void reset() {
    _status = AuthStatus.initial;
    _errorMessage = null;
    _isNationalIdVerified = false;
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
  
  Future<void> logout() async {
     // Implement logout logic (clear token, etc.)
     _status = AuthStatus.unauthenticated;
     _isNationalIdVerified = false;
     notifyListeners();
  }

  Future<String?> initiateKyc({String? token}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final id = await _authRepository.initiateKyc(token: token);
      _kycRequestId = id;
      _status = AuthStatus.initial;
      notifyListeners();
      return id;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> loadCurrentUser() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = await _authRepository.fetchCurrentUser();
      if (data == null) {
        _status = AuthStatus.error;
        _errorMessage = 'Failed to load user';
        notifyListeners();
        return false;
      }
      _updateUserData(data);
      _profileLoaded = true;
      _status = AuthStatus.initial;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchKycRequest(String id) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = await _authRepository.getKycRequest(id);
      if (data == null) {
        _status = AuthStatus.error;
        _errorMessage = 'Failed to load KYC request';
        notifyListeners();
        return false;
      }
      _updateUserData(data);
      _status = AuthStatus.initial;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _updateUserData(Map<String, dynamic> data) {
    final String? fn = (data['first_name'] ?? data['firstName'])?.toString();
    final String? ln = (data['last_name'] ?? data['lastName'])?.toString();
    final String? g = (data['gender'])?.toString();
    final String? dob = (data['date_of_birth'] ?? data['dateOfBirth'] ?? data['dob'])?.toString();
    final String? nat = (data['nationality'])?.toString();
    final String? doi = (data['date_of_issue'] ?? data['dateOfIssue'])?.toString();
    final String? doe = (data['date_of_expiry'] ?? data['dateOfExpiry'])?.toString();
    final String? nid = (data['national_id'] ?? data['nationalId'])?.toString();
    final String? em = (data['email'])?.toString();
    _firstName = fn ?? _firstName;
    _lastName = ln ?? _lastName;
    _gender = g ?? _gender;
    _dateOfBirth = dob ?? _dateOfBirth;
    _nationality = nat ?? _nationality;
    _dateOfIssue = doi ?? _dateOfIssue;
    _dateOfExpiry = doe ?? _dateOfExpiry;
    _nationalId = nid ?? _nationalId;
    _email = em ?? _email;
  }
}
