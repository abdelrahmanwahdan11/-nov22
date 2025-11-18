import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../../features/common/models/document.dart';
import '../../features/common/models/support_message.dart';
import '../../features/common/models/reminder.dart';

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
  List<String> _journeyStepsCompleted = [];
  double _budgetTarget = 5000;
  List<String> _readinessCompleted = [];
  double _calcHomePrice = 450000;
  double _calcDownPayment = 10;
  double _calcRate = 6.0;
  int _calcYears = 20;
  List<Document> _documents = [];
  List<Reminder> _reminders = [];
  bool _offlineMode = false;
  bool _autoSync = true;
  DateTime? _lastSyncAt;
  List<String> _offlineCollections = ['favorites', 'visits', 'documents'];

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
  List<String> get journeyStepsCompleted => List.unmodifiable(_journeyStepsCompleted);
  double get budgetTarget => _budgetTarget;
  List<String> get readinessCompleted => List.unmodifiable(_readinessCompleted);
  double get calcHomePrice => _calcHomePrice;
  double get calcDownPayment => _calcDownPayment;
  double get calcRate => _calcRate;
  int get calcYears => _calcYears;
  List<Document> get documents => List.unmodifiable(_documents);
  List<Reminder> get reminders => List.unmodifiable(_reminders);
  bool get offlineMode => _offlineMode;
  bool get autoSync => _autoSync;
  DateTime? get lastSyncAt => _lastSyncAt;
  List<String> get offlineCollections => List.unmodifiable(_offlineCollections);
  Reminder? get nextReminder {
    if (_reminders.isEmpty) return null;
    final pending = _reminders.where((reminder) => !reminder.done).toList()
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    if (pending.isEmpty) return null;
    final now = DateTime.now();
    for (final reminder in pending) {
      if (!reminder.dueAt.isBefore(now)) return reminder;
    }
    return pending.first;
  }
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
    _offlineMode = prefs.getBool('offlineMode') ?? false;
    _autoSync = prefs.getBool('autoSync') ?? true;
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
    final syncTs = prefs.getInt('lastSyncAt');
    if (syncTs != null) {
      _lastSyncAt = DateTime.fromMillisecondsSinceEpoch(syncTs);
    }
    final supportRaw = prefs.getString('supportMessages');
    if (supportRaw != null && supportRaw.isNotEmpty) {
      final decoded = jsonDecode(supportRaw) as List<dynamic>;
      _supportMessages = decoded
          .map((entry) => SupportMessage.fromMap(Map<String, dynamic>.from(entry as Map<dynamic, dynamic>)))
          .toList();
    }
    final remindersRaw = prefs.getString('reminders');
    if (remindersRaw != null && remindersRaw.isNotEmpty) {
      final decoded = jsonDecode(remindersRaw) as List<dynamic>;
      _reminders = decoded
          .map((entry) => Reminder.fromMap(Map<String, dynamic>.from(entry as Map<dynamic, dynamic>)))
          .toList();
      _reminders.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    }
    final documentsRaw = prefs.getString('documents');
    if (documentsRaw != null && documentsRaw.isNotEmpty) {
      final decoded = jsonDecode(documentsRaw) as List<dynamic>;
      _documents = decoded
          .map((entry) => Document.fromMap(Map<String, dynamic>.from(entry as Map<dynamic, dynamic>)))
          .toList();
    }
    _journeyStepsCompleted = prefs.getStringList('journeyStepsCompleted') ?? [];
    _budgetTarget = (prefs.getDouble('budgetTarget') ?? 5000).clamp(1000, 20000).toDouble();
    _readinessCompleted = prefs.getStringList('readinessCompleted') ?? [];
    _calcHomePrice = (prefs.getDouble('calcHomePrice') ?? 450000).clamp(50000, 1500000);
    _calcDownPayment = (prefs.getDouble('calcDownPayment') ?? 10).clamp(0, 80);
    _calcRate = (prefs.getDouble('calcRate') ?? 6.0).clamp(0, 25);
    _calcYears = (prefs.getInt('calcYears') ?? 20).clamp(5, 35);
    _offlineCollections = prefs.getStringList('offlineCollections') ?? _offlineCollections;
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

  Future<void> setOfflineMode(bool value) async {
    _offlineMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('offlineMode', value);
    notifyListeners();
  }

  Future<void> setAutoSync(bool value) async {
    _autoSync = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoSync', value);
    notifyListeners();
  }

  Future<void> updateOfflineCollections(List<String> collections) async {
    _offlineCollections = collections;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('offlineCollections', collections);
    notifyListeners();
  }

  Future<void> markSyncedNow() async {
    _lastSyncAt = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastSyncAt', _lastSyncAt!.millisecondsSinceEpoch);
    notifyListeners();
  }

  Future<void> clearOfflineCache() async {
    _lastSyncAt = null;
    _offlineMode = false;
    _autoSync = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lastSyncAt');
    await prefs.remove('offlineMode');
    await prefs.remove('autoSync');
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

  Future<void> addReminder(Reminder reminder) async {
    _reminders = [..._reminders, reminder]..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    await _persistReminders();
    notifyListeners();
  }

  Future<void> toggleReminderDone(String id) async {
    _reminders = _reminders
        .map((reminder) => reminder.id == id ? reminder.copyWith(done: !reminder.done) : reminder)
        .toList();
    await _persistReminders();
    notifyListeners();
  }

  Future<void> removeReminder(String id) async {
    _reminders = _reminders.where((reminder) => reminder.id != id).toList();
    await _persistReminders();
    notifyListeners();
  }

  Future<void> clearReminders() async {
    _reminders = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('reminders');
    notifyListeners();
  }

  Future<void> _persistSupportMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('supportMessages', jsonEncode(_supportMessages.map((e) => e.toMap()).toList()));
  }

  Future<void> _persistReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reminders', jsonEncode(_reminders.map((e) => e.toMap()).toList()));
  }

  Future<void> toggleJourneyStep(String id) async {
    if (_journeyStepsCompleted.contains(id)) {
      _journeyStepsCompleted.remove(id);
    } else {
      _journeyStepsCompleted.add(id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('journeyStepsCompleted', _journeyStepsCompleted);
    notifyListeners();
  }

  Future<void> resetJourneySteps() async {
    _journeyStepsCompleted.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('journeyStepsCompleted', _journeyStepsCompleted);
    notifyListeners();
  }

  Future<void> setBudgetTarget(double value) async {
    _budgetTarget = value.clamp(1000, 20000).toDouble();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('budgetTarget', _budgetTarget);
    notifyListeners();
  }

  Future<void> toggleReadiness(String id) async {
    if (_readinessCompleted.contains(id)) {
      _readinessCompleted.remove(id);
    } else {
      _readinessCompleted.add(id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('readinessCompleted', _readinessCompleted);
    notifyListeners();
  }

  Future<void> addDocument(Document document) async {
    _documents = [document, ..._documents];
    await _persistDocuments();
    notifyListeners();
  }

  Future<void> updateDocument(String id, {String? status, String? note}) async {
    _documents = _documents
        .map(
          (doc) => doc.id == id
              ? doc.copyWith(
                  status: status ?? doc.status,
                  note: note ?? doc.note,
                  updatedAt: DateTime.now(),
                )
              : doc,
        )
        .toList();
    await _persistDocuments();
    notifyListeners();
  }

  Future<void> removeDocument(String id) async {
    _documents = _documents.where((doc) => doc.id != id).toList();
    await _persistDocuments();
    notifyListeners();
  }

  Future<void> clearDocuments() async {
    _documents = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('documents');
    notifyListeners();
  }

  Future<void> _persistDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('documents', jsonEncode(_documents.map((e) => e.toMap()).toList()));
  }

  Future<void> resetReadiness() async {
    _readinessCompleted.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('readinessCompleted', _readinessCompleted);
    notifyListeners();
  }

  Future<void> updateCalculator({
    double? price,
    double? downPayment,
    double? rate,
    int? years,
  }) async {
    _calcHomePrice = (price ?? _calcHomePrice).clamp(50000, 1500000);
    _calcDownPayment = (downPayment ?? _calcDownPayment).clamp(0, 80);
    _calcRate = (rate ?? _calcRate).clamp(0, 25);
    _calcYears = (years ?? _calcYears).clamp(5, 35);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('calcHomePrice', _calcHomePrice);
    await prefs.setDouble('calcDownPayment', _calcDownPayment);
    await prefs.setDouble('calcRate', _calcRate);
    await prefs.setInt('calcYears', _calcYears);
    notifyListeners();
  }
}
