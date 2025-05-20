import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  late final SupabaseClient _client;

  SupabaseClient get client => _client;

  Future<void> initialize() async {
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final anonKey = dotenv.env['SUPABASE_KEY'] ?? ''; // Make sure this matches your .env key name
    
    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception('Missing Supabase credentials in .env file');
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    _client = Supabase.instance.client;
  }
}