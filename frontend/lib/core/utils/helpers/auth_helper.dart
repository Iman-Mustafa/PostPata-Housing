// lib/core/utils/helpers/auth_helper.dart

import '../../../data/models/auth/user_model.dart';

class AuthHelper {
  static String formatTanzanianPhone(String phone) {
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (phone.startsWith('0')) {
      return '+255${phone.substring(1)}';
    }
    if (phone.startsWith('255') && phone.length == 12) {
      return '+$phone';
    }
    if (phone.length == 9) {
      return '+255$phone';
    }
    return phone;
  }

  static bool isValidTanzanianPhone(String phone) {
    final regex = RegExp(
      r'^(?:\+255|0)?(?:7[0-9]|6[0-9]|74|75|76|77|78|79)[0-9]{7}$'
    );
    return regex.hasMatch(phone);
  }

  static String getUserRoleName(UserRole role) {
    switch (role) {
      case UserRole.tenant:
        return 'Tenant';
      case UserRole.landlord:
        return 'Landlord';
      case UserRole.admin:
        return 'Admin';
    }
  }
}