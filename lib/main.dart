import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/phone_login_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url:
        'https://vwazacymtdhvynuglzph.supabase.co', // TODO: Replace with your Supabase project URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ3YXphY3ltdGRodnludWdsenBoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgyMzgzODksImV4cCI6MjA4MzgxNDM4OX0.IOuh5IHH9rcEcpdQlv0FJZChbO6aRJcLjo0XH9fPDw8', // TODO: Replace with your Supabase anon key
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My City App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: AuthService.isLoggedIn ? const HomeScreen() : PhoneLoginScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => PhoneLoginScreen(),
      },
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
