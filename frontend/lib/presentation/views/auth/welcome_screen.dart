import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../router/route_names.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/welcome.jpeg', height: 220),
            const SizedBox(height: 30),
            Text(
              AppStrings.welcomeTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.welcomeSubtitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              text: 'English - Continue',
              onPressed: () {
                // Set English locale
                Navigator.pushNamed(context, RouteNames.login);
              },
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Kiswahili - Endelea',
              variant: ButtonVariant.outlined,
              onPressed: () {
                // Set Swahili locale
                Navigator.pushNamed(context, RouteNames.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}