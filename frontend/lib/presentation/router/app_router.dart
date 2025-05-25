import 'package:flutter/material.dart';
import 'package:frontend/presentation/views/home/home_screen.dart';

import '../../presentation/views/auth/forgot_password_screen.dart';
import '../../presentation/views/auth/login_screen.dart';
import '../../presentation/views/auth/otp_screen.dart';
import '../../presentation/views/auth/register_screen.dart';
import '../../presentation/views/auth/welcome_screen.dart';
import 'route_names.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case RouteNames.register:
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case RouteNames.forgotPassword:
        return MaterialPageRoute(builder: (_) => ForgotPasswordScreen());
      case RouteNames.otp:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null) {
          return _errorRoute('OTP Screen requires emailOrPhone and isPhoneVerification arguments');
        }
        return MaterialPageRoute(
          builder: (_) => OtpScreen(
            emailOrPhone: args['emailOrPhone'] as String,
            isPhoneVerification: args['isPhoneVerification'] as bool,
            isPasswordReset: args['isPasswordReset'] as bool? ?? false,
          ),
        );
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return _errorRoute('No route defined for ${settings.name}');
    }
  }

  static MaterialPageRoute _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(message),
        ),
      ),
    );
  }
}