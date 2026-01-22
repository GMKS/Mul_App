import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Example widget demonstrating localization usage
///
/// This shows how to convert hardcoded strings to localized versions
class LocalizationExample extends StatelessWidget {
  const LocalizationExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the localization instance
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        // Before: title: Text('Regional')
        // After:
        title: Text(l10n.regional),
      ),
      body: ListView(
        children: [
          // Service Cards Example
          ListTile(
            // Before: title: Text('Cab Services')
            // After:
            title: Text(l10n.cabServices),
            leading: const Icon(Icons.local_taxi),
          ),
          ListTile(
            // Before: title: Text('Local Alerts')
            // After:
            title: Text(l10n.localAlerts),
            leading: const Icon(Icons.notifications_active),
          ),
          ListTile(
            // Before: title: Text('Marketplace & Classifieds')
            // After:
            title: Text(l10n.marketplaceAndClassifieds),
            leading: const Icon(Icons.storefront),
          ),
          ListTile(
            // Before: title: Text('Community Help')
            // After:
            title: Text(l10n.communityHelp),
            leading: const Icon(Icons.people),
          ),
          ListTile(
            // Before: title: Text('Home Services')
            // After:
            title: Text(l10n.homeServices),
            leading: const Icon(Icons.home_repair_service),
          ),

          const Divider(),

          // Action Buttons Example
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  // Before: label: Text('Call')
                  // After:
                  onPressed: () {},
                  icon: const Icon(Icons.phone),
                  label: Text(l10n.call),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  // Before: label: Text('Book')
                  // After:
                  onPressed: () {},
                  icon: const Icon(Icons.book_online),
                  label: Text(l10n.book),
                ),
              ],
            ),
          ),

          const Divider(),

          // Formatted Strings Example
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Distance
                // Before: Text('5 km away')
                // After:
                Text(l10n.kmAway('5')),

                const SizedBox(height: 8),

                // Price per hour
                // Before: Text('₹100/hour')
                // After:
                Text(l10n.perHour('100')),

                const SizedBox(height: 8),

                // Rating
                // Before: Text('4.5 ★')
                // After:
                Text(l10n.rating('4.5')),

                const SizedBox(height: 8),

                // Years experience
                // Before: Text('5 years experience')
                // After:
                Text(l10n.yearsExperience('5')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shorter syntax using extension
/// Add this import: import '../utils/localization_extension.dart';
class ShortSyntaxExample extends StatelessWidget {
  const ShortSyntaxExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Using extension for cleaner code
        title: Text(context.l10n.regional),
      ),
      body: Column(
        children: [
          Text(context.l10n.cabServices),
          Text(context.l10n.marketplaceAndClassifieds),
          Text(context.l10n.homeServices),
          ElevatedButton(
            onPressed: () {},
            child: Text(context.l10n.call),
          ),
        ],
      ),
    );
  }
}
