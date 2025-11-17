import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_scope.dart';
import '../common/controllers/items_controller.dart';
import '../settings/settings_page.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key, required this.itemsController});

  static const route = '/feedback';

  final ItemsController itemsController;

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  late double _rating;
  late TextEditingController _noteController;
  Set<String> _topics = {};
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final app = AppScope.of(context);
    _rating = app.feedbackRating > 0 ? app.feedbackRating : 3.5;
    _topics = app.feedbackTopics.toSet();
    _noteController = TextEditingController(text: app.feedbackNote);
    _initialized = true;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final stats = widget.itemsController.snapshot();
    final lastUpdated = app.feedbackUpdatedAt;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('feedback')),
        actions: [
          IconButton(
            tooltip: t.translate('settings'),
            icon: const Icon(IconlyLight.setting),
            onPressed: () => Navigator.of(context).pushNamed(SettingsPage.route),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t.translate('feedback_intro'), style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 14),
          Row(
            children: [
              _FeedbackStat(label: t.translate('favorites'), value: stats['favorites'] as int? ?? 0),
              const SizedBox(width: 8),
              _FeedbackStat(label: t.translate('saved_searches'), value: stats['savedSearches'] as int? ?? 0),
              const SizedBox(width: 8),
              _FeedbackStat(label: t.translate('visits'), value: stats['visits'] as int? ?? 0),
            ],
          ),
          const SizedBox(height: 24),
          Text(t.translate('satisfaction'), style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: _rating,
            min: 1,
            max: 5,
            divisions: 8,
            label: _rating.toStringAsFixed(1),
            onChanged: (value) => setState(() => _rating = value),
          ),
          const SizedBox(height: 12),
          Text(t.translate('feedback_topics'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _topicChip(t.translate('topic_ui'), 'ui'),
              _topicChip(t.translate('topic_data'), 'data'),
              _topicChip(t.translate('topic_performance'), 'performance'),
              _topicChip(t.translate('topic_other'), 'other'),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: t.translate('note'),
              hintText: t.translate('feedback_note_hint'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await app.saveFeedback(
                      rating: _rating,
                      topics: _topics.toList(),
                      note: _noteController.text,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(t.translate('feedback_saved'))));
                    }
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: Text(t.translate('send_feedback')),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: t.translate('clear'),
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () async {
                  await app.clearFeedback();
                  if (mounted) {
                    setState(() {
                      _rating = 3.5;
                      _topics.clear();
                      _noteController.clear();
                    });
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(t.translate('feedback_cleared'))));
                  }
                },
              )
            ],
          ),
          const SizedBox(height: 18),
          if (lastUpdated != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.translate('latest_feedback'),
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('${t.translate('satisfaction')}: ${app.feedbackRating.toStringAsFixed(1)}'),
                        if (app.feedbackTopics.isNotEmpty)
                          Text('${t.translate('feedback_topics')}: ${app.feedbackTopics.join(', ')}'),
                        if (app.feedbackNote.isNotEmpty) Text(app.feedbackNote),
                        Text('${t.translate('last_updated')}: ${TimeOfDay.fromDateTime(lastUpdated).format(context)}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _topicChip(String label, String key) {
    return FilterChip(
      label: Text(label),
      selected: _topics.contains(key),
      onSelected: (_) => setState(() {
        if (_topics.contains(key)) {
          _topics.remove(key);
        } else {
          _topics.add(key);
        }
      }),
    );
  }
}

class _FeedbackStat extends StatelessWidget {
  const _FeedbackStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            Text('$value', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
