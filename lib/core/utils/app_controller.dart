import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../../features/common/models/support_message.dart';

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
  double _feedbackRating = 0;
  List<String> _feedbackTopics = [];
  String _feedbackNote = '';
  DateTime? _feedbackUpdatedAt;
  bool _highContrast = false;
  bool _reduceMotion = false;
  List<SupportMessage> _supportMessages = [];

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  Locale get locale => _locale;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isLoggedIn => _isLoggedIn;
  double get textScale => _textScale;
  bool get compactCards => _compactCards;
  bool get useGridLayout => _useGridLayout;
  bool get isReady => _isReady;
  double get feedbackRating => _feedbackRating;
  List<String> get feedbackTopics => List.unmodifiable(_feedbackTopics);
  String get feedbackNote => _feedbackNote;
  DateTime? get feedbackUpdatedAt => _feedbackUpdatedAt;
  bool get highContrast => _highContrast;
  bool get reduceMotion => _reduceMotion;
  List<SupportMessage> get supportMessages => List.unmodifiable(_supportMessages);
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
    _highContrast = prefs.getBool('highContrast') ?? false;
    _reduceMotion = prefs.getBool('reduceMotion') ?? false;
    _feedbackRating = prefs.getDouble('feedbackRating') ?? 0;
    final topicsRaw = prefs.getString('feedbackTopics');
    if (topicsRaw != null && topicsRaw.isNotEmpty) {
      _feedbackTopics = List<String>.from(jsonDecode(topicsRaw) as List<dynamic>);
    }
    _feedbackNote = prefs.getString('feedbackNote') ?? '';
    final feedbackTs = prefs.getInt('feedbackUpdatedAt');
    if (feedbackTs != null) {
      _feedbackUpdatedAt = DateTime.fromMillisecondsSinceEpoch(feedbackTs);
    }
    final supportRaw = prefs.getString('supportMessages');
    if (supportRaw != null && supportRaw.isNotEmpty) {
      final decoded = jsonDecode(supportRaw) as List<dynamic>;
      _supportMessages = decoded
          .map((entry) => SupportMessage.fromMap(Map<String, dynamic>.from(entry as Map<dynamic, dynamic>)))
          .toList();
    }
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

  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('highContrast', value);
    notifyListeners();
  }

  Future<void> setReduceMotion(bool value) async {
    _reduceMotion = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reduceMotion', value);
    notifyListeners();
  }

  Future<void> saveFeedback({required double rating, required List<String> topics, required String note}) async {
    _feedbackRating = rating;
    _feedbackTopics = topics;
    _feedbackNote = note;
    _feedbackUpdatedAt = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('feedbackRating', rating);
    await prefs.setString('feedbackTopics', jsonEncode(topics));
    await prefs.setString('feedbackNote', note);
    await prefs.setInt('feedbackUpdatedAt', _feedbackUpdatedAt!.millisecondsSinceEpoch);
    notifyListeners();
  }

  Future<void> clearFeedback() async {
    _feedbackRating = 0;
    _feedbackTopics = [];
    _feedbackNote = '';
    _feedbackUpdatedAt = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('feedbackRating');
    await prefs.remove('feedbackTopics');
    await prefs.remove('feedbackNote');
    await prefs.remove('feedbackUpdatedAt');
    notifyListeners();
  }

  Future<void> addSupportMessage(SupportMessage message) async {
    _supportMessages = [message, ..._supportMessages];
    await _persistSupportMessages();
    notifyListeners();
  }

  Future<void> toggleSupportResolved(String id) async {
    _supportMessages = _supportMessages
        .map((msg) => msg.id == id ? msg.copyWith(resolved: !msg.resolved) : msg)
        .toList();
    await _persistSupportMessages();
    notifyListeners();
  }

  Future<void> removeSupportMessage(String id) async {
    _supportMessages = _supportMessages.where((msg) => msg.id != id).toList();
    await _persistSupportMessages();
    notifyListeners();
  }

  Future<void> clearSupportMessages() async {
    _supportMessages = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('supportMessages');
    notifyListeners();
  }

  Future<void> _persistSupportMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('supportMessages', jsonEncode(_supportMessages.map((e) => e.toMap()).toList()));
  }
}
