// lib/presentation/views/profile/landlord_profile.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/auth/user_model.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../router/route_names.dart';

class LandlordProfile extends StatelessWidget {
  const LandlordProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.read<AuthController>();
    final user = authController.currentUser;
    if (user == null) return const Center(child: Text('Not logged in'));

    return Scaffold(
      appBar: AppBar(title: const Text('Landlord Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(user),
            const Divider(),
            _buildLandlordActions(context),
            const Divider(),
            _buildSettings(context, authController),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: user.photoUrl != null 
              ? NetworkImage(user.photoUrl!) 
              : null,
          child: user.photoUrl == null 
              ? const Icon(Icons.person, size: 40) 
              : null,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.fullName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('Mmiliki wa Nyumba'),
            Text(user.email ?? user.phone ?? ''),
          ],
        ),
      ],
    );
  }

  Widget _buildLandlordActions(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Nyumba Zangu'),
          onTap: () => Navigator.pushNamed(context, RouteNames.myProperties),
        ),
        ListTile(
          leading: const Icon(Icons.assignment),
          title: const Text('Maombi ya Kukodi'),
          onTap: () => Navigator.pushNamed(context, RouteNames.rentalApplications),
        ),
        ListTile(
          leading: const Icon(Icons.payment),
          title: const Text('Malipo'),
          onTap: () => Navigator.pushNamed(context, RouteNames.rentalPayments),
        ),
      ],
    );
  }

  Widget _buildSettings(BuildContext context, AuthController authController) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Mipangilio'),
          onTap: () => Navigator.pushNamed(context, RouteNames.settings),
        ),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Toka'),
          onTap: () async {
            await authController.logout();
            Navigator.pushNamedAndRemoveUntil(
              context, 
              RouteNames.welcome, 
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}