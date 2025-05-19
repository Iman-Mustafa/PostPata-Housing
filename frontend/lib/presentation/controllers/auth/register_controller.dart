// lib/presentation/controllers/auth/register_controller.dart
import 'package:flutter/material.dart';
import '../../../data/models/auth/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

class RegisterController with ChangeNotifier {
  final AuthRepository _repository;
  bool _isLoading = false;
  bool _isPhoneRegistration = true;
  UserRole _selectedRole = UserRole.tenant;
  String? _errorMessage; // Changed from _error to _errorMessage for consistency

  RegisterController(this._repository);

  bool get isLoading => _isLoading;
  bool get isPhoneRegistration => _isPhoneRegistration;
  UserRole get selectedRole => _selectedRole;
  String? get errorMessage => _errorMessage; // Changed to match your widget's expectation

  void toggleRegistrationMethod() {
    _isPhoneRegistration = !_isPhoneRegistration;
    _errorMessage = null;
    notifyListeners();
  }

  void setRole(UserRole role) {
    _selectedRole = role;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String? _validateInputs({
    required String fullName,
    required String emailOrPhone,
    required String password,
  }) {
    if (fullName.isEmpty) return 'Full name is required';
    if (emailOrPhone.isEmpty) {
      return _isPhoneRegistration 
          ? 'Phone number is required' 
          : 'Email is required';
    }
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<bool> register({
    required String fullName,
    required String emailOrPhone,
    required String password,
    required BuildContext context, // Added context parameter
  }) async {
    // First validate inputs
    _errorMessage = _validateInputs(
      fullName: fullName,
      emailOrPhone: emailOrPhone,
      password: password,
    );
    
    if (_errorMessage != null) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.register(
        fullName: fullName,
        emailOrPhone: emailOrPhone,
        password: password,
        role: _selectedRole,
        isPhone: _isPhoneRegistration,
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

  String _translateError(String error) {
    if (error.contains('invalid login credentials')) {
      return 'Invalid email/phone or password';
    }
    if (error.contains('phone already registered')) {
      return 'Phone number already registered';
    }
    if (error.contains('email already registered')) {
      return 'Email already registered';
    }
    if (error.contains('weak password')) {
      return 'Password is too weak';
    }
    return 'Registration failed. Please try again.';
  }
}