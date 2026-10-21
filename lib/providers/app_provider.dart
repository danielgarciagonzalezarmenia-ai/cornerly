import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/data_models.dart';
import '../services/database_service.dart';
import '../services/analysis_service.dart';
import '../services/notification_service.dart';
import '../services/prefs_service.dart';
import '../utils/constants.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _db;
  final AnalysisService _analysis;
  final NotificationService _notifications;
  final PrefsService _prefs;

  UserProfile? _profile;
  List<AnalyzedMatch> _todaysMatches = [];
  List<Parlay> _parlays = [];
  List<BalanceMovement> _movements = [];
  bool _isLoading = true;
  bool _hasOnboarded = false;
  bool _analysisDoneToday = false;

  AppProvider(this._db, this._analysis, this._notifications, this._prefs);

  UserProfile? get profile => _profile;
  List<AnalyzedMatch> get todaysMatches => _todaysMatches;
  List<Parlay> get parlays => _parlays;
  List<BalanceMovement> get movements => _movements;
  bool get isLoading => _isLoading;
  bool get hasOnboarded => _hasOnboarded;
  bool get analysisDoneToday => _analysisDoneToday;

  Future<void> init() async {
    _profile = await _db.getUserProfile();
    _hasOnboarded = await _prefs.onboardingDone;
    _analysisDoneToday = await _analysis.hasAnalysisToday();
    await _loadTodaysMatches();
    await _loadParlays();
    await _loadMovements();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadTodaysMatches() async {
    _todaysMatches = await _analysis.getTodaysMatches();
  }

  Future<void> _loadParlays() async {
    _parlays = await _db.getAllParlays();
  }

  Future<void> _loadMovements() async {
    _movements = await _db.getBalanceMovements();
  }

  Future<void> createProfile({
    required String name,
    required String currency,
    required String currencySymbol,
    required double balance,
    required String experience,
    required double riskMaxPct,
    required String reminderTime,
  }) async {
    _isLoading = true;
    notifyListeners();

    final profile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      currency: currency,
      currencySymbol: currencySymbol,
      balance: balance,
      experience: experience,
      riskMaxPct: riskMaxPct,
      reminderTime: reminderTime,
    );
    await _db.saveUserProfile(profile);
    await _prefs.setCurrency(currency);
    await _prefs.setReminderTime(reminderTime);
    await _prefs.setRiskPct(riskMaxPct);

    _profile = profile;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasOnboarded = true;
    await _prefs.setOnboardingDone(true);
    await _notifications.init();
    await _notifications.requestPermissions();
    final time = _profile?.reminderTime ?? '10:00';
    final parts = time.split(':');
    await _notifications.scheduleDailyReminder(int.parse(parts[0]), int.parse(parts[1]));
    notifyListeners();
  }

  Future<void> runAnalysis() async {
    _isLoading = true;
    notifyListeners();

    final result = await _analysis.runDailyAnalysis();
    _todaysMatches = result.matches;
    _analysisDoneToday = !result.hasError;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name, String? currency, String? currencySymbol,
    double? balance, String? experience, double? riskMaxPct,
    String? reminderTime, bool? notificationsEnabled,
  }) async {
    if (_profile == null) return;
    _profile = _profile!.copyWith(
      name: name, currency: currency, currencySymbol: currencySymbol,
      balance: balance, experience: experience, riskMaxPct: riskMaxPct,
      reminderTime: reminderTime, notificationsEnabled: notificationsEnabled,
    );
    await _db.saveUserProfile(_profile!);
    if (currency != null) await _prefs.setCurrency(currency);
    if (reminderTime != null) await _prefs.setReminderTime(reminderTime);
    if (riskMaxPct != null) await _prefs.setRiskPct(riskMaxPct);
    if (notificationsEnabled != null) await _prefs.setNotificationsEnabled(notificationsEnabled);
    notifyListeners();
  }

  void addToBalance(double amount, {String type = 'deposit'}) {
    if (_profile == null) return;
    final newBalance = _profile!.balance + amount;
    _profile = _profile!.copyWith(balance: newBalance);
    final movement = BalanceMovement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      type: type,
      amount: amount,
      resultingBalance: newBalance,
    );
    _db.saveUserProfile(_profile!);
    _db.saveBalanceMovement(movement);
    _movements.insert(0, movement);
    notifyListeners();
  }

  void subtractFromBalance(double amount, {String type = 'bet'}) {
    if (_profile == null) return;
    final newBalance = _profile!.balance - amount;
    _profile = _profile!.copyWith(balance: newBalance);
    final movement = BalanceMovement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      type: type,
      amount: -amount,
      resultingBalance: newBalance,
    );
    _db.saveUserProfile(_profile!);
    _db.saveBalanceMovement(movement);
    _movements.insert(0, movement);
    notifyListeners();
  }

  Future<void> createParlay(double amount, List<String> eventIds, double totalOdds) async {
    final potentialWin = amount * totalOdds;
    subtractFromBalance(amount, type: 'bet');

    final parlay = Parlay(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      amount: amount,
      totalOdds: totalOdds,
      potentialWin: potentialWin,
      legEventIds: eventIds,
    );
    await _db.saveParlay(parlay);
    _parlays.insert(0, parlay);
    notifyListeners();
  }

  Future<void> resolveParlay(String parlayId, String status) async {
    final parlay = _parlays.firstWhere((p) => p.id == parlayId);
    await _db.updateParlayStatus(parlayId, status, resolvedAt: DateTime.now());
    parlay.status = status;
    parlay.resolvedAt = DateTime.now();

    if (status == 'won') {
      addToBalance(parlay.amount * parlay.totalOdds, type: 'win');
    }

    await _notifications.scheduleParlayResultNotification(
      id: parlayId.hashCode.abs(),
      title: status == 'won' ? '¡Combinada ganada!' : 'Combinada perdida',
      body: status == 'won'
          ? '¡+${(parlay.amount * parlay.totalOdds).toStringAsFixed(0)} ${_profile?.currencySymbol ?? _profile?.currency}!'
          : 'Tu combinada se ha resuelto como perdida.',
    );

    notifyListeners();
  }

  Future<void> clearAllData() async {
    await _db.clearAllData();
    await _prefs.clear();
    _profile = null;
    _todaysMatches = [];
    _parlays = [];
    _movements = [];
    _hasOnboarded = false;
    _analysisDoneToday = false;
    _isLoading = false;
    notifyListeners();
  }

  double get totalWinnings {
    return _parlays.where((p) => p.status == 'won').fold(0.0, (sum, p) => sum + p.amount * p.totalOdds);
  }

  double get totalLosses {
    return _parlays.where((p) => p.status == 'lost').fold(0.0, (sum, p) => sum + p.amount);
  }

  double get accuracyRate {
    final resolved = _parlays.where((p) => p.status == 'won' || p.status == 'lost').length;
    if (resolved == 0) return 0.0;
    final won = _parlays.where((p) => p.status == 'won').length;
    return (won / resolved) * 100;
  }
}

class AppProviderScope extends StatelessWidget {
  final Widget child;
  final DatabaseService db;
  final AnalysisService analysis;
  final NotificationService notifications;
  final PrefsService prefs;

  const AppProviderScope({
    super.key,
    required this.child,
    required this.db,
    required this.analysis,
    required this.notifications,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: db),
        Provider.value(value: analysis),
        Provider.value(value: notifications),
        Provider.value(value: prefs),
        ChangeNotifierProvider(create: (_) => AppProvider(db, analysis, notifications, prefs)),
      ],
      child: child,
    );
  }
}

AppProvider appProviderOf(BuildContext context) => Provider.of<AppProvider>(context, listen: false);
AppProvider appProviderWatch(BuildContext context) => Provider.of<AppProvider>(context, listen: true);
