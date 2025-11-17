import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

class AppController extends ChangeNotifier {
  AppController() {
    _loadPreferences();
  }

  final Completer<void> _readyCompleter = Completer<void>();

  ThemeMode _themeMode = ThemeMode.light;
  Color _primaryColor = AppTheme.defaultPrimary;
  Locale _locale = const Locale('ar');
  bool _hasSeenOnboarding = false;
  bool _isLoggedIn = false;
  double _textScale = 1.0;
  bool _compactCards = false;
  bool _useGridLayout = true;
  bool _isReady = false;

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  Locale get locale => _locale;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isLoggedIn => _isLoggedIn;
  double get textScale => _textScale;
  bool get compactCards => _compactCards;
  bool get useGridLayout => _useGridLayout;
  bool get isReady => _isReady;
  Future<void> get ready => _readyCompleter.future;

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final storedThemeIndex = prefs.getInt('themeMode');
    if (storedThemeIndex != null &&
        storedThemeIndex >= 0 &&
        storedThemeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[storedThemeIndex];
    } else {
      _themeMode = ThemeMode.light;
    }
    final colorValue = prefs.getInt('primaryColor') ?? AppTheme.defaultPrimary.value;
    _primaryColor = Color(colorValue);
    _locale = Locale(prefs.getString('locale') ?? 'ar');
    _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _textScale = (prefs.getDouble('textScale') ?? 1.0).clamp(0.9, 1.2).toDouble();
    _compactCards = prefs.getBool('compactCards') ?? false;
    _useGridLayout = prefs.getBool('useGridLayout') ?? true;
    _isReady = true;
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
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

  Future<void> setTextScale(double value) async {
    _textScale = value.clamp(0.9, 1.2).toDouble();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textScale', _textScale);
    notifyListeners();
  }

  Future<void> setCompactCards(bool value) async {
    _compactCards = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('compactCards', value);
    notifyListeners();
  }

  Future<void> setUseGridLayout(bool value) async {
    _useGridLayout = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useGridLayout', value);
    notifyListeners();
  }
}
