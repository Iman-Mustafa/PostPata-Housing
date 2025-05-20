import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../router/route_names.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final _emailOrPhoneController = TextEditingController();

  ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.forgotPassword)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              AppStrings.forgotPasswordInstruction,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailOrPhoneController,
              decoration: InputDecoration(
                labelText: authController.isPhoneLogin
                    ? AppStrings.phoneNumber
                    : AppStrings.email,
                prefixIcon: Icon(
                  authController.isPhoneLogin ? Icons.phone : Icons.email,
                ),
                hintText: authController.isPhoneLogin
                    ? 'e.g. +1234567890'
                    : 'e.g. user@example.com',
              ),
              keyboardType: authController.isPhoneLogin
                  ? TextInputType.phone
                  : TextInputType.emailAddress,
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
                  onChanged: (_) {
                    _emailOrPhoneController.clear();
                    authController.toggleLoginMethod();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
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
              onPressed: () async {
                final emailOrPhone = _emailOrPhoneController.text;
                if (emailOrPhone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppStrings.enterEmailOrPhone)),
                  );
                  return;
                }
                await authController.requestPasswordReset(
                  emailOrPhone: emailOrPhone,
                  isPhone: authController.isPhoneLogin,
                );
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
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, RouteNames.login),
              child: Text(AppStrings.backToLogin),
            ),
          ],
        ),
      ),
    );
  }
}