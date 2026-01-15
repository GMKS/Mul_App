import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized app state manager - Single source of truth for:
/// - City/Region selection
/// - User settings
/// - App configuration
class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // App initialization state
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _initError;
  bool _isFirstLaunch = true;

  // Region/City state
  String? _selectedCity;
  String? _selectedState;
  String? _selectedRegion;
  String? _selectedVillage;
  double? _latitude;
  double? _longitude;

  // User state
  bool _isLoggedIn = false;
  String? _userId;
  String? _userDisplayName;

  // Settings
  String _selectedLanguage = 'en';
  bool _notificationsEnabled = true;
  bool _darkMode = false;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get initError => _initError;
  bool get isFirstLaunch => _isFirstLaunch;

  String? get selectedCity => _selectedCity;
  String? get selectedState => _selectedState;
  String? get selectedRegion => _selectedRegion;
  String? get selectedVillage => _selectedVillage;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get hasRegion => _selectedCity != null && _selectedState != null;

  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get userDisplayName => _userDisplayName;

  String get selectedLanguage => _selectedLanguage;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkMode => _darkMode;

  // Default fallback values
  static const String defaultCity = 'Hyderabad';
  static const String defaultState = 'Telangana';
  static const String defaultRegion = 'South';

  /// Initialize app state from local storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    _initError = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load first launch status
      _isFirstLaunch = prefs.getBool('first_launch') ?? true;

      // Load region data
      _selectedCity = prefs.getString('user_city');
      _selectedState = prefs.getString('user_state');
      _selectedRegion = prefs.getString('user_region');
      _selectedVillage = prefs.getString('user_village');
      _latitude = prefs.getDouble('user_latitude');
      _longitude = prefs.getDouble('user_longitude');

      // Load settings
      _selectedLanguage = prefs.getString('selected_language') ?? 'en';
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? false;

      // Apply defaults if no region set
      if (_selectedCity == null || _selectedState == null) {
        await _applyDefaultRegion(prefs);
      }

      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _initError = 'Failed to initialize app: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _applyDefaultRegion(SharedPreferences prefs) async {
    _selectedCity = defaultCity;
    _selectedState = defaultState;
    _selectedRegion = defaultRegion;
    await prefs.setString('user_city', defaultCity);
    await prefs.setString('user_state', defaultState);
    await prefs.setString('user_region', defaultRegion);
  }

  /// Update selected city and persist
  Future<void> setCity({
    required String city,
    required String state,
    String? region,
    String? village,
    double? lat,
    double? lng,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _selectedCity = city;
    _selectedState = state;
    _selectedRegion = region;
    _selectedVillage = village;
    _latitude = lat;
    _longitude = lng;

    await prefs.setString('user_city', city);
    await prefs.setString('user_state', state);
    if (region != null) await prefs.setString('user_region', region);
    if (village != null) await prefs.setString('user_village', village);
    if (lat != null) await prefs.setDouble('user_latitude', lat);
    if (lng != null) await prefs.setDouble('user_longitude', lng);

    notifyListeners();

    // Trigger dependent data reload
    _onCityChanged();
  }

  /// Called when city changes - override in subclass or use listeners
  void _onCityChanged() {
    // This will be handled by listeners in the app
  }

  /// Update user login state
  void setUser({
    required bool isLoggedIn,
    String? userId,
    String? displayName,
  }) {
    _isLoggedIn = isLoggedIn;
    _userId = userId;
    _userDisplayName = displayName;
    notifyListeners();
  }

  /// Update language setting
  Future<void> setLanguage(String languageCode) async {
    _selectedLanguage = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);
    notifyListeners();
  }

  /// Update notifications setting
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    notifyListeners();
  }

  /// Update dark mode setting
  Future<void> setDarkMode(bool enabled) async {
    _darkMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', enabled);
    notifyListeners();
  }

  /// Mark first launch as complete
  Future<void> completeFirstLaunch() async {
    _isFirstLaunch = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
    notifyListeners();
  }

  /// Retry initialization after error
  Future<void> retryInitialization() async {
    _isInitialized = false;
    _initError = null;
    await initialize();
  }

  /// Clear all data (for logout/reset)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _selectedCity = null;
    _selectedState = null;
    _selectedRegion = null;
    _selectedVillage = null;
    _latitude = null;
    _longitude = null;
    _isLoggedIn = false;
    _userId = null;
    _userDisplayName = null;
    _isFirstLaunch = true;

    notifyListeners();
  }
}
