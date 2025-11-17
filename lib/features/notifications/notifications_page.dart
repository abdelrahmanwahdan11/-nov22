import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  static const route = '/notifications';

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<_Notification> _items = List.generate(
    6,
    (i) => _Notification(
      title: 'Update #$i',
      subtitle: 'Your saved item has a new preview',
      time: '${i + 1}h ago',
    ),
  );

  void _markAllRead() {
    setState(() => _items.clear());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('notifications')),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: Text(t.translate('mark_all_read')),
          )
        ],
      ),
      body: _items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(IconlyLight.tick_square, size: 56, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(t.translate('all_caught_up'), style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(t.translate('all_caught_up_desc'), textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          : ListView.separated(
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  leading: const Icon(IconlyLight.notification),
                  title: Text(item.title),
                  subtitle: Text(item.subtitle),
                  trailing: Text(item.time),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemCount: _items.length,
            ),
    );
  }
}

class _Notification {
  _Notification({required this.title, required this.subtitle, required this.time});

  final String title;
  final String subtitle;
  final String time;
}
