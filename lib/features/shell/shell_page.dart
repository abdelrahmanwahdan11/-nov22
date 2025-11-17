import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../catalog/catalog_page.dart';
import '../compare/compare_page.dart';
import '../common/controllers/items_controller.dart';
import '../home/home_page.dart';
import '../profile/profile_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key, required this.itemsController});
  static const route = '/shell';

  final ItemsController itemsController;

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final pages = [
      HomePage(itemsController: widget.itemsController),
      CatalogPage(itemsController: widget.itemsController),
      ComparePage(itemsController: widget.itemsController),
      const ProfilePage(),
    ];
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(icon: const Icon(IconlyBold.home), label: t.translate('home')),
          BottomNavigationBarItem(icon: const Icon(IconlyBold.category), label: t.translate('catalog')),
          BottomNavigationBarItem(icon: const Icon(IconlyBold.swap), label: t.translate('compare')),
          BottomNavigationBarItem(icon: const Icon(IconlyBold.profile), label: t.translate('profile')),
        ],
      ),
    );
  }
}
