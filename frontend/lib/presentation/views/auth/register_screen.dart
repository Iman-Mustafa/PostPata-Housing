import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../data/models/auth/user_model.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../router/route_names.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister(BuildContext context, AuthController controller) async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      controller.setErrorMessage(AppStrings.passwordMismatch);
      return;
    }

    try {
      controller.setLoading(true);
      controller.clearErrorMessage();

      final success = await controller.register(
        fullName: _fullNameController.text.trim(),
        emailOrPhone: _emailOrPhoneController.text.trim(),
        password: _passwordController.text,
        role: controller.selectedRole ?? UserRole.tenant,
        isPhone: controller.isPhoneLogin,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.registrationSuccess))
        );

        if (controller.requiresVerification) {
          Navigator.pushNamed(
            context,
            RouteNames.otp,
            arguments: {
              'emailOrPhone': _emailOrPhoneController.text.trim(),
              'isPhoneVerification': controller.isPhoneLogin,
              'isPasswordReset': false,
            },
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.home,
            (route) => false,
          );
        }
      }
    } on ApiException catch (e) {
      controller.setErrorMessage(e.message);
    } catch (e) {
      controller.setErrorMessage(AppStrings.genericError);
    } finally {
      if (mounted) {
        controller.setLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.createAccount)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: AppStrings.fullName,
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.fullNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailOrPhoneController,
                decoration: InputDecoration(
                  labelText: controller.isPhoneLogin
                      ? AppStrings.phoneNumber
                      : AppStrings.email,
                  prefixIcon: Icon(
                    controller.isPhoneLogin ? Icons.phone : Icons.email,
                  ),
                  hintText: controller.isPhoneLogin
                      ? AppStrings.phoneHint
                      : AppStrings.emailHint,
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
                    // Update regex to match your backend validation
                    final phoneRegex = RegExp(r'^\+?[\d]{10,12}$');
                    if (!phoneRegex.hasMatch(value.trim())) {
                      return AppStrings.invalidPhone;
                    }
                  } else {
                    // Update regex to match your backend validation
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return AppStrings.invalidEmail;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: AppStrings.password,
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
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

              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: AppStrings.confirmPassword,
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return AppStrings.passwordMismatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.isPhoneLogin
                        ? AppStrings.registerWithEmail
                        : AppStrings.registerWithPhone,
                  ),
                  Switch(
                    value: controller.isPhoneLogin,
                    onChanged: (_) {
                      _emailOrPhoneController.clear();
                      controller.toggleLoginMethod();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

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

              if (controller.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    controller.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),

              PrimaryButton(
                text: AppStrings.register,
                isLoading: controller.isLoading,
                onPressed: () => _handleRegister(context, controller),
              ),
              const SizedBox(height: 8),

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