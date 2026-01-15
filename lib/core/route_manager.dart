import 'package:flutter/material.dart';

/// Centralized route management
/// Prevents duplicate screen stacking and provides safe navigation
class RouteManager {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String phoneLogin = '/phone-login';
  static const String home = '/home';
  static const String regionSelection = '/region-selection';
  static const String languageSelection = '/language-selection';
  static const String localAlerts = '/local-alerts';
  static const String cabServices = '/cab-services';
  static const String settings = '/settings';
  static const String businessDashboard = '/business/dashboard';
  static const String businessAnalytics = '/business/analytics';
  static const String devotionalFeed = '/devotional/feed';
  static const String regionalFeed = '/regional/feed';

  /// Get current context safely
  static BuildContext? get currentContext => navigatorKey.currentContext;

  /// Navigate to a named route (replaces current)
  static Future<T?>? pushNamed<T>(String routeName, {Object? arguments}) {
    if (navigatorKey.currentState == null) return null;
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and remove all previous routes
  static Future<T?>? pushNamedAndRemoveUntil<T>(
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    if (navigatorKey.currentState == null) return null;
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Replace current route
  static Future<T?>? pushReplacementNamed<T, TO>(
    String routeName, {
    Object? arguments,
  }) {
    if (navigatorKey.currentState == null) return null;
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
    );
  }

  /// Pop current route safely
  static void pop<T>([T? result]) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState!.pop(result);
    }
  }

  /// Pop until a specific route
  static void popUntil(String routeName) {
    if (navigatorKey.currentState == null) return;
    navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }

  /// Check if can pop
  static bool canPop() {
    return navigatorKey.currentState?.canPop() ?? false;
  }

  /// Navigate to home and clear stack
  static void goToHome() {
    pushNamedAndRemoveUntil(home);
  }

  /// Navigate to login and clear stack
  static void goToLogin() {
    pushNamedAndRemoveUntil(login);
  }

  /// Navigate to onboarding (first launch)
  static void goToOnboarding() {
    pushNamedAndRemoveUntil(onboarding);
  }

  /// Prevent duplicate screen by checking current route
  static bool _isCurrentRoute(String routeName) {
    bool isCurrent = false;
    navigatorKey.currentState?.popUntil((route) {
      if (route.settings.name == routeName) {
        isCurrent = true;
      }
      return true;
    });
    return isCurrent;
  }

  /// Safe navigation - prevents duplicate screens
  static Future<T?>? safeNavigate<T>(String routeName, {Object? arguments}) {
    if (_isCurrentRoute(routeName)) {
      return null; // Already on this screen
    }
    return pushNamed<T>(routeName, arguments: arguments);
  }
}

/// Route generator for MaterialApp
class AppRouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Import screens lazily to avoid circular dependencies
    switch (settings.name) {
      case RouteManager.splash:
        return _buildRoute(
          settings,
          const _PlaceholderScreen(title: 'Splash'),
        );

      case RouteManager.home:
        return _buildRoute(
          settings,
          const _PlaceholderScreen(title: 'Home'),
        );

      case RouteManager.login:
        return _buildRoute(
          settings,
          const _PlaceholderScreen(title: 'Login'),
        );

      default:
        return _buildRoute(
          settings,
          _NotFoundScreen(routeName: settings.name),
        );
    }
  }

  static MaterialPageRoute<T> _buildRoute<T>(
    RouteSettings settings,
    Widget screen,
  ) {
    return MaterialPageRoute<T>(
      builder: (_) => screen,
      settings: settings,
    );
  }
}

/// Placeholder screen for lazy loading
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(title)),
    );
  }
}

/// 404 Not Found screen
class _NotFoundScreen extends StatelessWidget {
  final String? routeName;
  const _NotFoundScreen({this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Route not found: ${routeName ?? 'unknown'}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => RouteManager.goToHome(),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
