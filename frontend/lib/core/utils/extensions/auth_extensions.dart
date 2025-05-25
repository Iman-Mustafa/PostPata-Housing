import 'package:frontend/core/utils/extensions/custom_auth_response.dart';
import 'package:frontend/data/models/auth/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Add this import

extension AuthResponseExtensions on AuthResponse {
  /// Enhanced conversion to CustomAuthResponse
  Future<CustomAuthResponse> toCustomAuthResponse({
    required SupabaseClient supabaseClient,
    required String profileTable,
    required bool isPhoneRegistration,
  }) async {
    if (user == null) throw Exception('No user in auth response');

    final profileData = await supabaseClient
        .from(profileTable)
        .select()
        .eq('id', user!.id)
        .single();

    return CustomAuthResponse(
      user: UserModel.fromJson(profileData),
      requiresVerification: isPhoneRegistration,
      session: session,
    );
  }

  /// Quick verification check
  bool get requiresVerification => user?.phone != null && session == null;
}