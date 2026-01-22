import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  String get currentLanguageCode => Localizations.localeOf(this).languageCode;

  bool get isEnglish => currentLanguageCode == 'en';
  bool get isTelugu => currentLanguageCode == 'te';
  bool get isHindi => currentLanguageCode == 'hi';
}
