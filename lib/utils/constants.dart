import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Cornerly';
  static const String bundleId = 'com.cornerly.app';
  static const String defaultTimezone = 'America/Bogota';
  static const TimeOfDay defaultReminderTime = TimeOfDay(hour: 10, minute: 0);

  static const double filterAMaxLocalOdds = 1.38;
  static const double filterBMinLocalOdds = 2.05;
  static const double filterBMaxVisitorOdds = 3.30;
  static const double cornersLineA = 7.5;
  static const double cornersLineB = 11.5;

  static const int minTotalCornersForOver7 = 8;
  static const int maxTotalCornersForUnder11 = 11;

  static const String sofascoreBaseUrl = 'https://api.sofascore.com/api/v1';

  static const String notificationChannelId = 'cornerly_reminders';
  static const String notificationChannelName = 'Recordatorios Cornerly';
  static const String notificationChannelDescription = 'Recordatorio diario de análisis de partidos';

  static const String prefsUserProfile = 'user_profile';
  static const String prefsOnboardingDone = 'onboarding_done';
  static const String prefsReminderTime = 'reminder_time';
  static const String prefsCurrency = 'currency';
  static const String prefsRiskPct = 'risk_pct';
  static const String prefsNotificationsEnabled = 'notifications_enabled';
}
