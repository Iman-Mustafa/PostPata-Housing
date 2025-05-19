import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../data/models/auth/user_model.dart';
import '../../controllers/auth/register_controller.dart';
import '../../router/route_names.dart';

class RegisterScreen extends StatelessWidget {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RegisterController>(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.createAccount)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: AppStrings.fullName,
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: controller.isPhoneRegistration 
                    ? AppStrings.phoneNumber 
                    : AppStrings.email,
                prefixIcon: Icon(controller.isPhoneRegistration 
                    ? Icons.phone 
                    : Icons.email),
              ),
              keyboardType: controller.isPhoneRegistration 
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
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: AppStrings.confirmPassword,
                prefixIcon: const Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Text(AppStrings.selectRole),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: UserRole.values.map((role) {
                return ChoiceChip(
                  label: Text(role.toString().split('.').last),
                  selected: controller.selectedRole == role,
                  onSelected: (_) => controller.setRole(role),
                );
              }).toList(),
            ),
            Row(
              children: [
                Text(controller.isPhoneRegistration 
                    ? AppStrings.registerWithEmail 
                    : AppStrings.registerWithPhone),
                Switch(
                  value: controller.isPhoneRegistration,
                  onChanged: (_) => controller.toggleRegistrationMethod(),
                ),
              ],
            ),
            if (controller.errorMessage != null)
              Text(
                controller.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const Spacer(),
            PrimaryButton(
              text: AppStrings.register,
              isLoading: controller.isLoading,
              onPressed: () => controller.register(
                context: context,
                fullName: _fullNameController.text,
                emailOrPhone: _emailController.text,
                password: _passwordController.text,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, RouteNames.login),
              child: Text(AppStrings.alreadyHaveAccount),
            ),
          ],
        ),
      ),
    );
  }
}