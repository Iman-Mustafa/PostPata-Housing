import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/connectivity_banner.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../router/route_names.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}


class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailOrPhoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    super.dispose();
  }

  VoidCallback _getOnPressed(AuthController authController) {
  if (!authController.hasConnection || authController.isLoading) {
    return () {};
  } else {
    return () => _handleResetRequest(authController);
  }
}
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      authController.initialize();
    });
  }

  String? _validateInput(String? value, bool isPhone) {
    if (value == null || value.isEmpty) {
      return AppStrings.enterEmailOrPhone;
    }

    if (isPhone) {
      if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value)) {
        return AppStrings.invalidPhone;
      }
    } else {
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
        return AppStrings.invalidEmail;
      }
    }
    return null;
  }

  // ignore: unused_element
  Future<void> _handleResetRequest(AuthController authController) async {
    if (!_formKey.currentState!.validate()) return;

    final emailOrPhone = _emailOrPhoneController.text.trim();

    try {
      await authController.requestPasswordReset(
        emailOrPhone: emailOrPhone,
        isPhone: authController.isPhoneLogin,
      );

      if (!mounted) return;

      if (authController.errorMessage == null) {
        Navigator.pushNamed(
          context,
          RouteNames.otp,
          arguments: {
            'emailOrPhone': emailOrPhone,
            'isPhoneVerification': authController.isPhoneLogin,
          },
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.forgotPassword)),
      body: Column(
        children: [
          if (!authController.hasConnection) const ConnectivityBanner(),
          Expanded(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      AppStrings.forgotPasswordInstruction,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailOrPhoneController,
                      decoration: InputDecoration(
                        labelText:
                            authController.isPhoneLogin
                                ? AppStrings.phoneNumber
                                : AppStrings.email,
                        prefixIcon: Icon(
                          authController.isPhoneLogin
                              ? Icons.phone
                              : Icons.email,
                        ),
                        hintText:
                            authController.isPhoneLogin
                                ? 'e.g. +1234567890'
                                : 'e.g. user@example.com',
                      ),
                      keyboardType:
                          authController.isPhoneLogin
                              ? TextInputType.phone
                              : TextInputType.emailAddress,
                      validator:
                          (value) => _validateInput(
                            value,
                            authController.isPhoneLogin,
                          ),
                      enabled: !authController.isLoading,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          authController.isPhoneLogin
                              ? AppStrings.resetWithEmail
                              : AppStrings.resetWithPhone,
                        ),
                        Switch(
                          value: authController.isPhoneLogin,
                          onChanged:
                              authController.isLoading
                                  ? null
                                  : (_) {
                                    _emailOrPhoneController.clear();
                                    authController.toggleLoginMethod();
                                  },
                        ),
                      ],
                    ),
                    if (authController.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          authController.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    const Spacer(),
                    PrimaryButton(
                      text: AppStrings.sendOtp,
                      isLoading: authController.isLoading,
                      onPressed: _getOnPressed(authController),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed:
                          authController.isLoading
                              ? null
                              : () => Navigator.pushNamed(
                                context,
                                RouteNames.login,
                              ),
                      child: Text(AppStrings.backToLogin),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
