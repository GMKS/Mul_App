import 'package:flutter/foundation.dart';

/// Lightweight structured logging for the app
/// Logs navigation, city selection, data loading, and errors
class AppLogger {
  static bool _enabled = !kReleaseMode;

  /// Enable or disable logging
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Log navigation events
  static void navigation(String event,
      {String? from, String? to, Map<String, dynamic>? data}) {
    if (!_enabled) return;
    _log('NAV', event, {
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (data != null) ...data,
    });
  }

  /// Log city/region selection events
  static void citySelection(String event,
      {String? city, String? state, String? region}) {
    if (!_enabled) return;
    _log('CITY', event, {
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (region != null) 'region': region,
    });
  }

  /// Log data loading events
  static void dataLoad(String event,
      {String? source, int? count, Duration? duration}) {
    if (!_enabled) return;
    _log('DATA', event, {
      if (source != null) 'source': source,
      if (count != null) 'count': count,
      if (duration != null) 'duration_ms': duration.inMilliseconds,
    });
  }

  /// Log user actions
  static void userAction(String action, {Map<String, dynamic>? data}) {
    if (!_enabled) return;
    _log('USER', action, data ?? {});
  }

  /// Log errors
  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    if (!_enabled) return;
    _log('ERROR', message, {
      'error': error?.toString(),
      if (stackTrace != null)
        'stack': stackTrace.toString().split('\n').take(5).join('\n'),
    });
  }

  /// Log info messages
  static void info(String message, {Map<String, dynamic>? data}) {
    if (!_enabled) return;
    _log('INFO', message, data ?? {});
  }

  /// Log warning messages
  static void warning(String message, {Map<String, dynamic>? data}) {
    if (!_enabled) return;
    _log('WARN', message, data ?? {});
  }

  /// Log app lifecycle events
  static void lifecycle(String event, {Map<String, dynamic>? data}) {
    if (!_enabled) return;
    _log('LIFE', event, data ?? {});
  }

  /// Log API calls
  static void api(String endpoint,
      {String? method, int? statusCode, Duration? duration}) {
    if (!_enabled) return;
    _log('API', endpoint, {
      if (method != null) 'method': method,
      if (statusCode != null) 'status': statusCode,
      if (duration != null) 'duration_ms': duration.inMilliseconds,
    });
  }

  /// Internal log method
  static void _log(String tag, String message, Map<String, dynamic> data) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final dataStr = data.isNotEmpty ? ' | $data' : '';
    debugPrint('[$timestamp][$tag] $message$dataStr');
  }
}
