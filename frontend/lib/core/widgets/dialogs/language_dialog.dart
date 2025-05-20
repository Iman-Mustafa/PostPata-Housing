import 'package:flutter/material.dart';
 // Import your localization file

class LanguageDialog extends StatelessWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLanguageSelected;

  const LanguageDialog({
    super.key,
    required this.currentLocale,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context); // Get localizations

    return AlertDialog(
      title: Text(l10n?.selectLanguage ?? 'Select Language'), // Safe navigation
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(l10n?.english ?? 'English'),
            leading: Radio<Locale>(
              value: const Locale('en'),
              groupValue: currentLocale,
              onChanged: (locale) {
                if (locale != null) {
                  onLanguageSelected(locale);
                  Navigator.pop(context);
                }
              },
            ),
          ),
          ListTile(
            title: Text(l10n?.swahili ?? 'Swahili'),
            leading: Radio<Locale>(
              value: const Locale('sw'),
              groupValue: currentLocale,
              onChanged: (locale) {
                if (locale != null) {
                  onLanguageSelected(locale);
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AppLocalizations {
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String? get selectLanguage => 'Select Language';
  String? get english => 'English';
  String? get swahili => 'Swahili';
}