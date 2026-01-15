/// Empty and Error State Widgets
/// User-friendly states for the regional feed

import 'package:flutter/material.dart';

/// Empty state when no videos are available
class EmptyFeedState extends StatelessWidget {
  final String? city;
  final String? language;
  final VoidCallback? onChangeLocation;
  final VoidCallback? onChangeLanguage;
  final VoidCallback? onRefresh;

  const EmptyFeedState({
    super.key,
    this.city,
    this.language,
    this.onChangeLocation,
    this.onChangeLanguage,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.video_library_outlined,
                  size: 60,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'No Videos Yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                _getDescription(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onChangeLocation != null)
                    _ActionButton(
                      icon: Icons.location_on,
                      label: 'Change City',
                      onTap: onChangeLocation!,
                    ),
                  if (onChangeLocation != null && onChangeLanguage != null)
                    const SizedBox(width: 16),
                  if (onChangeLanguage != null)
                    _ActionButton(
                      icon: Icons.language,
                      label: 'Change Language',
                      onTap: onChangeLanguage!,
                    ),
                ],
              ),

              if (onRefresh != null) ...[
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getDescription() {
    if (city != null && language != null) {
      return 'There are no videos available for $city in your selected language yet. Try changing your location or language preferences.';
    } else if (city != null) {
      return 'There are no videos available for $city yet. Be the first to share content from your city!';
    } else if (language != null) {
      return 'There are no videos available in your selected language yet. Try a different language.';
    }
    return 'No videos are available right now. Pull down to refresh or try different filters.';
  }
}

/// Error state when feed fails to load
class ErrorFeedState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final bool isNetworkError;

  const ErrorFeedState({
    super.key,
    this.message,
    this.onRetry,
    this.isNetworkError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNetworkError ? Icons.wifi_off : Icons.error_outline,
                size: 50,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              isNetworkError
                  ? 'No Internet Connection'
                  : 'Something Went Wrong',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message ??
                  (isNetworkError
                      ? 'Please check your internet connection and try again.'
                      : 'We couldn\'t load the videos. Please try again.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Retry button
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Loading state with custom message
class LoadingFeedState extends StatelessWidget {
  final String? message;

  const LoadingFeedState({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// No results state for search
class NoResultsState extends StatelessWidget {
  final String query;
  final VoidCallback? onClearSearch;

  const NoResultsState({
    super.key,
    required this.query,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 24),
            Text(
              'No Results Found',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We couldn\'t find any videos matching "$query"',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            if (onClearSearch != null) ...[
              const SizedBox(height: 24),
              TextButton(
                onPressed: onClearSearch,
                child: const Text('Clear Search'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.grey[700]!),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
}
