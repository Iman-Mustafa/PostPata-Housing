import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../data/models/auth/user_model.dart';
import '../../controllers/auth/register_controller.dart';
import '../../router/route_names.dart';

class RegisterScreen extends StatelessWidget {
  final _fullNameController = TextEditingController();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RegisterController>(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.createAccount)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Full Name Field
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: AppStrings.fullName,
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              
              // Email/Phone Field with Toggle
              TextField(
                controller: _emailOrPhoneController,
                decoration: InputDecoration(
                  labelText: controller.isPhoneRegistration
                      ? AppStrings.phoneNumber
                      : AppStrings.email,
                  prefixIcon: Icon(
                    controller.isPhoneRegistration ? Icons.phone : Icons.email,
                  ),
                  hintText: controller.isPhoneRegistration
                      ? 'e.g. +1234567890'
                      : 'e.g. user@example.com',
                ),
                keyboardType: controller.isPhoneRegistration
                    ? TextInputType.phone
                    : TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              // Password Field
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: AppStrings.password,
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              
              // Confirm Password Field
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: AppStrings.confirmPassword,
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              
              // Registration Method Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(controller.isPhoneRegistration
                      ? AppStrings.registerWithEmail
                      : AppStrings.registerWithPhone),
                  Switch(
                    value: controller.isPhoneRegistration,
                    onChanged: (_) {
                      // Clear the field when switching methods
                      _emailOrPhoneController.clear();
                      controller.toggleRegistrationMethod();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Role Selection
              Text(AppStrings.selectRole),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: UserRole.values.map((role) {
                  return ChoiceChip(
                    label: Text(
                      role.toString().split('.').last,
                      style: TextStyle(
                        color: controller.selectedRole == role
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                      ),
                    ),
                    selected: controller.selectedRole == role,
                    onSelected: (_) => controller.setRole(role),
                    selectedColor: Theme.of(context).colorScheme.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              
              // Error Message
              if (controller.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    controller.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              
              // Register Button
              PrimaryButton(
                text: AppStrings.register,
                isLoading: controller.isLoading,
                onPressed: () => controller.register(
                  context: context,
                  fullName: _fullNameController.text,
                  emailOrPhone: _emailOrPhoneController.text,
                  password: _passwordController.text,
                ),
              ),
              const SizedBox(height: 8),
              
              // Login Link
              TextButton(
                onPressed: () => Navigator.pushNamed(context, RouteNames.login),
                child: Text(AppStrings.alreadyHaveAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}