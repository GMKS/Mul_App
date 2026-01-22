import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'core/app_state.dart';
import 'core/route_manager.dart';
import 'core/app_logger.dart';
import 'controllers/local_alerts_controller.dart';
import 'controllers/event_controller.dart';
import 'controllers/devotional_controller.dart';
import 'providers/localization_provider.dart';
import 'services/notification_service.dart';
import 'services/connectivity_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/region_selection_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/local_alerts_screen.dart';
import 'screens/cab_services_screen.dart';
import 'features/regional/regional.dart';
import 'theme/app_theme.dart';

// Global navigator key - kept for backward compatibility
final GlobalKey<NavigatorState> navigatorKey = RouteManager.navigatorKey;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services with error handling
  await _initializeServices();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => LocalAlertsController()),
        ChangeNotifierProvider(create: (_) => EventController()),
        ChangeNotifierProvider(create: (_) => DevotionalController()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _initializeServices() async {
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    AppLogger.lifecycle('Firebase initialized');

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await NotificationService().init();
  } catch (e) {
    AppLogger.error('Firebase initialization failed', error: e);
  }

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: 'https://vwazacymtdhvynuglzph.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ3YXphY3ltdGRodnludWdsenBoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgyMzgzODksImV4cCI6MjA4MzgxNDM4OX0.IOuh5IHH9rcEcpdQlv0FJZChbO6aRJcLjo0XH9fPDw8',
    );
    AppLogger.lifecycle('Supabase initialized');
  } catch (e) {
    AppLogger.error('Supabase initialization failed', error: e);
  }

  // Initialize connectivity monitoring
  try {
    await ConnectivityService().init();
    AppLogger.lifecycle('Connectivity service initialized');
  } catch (e) {
    AppLogger.error('Connectivity service failed', error: e);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        return MaterialApp(
          navigatorKey: RouteManager.navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'My City App',
          theme: _buildTheme(),
          locale: localizationProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('te'), // Telugu
            Locale('hi'), // Hindi
            Locale('ta'), // Tamil
            Locale('kn'), // Kannada
            Locale('ml'), // Malayalam
            Locale('bn'), // Bengali
            Locale('mr'), // Marathi
            Locale('gu'), // Gujarati
            Locale('pa'), // Punjabi
          ],
          home: const SplashScreen(),
          onGenerateRoute: _generateRoute,
          onUnknownRoute: (settings) => MaterialPageRoute(
            builder: (_) => _NotFoundScreen(routeName: settings.name),
          ),
        );
      },
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: const TextTheme(
        titleLarge: AppTextStyles.headline1,
        titleMedium: AppTextStyles.headline2,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodySecondary,
        bodySmall: AppTextStyles.bodySmall,
      ),
      cardColor: AppColors.card,
      iconTheme: const IconThemeData(color: AppColors.icon),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdRadius,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdRadius,
          ),
          side: const BorderSide(color: AppColors.primary),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: AppSpacing.listItemPadding,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdRadius,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.smRadius,
        ),
      ),
      useMaterial3: true,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    AppLogger.navigation('Route requested', to: settings.name);

    switch (settings.name) {
      case RouteManager.splash:
        return _buildRoute(settings, const SplashScreen());

      case RouteManager.home:
        return _buildRoute(settings, const HomeScreen());

      case RouteManager.login:
        return _buildRoute(settings, LoginScreen());

      case RouteManager.regionSelection:
        return _buildRoute(settings, const RegionSelectionScreen());

      case RouteManager.languageSelection:
        return _buildRoute(settings, const LanguageSelectionScreen());

      case RouteManager.localAlerts:
        return _buildRoute(settings, const LocalAlertsScreen());

      case RouteManager.cabServices:
        return _buildRoute(settings, const CabServicesScreen());

      case RouteManager.regionalFeed:
        return _buildRoute(settings, const RegionalFeedScreen());

      default:
        return null;
    }
  }

  MaterialPageRoute<T> _buildRoute<T>(RouteSettings settings, Widget screen) {
    return MaterialPageRoute<T>(
      builder: (_) => screen,
      settings: settings,
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  final String? routeName;
  const _NotFoundScreen({this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Page not found',
                style: AppTextStyles.headline2,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                routeName ?? 'Unknown route',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () => RouteManager.goToHome(),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
