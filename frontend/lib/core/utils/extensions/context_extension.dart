// lib/core/utils/extensions/context_extension.dart
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

extension ContextExtensions on BuildContext {
  // Colors
  AppColors get colors => AppColors();

  // TextStyles
TextStyle get displayLarge => Theme.of(this).textTheme.displayLarge!;
TextStyle get titleLarge => Theme.of(this).textTheme.titleLarge!;
TextStyle get bodyLarge => Theme.of(this).textTheme.bodyLarge!;
TextStyle get bodyMedium => Theme.of(this).textTheme.bodyMedium!;

  // MediaQuery
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;

  // Navigation
  void pushNamed(String routeName, {Object? arguments}) {
    Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  void pushReplacementNamed(String routeName, {Object? arguments}) {
    Navigator.of(this).pushReplacementNamed(routeName, arguments: arguments);
  }

  void pop([result]) {
    Navigator.of(this).pop(result);
  }

  // Localization shortcut
  String translate(String key) {
    // This assumes you're using AppLocalizations
    // return AppLocalizations.of(this)!.translate(key);
    return key; // Fallback
  }
}
