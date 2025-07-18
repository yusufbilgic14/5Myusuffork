import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('tr');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['tr', 'en'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
  }
}
