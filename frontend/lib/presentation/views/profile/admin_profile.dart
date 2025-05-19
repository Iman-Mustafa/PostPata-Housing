// lib/presentation/views/profile/admin_profile.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/auth/user_model.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../router/route_names.dart';

class AdminProfile extends StatelessWidget {
  const AdminProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    if (user == null) return const Center(child: Text('Not logged in'));

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(user),
            const Divider(),
            _buildAdminActions(context),
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
            Text('Admin'),
            Text(user.email ?? user.phone ?? ''),
          ],
        ),
      ],
    );
  }

  Widget _buildAdminActions(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('Manage Users'),
          onTap: () => Navigator.pushNamed(context, RouteNames.userManagement),
        ),
        ListTile(
          leading: const Icon(Icons.bar_chart),
          title: const Text('View Reports'),
          onTap: () => Navigator.pushNamed(context, RouteNames.reports),
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('System Settings'),
          onTap: () => Navigator.pushNamed(context, RouteNames.systemSettings),
        ),
      ],
    );
  }
}