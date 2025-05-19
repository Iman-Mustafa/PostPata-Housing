// lib/presentation/controllers/auth/auth_controller.dart
import 'package:flutter/material.dart';
import '../../../data/models/auth/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthController with ChangeNotifier {
  AuthRepository _repository; // Changed from final to mutable
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthController(this._repository);

  // Add this method for ChangeNotifierProxyProvider
  void updateAuthRepo(AuthRepository repository) {
    if (_repository != repository) {
      _repository = repository;
      // You can add additional logic here if needed when repository changes
      // For example, re-initialize or reload user data:
      if (_currentUser != null) {
        initialize();
      }
    }
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    if (_isLoading) return; // Prevent duplicate initialization
    
    _isLoading = true;
    notifyListeners();
    
    try {
      _currentUser = await _repository.getCurrentUser();
      _error = null;
    } catch (e) {
      _error = e.toString();
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
    if (_isLoading) return false; // Prevent duplicate login attempts
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _repository.login(
        emailOrPhone: emailOrPhone,
        password: password,
        isPhone: isPhone,
      );
      return true;
    } catch (e) {
      _error = _translateError(e.toString());
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
    if (_isLoading) return false; // Prevent duplicate registration
    
    _isLoading = true;
    _error = null;
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
      _error = _translateError(e.toString());
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
    if (_isLoading) return; // Prevent duplicate verification
    
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.verifyOtp(
        emailOrPhone: emailOrPhone,
        otp: otp,
        isPhone: isPhone,
      );
      _currentUser = await _repository.getCurrentUser();
      _error = null;
    } catch (e) {
      _error = _translateError(e.toString());
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (_isLoading) return; // Prevent duplicate logout
    
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.logout();
      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    return error;
  }
}