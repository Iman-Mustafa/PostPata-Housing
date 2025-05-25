import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service class for handling Supabase authentication and user management
class SupabaseService {
  // Singleton pattern
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient client;

  /// Initialize Supabase client with environment variables
  /// Returns the service instance for method chaining
  Future<SupabaseService> initialize() async {
    try {
      // Avoid loading env file multiple times
      if (!dotenv.isInitialized) {
        await dotenv.load(fileName: '.env');
      }

      // Check if required env variables exist
      final url = dotenv.env['SUPABASE_URL'];
      final anonKey = dotenv.env['SUPABASE_KEY'];

      if (url == null || anonKey == null) {
        throw Exception(
          'Missing required environment variables: SUPABASE_URL or SUPABASE_KEY',
        );
      }

      // Initialize Supabase if not already initialized
      if (Supabase.instance.client.auth.currentSession == null) {
        await Supabase.initialize(
          url: url,
          anonKey: anonKey,
          debug: !const bool.fromEnvironment('dart.vm.product'),
        );
      }

      client = Supabase.instance.client;
      return this;
    } catch (e, stackTrace) {
      throw Exception('''
Failed to initialize Supabase:
Error: ${e.toString()}
Stack trace: $stackTrace
Please check your environment variables and connection.
''');
    }
  }

  /// Email sign up with optional metadata
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      return await client.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
    } catch (e) {
      throw Exception('Email signup failed: ${e.toString()}');
    }
  }

  /// Phone sign up with optional metadata
  Future<AuthResponse> signUpWithPhone({
    required String phone,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      return await client.auth.signUp(
        phone: phone,
        password: password,
        data: data,
      );
    } catch (e) {
      throw Exception('Phone signup failed: ${e.toString()}');
    }
  }

  /// Email sign in with password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Email signin failed: ${e.toString()}');
    }
  }

  /// Phone sign in with password
  Future<AuthResponse> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    try {
      return await client.auth.signInWithPassword(
        phone: phone,
        password: password,
      );
    } catch (e) {
      throw Exception('Phone signin failed: ${e.toString()}');
    }
  }

  /// Verify OTP for email verification or password reset
  Future<void> verifyOTP({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    try {
      await client.auth.verifyOTP(
        email: email, 
        token: token, 
        type: type,
      );
    } catch (e) {
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw Exception('Signout failed: ${e.toString()}');
    }
  }

  // User state getters
  /// Get current authenticated user
  User? get currentUser => client.auth.currentUser;

  /// Get current authentication state
  AuthState get authState => client.auth.currentSession != null
      ? AuthState.authenticated
      : AuthState.unauthenticated;

  /// Stream of authentication state changes
  Stream<AuthState> get onAuthStateChange => client.auth.onAuthStateChange.map(
        (event) => event.session != null
            ? AuthState.authenticated
            : AuthState.unauthenticated,
      );
}

/// Enum representing authentication states
enum AuthState { authenticated, unauthenticated }