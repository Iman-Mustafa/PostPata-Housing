import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../controllers/auth/login_controller.dart';
import '../../router/route_names.dart';

class LoginScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<LoginController>(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.login)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: controller.isPhoneLogin 
                    ? AppStrings.phoneNumber 
                    : AppStrings.email,
                prefixIcon: Icon(controller.isPhoneLogin 
                    ? Icons.phone 
                    : Icons.email),
              ),
              keyboardType: controller.isPhoneLogin 
                  ? TextInputType.phone 
                  : TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: AppStrings.password,
                prefixIcon: const Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            if (controller.errorMessage != null) ...[
              Text(
                controller.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            ],
            Row(
              children: [
                Text(controller.isPhoneLogin 
                    ? AppStrings.loginWithEmail 
                    : AppStrings.loginWithPhone),
                Switch(
                  value: controller.isPhoneLogin,
                  onChanged: (_) => controller.toggleLoginMethod(),
                ),
              ],
            ),
            const Spacer(),
            PrimaryButton(
              text: AppStrings.login,
              isLoading: controller.isLoading,
              onPressed: () => controller.login(
                emailOrPhone: _emailController.text,
                password: _passwordController.text,
                context: context,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, RouteNames.register),
              child: Text(AppStrings.createAccount),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, RouteNames.forgotPassword),
              child: Text(AppStrings.forgotPassword),
            ),
          ],
        ),
      ),
    );
  }
}