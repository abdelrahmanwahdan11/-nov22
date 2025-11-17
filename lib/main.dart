import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_controller.dart';
import 'core/utils/app_scope.dart';
import 'features/common/controllers/items_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appController = AppController();
  final itemsController = ItemsController();
  await Future.wait([appController.ready, itemsController.ready]);
  runApp(AppRoot(appController: appController, itemsController: itemsController));
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key, required this.appController, required this.itemsController});

  final AppController appController;
  final ItemsController itemsController;

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appController,
      builder: (context, _) {
        if (!widget.appController.isReady) {
          return const MaterialApp(home: SizedBox());
        }
        return Directionality(
          textDirection: widget.appController.locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: AppScope(
            notifier: widget.appController,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: widget.appController.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: AppTheme.light(widget.appController.primaryColor),
              darkTheme: AppTheme.dark(widget.appController.primaryColor),
              themeMode: widget.appController.themeMode,
              initialRoute: '/',
              onGenerateRoute: (settings) => AppRouter.onGenerateRoute(settings, widget.itemsController),
            ),
          ),
        );
      },
    );
  }
}
