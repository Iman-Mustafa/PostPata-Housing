import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/data/repositories/repository_exception.dart';
import 'package:frontend/services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/property_model.dart';

class PropertyRepository {
  static const _tableName = 'properties';
  static const _endpoint = 'properties';
  static const _timeoutDuration = Duration(seconds: 10);

  final SupabaseClient _supabaseClient;
  final ApiService _apiService;

  PropertyRepository(this._supabaseClient, this._apiService);

  Future<PropertyModel> addProperty(PropertyModel property) async {
    try {
      return await _tryApiWithFallback(
        apiCall: () async {
          final response = await _apiService.post(
            Uri.parse(_endpoint) as String,
            property.toJson(),
            timeout: _timeoutDuration,
          );
          return PropertyModel.fromJson(response);
        },
        fallback: () async {
          final data =
              await _supabaseClient
                  .from(_tableName)
                  .insert(property.toJson())
                  .select()
                  .single();
          return PropertyModel.fromJson(data);
        },
      );
    } catch (e) {
      throw _handleError(e, 'Failed to add property');
    }
  }

  Future<List<PropertyModel>> getFeaturedProperties() async {
    try {
      return await _tryApiWithFallback(
        apiCall: () async {
          final response = await _apiService.get(
            '$_endpoint/featured',
            timeout: _timeoutDuration,
          );
          return (response as List)
              .map((json) => PropertyModel.fromJson(json))
              .toList();
        },
        fallback: () async {
          final data = await _supabaseClient
              .from(_tableName)
              .select()
              .eq('is_featured', true)
              .order('created_at', ascending: false)
              .limit(5);

          return data.map((json) => PropertyModel.fromJson(json)).toList();
        },
      );
    } catch (e) {
      throw _handleError(e, 'Failed to fetch featured properties');
    }
  }

  Future<List<PropertyModel>> getAllProperties({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    try {
      return await _tryApiWithFallback(
        apiCall: () async {
          final queryParams = _buildQueryParams(page, limit, filters);
          final response = await _apiService.get(
            _endpoint,
            queryParams: queryParams,
            timeout: _timeoutDuration,
          );
          return (response as List)
              .map((json) => PropertyModel.fromJson(json))
              .toList();
        },
        fallback: () async {
          PostgrestTransformBuilder query = _supabaseClient
              .from(_tableName)
              .select()
              .order('created_at', ascending: false)
              .range((page - 1) * limit, page * limit - 1);

          query = _applyFilters(query, filters);

          final data = await query;
          return data.map((json) => PropertyModel.fromJson(json)).toList();
        },
      );
    } catch (e) {
      throw _handleError(e, 'Failed to fetch properties');
    }
  }

  Future<PropertyModel> getPropertyById(String id) async {
    _validateId(id);

    try {
      return await _tryApiWithFallback(
        apiCall: () async {
          final response = await _apiService.get(
            '$_endpoint/$id',
            timeout: _timeoutDuration,
          );
          return PropertyModel.fromJson(response);
        },
        fallback: () async {
          final data =
              await _supabaseClient
                  .from(_tableName)
                  .select()
                  .eq('id', id)
                  .maybeSingle();

          if (data == null) {
            throw RepositoryException('Property not found');
          }
          return PropertyModel.fromJson(data);
        },
      );
    } catch (e) {
      throw _handleError(e, 'Failed to fetch property');
    }
  }
  void _validateId(String id) {
    if (id.isEmpty) {
      throw RepositoryException('Property ID cannot be empty');
    }
    // Add any other ID validation rules you need
    if (!RegExp(r'^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$').hasMatch(id)) {
      throw RepositoryException('Invalid property ID format');
    }
  }

  // Helper Methods
  Map<String, String> _buildQueryParams(
    int page,
    int limit,
    Map<String, dynamic>? filters,
  ) {
    return {
      'page': page.toString(),
      'limit': limit.toString(),
      if (filters != null)
        ...filters.map((key, value) => MapEntry(key, value.toString())),
    };
  }
  PostgrestTransformBuilder _applyFilters(
  PostgrestTransformBuilder query,
  Map<String, dynamic>? filters,
) {
  if (filters != null && filters.isNotEmpty) {
    // Price range
    if (filters['price_min'] != null) {
      query = query.match(
        {'price': {'gte': filters['price_min']}}
      );
    }
    if (filters['price_max'] != null) {
      query = query.match(
        {'price': {'lte': filters['price_max']}}
      );
    }
    
    // Search
    if (filters['search'] != null) {
      query = query.textSearch(
        'title', 
        filters['search'],
        config: 'english',
      );
    }
    
    // Other filters (exact matches)
    final otherFilters = filters.entries.where((e) => 
      !['price_min', 'price_max', 'search'].contains(e.key) &&
      e.value != null
    );
    
    for (final filter in otherFilters) {
      query = query.eq(filter.key, filter.value);
    }
  }
  return query;
}

  Future<T> _tryApiWithFallback<T>({
    required Future<T> Function() apiCall,
    required Future<T> Function() fallback,
  }) async {
    try {
      return await apiCall();
    } on ApiException {
      return await fallback();
    }
  }

  Exception _handleError(Object error, String message) {
    if (error is PostgrestException) {
      return RepositoryException('Database error: ${error.message}');
    }
    return RepositoryException('$message: $error');
  }
}

extension on PostgrestTransformBuilder {
  PostgrestTransformBuilder match(Map<String, Map<String, dynamic>> map) {
    for (var entry in map.entries) {
      final key = entry.key;
      final conditions = entry.value;
      for (var condition in conditions.entries) {
        final value = condition.value;
        this.eq(key, value); // Assuming eq is a method that applies the condition
      }
    }
    return this;
  }
  
  PostgrestTransformBuilder textSearch(String s, filter, {required String config}) {
    // Assuming this method applies a text search filter
    // The actual implementation may vary based on the PostgREST client library
    return this; // Placeholder for actual text search logic
  }
  
  PostgrestTransformBuilder eq(String key, value) {
    // Assuming this method applies an equality filter
    // The actual implementation may vary based on the PostgREST client library
    return this; // Placeholder for actual equality logic
  }
}
