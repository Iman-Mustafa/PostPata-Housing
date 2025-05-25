import 'package:frontend/core/utils/extensions/auth_extensions.dart';
import 'package:frontend/core/utils/extensions/custom_auth_response.dart';
import 'package:frontend/services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/auth/user_model.dart';

class AuthRepository {
  // Constants
  static const _profileTable = 'profiles';
  static const _authEndpoint = 'auth';

  // Dependencies
  final SupabaseClient _supabaseClient;
  final ApiService _apiService;

  // Constructor
  AuthRepository(this._supabaseClient, this._apiService);

  // User Management Methods
  Future<UserModel?> getCurrentUser() async {
    try {
      final session = _supabaseClient.auth.currentSession;
      if (session == null) return null;

      try {
        final response = await _apiService.get('$_authEndpoint/me');
        return UserModel.fromJson(response);
      } catch (e) {
        final userData =
            await _supabaseClient
                .from(_profileTable)
                .select()
                .eq('id', session.user.id)
                .maybeSingle();

        if (userData == null) {
          throw Exception('User profile not found');
        }

        return UserModel.fromJson(userData);
      }
    } catch (e) {
      throw Exception('Failed to fetch user profile: ${e.toString()}');
    }
  }

  // Authentication Methods
  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
    required bool isPhone,
  }) async {
    try {
      try {
        final response = await _apiService.post('$_authEndpoint/login', {
          if (isPhone) 'phone': _normalizePhoneNumber(emailOrPhone),
          if (!isPhone) 'email': emailOrPhone.trim().toLowerCase(),
          'password': password,
        });
        return UserModel.fromJson(response['user']);
      } catch (e) {
        final AuthResponse response;

        if (isPhone) {
          response = await _supabaseClient.auth.signInWithPassword(
            phone: _normalizePhoneNumber(emailOrPhone),
            password: password,
          );
        } else {
          response = await _supabaseClient.auth.signInWithPassword(
            email: emailOrPhone.trim().toLowerCase(),
            password: password,
          );
        }

        if (response.user == null) {
          throw Exception('Authentication failed - no user returned');
        }

        return (await getCurrentUser())!;
      }
    } on AuthException catch (e) {
      throw Exception(_parseAuthError(e.message));
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<CustomAuthResponse> register({
  required String fullName,
  required String emailOrPhone,
  required String password,
  required UserRole role,
  required bool isPhone,
}) async {
  try {
    // 1. Perform registration
    final authResponse = await _supabaseClient.auth.signUp(
      email: isPhone ? null : emailOrPhone.trim().toLowerCase(),
      phone: isPhone ? _normalizePhoneNumber(emailOrPhone) : null,
      password: password,
      data: {'full_name': fullName.trim(), 'role': role.name},
    );

    if (authResponse.user == null) {
      throw Exception('Registration failed - no user created');
    }

    // 2. Create profile
    await _supabaseClient.from(_profileTable).insert({
      'id': authResponse.user!.id,
      'full_name': fullName.trim(),
      'role': role.name,
      if (!isPhone) 'email': emailOrPhone.trim().toLowerCase(),
      if (isPhone) 'phone': _normalizePhoneNumber(emailOrPhone),
      'is_verified': false,
    });

    // 3. Convert using extension method
    return await authResponse.toCustomAuthResponse(
      supabaseClient: _supabaseClient,
      profileTable: _profileTable,
      isPhoneRegistration: isPhone,
    );
    
  } on AuthException catch (e) {
    throw Exception(_parseAuthError(e.message));
  } catch (e) {
    throw Exception('Registration failed: ${e.toString()}');
  }
}

  // OTP and Password Management Methods
  Future<void> verifyOtp({
    required String emailOrPhone,
    required String otp,
    required bool isPhone,
  }) async {
    try {
      final AuthResponse response;

      if (isPhone) {
        response = await _supabaseClient.auth.verifyOTP(
          phone: _normalizePhoneNumber(emailOrPhone),
          token: otp,
          type: OtpType.sms,
        );
      } else {
        response = await _supabaseClient.auth.verifyOTP(
          email: emailOrPhone.trim().toLowerCase(),
          token: otp,
          type: OtpType.recovery,
        );
      }

      if (response.session == null) {
        throw Exception('OTP verification failed - no session created');
      }

      final user = await getCurrentUser();
      if (user != null) {
        await _supabaseClient
            .from(_profileTable)
            .update({'is_verified': true})
            .eq('id', user.id);
      }
    } on AuthException catch (e) {
      throw Exception(_parseAuthError(e.message));
    } catch (e) {
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  Future<void> requestPasswordReset({
    required String emailOrPhone,
    required bool isPhone,
  }) async {
    try {
      if (isPhone) {
        await _supabaseClient.auth.signInWithOtp(
          phone: _normalizePhoneNumber(emailOrPhone),
        );
      } else {
        await _supabaseClient.auth.resetPasswordForEmail(
          emailOrPhone.trim().toLowerCase(),
        );
      }
    } on AuthException catch (e) {
      throw Exception(_parseAuthError(e.message));
    } catch (e) {
      throw Exception('Password reset request failed: ${e.toString()}');
    }
  }

  Future<void> resetPassword({
    required String emailOrPhone,
    required String newPassword,
    required bool isPhone,
  }) async {
    try {
      final session = _supabaseClient.auth.currentSession;
      if (session == null) {
        throw Exception('No active session - please verify OTP first');
      }

      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      final user = await getCurrentUser();
      if (user == null) {
        throw Exception('User profile not found after password reset');
      }
    } on AuthException catch (e) {
      throw Exception(_parseAuthError(e.message));
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      try {
        await _apiService.post('$_authEndpoint/logout', {});
      } catch (e) {
        // Ignore backend errors
      }
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  // Helper Methods
  String _normalizePhoneNumber(String phone) {
    final normalized = phone.trim().replaceAll(RegExp(r'[^\d+]'), '');
    if (!normalized.startsWith('+')) {
      return '+255$normalized';
    }
    return normalized;
  }

  String _parseAuthError(String message) {
    if (message.contains('User already registered') ||
        message.contains('already in use')) {
      return 'email already registered';
    }
    if (message.contains('Invalid login credentials')) {
      return 'invalid login credentials';
    }
    if (message.contains('Phone number')) {
      return 'phone already registered';
    }
    if (message.contains('Email')) {
      return 'Invalid email format';
    }
    if (message.contains('Password')) {
      return 'Password does not meet requirements';
    }
    if (message.contains('OTP') || message.contains('token')) {
      return 'invalid OTP';
    }
    if (message.contains('User not found')) {
      return 'user not found';
    }
    return message;
  }
}
