import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/home_screen.dart';
import 'screens/phone_login_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

import 'package:provider/provider.dart';
import 'controllers/local_alerts_controller.dart';

// Global navigator key for NotificationService to access context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (with error handling)
  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialized successfully');

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Initialize Notification Service
    await NotificationService().init();
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
    debugPrint('⚠️ App will run without Firebase features');
    debugPrint('⚠️ Add google-services.json to enable Firebase');
  }

  // Initialize Supabase
  await Supabase.initialize(
    url:
        'https://vwazacymtdhvynuglzph.supabase.co', // TODO: Replace with your Supabase project URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ3YXphY3ltdGRodnludWdsenBoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgyMzgzODksImV4cCI6MjA4MzgxNDM4OX0.IOuh5IHH9rcEcpdQlv0FJZChbO6aRJcLjo0XH9fPDw8', // TODO: Replace with your Supabase anon key
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => LocalAlertsController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My City App',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          background: AppColors.background,
        ),
        textTheme: TextTheme(
          titleLarge: AppTextStyles.headline1,
          titleMedium: AppTextStyles.headline2,
          bodyLarge: AppTextStyles.body,
          bodyMedium: AppTextStyles.bodySecondary,
        ),
        cardColor: AppColors.card,
        iconTheme: IconThemeData(color: AppColors.icon),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: AuthService.isLoggedIn ? const HomeScreen() : LoginScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => LoginScreen(),
      },
      navigatorKey: navigatorKey,
    );
  }
}

// --- DEMO: Customer Side Alert Submission & Fetch ---
Future<void> submitLocalAlert() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  if (user == null) {
    // You should show a login screen or error
    debugPrint('User not logged in!');
    return;
  }
  await supabase.from('alert_submissions').insert({
    'title': '20% off on all medical equipment',
    'message': 'Limited time offer at MediCare Store',
    'area': 'Medchal-Malkajgiri',
    'locality': 'Kompally',
    'category': 'offer',
    'submitted_by': user.id,
  });
  debugPrint('Alert submitted for admin approval!');
}

Future<void> fetchApprovedAlerts() async {
  final supabase = Supabase.instance.client;
  final alerts = await supabase
      .from('local_alerts')
      .select()
      .eq('status', 'approved')
      .order('start_time', ascending: false);
  debugPrint('Approved alerts:');
  for (final alert in alerts) {
    debugPrint(alert.toString());
  }
}
