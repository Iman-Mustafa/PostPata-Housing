import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Local imports - organized by feature
import 'core/constants/app_strings.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/property_repository.dart';
import 'data/services/connectivity_service.dart';
import 'presentation/controllers/auth/auth_controller.dart';
import 'presentation/controllers/property_controller.dart';
import 'presentation/router/app_router.dart';
import 'presentation/router/route_names.dart';
import 'services/api_service.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");

    // Initialize services
    final supabaseService = await SupabaseService().initialize();
    final connectivityService = ConnectivityService();
    final apiService = ApiService(
      baseUrl: dotenv.env['API_URL_DEV'] ?? 'http://localhost:3000/api',
      timeout: Duration(
        milliseconds: int.parse(dotenv.env['API_TIMEOUT'] ?? '30000'),
      ),
    );

    // Initialize repositories with dependencies
    final authRepository = AuthRepository(supabaseService.client, apiService);
    final propertyRepository = PropertyRepository(supabaseService.client, apiService);

    runApp(
      MultiProvider(
        providers: [
          // Services
          Provider<ApiService>.value(value: apiService),
          Provider<SupabaseService>.value(value: supabaseService),
          Provider<ConnectivityService>.value(value: connectivityService),

          // Repositories
          Provider<AuthRepository>.value(value: authRepository),
          Provider<PropertyRepository>.value(value: propertyRepository),

          // Controllers with auto-updating dependencies
          ChangeNotifierProxyProvider3<AuthRepository, ApiService, ConnectivityService, AuthController>(
            create: (context) => AuthController(
              context.read<AuthRepository>(),
              context.read<ApiService>(),
              context.read<ConnectivityService>(),
            ),
            update: (_, authRepo, apiService, connectivityService, controller) {
              controller!.updateAuthRepo(authRepo);
              controller.updateApiService(apiService);
              controller.updateConnectivityService(connectivityService);
              return controller;
            },
          ),
          
          ChangeNotifierProxyProvider3<PropertyRepository, ApiService, ConnectivityService, PropertyController>(
            create: (context) => PropertyController(
              context.read<PropertyRepository>(),
              context.read<ApiService>(),
              context.read<ConnectivityService>(),
            ),
            update: (_, propertyRepo, apiService, connectivityService, controller) {
              controller!.updatePropertyRepo(propertyRepo);
              controller.updateApiService(apiService);
              controller.updateConnectivityService(connectivityService);
              return controller;
            },
          ),

        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('Initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
    runApp(
      MaterialApp(
        home: ErrorScreen(
          error: e.toString(),
          stackTrace: stackTrace.toString(),
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String error;
  final String stackTrace;

  const ErrorScreen({super.key, required this.error, required this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 50, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'Initialization Error',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Please check your configuration and restart the app',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('sw', 'TZ')],
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: RouteNames.welcome,
      debugShowCheckedModeBanner: false,
    );
  }
}