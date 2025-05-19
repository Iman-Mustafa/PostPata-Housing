// lib/presentation/router/route_names.dart
class RouteNames {
  // Auth Routes
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';
  
  // Main Routes
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  
  // Property Routes
  static const String propertyList = '/properties';
  static const String propertyDetail = '/property/:id';
  static const String addProperty = '/property/add';
  static const String editProperty = '/property/edit/:id';
  
  // Tenant Routes
  static const String favorites = '/tenant/favorites';
  static const String applications = '/tenant/applications';
  static const String paymentHistory = '/tenant/payments';
  
  // Landlord Routes
  static const String myProperties = '/landlord/properties';
  static const String rentalApplications = '/landlord/applications';
  static const String rentalPayments = '/landlord/payments';
  
  // Admin Routes
  static const String userManagement = '/admin/users';
  static const String reports = '/admin/reports';
  static const String systemSettings = '/admin/settings';
  
  // Helper Methods
  static String propertyDetailPath(String id) => '/property/$id';
  static String editPropertyPath(String id) => '/property/edit/$id';
}