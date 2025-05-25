import 'package:flutter/material.dart';
import 'package:frontend/data/services/connectivity_service.dart';
import '../../data/models/property_model.dart';
import '../../data/repositories/property_repository.dart';
import '../../services/api_service.dart';

class PropertyController with ChangeNotifier {
  // Dependencies
  PropertyRepository _repository;
  ApiService _apiService;
  ConnectivityService _connectivityService;

  // State
  List<PropertyModel> _properties = [];
  List<PropertyModel> _featuredProperties = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasConnection = true;

  // Constructor
  PropertyController(
    this._repository,
    this._apiService,
    this._connectivityService,
  ) {
    _initConnectivityListener();
  }

  // Getters
  List<PropertyModel> get properties => _properties;
  List<PropertyModel> get allProperties => _properties;
  List<PropertyModel> get featuredProperties => _featuredProperties;
  bool get isLoading => _isLoading;
  String? get error => _errorMessage;
  bool get hasConnection => _hasConnection;

  // Dependency update methods
  void updatePropertyRepo(PropertyRepository repository) {
    if (_repository != repository) {
      _repository = repository;
      loadProperties(); // Refresh data when repository changes
    }
  }

  void updateApiService(ApiService service) {
    if (_apiService != service) {
      _apiService = service;
      notifyListeners();
    }
  }

  void updateConnectivityService(ConnectivityService service) {
    if (_connectivityService != service) {
      _connectivityService = service;
      _initConnectivityListener();
      notifyListeners();
    }
  }

  // Connectivity handling
  void _initConnectivityListener() {
    _connectivityService.onConnectivityChanged.listen((isConnected) {
      _hasConnection = isConnected;
      notifyListeners();
      if (isConnected && _properties.isEmpty) {
        loadProperties();
      }
    });
  }

  // Load properties with connectivity check
  Future<void> loadProperties() async {
    if (_isLoading) return;

    if (!await _connectivityService.isConnected()) {
      _errorMessage = 'No internet connection';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedProperties = await _repository.getAllProperties();
      final featured = await _repository.getFeaturedProperties();

      _properties = fetchedProperties;
      _featuredProperties = featured;
    } catch (e) {
      _errorMessage = _translateError(e.toString());
      if (_properties.isEmpty) rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add property with validation
  Future<PropertyModel?> addProperty(PropertyModel property) async {
    if (!await _validateOperation()) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final newProperty = await _repository.addProperty(property);
      _properties.insert(0, newProperty);

      if (newProperty.isFeatured) {
        _featuredProperties.insert(0, newProperty);
      }

      return newProperty;
    } catch (e) {
      _errorMessage = _translateError(e.toString());
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper methods
  Future<bool> _validateOperation() async {
    if (!await _connectivityService.isConnected()) {
      _errorMessage = 'No internet connection';
      notifyListeners();
      return false;
    }
    return true;
  }

  String _translateError(String error) {
    if (error.contains('network')) {
      return 'Network error. Please check your connection';
    }
    if (error.contains('not found')) {
      return 'Property not found';
    }
    if (error.contains('permission')) {
      return 'You don\'t have permission to perform this action';
    }
    return 'Operation failed. Please try again';
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}
