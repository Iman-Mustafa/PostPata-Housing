import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../router/route_names.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Lifecycle methods
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Authentication methods
  Future<void> _checkAuthStatus() async {
    try {
      final controller = Provider.of<AuthController>(context, listen: false);
      await controller.initialize();
      
      if (!mounted) return;
      if (controller.currentUser != null) {
        _navigateToHome();
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage('Authentication error: ${e.toString()}');
    }
  }

  Future<void> _handleLogin(BuildContext context, AuthController controller) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final success = await controller.login(
        emailOrPhone: _emailOrPhoneController.text.trim(),
        password: _passwordController.text,
        isPhone: controller.isPhoneLogin,
      );

      if (!mounted) return;
      if (success) {
        _navigateToHome();
      } else {
        _showErrorMessage('Login failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage('Login error: ${e.toString()}');
    }
  }

  // Navigation methods
  void _navigateToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.home,
      (route) => false,
    );
  }

  // UI Helper methods
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Validation methods
  String? _validateEmailOrPhone(String? value, bool isPhone) {
    if (value == null || value.trim().isEmpty) {
      return isPhone ? AppStrings.phoneRequired : AppStrings.emailRequired;
    }

    if (isPhone) {
      final phoneRegex = RegExp(r'^\d{10}$');
      if (!phoneRegex.hasMatch(value.trim())) {
        return AppStrings.invalidPhone;
      }
    } else {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(value.trim())) {
        return AppStrings.invalidEmail;
      }
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    if (value.length < 6) {
      return AppStrings.passwordLength;
    }
    return null;
  }

  // Widget build methods
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AuthController>(context);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.login)),
      body: _buildLoginForm(context, controller),
    );
  }

  Widget _buildLoginForm(BuildContext context, AuthController controller) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 30),
              _buildEmailPhoneField(controller),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 16),
              if (controller.errorMessage != null) 
                _buildErrorMessage(controller),
              _buildLoginMethodToggle(controller),
              const SizedBox(height: 30),
              _buildLoginButton(controller),
              const SizedBox(height: 16),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
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
      ],
    );
  }

  Widget _buildEmailPhoneField(AuthController controller) {
    return TextFormField(
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
      validator: (value) => _validateEmailOrPhone(value, controller.isPhoneLogin),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: const InputDecoration(
        labelText: AppStrings.password,
        prefixIcon: Icon(Icons.lock),
        border: OutlineInputBorder(),
      ),
      obscureText: true,
      validator: _validatePassword,
    );
  }

  Widget _buildErrorMessage(AuthController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        controller.errorMessage!,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildLoginMethodToggle(AuthController controller) {
    return Row(
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
    );
  }

  Widget _buildLoginButton(AuthController controller) {
    return PrimaryButton(
      text: AppStrings.login,
      isLoading: controller.isLoading,
      onPressed: () => _handleLogin(context, controller),
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      children: [
        Center(
          child: TextButton(
            onPressed: () => Navigator.pushNamed(context, RouteNames.register),
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
            onPressed: () => Navigator.pushNamed(
              context,
              RouteNames.forgotPassword,
            ),
            child: Text(
              AppStrings.forgotPassword,
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}