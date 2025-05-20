// lib/presentation/router/route_names.dart
class RouteNames {
  // Auth Routes
  static const String splash = '/'; // Initial route for splash screen
  static const String welcome = '/welcome'; // Welcome screen for onboarding
  static const String login = '/login'; // Login screen
  static const String register = '/register'; // Registration screen
  static const String otp = '/otp'; // OTP verification screen
  static const String forgotPassword = '/forgot-password'; // Forgot password screen
  
  // Main Routes
  static const String home = '/home'; // Main home screen
  static const String profile = '/profile'; // User profile screen
  static const String settings = '/settings'; // Settings screen
  
  // Property Routes
  static const String propertyList = '/properties'; // List of properties
  static const String propertyDetail = '/property/:id'; // Dynamic route for property details
  static const String addProperty = '/property/add'; // Add new property screen
  static const String editProperty = '/property/edit/:id'; // Dynamic route for editing a property
  
  // Tenant Routes
  static const String favorites = '/tenant/favorites'; // Tenant's favorite properties
  static const String applications = '/tenant/applications'; // Tenant's rental applications
  static const String paymentHistory = '/tenant/payments'; // Tenant's payment history
  
  // Landlord Routes
  static const String myProperties = '/landlord/properties'; // Landlord's properties
  static const String rentalApplications = '/landlord/applications'; // Landlord's rental applications
  static const String rentalPayments = '/landlord/payments'; // Landlord's payment records
  
  // Admin Routes
  static const String userManagement = '/admin/users'; // Admin user management
  static const String reports = '/admin/reports'; // Admin reports
  static const String systemSettings = '/admin/settings'; // Admin system settings
  
  // Helper Methods for Dynamic Routes
  static String propertyDetailPath(String id) => '/property/$id'; // Helper for property detail route
  static String editPropertyPath(String id) => '/property/edit/$id'; // Helper for edit property route
}