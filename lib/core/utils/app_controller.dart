import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

class AppController extends ChangeNotifier {
  AppController() {
    _loadPreferences();
  }

  ThemeMode _themeMode = ThemeMode.light;
  Color _primaryColor = AppTheme.defaultPrimary;
  Locale _locale = const Locale('ar');
  bool _hasSeenOnboarding = false;
  bool _isLoggedIn = false;
  bool _isReady = false;

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  Locale get locale => _locale;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isLoggedIn => _isLoggedIn;
  bool get isReady => _isReady;

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? ThemeMode.light.index];
    final colorValue = prefs.getInt('primaryColor') ?? AppTheme.defaultPrimary.value;
    _primaryColor = Color(colorValue);
    _locale = Locale(prefs.getString('locale') ?? 'ar');
    _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _isReady = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', color.value);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    notifyListeners();
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    _hasSeenOnboarding = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', value);
    notifyListeners();
  }

  Future<void> setLoggedIn(bool value) async {
    _isLoggedIn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
    notifyListeners();
  }
}
