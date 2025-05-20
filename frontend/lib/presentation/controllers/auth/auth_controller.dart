import 'package:flutter/material.dart';
import '../../../data/models/auth/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthController with ChangeNotifier {
  // ...existing code...
void setErrorMessage(String message) {
  _errorMessage = message; // Make sure you have a private field _errorMessage
  notifyListeners();
}
// ...existing code...
  // ...existing code...

// ...existing code...
  // ...existing code...
// ...existing code...
  AuthRepository _repository;
  UserModel? _currentUser;
  // ...existing code...
UserRole? _selectedRole;
UserRole? get selectedRole => _selectedRole;
void setRole(UserRole role) {
  _selectedRole = role;
  notifyListeners();
}

// ...existing code...
  bool _isLoading = false;
  // ...existing code...
String? _errorMessage;

String? get errorMessage => _errorMessage;
// ...existing code...
  bool _isPhoneLogin = false; // Added for toggling login/reset method

  AuthController(this._repository);

  void updateAuthRepo(AuthRepository repository) {
    if (_repository != repository) {
      _repository = repository;
      if (_currentUser != null) {
        initialize();
      }
    }
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  // Changed from error to errorMessage
  bool get isPhoneLogin => _isPhoneLogin;

  Future<void> initialize() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _repository.getCurrentUser();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String emailOrPhone,
    required String password,
    required bool isPhone,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _repository.login(
        emailOrPhone: emailOrPhone,
        password: password,
        isPhone: isPhone,
      );
      return true;
    } catch (e) {
      _errorMessage = _translateError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String fullName,
    required String emailOrPhone,
    required String password,
    required UserRole role,
    required bool isPhone,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _repository.register(
        fullName: fullName,
        emailOrPhone: emailOrPhone,
        password: password,
        role: role,
        isPhone: isPhone,
      );
      return true;
    } catch (e) {
      _errorMessage = _translateError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp({
    required String emailOrPhone,
    required String otp,
    required bool isPhone,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _repository.verifyOtp(
        emailOrPhone: emailOrPhone,
        otp: otp,
        isPhone: isPhone,
      );
      _currentUser = await _repository.getCurrentUser();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _translateError(e.toString());
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestPasswordReset({
    required String emailOrPhone,
    required bool isPhone,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.requestPasswordReset(
        emailOrPhone: emailOrPhone,
        isPhone: isPhone,
      );
    } catch (e) {
      _errorMessage = _translateError(e.toString());
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword({
    required String emailOrPhone,
    required String newPassword,
    required bool isPhone,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.resetPassword(
        emailOrPhone: emailOrPhone,
        newPassword: newPassword,
        isPhone: isPhone,
      );
      _currentUser = await _repository.getCurrentUser();
    } catch (e) {
      _errorMessage = _translateError(e.toString());
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _repository.logout();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleLoginMethod() {
    _isPhoneLogin = !_isPhoneLogin;
    notifyListeners();
  }

  String _translateError(String error) {
    if (error.contains('invalid login credentials')) {
      return 'Barua pepe/namba ya simu au nenosiri si sahihi';
    }
    if (error.contains('phone already registered')) {
      return 'Namba ya simu tayari imesajiliwa';
    }
    if (error.contains('email already registered')) {
      return 'Barua pepe tayari imesajiliwa';
    }
    if (error.contains('user not found')) {
      return 'Akaunti haipatikani';
    }
    if (error.contains('invalid OTP')) {
      return 'Msimbo wa OTP si sahihi';
    }
    return error;
  }
}
