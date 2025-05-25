import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/data/services/connectivity_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../router/route_names.dart';

class LoginController with ChangeNotifier {
  // Dependencies
  final AuthRepository _authRepo;
  final ConnectivityService _connectivityService;

  // State variables
  bool _isLoading = false;
  bool _isPhoneLogin = false;
  String? _errorMessage;
  bool _hasConnection = true;
  StreamSubscription<bool>? _connectivitySubscription;

  // Constructor
  LoginController(this._authRepo, this._connectivityService) {
    _initConnectivityListener();
  }

  // Getters
  bool get isLoading => _isLoading;
  bool get isPhoneLogin => _isPhoneLogin;
  String? get errorMessage => _errorMessage;
  bool get hasConnection => _hasConnection;

  // Initialize connectivity listener
  void _initConnectivityListener() {
    _connectivitySubscription = _connectivityService
        .onConnectivityChanged
        .listen((isConnected) {
      _hasConnection = isConnected;
      notifyListeners();
    });
  }

  // UI Methods
  void toggleLoginMethod() {
    _isPhoneLogin = !_isPhoneLogin;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Authentication Methods
  Future<void> login({
    required String emailOrPhone,
    required String password,
    required BuildContext context,
  }) async {
    if (_isLoading) return;

    // Validate inputs
    if (emailOrPhone.trim().isEmpty || password.isEmpty) {
      _errorMessage = 'Please fill in all fields';
      notifyListeners();
      return;
    }

    // Check connectivity
    if (!await _connectivityService.isConnected()) {
      _errorMessage = 'No internet connection';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepo.login(
        emailOrPhone: emailOrPhone.trim(),
        password: password,
        isPhone: _isPhoneLogin,
      );

      // Handle verification status
      if (!context.mounted) return;
      
      if (!user.isVerified) {
        Navigator.pushNamed(
          context,
          RouteNames.otp,
          arguments: {
            'isPhone': _isPhoneLogin,
            'emailOrPhone': emailOrPhone.trim(),
          },
        );
      } else {
        Navigator.pushReplacementNamed(context, RouteNames.home);
      }
    } catch (e) {
      _errorMessage = _translateError(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Error translation
  String _translateError(String error) {
    if (error.contains('invalid login credentials')) {
      return 'Invalid email/phone or password';
    }
    if (error.contains('too many attempts')) {
      return 'Too many login attempts. Please try again later';
    }
    if (error.contains('network')) {
      return 'Connection error. Please check your internet';
    }
    if (error.contains('email already registered')) {
      return 'This email is already registered';
    }
    if (error.contains('phone already registered')) {
      return 'This phone number is already registered';
    }
    return 'An error occurred. Please try again';
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}