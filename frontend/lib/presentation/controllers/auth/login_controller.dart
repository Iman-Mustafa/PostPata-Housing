import 'package:flutter/material.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../router/route_names.dart';

class LoginController with ChangeNotifier {
  final AuthRepository _authRepo;

  LoginController(this._authRepo);

  bool _isLoading = false;
  bool _isPhoneLogin = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isPhoneLogin => _isPhoneLogin;
  String? get errorMessage => _errorMessage;

  void toggleLoginMethod() {
    _isPhoneLogin = !_isPhoneLogin;
    notifyListeners();
  }

  Future<void> login({
    required String emailOrPhone,
    required String password,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authRepo.login(
        emailOrPhone: emailOrPhone,
        password: password,
        isPhone: _isPhoneLogin,
      );

      if (!user.isVerified) {
        Navigator.pushNamed(
          context,
          RouteNames.otp,
          arguments: {'isPhone': _isPhoneLogin, 'emailOrPhone': emailOrPhone},
        );
      } else {
        Navigator.pushReplacementNamed(context, RouteNames.home);
      }
        } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}