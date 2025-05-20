// lib/presentation/controllers/auth/register_controller.dart
import 'package:flutter/material.dart';
import '../../../data/models/auth/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

class RegisterController with ChangeNotifier {
  final AuthRepository _repository;
  bool _isLoading = false;
  bool _isPhoneRegistration = false; // Default to email registration
  UserRole _selectedRole = UserRole.tenant;
  String? _errorMessage;

  RegisterController(this._repository);

  bool get isLoading => _isLoading;
  bool get isPhoneRegistration => _isPhoneRegistration;
  UserRole get selectedRole => _selectedRole;
  String? get errorMessage => _errorMessage;

  void toggleRegistrationMethod() {
    _isPhoneRegistration = !_isPhoneRegistration;
    _errorMessage = null; // Clear error when switching methods
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
    // Validate inputs first
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
        emailOrPhone: _isPhoneRegistration 
            ? _formatPhoneNumber(emailOrPhone.trim())
            : emailOrPhone.trim().toLowerCase(),
        password: password.trim(),
        role: _selectedRole,
        isPhone: _isPhoneRegistration,
      );
      
      // Optional: You might want to automatically log in the user after registration
      // await _repository.login(emailOrPhone: emailOrPhone, password: password);
      
      return true;
    } catch (e) {
      _errorMessage = _translateError(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _formatPhoneNumber(String phone) {
    // Ensure phone number starts with +
    if (!phone.startsWith('+')) {
      // Add default country code if missing - adjust as needed
      return '+1$phone'; // Default to US country code
    }
    return phone;
  }

  String _translateError(String error) {
    error = error.toLowerCase();
    
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
}