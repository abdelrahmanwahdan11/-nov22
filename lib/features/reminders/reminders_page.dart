import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_scope.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/skeleton_card.dart';
import '../../core/widgets/filter_chip.dart';
import '../settings/settings_page.dart';
import '../common/models/reminder.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});
  static const route = '/reminders';

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  String _category = 'visit';
  DateTime _dueAt = DateTime.now().add(const Duration(days: 1));
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final app = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('reminders')),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.setting),
            onPressed: () => Navigator.of(context).pushNamed(SettingsPage.route),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReminderSheet(context),
        icon: const Icon(Icons.add_task),
        label: Text(t.translate('add_reminder')),
      ),
      body: AnimatedBuilder(
        animation: app,
        builder: (context, _) {
          final reminders = List.of(app.reminders)
            ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
          final pending = reminders.where((reminder) => !reminder.done).toList();
          final completed = reminders.where((reminder) => reminder.done).toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (app.nextReminder != null)
                _ReminderHero(reminder: app.nextReminder!),
              const SizedBox(height: 12),
              Text(t.translate('open_tasks'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              if (pending.isEmpty)
                _EmptyReminderState(message: t.translate('reminders_empty'))
              else
                ...pending.map((reminder) => _ReminderTile(reminder: reminder)),
              const SizedBox(height: 16),
              Text(t.translate('completed'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              if (completed.isEmpty)
                _EmptyReminderState(message: t.translate('reminders_completed_empty'))
              else
                ...completed.map((reminder) => _ReminderTile(reminder: reminder)),
              const SizedBox(height: 24),
              Text(t.translate('templates'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  FilterChipWidget(
                    label: Text(t.translate('reminder_visit_title')),
                    selected: false,
                    onSelected: (_) => _applyTemplate(
                      title: t.translate('reminder_visit_title'),
                      category: 'visit',
                    ),
                  ),
                  FilterChipWidget(
                    label: Text(t.translate('reminder_document_title')),
                    selected: false,
                    onSelected: (_) => _applyTemplate(
                      title: t.translate('reminder_document_title'),
                      category: 'document',
                    ),
                  ),
                  FilterChipWidget(
                    label: Text(t.translate('reminder_task_title')),
                    selected: false,
                    onSelected: (_) => _applyTemplate(
                      title: t.translate('reminder_task_title'),
                      category: 'task',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.translate('reminder_notes_hint'),
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(t.translate('reminders_local_only'))),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _applyTemplate({required String title, required String category}) {
    setState(() {
      _titleController.text = title;
      _category = category;
      _dueAt = DateTime.now().add(const Duration(days: 2));
    });
    _showReminderSheet(context);
  }

  Future<void> _showReminderSheet(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final app = AppScope.of(context);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 16, left: 16, right: 16, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(t.translate('add_reminder'), style: Theme.of(ctx).textTheme.titleMedium)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: t.translate('title'),
                  hintText: t.translate('reminder_title_hint'),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                onChanged: (value) => setState(() => _category = value ?? 'visit'),
                items: [
                  DropdownMenuItem(value: 'visit', child: Text(t.translate('reminder_visit'))),
                  DropdownMenuItem(value: 'document', child: Text(t.translate('reminder_document'))),
                  DropdownMenuItem(value: 'task', child: Text(t.translate('reminder_task'))),
                ],
                decoration: InputDecoration(labelText: t.translate('category')),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(DateFormat.yMMMd().format(_dueAt)),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: ctx,
                          initialDate: _dueAt,
                          firstDate: DateTime.now().subtract(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _dueAt = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                _dueAt.hour,
                                _dueAt.minute,
                              ));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.schedule_outlined),
                      label: Text(DateFormat.Hm().format(_dueAt)),
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.fromDateTime(_dueAt),
                        );
                        if (time != null) {
                          setState(() => _dueAt = DateTime(
                                _dueAt.year,
                                _dueAt.month,
                                _dueAt.day,
                                time.hour,
                                time.minute,
                              ));
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(labelText: t.translate('notes')),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: t.translate('save'),
                onPressed: () async {
                  final title = _titleController.text.trim();
                  if (title.isEmpty) return;
                  final reminder = Reminder(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    title: title,
                    category: _category,
                    dueAt: _dueAt,
                    note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
                  );
                  await app.addReminder(reminder);
                  _titleController.clear();
                  _noteController.clear();
                  setState(() => _category = 'visit');
                  if (mounted) Navigator.of(ctx).pop();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.reminder});

  final Reminder reminder;

  Color _categoryColor(String category, BuildContext context) {
    switch (category) {
      case 'document':
        return Colors.orange.shade400;
      case 'task':
        return Colors.teal;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _icon(String category) {
    switch (category) {
      case 'document':
        return Icons.file_present_outlined;
      case 'task':
        return Icons.check_circle_outline;
      default:
        return Icons.event_available_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final dueLabel = DateFormat.yMMMd().add_Hm().format(reminder.dueAt);
    return Card(
      child: ListTile(
        leading: Icon(_icon(reminder.category), color: _categoryColor(reminder.category, context)),
        title: Text(reminder.title, style: reminder.done ? const TextStyle(decoration: TextDecoration.lineThrough) : null),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${t.translate('due')}: $dueLabel'),
            if (reminder.note?.isNotEmpty ?? false) Text(reminder.note!),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(reminder.done ? Icons.undo : Icons.check),
              onPressed: () => app.toggleReminderDone(reminder.id),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => app.removeReminder(reminder.id),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderHero extends StatelessWidget {
  const _ReminderHero({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final dueLabel = DateFormat.yMMMd().add_Hm().format(reminder.dueAt);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.alarm, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.translate('upcoming_reminder'), style: Theme.of(context).textTheme.titleMedium),
                Text(reminder.title, style: Theme.of(context).textTheme.bodyLarge),
                Text(dueLabel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReminderState extends StatelessWidget {
  const _EmptyReminderState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const SkeletonCard(height: 80),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
      ],
    );
  }
}
