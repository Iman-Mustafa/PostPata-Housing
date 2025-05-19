import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/core/constants/app_strings.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:provider/provider.dart';

import 'data/repositories/property_repository.dart';
import 'presentation/controllers/auth/auth_controller.dart';
import 'presentation/controllers/property_controller.dart';
import 'presentation/router/app_router.dart';
import 'presentation/router/route_names.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  final supabaseService = SupabaseService();
  await supabaseService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>(
          create: (_) => AuthRepository(supabaseService.client),
        ),
        Provider<PropertyRepository>(
          create: (_) => PropertyRepository(supabaseService.client),
        ),
        ChangeNotifierProxyProvider<AuthRepository, AuthController>(
          create: (context) => AuthController(context.read<AuthRepository>()),
          update: (context, authRepo, authController) => 
              authController!..updateAuthRepo(authRepo),
        ),
        ChangeNotifierProxyProvider<PropertyRepository, PropertyController>(
          create: (context) => PropertyController(context.read<PropertyRepository>()),
          update: (context, propertyRepo, propertyController) => 
              propertyController!..updatePropertyRepo(propertyRepo),
        ),
      ],
      child: const MyApp(),
    ),
  );
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('sw', 'TZ'), // Swahili
      ],
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: RouteNames.welcome,
    );
  }
}