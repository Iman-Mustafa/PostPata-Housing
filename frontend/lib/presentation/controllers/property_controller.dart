// lib/presentation/controllers/property_controller.dart
import 'package:flutter/material.dart';
import '../../data/models/property_model.dart';
import '../../data/repositories/property_repository.dart';

class PropertyController with ChangeNotifier {
  PropertyRepository _repository;
  List<PropertyModel> _allProperties = []; // Renamed from _properties
  List<PropertyModel> _featuredProperties = [];
  bool _isLoading = false;
  String? _errorMessage; // More descriptive name

  PropertyController(this._repository);

  // Public getters
  List<PropertyModel> get allProperties => _allProperties;
  List<PropertyModel> get featuredProperties => _featuredProperties;
  bool get isLoading => _isLoading;
  String? get error => _errorMessage;

  // Update repository reference
  void updatePropertyRepo(PropertyRepository repository) {
    if (_repository != repository) {
      _repository = repository;
      loadProperties();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load all properties
  Future<void> loadProperties() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final properties = await _repository.getAllProperties();
      final featured = await _repository.getFeaturedProperties();
      
      _allProperties = properties;
      _featuredProperties = featured;
    } catch (e) {
      _errorMessage = e.toString();
      if (_allProperties.isEmpty) rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new property
  Future<PropertyModel?> addProperty(PropertyModel property) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newProperty = await _repository.addProperty(property);
      _allProperties.insert(0, newProperty);
      
      // Add to featured if applicable
      if (newProperty.isFeatured) {
        _featuredProperties.insert(0, newProperty);
      }
      
      return newProperty;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete property
  Future<bool> deleteProperty(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteProperty(id);
      _allProperties.removeWhere((p) => p.id == id);
      _featuredProperties.removeWhere((p) => p.id == id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle featured status
  Future<bool> toggleFeaturedStatus(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final property = _allProperties.firstWhere((p) => p.id == id);
      final updatedProperty = property.copyWith(isFeatured: !property.isFeatured);
      
      await _repository.updateProperty(updatedProperty);
      
      // Update local lists
      _allProperties = _allProperties.map((p) => 
        p.id == id ? updatedProperty : p
      ).toList();
      
      if (updatedProperty.isFeatured) {
        _featuredProperties.insert(0, updatedProperty);
      } else {
        _featuredProperties.removeWhere((p) => p.id == id);
      }
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}