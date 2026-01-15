/// Language Filter Widget
/// Dropdown for selecting content language in the regional feed

import 'package:flutter/material.dart';

import '../models/models.dart';

class LanguageFilterWidget extends StatelessWidget {
  final String? selectedLanguage;
  final List<LanguageOption> availableLanguages;
  final ValueChanged<String> onLanguageChanged;
  final bool showNativeName;

  const LanguageFilterWidget({
    super.key,
    required this.selectedLanguage,
    this.availableLanguages = LanguageOption.indianLanguages,
    required this.onLanguageChanged,
    this.showNativeName = true,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: selectedLanguage,
      onSelected: onLanguageChanged,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.grey[900],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey[700]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.language,
              size: 18,
              color: Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              _getSelectedLanguageName(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Colors.white70,
            ),
          ],
        ),
      ),
      itemBuilder: (context) {
        return availableLanguages.map((lang) {
          final isSelected = lang.code == selectedLanguage;
          return PopupMenuItem<String>(
            value: lang.code,
            child: Row(
              children: [
                if (isSelected)
                  const Icon(
                    Icons.check,
                    size: 18,
                    color: Colors.green,
                  )
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lang.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (showNativeName && lang.nativeName != lang.name)
                        Text(
                          lang.nativeName,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  String _getSelectedLanguageName() {
    final language = LanguageOption.getByCode(selectedLanguage ?? 'en');
    if (showNativeName && language != null) {
      return language.nativeName;
    }
    return language?.name ?? 'Language';
  }
}

/// Compact language filter chip
class LanguageFilterChip extends StatelessWidget {
  final String? selectedLanguage;
  final VoidCallback onTap;

  const LanguageFilterChip({
    super.key,
    required this.selectedLanguage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final language = LanguageOption.getByCode(selectedLanguage ?? 'en');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF).withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              language?.nativeName ?? 'Language',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}

/// Language selection bottom sheet
class LanguageSelectionSheet extends StatelessWidget {
  final String? selectedLanguage;
  final List<LanguageOption> availableLanguages;
  final ValueChanged<String> onLanguageSelected;

  const LanguageSelectionSheet({
    super.key,
    required this.selectedLanguage,
    this.availableLanguages = LanguageOption.indianLanguages,
    required this.onLanguageSelected,
  });

  static Future<String?> show(
    BuildContext context, {
    String? selectedLanguage,
    List<LanguageOption>? availableLanguages,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return LanguageSelectionSheet(
          selectedLanguage: selectedLanguage,
          availableLanguages:
              availableLanguages ?? LanguageOption.indianLanguages,
          onLanguageSelected: (language) {
            Navigator.pop(context, language);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.language,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Select Language',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.grey),

          // Language list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableLanguages.length,
              itemBuilder: (context, index) {
                final language = availableLanguages[index];
                final isSelected = language.code == selectedLanguage;

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.2)
                          : Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        language.code.toUpperCase(),
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    language.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    language.nativeName,
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                  onTap: () => onLanguageSelected(language.code),
                );
              },
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}
