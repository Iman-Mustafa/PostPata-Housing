// lib/presentation/views/profile/tenant_profile.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/auth/user_model.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../router/route_names.dart';

class TenantProfile extends StatelessWidget {
  const TenantProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = context.read<AuthController>();
    final user = authController.currentUser;
    if (user == null) return const Center(child: Text('Not logged in'));

    return Scaffold(
      appBar: AppBar(title: const Text('Wasifu Wako')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(user),
            const Divider(),
            _buildTenantActions(context),
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
            const Text('Mpangizi'),
            Text(user.email ?? user.phone ?? ''),
          ],
        ),
      ],
    );
  }

  Widget _buildTenantActions(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.favorite),
          title: const Text('Nyumba Unazozipenda'),
          onTap: () => Navigator.pushNamed(context, RouteNames.favorites),
        ),
        ListTile(
          leading: const Icon(Icons.assignment),
          title: const Text('Maombi Yako'),
          onTap: () => Navigator.pushNamed(context, RouteNames.applications),
        ),
        ListTile(
          leading: const Icon(Icons.payment),
          title: const Text('Malipo Yako'),
          onTap: () => Navigator.pushNamed(context, RouteNames.paymentHistory),
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