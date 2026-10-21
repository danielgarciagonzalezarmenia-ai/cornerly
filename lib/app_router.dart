import 'package:cornerly/providers/app_provider.dart';
import 'package:cornerly/ui/screens/dashboard_screen.dart';
import 'package:cornerly/ui/screens/onboarding_screen.dart';
import 'package:cornerly/ui/screens/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class RouterScreen extends StatefulWidget {
  const RouterScreen({super.key});

  @override
  State<RouterScreen> createState() => _RouterScreenState();
}

class _RouterScreenState extends State<RouterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().init();
    });
  }

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
