import 'package:cornerly/providers/app_provider.dart';
import 'package:cornerly/services/database_service.dart';
import 'package:cornerly/services/analysis_service.dart';
import 'package:cornerly/services/notification_service.dart';
import 'package:cornerly/services/prefs_service.dart';
import 'package:cornerly/services/sofascore_repository.dart';
import 'package:cornerly/theme/app_theme.dart';
import 'package:cornerly/ui/screens/dashboard_screen.dart';
import 'package:cornerly/ui/screens/historial_screen.dart';
import 'package:cornerly/ui/screens/menu_screen.dart';
import 'package:cornerly/ui/screens/onboarding_screen.dart';
import 'package:cornerly/ui/screens/progress_screen.dart';
import 'package:cornerly/ui/screens/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const CornerlyApp());
}

class CornerlyApp extends StatefulWidget {
  const CornerlyApp({super.key});

  @override
  State<CornerlyApp> createState() => _CornerlyAppState();
}

class _CornerlyAppState extends State<CornerlyApp> {
  late final DatabaseService _db;
  late final AnalysisService _analysis;
  late final NotificationService _notifications;
  late final PrefsService _prefs;

  @override
  void initState() {
    super.initState();
    _db = DatabaseService();
    _analysis = AnalysisService(_db, SofascoreRepository());
    _notifications = NotificationService();
    _prefs = PrefsService();
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppProviderScope(
      db: _db,
      analysis: _analysis,
      notifications: _notifications,
      prefs: _prefs,
      child: CupertinoApp(
        title: 'Cornerly',
        theme: const CupertinoThemeData(brightness: Brightness.light),
        localizationsDelegates: const [
          DefaultCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es')],
        locale: const Locale('es'),
        home: const RouterScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class RouterScreen extends StatelessWidget {
  const RouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SplashScreen();
        }
        if (!provider.hasOnboarded) {
          return const OnboardingScreen();
        }
        return const DashboardScreen();
      },
    );
  }
}
