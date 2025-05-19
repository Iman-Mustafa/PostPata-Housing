// lib/data/repositories/auth_repository.dart
import 'package:frontend/data/models/auth/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepository(this._supabaseClient);

  Future<UserModel?> getCurrentUser() async {
    final session = _supabaseClient.auth.currentSession;
    if (session == null) return null;

    try {
      final userData = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', session.user.id)
          .single();
      
      return UserModel.fromJson(userData);
    } catch (e) {
      throw Exception('Failed to fetch user profile: ${e.toString()}');
    }
  }

  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
    required bool isPhone,
  }) async {
    try {
      final response = isPhone
          ? await _supabaseClient.auth.signInWithPassword(
              phone: emailOrPhone,
              password: password,
            )
          : await _supabaseClient.auth.signInWithPassword(
              email: emailOrPhone,
              password: password,
            );

      if (response.user == null) throw Exception('Login failed');
      
      final user = await getCurrentUser();
      if (user == null) throw Exception('Failed to retrieve current user after login');
      return user;
    } catch (e) {
      throw Exception('Login error: ${e.toString()}');
    }
  }

  Future<UserModel> register({
    required String fullName,
    required String emailOrPhone,
    required String password,
    required UserRole role,
    required bool isPhone,
  }) async {
    try {
      final authResponse = isPhone
          ? await _supabaseClient.auth.signUp(
              phone: emailOrPhone,
              password: password,
            )
          : await _supabaseClient.auth.signUp(
              email: emailOrPhone,
              password: password,
            );

      if (authResponse.user == null) throw Exception('Registration failed');

      final profileData = await _supabaseClient
          .from('profiles')
          .insert({
            'id': authResponse.user!.id,
            'full_name': fullName,
            'role': role.toString().split('.').last,
            'is_verified': false,
          })
          .select()
          .single();

      return UserModel.fromJson(profileData);
    } catch (e) {
      throw Exception('Registration error: ${e.toString()}');
    }
  }

  Future<void> verifyOtp({
    required String emailOrPhone,
    required String otp,
    required bool isPhone,
  }) async {
    try {
      final response = isPhone
          ? await _supabaseClient.auth.verifyOTP(
              phone: emailOrPhone,
              token: otp,
              type: OtpType.sms,
            )
          : await _supabaseClient.auth.verifyOTP(
              email: emailOrPhone,
              token: otp,
              type: OtpType.email,
            );

      if (response.session == null) throw Exception('OTP verification failed');
    } catch (e) {
      throw Exception('OTP verification error: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('Logout error: ${e.toString()}');
    }
  }
}