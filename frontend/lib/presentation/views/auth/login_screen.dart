import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../router/route_names.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<AuthController>(context, listen: false);
      controller.initialize().then((_) {
        if (controller.currentUser != null && mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.home,
            (route) => false,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context, AuthController controller) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await controller.login(
      emailOrPhone: _emailOrPhoneController.text.trim(),
      password: _passwordController.text,
      isPhone: controller.isPhoneLogin,
    );

    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.home,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.login)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  AppStrings.welcome,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.welcomeMessage,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailOrPhoneController,
                  decoration: InputDecoration(
                    labelText: controller.isPhoneLogin
                        ? AppStrings.phoneNumber
                        : AppStrings.email,
                    prefixIcon: Icon(
                      controller.isPhoneLogin ? Icons.phone : Icons.email,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: controller.isPhoneLogin
                      ? TextInputType.phone
                      : TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return controller.isPhoneLogin
                          ? AppStrings.phoneRequired
                          : AppStrings.emailRequired;
                    }
                    if (controller.isPhoneLogin) {
                      final phoneRegex = RegExp(r'^\d{10}$');
                      if (!phoneRegex.hasMatch(value.trim())) {
                        return AppStrings.invalidPhone;
                      }
                    } else {
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Invalid email format';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.password,
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.passwordRequired;
                    }
                    if (value.length < 6) {
                      return AppStrings.passwordLength;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (controller.errorMessage != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      controller.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.isPhoneLogin
                          ? AppStrings.loginWithEmail
                          : AppStrings.loginWithPhone,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Switch(
                      value: controller.isPhoneLogin,
                      onChanged: (_) => controller.toggleLoginMethod(),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                PrimaryButton(
                  text: AppStrings.login,
                  isLoading: controller.isLoading,
                  onPressed: () => _handleLogin(context, controller),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteNames.register),
                    child: Text(
                      AppStrings.createAccount,
                      style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteNames.forgotPassword),
                    child: Text(
                      AppStrings.forgotPassword,
                      style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}