import 'package:flutter/material.dart';

import '../../features/ai_info_placeholder/ai_info_placeholder_page.dart';
import '../../features/auth/forgot_password/forgot_password_page.dart';
import '../../features/auth/login/login_page.dart';
import '../../features/auth/register/register_page.dart';
import '../../features/catalog/catalog_page.dart';
import '../../features/common/controllers/items_controller.dart';
import '../../features/compare/compare_page.dart';
import '../../features/favorites/favorites_page.dart';
import '../../features/home/home_page.dart';
import '../../features/item_details/item_details_page.dart';
import '../../features/notifications/notifications_page.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/search/search_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/shell/shell_page.dart';
import '../../features/splash/splash_page.dart';

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
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case NotificationsPage.route:
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
      case AiInfoPlaceholderPage.route:
        return MaterialPageRoute(builder: (_) => const AiInfoPlaceholderPage());
      default:
        return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }
}
