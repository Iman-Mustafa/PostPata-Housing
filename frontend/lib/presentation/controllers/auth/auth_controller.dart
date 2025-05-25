import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import '../../../data/models/auth/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/connectivity_service.dart';


class AuthController with ChangeNotifier {
  // Dependencies
  late AuthRepository _repository;
  late ApiService _apiService;
  late ConnectivityService _connectivityService;
  StreamSubscription<bool>? _connectivitySubscription;

  // State variables
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPhoneLogin = false;
  UserRole? _selectedRole;
  bool _hasConnection = true;
  bool _requiresVerification = false;

  // Constructor
  AuthController(
    this._repository,
    this._apiService,
    this._connectivityService,
  ) {
    _initConnectivityListener();
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPhoneLogin => _isPhoneLogin;
  UserRole? get selectedRole => _selectedRole;
  bool get hasConnection => _hasConnection;
  bool get requiresVerification => _requiresVerification;

  // Initialization
  Future<void> initialize() async {
    if (_isLoading) return;
    if (!await _validateOperation()) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _repository.getCurrentUser();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _translateError(e.toString());
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Authentication Methods
  Future<bool> login({
    required String emailOrPhone,
    required String password,
    required bool isPhone,
  }) async {
    if (_isLoading) return false;
    if (!await _validateOperation()) return false;

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
  if (!await _validateOperation()) return false;

  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final response = await _repository.register(
      fullName: fullName,
      emailOrPhone: emailOrPhone,
      password: password,
      role: role,
      isPhone: isPhone,
    );
    
    // Store the user if registration was successful
    _currentUser = response.user;
    // Update verification requirement
    _requiresVerification = response.requiresVerification;
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
    if (!await _validateOperation()) return;

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

  // Password Management
  Future<void> requestPasswordReset({
    required String emailOrPhone,
    required bool isPhone,
  }) async {
    if (_isLoading) return;
    if (!await _validateOperation()) return;

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
    if (!await _validateOperation()) return;

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

  // Session Management
  Future<void> logout() async {
    if (_isLoading) return;
    if (!await _validateOperation()) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _repository.logout();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _translateError(e.toString());
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // State Management Methods
  void setRole(UserRole role) {
    _selectedRole = role;
    notifyListeners();
  }

  void toggleLoginMethod() {
    _isPhoneLogin = !_isPhoneLogin;
    notifyListeners();
  }

  void setRequiresVerification(bool value) {
    if (_requiresVerification != value) {
      _requiresVerification = value;
      notifyListeners();
    }
  }

  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearErrorMessage() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Service Update Methods
  void updateAuthRepo(AuthRepository repository) {
    if (_repository != repository) {
      _repository = repository;
      if (_currentUser != null) {
        initialize();
      }
    }
  }

  void updateApiService(ApiService apiService) {
    if (_apiService != apiService) {
      _apiService = apiService;
      notifyListeners();
    }
  }

  void updateConnectivityService(ConnectivityService service) {
    if (_connectivityService != service) {
      _connectivityService = service;
      _connectivitySubscription?.cancel();
      _initConnectivityListener();
    }
  }

  // Connectivity Management
  void _initConnectivityListener() {
    _connectivitySubscription = _connectivityService.onConnectivityChanged
        .listen((isConnected) {
      _hasConnection = isConnected;
      notifyListeners();
    });
  }

  Future<bool> _validateOperation() async {
    if (!await _connectivityService.isConnected()) {
      _errorMessage = 'No internet connection';
      notifyListeners();
      return false;
    }
    return true;
  }

  // Error Handling
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
    if (error.contains('network')) {
      return 'Network error. Please check your connection';
    }
    return error;
  }

  // Cleanup
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}