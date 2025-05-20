import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auth/user_model.dart';

class AuthRepository {
  final SupabaseClient _supabaseClient;
  static const _profileTable = 'profiles';

  AuthRepository(this._supabaseClient);

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final session = _supabaseClient.auth.currentSession;
      if (session == null) return null;

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
    } catch (e) {
      throw Exception('Failed to fetch user profile: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
    required bool isPhone,
  }) async {
    try {
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

      final user = await getCurrentUser();
      if (user == null) {
        throw Exception('User profile not found after successful login');
      }

      return user;
    } on AuthException catch (e) {
      throw Exception(_parseAuthError(e.message));
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String emailOrPhone,
    required String password,
    required UserRole role,
    required bool isPhone,
  }) async {
    try {
      final AuthResponse authResponse;

      if (isPhone) {
        authResponse = await _supabaseClient.auth.signUp(
          phone: _normalizePhoneNumber(emailOrPhone),
          password: password,
          data: {'full_name': fullName.trim(), 'role': role.name},
        );
      } else {
        authResponse = await _supabaseClient.auth.signUp(
          email: emailOrPhone.trim().toLowerCase(),
          password: password,
          data: {'full_name': fullName.trim(), 'role': role.name},
        );
      }

      if (authResponse.user == null) {
        throw Exception('Registration failed - no user created');
      }

      // Create user profile
      final profileData =
          await _supabaseClient
              .from(_profileTable)
              .insert({
                'id': authResponse.user!.id,
                'full_name': fullName.trim(),
                'role': role.name,
                'email': isPhone ? null : emailOrPhone.trim().toLowerCase(),
                'phone': isPhone ? _normalizePhoneNumber(emailOrPhone) : null,
                'is_verified': false,
              })
              .select()
              .single();

      return UserModel.fromJson(profileData);
    } on AuthException catch (e) {
      throw Exception(_parseAuthError(e.message));
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
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
          type: OtpType.recovery, // Use recovery type for password reset
        );
      }

      if (response.session == null) {
        throw Exception('OTP verification failed - no session created');
      }

      // Update is_verified status in the profile
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

  @override
  Future<void> requestPasswordReset({
    required String emailOrPhone,
    required bool isPhone,
  }) async {
    try {
      if (isPhone) {
        // Custom solution for phone-based password reset
        // Send an OTP to the phone number
        await _supabaseClient.auth.signInWithOtp(
          phone: _normalizePhoneNumber(emailOrPhone),
        );
      } else {
        // Email-based password reset using Supabase's native method
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

  @override
  Future<void> resetPassword({
    required String emailOrPhone,
    required String newPassword,
    required bool isPhone,
  }) async {
    try {
      // Ensure a session is active after OTP verification
      final session = _supabaseClient.auth.currentSession;
      if (session == null) {
        throw Exception('No active session - please verify OTP first');
      }

      // Update the password
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      // Ensure the user profile is updated if needed
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

  @override
  Future<void> logout() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  String _normalizePhoneNumber(String phone) {
    // Ensure consistent phone number format for Tanzania
    final normalized = phone.trim().replaceAll(RegExp(r'[^\d+]'), '');
    if (!normalized.startsWith('+')) {
      return '+255$normalized'; // Default to Tanzania country code
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
