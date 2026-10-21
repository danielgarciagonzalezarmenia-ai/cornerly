import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class PrefsService {
  static SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<bool> get onboardingDone async =>
      (await prefs).getBool(AppConstants.prefsOnboardingDone) ?? false;

  Future<void> setOnboardingDone(bool value) async =>
      (await prefs).setBool(AppConstants.prefsOnboardingDone, value);

  Future<String?> get reminderTime async =>
      (await prefs).getString(AppConstants.prefsReminderTime);

  Future<void> setReminderTime(String time) async =>
      (await prefs).setString(AppConstants.prefsReminderTime, time);

  Future<String?> get currency async =>
      (await prefs).getString(AppConstants.prefsCurrency);

  Future<void> setCurrency(String currency) async =>
      (await prefs).setString(AppConstants.prefsCurrency, currency);

  Future<double> get riskPct async =>
      (await prefs).getDouble(AppConstants.prefsRiskPct) ?? 5.0;

  Future<void> setRiskPct(double pct) async =>
      (await prefs).setDouble(AppConstants.prefsRiskPct, pct);

  Future<bool> get notificationsEnabled async =>
      (await prefs).getBool(AppConstants.prefsNotificationsEnabled) ?? false;

  Future<void> setNotificationsEnabled(bool value) async =>
      (await prefs).setBool(AppConstants.prefsNotificationsEnabled, value);

  Future<void> clear() async => (await prefs).clear();
}
