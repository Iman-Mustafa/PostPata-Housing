import 'package:gotrue/gotrue.dart';
import 'package:frontend/data/models/auth/user_model.dart';

class CustomAuthResponse {
  final UserModel user;
  final bool requiresVerification;
  final Session? session;

  const CustomAuthResponse({
    required this.user,
    required this.requiresVerification,
    this.session,
  });

  /// Getter for verification status (delegates to UserModel)
  bool get isVerified => user.isVerified;

  /// Factory constructor from Supabase components
  factory CustomAuthResponse.fromSupabase({
    required UserModel user,
    required bool requiresVerification,
    required AuthResponse? supabaseResponse,
  }) {

    return CustomAuthResponse(
      user: user,
      requiresVerification: requiresVerification,
      session: supabaseResponse?.session,
    );
  }

  /// Alternative constructor from JSON data
  factory CustomAuthResponse.fromJson(Map<String, dynamic> json) {
    return CustomAuthResponse(
      user: UserModel.fromJson(json['user']),
      requiresVerification: json['requires_verification'] as bool,
      session: json['session'] != null 
          ? Session.fromJson(json['session']) 
          : null,
    );
  }

  /// Serialization method
  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'requires_verification': requiresVerification,
    'session': session?.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomAuthResponse &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          requiresVerification == other.requiresVerification &&
          session?.accessToken == other.session?.accessToken;

  @override
  int get hashCode => 
      user.hashCode ^ 
      requiresVerification.hashCode ^ 
      session!.accessToken.hashCode;

  @override
  String toString() =>
      'CustomAuthResponse(user: $user, '
      'requiresVerification: $requiresVerification, '
      'session: ${session?.accessToken})';
}