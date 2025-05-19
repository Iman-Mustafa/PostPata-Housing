// lib/data/repositories/property_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/property_model.dart';

class PropertyRepository {
  final SupabaseClient _supabaseClient;

  PropertyRepository(this._supabaseClient);

  Future<List<PropertyModel>> getFeaturedProperties() async {
    final response = await _supabaseClient
        .from('properties')
        .select()
        .eq('is_featured', true)
        .order('created_at', ascending: false)
        .limit(5)
        .execute();

    if (response.error != null) throw Exception(response.error!.message);
    return (response.data as List)
        .map((json) => PropertyModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<PropertyModel>> getAllProperties() async {
    final response = await _supabaseClient
        .from('properties')
        .select()
        .order('created_at', ascending: false)
        .execute();

    if (response.error != null) throw Exception(response.error!.message);
    return (response.data as List)
        .map((json) => PropertyModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<PropertyModel> getPropertyById(String id) async {
    final response = await _supabaseClient
        .from('properties')
        .select()
        .eq('id', id)
        .single()
        .execute();

    if (response.error != null) throw Exception(response.error!.message);
    return PropertyModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PropertyModel> addProperty(PropertyModel property) async {
    final response = await _supabaseClient
        .from('properties')
        .insert(property.toJson())
        .select()
        .single()
        .execute();

    if (response.error != null) throw Exception(response.error!.message);
    return PropertyModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteProperty(String id) async {
    final response = await _supabaseClient
        .from('properties')
        .delete()
        .eq('id', id)
        .execute();

    if (response.error != null) throw Exception(response.error!.message);
  }
}