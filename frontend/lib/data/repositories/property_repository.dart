// lib/data/repositories/property_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property_model.dart';

class PropertyRepository {
  final SupabaseClient _supabaseClient;

  PropertyRepository(this._supabaseClient);

  Future<List<PropertyModel>> getFeaturedProperties() async {
    final data = await _supabaseClient
        .from('properties')
        .select()
        .eq('is_featured', true)
        .order('created_at', ascending: false)
        .limit(5);

    // ignore: unnecessary_cast
    return data
        // ignore: unnecessary_cast
        .map((json) => PropertyModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<PropertyModel>> getAllProperties() async {
    final data = await _supabaseClient
        .from('properties')
        .select()
        .order('created_at', ascending: false);

    return data.map((json) => PropertyModel.fromJson(json)).toList();
  }

  Future<PropertyModel> getPropertyById(String id) async {
    final data =
        await _supabaseClient
            .from('properties')
            .select()
            .eq('id', id)
            .maybeSingle(); // Use maybeSingle instead of single

    if (data == null) throw Exception('Property not found');

    return PropertyModel.fromJson(data);
  }

  Future<PropertyModel> addProperty(PropertyModel property) async {
    final data =
        await _supabaseClient
            .from('properties')
            .insert(property.toJson())
            .select()
            .maybeSingle(); // Use maybeSingle instead of single

    if (data == null) throw Exception('Failed to create property');

    return PropertyModel.fromJson(data);
  }

  Future<void> updateProperty(PropertyModel property) async {
  await _supabaseClient
      .from('properties')
      .update(property.toJson())
      .eq('id', property.id);
}

  Future<void> deleteProperty(String id) async {
    await _supabaseClient.from('properties').delete().eq('id', id);
  }
}
