import 'package:flutter/material.dart';
import '../../../data/models/auth/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/connectivity_service.dart';


class RegisterController with ChangeNotifier {
  // Dependencies
  final AuthRepository _repository;
  final ConnectivityService _connectivityService;

  // State
  bool _isLoading = false;
  bool _isPhoneRegistration = false;
  UserRole _selectedRole = UserRole.tenant;
  String? _errorMessage;
  bool _hasConnection = true;

  // Constructor
  RegisterController(this._repository, this._connectivityService) {
    _initConnectivityListener();
  }

  // Getters
  bool get isLoading => _isLoading;
  bool get isPhoneRegistration => _isPhoneRegistration;
  UserRole get selectedRole => _selectedRole;
  String? get errorMessage => _errorMessage;
  bool get hasConnection => _hasConnection;

  // Connectivity handling
  void _initConnectivityListener() {
    _connectivityService.onConnectivityChanged.listen((isConnected) {
      _hasConnection = isConnected;
      notifyListeners();
    });
  }

  // UI Methods
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

  // Validation Methods
  String? _validateInputs({
    required String fullName,
    required String emailOrPhone,
    required String password,
  }) {
    // ...existing validation code...
    if (fullName.isEmpty) return 'Full name is required';
    if (fullName.length < 3) return 'Name must be at least 3 characters';

    if (emailOrPhone.isEmpty) {
      return _isPhoneRegistration
          ? 'Phone number is required'
          : 'Email is required';
    }

    if (_isPhoneRegistration) {
      if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(emailOrPhone)) {
        return 'Enter a valid phone number (e.g. +1234567890)';
      }
    } else {
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailOrPhone)) {
        return 'Enter a valid email address';
      }
    }

    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';

    return null;
  }

  Future<bool> register({
    required BuildContext context,
    required String fullName,
    required String emailOrPhone,
    required String password,
  }) async {
    if (_isLoading) return false;

    // Check connectivity first
    if (!await _connectivityService.isConnected()) {
      _errorMessage = 'No internet connection';
      notifyListeners();
      return false;
    }

    // Validate inputs
    _errorMessage = _validateInputs(
      fullName: fullName,
      emailOrPhone: emailOrPhone,
      password: password,
    );

    if (_errorMessage != null) {
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.register(
        fullName: fullName.trim(),
        emailOrPhone:
            _isPhoneRegistration
                ? _formatPhoneNumber(emailOrPhone.trim())
                : emailOrPhone.trim().toLowerCase(),
        password: password,
        role: _selectedRole,
        isPhone: _isPhoneRegistration,
      );

      if (!context.mounted) return false;

      // Navigate to OTP verification if needed
      if (!user.isVerified) {
        Navigator.pushNamed(
          context,
          'otp',
          arguments: {
            'isPhone': _isPhoneRegistration,
            'emailOrPhone': emailOrPhone.trim(),
          },
        );
      }

      return true;
    } catch (e) {
      _errorMessage = _translateError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper Methods
  String _formatPhoneNumber(String phone) {
    if (!phone.startsWith('+')) {
      return '+255${phone.replaceAll(RegExp(r'[^\d]'), '')}'; // Tanzania code
    }
    return phone;
  }

  String _translateError(String error) {
    error = error.toLowerCase();

    // ...existing error translation code...
    if (error.contains('already registered')) {
      return _isPhoneRegistration
          ? 'Phone number already in use'
          : 'Email already in use';
    }
    if (error.contains('invalid phone')) {
      return 'Invalid phone number format';
    }
    if (error.contains('invalid email')) {
      return 'Invalid email format';
    }
    if (error.contains('password')) {
      return 'Password must be stronger (min 6 chars)';
    }
    if (error.contains('network')) {
      return 'Network error. Please check your connection';
    }
    return 'Registration failed. Please try again.';
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}