// lib/presentation/views/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/auth/user_model.dart';
import '../../controllers/auth/auth_controller.dart';
import 'admin_profile.dart';
import 'landlord_profile.dart';
import 'tenant_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    if (user == null) return const Center(child: Text('Not logged in'));

    switch (user.role) {
      case UserRole.admin:
        return const AdminProfile();
      case UserRole.landlord:
        return const LandlordProfile();
      case UserRole.tenant:
      return const TenantProfile();
    }
  }
}