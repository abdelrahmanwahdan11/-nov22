import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_scope.dart';
import '../common/models/document.dart';
import '../settings/settings_page.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  static const route = '/documents';

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  String? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = AppLocalizations.of(context);
    final statuses = ['pending', 'received', 'reviewed'];
    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        final documents = app.documents
            .where((doc) => _filterStatus == null || doc.status == _filterStatus)
            .toList();
        return Scaffold(
          appBar: AppBar(
            title: Text(t.translate('document_center')),
            actions: [
              IconButton(
                icon: const Icon(IconlyLight.setting),
                onPressed: () => Navigator.of(context).pushNamed(SettingsPage.route),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _showAddSheet(context, statuses: statuses),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryCard(statuses: statuses, documents: app.documents, t: t),
              const SizedBox(height: 12),
              Text(t.translate('document_filters'), style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: Text(t.translate('all')),
                    selected: _filterStatus == null,
                    onSelected: (_) => setState(() => _filterStatus = null),
                  ),
                  for (final status in statuses)
                    FilterChip(
                      label: Text(t.translate('document_status_$status')),
                      selected: _filterStatus == status,
                      onSelected: (_) => setState(() => _filterStatus = status),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file_outlined),
                label: Text(t.translate('add_document')),
                onPressed: () => _showAddSheet(context, statuses: statuses),
              ),
              const SizedBox(height: 12),
              if (documents.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(Icons.folder_open, size: 48, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 12),
                      Text(t.translate('document_empty'), textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      Text(t.translate('document_suggestions'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                )
              else
                ...[
                  for (final doc in documents) ...[
                    _DocumentCard(document: doc, statuses: statuses),
                    const SizedBox(height: 10),
                  ]
                ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddSheet(BuildContext context, {required List<String> statuses}) async {
    final t = AppLocalizations.of(context);
    final titleCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String type = t.translate('document_type_default');
    String status = statuses.first;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.translate('add_document'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: t.translate('document_title_hint'),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: type,
              decoration: InputDecoration(labelText: t.translate('document_type')),
              items: [
                t.translate('document_type_default'),
                t.translate('document_type_id'),
                t.translate('document_type_finance'),
              ]
                  .map((value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => type = value ?? type,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: status,
              decoration: InputDecoration(labelText: t.translate('document_status_label')),
              items: statuses
                  .map((value) => DropdownMenuItem<String>(value: value, child: Text(t.translate('document_status_$value'))))
                  .toList(),
              onChanged: (value) => status = value ?? status,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteCtrl,
              decoration: InputDecoration(
                labelText: t.translate('document_note_optional'),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final title = titleCtrl.text.trim();
                      if (title.isEmpty) return;
                      final app = AppScope.of(context);
                      app.addDocument(
                        Document(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          title: title,
                          type: type,
                          status: status,
                          note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                          updatedAt: DateTime.now(),
                        ),
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(t.translate('document_added'))));
                    },
                    child: Text(t.translate('add')),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.statuses, required this.documents, required this.t});

  final List<String> statuses;
  final List<Document> documents;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(t.translate('documents'), style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text('${documents.length}', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final status in statuses)
                Chip(
                  label: Text('${t.translate('document_status_$status')} · ${documents.where((d) => d.status == status).length}'),
                  avatar: Icon(
                    status == 'reviewed'
                        ? Icons.verified_outlined
                        : status == 'received'
                            ? Icons.check_circle_outline
                            : Icons.watch_later_outlined,
                    size: 18,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document, required this.statuses});

  final Document document;
  final List<String> statuses;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final app = AppScope.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(document.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(document.type, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz),
                onSelected: (value) {
                  if (value == 'delete') {
                    app.removeDocument(document.id);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(t.translate('document_removed'))));
                  } else {
                    app.updateDocument(document.id, status: value);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(t.translate('document_status_updated'))));
                  }
                },
                itemBuilder: (context) => [
                  for (final status in statuses)
                    PopupMenuItem(
                      value: status,
                      child: Text(t.translate('document_status_$status')),
                    ),
                  const PopupMenuDivider(),
                  PopupMenuItem(value: 'delete', child: Text(t.translate('remove'))),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Chip(
                label: Text(t.translate('document_status_${document.status}')),
                backgroundColor: _statusColor(context, document.status).withOpacity(0.12),
                labelStyle: TextStyle(color: _statusColor(context, document.status)),
              ),
              const SizedBox(width: 8),
              Icon(Icons.schedule, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 4),
              Text(t.formatDate(document.updatedAt), style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          if (document.note != null && document.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(document.note!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  Color _statusColor(BuildContext context, String status) {
    final color = Theme.of(context).colorScheme;
    switch (status) {
      case 'reviewed':
        return color.secondary;
      case 'received':
        return color.primary;
      default:
        return color.tertiary;
    }
  }
}
