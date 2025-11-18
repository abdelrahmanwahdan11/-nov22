import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_scope.dart';
import '../shell/shell_page.dart';
import '../auth/login/login_page.dart';
import '../onboarding/onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  static const route = '/';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final controller = AppScope.of(context);
    if (!mounted) return;
    if (!controller.hasSeenOnboarding) {
      Navigator.of(context).pushReplacementNamed(OnboardingPage.route);
    } else if (!controller.isLoggedIn) {
      Navigator.of(context).pushReplacementNamed(LoginPage.route);
    } else {
      Navigator.of(context).pushReplacementNamed(ShellPage.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_city, size: 48, color: Theme.of(context).colorScheme.primary),
            ).animate().fadeIn().scale(duration: const Duration(milliseconds: 400)),
            const SizedBox(height: 16),
            Text(
              t.translate('app_title'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}
