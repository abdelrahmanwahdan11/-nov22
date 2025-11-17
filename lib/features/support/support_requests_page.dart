import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_scope.dart';
import '../common/models/support_message.dart';
import '../settings/settings_page.dart';

class SupportRequestsPage extends StatefulWidget {
  const SupportRequestsPage({super.key});
  static const route = '/support-requests';

  @override
  State<SupportRequestsPage> createState() => _SupportRequestsPageState();
}

class _SupportRequestsPageState extends State<SupportRequestsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  String _topic = 'general';

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _openComposer(AppLocalizations t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t.translate('new_request'), style: Theme.of(context).textTheme.titleMedium),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    )
                  ],
                ),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: t.translate('request_title')),
                  validator: (v) => (v == null || v.isEmpty) ? t.translate('required_field') : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _topic,
                  decoration: InputDecoration(labelText: t.translate('request_topic')),
                  items: [
                    DropdownMenuItem(value: 'general', child: Text(t.translate('topic_ui'))),
                    DropdownMenuItem(value: 'data', child: Text(t.translate('topic_data'))),
                    DropdownMenuItem(value: 'performance', child: Text(t.translate('topic_performance'))),
                    DropdownMenuItem(value: 'other', child: Text(t.translate('topic_other'))),
                  ],
                  onChanged: (value) => setState(() => _topic = value ?? 'general'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _detailsController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: t.translate('request_details'),
                    hintText: t.translate('support_request_hint'),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? t.translate('request_details_hint') : null,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        final app = AppScope.of(context);
                        await app.addSupportMessage(
                          SupportMessage(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: _titleController.text.trim(),
                            details: _detailsController.text.trim(),
                            topic: _topic,
                            resolved: false,
                            createdAt: DateTime.now(),
                          ),
                        );
                        _titleController.clear();
                        _detailsController.clear();
                        if (mounted) {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t.translate('request_saved'))),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.send_outlined),
                    label: Text(t.translate('send')),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final app = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('support_requests')),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.setting),
            onPressed: () => Navigator.of(context).pushNamed(SettingsPage.route),
          ),
          IconButton(
            icon: const Icon(Icons.add_task_outlined),
            onPressed: () => _openComposer(t),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openComposer(t),
        child: const Icon(Icons.edit_outlined),
      ),
      body: AnimatedBuilder(
        animation: app,
        builder: (context, _) {
          final messages = app.supportMessages;
          if (messages.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.support_agent, size: 48),
                    const SizedBox(height: 12),
                    Text(t.translate('support_empty_title'), style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(t.translate('support_empty_body'), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: () => _openComposer(t), child: Text(t.translate('new_request')))
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final message = messages[index];
              final resolved = message.resolved;
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(message.title, style: Theme.of(context).textTheme.titleMedium),
                          ),
                          Chip(
                            label: Text(resolved ? t.translate('resolved') : t.translate('pending')),
                            backgroundColor: resolved ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                            labelStyle: TextStyle(color: resolved ? Colors.green.shade800 : Colors.orange.shade800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(message.details),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.label_outline, size: 16, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(message.topic),
                          const SizedBox(width: 12),
                          Icon(Icons.schedule_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(message.formattedDate()),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () => app.toggleSupportResolved(message.id),
                            icon: Icon(resolved ? Icons.replay_outlined : Icons.check_circle_outline),
                            label: Text(resolved ? t.translate('mark_pending') : t.translate('mark_resolved')),
                          ),
                          const SizedBox(width: 12),
                          TextButton.icon(
                            onPressed: () async {
                              await app.removeSupportMessage(message.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(t.translate('request_removed'))),
                                );
                              }
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: Text(t.translate('remove')),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
