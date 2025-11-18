import 'package:flutter/material.dart';

import '../../features/ai_info_placeholder/ai_info_placeholder_page.dart';
import '../../features/about/about_page.dart';
import '../../features/auth/forgot_password/forgot_password_page.dart';
import '../../features/auth/login/login_page.dart';
import '../../features/auth/register/register_page.dart';
import '../../features/catalog/catalog_page.dart';
import '../../features/common/controllers/items_controller.dart';
import '../../features/compare/compare_page.dart';
import '../../features/favorites/favorites_page.dart';
import '../../features/guides/guides_page.dart';
import '../../features/help/help_center_page.dart';
import '../../features/home/home_page.dart';
import '../../features/item_details/item_details_page.dart';
import '../../features/notifications/notifications_page.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/search/search_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/shell/shell_page.dart';
import '../../features/splash/splash_page.dart';
import '../../features/feedback/feedback_page.dart';
import '../../features/changelog/changelog_page.dart';
import '../../features/safety/safety_tips_page.dart';
import '../../features/legal/legal_page.dart';
import '../../features/support/support_requests_page.dart';
import '../../features/journey/journey_page.dart';
import '../../features/insights/insights_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings, ItemsController items) {
    switch (settings.name) {
      case SplashPage.route:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case OnboardingPage.route:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case LoginPage.route:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case RegisterPage.route:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case ForgotPasswordPage.route:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      case ShellPage.route:
        return MaterialPageRoute(builder: (_) => ShellPage(itemsController: items));
      case HomePage.route:
        return MaterialPageRoute(builder: (_) => HomePage(itemsController: items));
      case CatalogPage.route:
        return MaterialPageRoute(builder: (_) => CatalogPage(itemsController: items));
      case ComparePage.route:
        return MaterialPageRoute(builder: (_) => ComparePage(itemsController: items));
      case FavoritesPage.route:
        return MaterialPageRoute(builder: (_) => FavoritesPage(itemsController: items));
      case SearchPage.route:
        return MaterialPageRoute(builder: (_) => SearchPage(itemsController: items));
      case ItemDetailsPage.route:
        return MaterialPageRoute(
          builder: (_) => ItemDetailsPage(item: settings.arguments, itemsController: items),
        );
      case ProfilePage.route:
        return MaterialPageRoute(builder: (_) => ProfilePage(itemsController: items));
      case SettingsPage.route:
        return MaterialPageRoute(builder: (_) => SettingsPage(itemsController: items));
      case NotificationsPage.route:
        return MaterialPageRoute(builder: (_) => NotificationsPage(itemsController: items));
      case AiInfoPlaceholderPage.route:
        return MaterialPageRoute(builder: (_) => const AiInfoPlaceholderPage());
      case AboutPage.route:
        return MaterialPageRoute(builder: (_) => const AboutPage());
      case HelpCenterPage.route:
        return MaterialPageRoute(builder: (_) => HelpCenterPage(itemsController: items));
      case GuidesPage.route:
        return MaterialPageRoute(builder: (_) => GuidesPage(itemsController: items));
      case FeedbackPage.route:
        return MaterialPageRoute(builder: (_) => FeedbackPage(itemsController: items));
      case ChangelogPage.route:
        return MaterialPageRoute(builder: (_) => const ChangelogPage());
      case SafetyTipsPage.route:
        return MaterialPageRoute(builder: (_) => const SafetyTipsPage());
      case LegalPage.route:
        return MaterialPageRoute(builder: (_) => const LegalPage());
      case SupportRequestsPage.route:
        return MaterialPageRoute(builder: (_) => const SupportRequestsPage());
      case JourneyPage.route:
        return MaterialPageRoute(builder: (_) => JourneyPage(itemsController: items));
      case InsightsPage.route:
        return MaterialPageRoute(builder: (_) => InsightsPage(itemsController: items));
      default:
        return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }
}
