import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/filter_chip.dart';
import '../ai_info_placeholder/ai_info_placeholder_page.dart';
import '../common/controllers/items_controller.dart';
import '../common/models/item.dart';

class ItemDetailsPage extends StatefulWidget {
  const ItemDetailsPage({super.key, required this.item, required this.itemsController});
  static const route = '/item-details';

  final Item item;
  final ItemsController itemsController;

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  bool _flipped = false;
  int _galleryIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.itemsController.markViewed(widget.item.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final gallery = [widget.item.image, widget.item.preview3d, widget.item.mapPreview];
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 260,
              child: PageView.builder(
                itemCount: gallery.length,
                onPageChanged: (i) => setState(() => _galleryIndex = i),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => setState(() => _flipped = !_flipped),
                  child: Hero(
                    tag: widget.item.id,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _flipped
                          ? Container(
                              key: const ValueKey('back'),
                              color: Theme.of(context).cardColor,
                              alignment: Alignment.center,
                              child: Text(widget.item.description ?? 'Immersive 3D preview coming soon'),
                            )
                          : Image.network(gallery[i], fit: BoxFit.cover, key: ValueKey('front-$i')),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                gallery.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _galleryIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).disabledColor,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.item.name, style: Theme.of(context).textTheme.headlineSmall),
                  Text(widget.item.location, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: widget.item.tags
                        .map((e) => AnimatedFilterChip(label: e, selected: true, onTap: () {}))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(icon: IconlyLight.wallet, label: t.translate('price'), value: widget.item.price),
                  _InfoRow(icon: IconlyLight.home, label: t.translate('type'), value: widget.item.type),
                  _InfoRow(icon: IconlyLight.user_1, label: t.translate('rooms'), value: widget.item.rooms.toString()),
                  _InfoRow(icon: Icons.bathtub_outlined, label: t.translate('baths'), value: widget.item.baths.toString()),
                  _InfoRow(
                    icon: Icons.square_foot,
                    label: t.translate('area'),
                    value: '${widget.item.area.toStringAsFixed(0)} m²',
                  ),
                  _InfoRow(icon: Icons.star_rounded, label: t.translate('rating'), value: widget.item.rating.toStringAsFixed(1)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(t.translate('note'), style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          isScrollControlled: true,
                          builder: (_) => _NoteSheet(
                            t: t,
                            initialValue: widget.itemsController.itemNotes[widget.item.id] ?? '',
                            onSave: (value) {
                              widget.itemsController.saveNote(widget.item.id, value);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(t.translate('note_saved'))),
                                );
                              }
                            },
                            onRemove: widget.itemsController.itemNotes.containsKey(widget.item.id)
                                ? () {
                                    widget.itemsController.removeNote(widget.item.id);
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(t.translate('note_removed'))),
                                      );
                                    }
                                  }
                                : null,
                          ),
                        ),
                        icon: const Icon(Icons.sticky_note_2_outlined),
                        label: Text(
                          widget.itemsController.itemNotes.containsKey(widget.item.id)
                              ? t.translate('edit_note')
                              : t.translate('add_note'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      widget.itemsController.itemNotes[widget.item.id] ?? t.translate('note_hint'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(t.translate('ai_info_placeholder')),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      isScrollControlled: true,
                      builder: (_) => _ScheduleVisitSheet(
                        t: t,
                        itemsController: widget.itemsController,
                        item: widget.item,
                      ),
                    ),
                    icon: const Icon(Icons.event_available),
                    label: Text(t.translate('schedule_visit')),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => widget.itemsController.toggleFavorite(widget.item.id),
                          icon: Icon(widget.itemsController.favorites.contains(widget.item.id)
                              ? IconlyBold.heart
                              : IconlyLight.heart),
                          label: Text(t.translate('add_to_favorites')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => widget.itemsController.toggleCompare(widget.item.id),
                          icon: const Icon(IconlyLight.swap),
                          label: Text(t.translate('add_to_compare')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      builder: (_) => _AiInfoSheet(t: t),
                    ),
                    child: Text(t.translate('ai_info_button')),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text('$label: $value'),
        ],
      ),
    );
  }
}

class _NoteSheet extends StatefulWidget {
  const _NoteSheet({required this.t, required this.initialValue, required this.onSave, this.onRemove});

  final AppLocalizations t;
  final String initialValue;
  final ValueChanged<String> onSave;
  final VoidCallback? onRemove;

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sticky_note_2_outlined),
              const SizedBox(width: 8),
              Text(t.translate('edit_note'), style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: t.translate('note'),
              hintText: t.translate('note_hint'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onSave(_controller.text),
                  child: Text(t.translate('done')),
                ),
              ),
              if (widget.onRemove != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onRemove,
                    child: Text(t.translate('remove')),
                  ),
                ),
              ]
            ],
          )
        ],
      ),
    );
  }
}

class _AiInfoSheet extends StatelessWidget {
  const _AiInfoSheet({required this.t});

  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t.translate('ai_info_headline'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(t.translate('ai_info_placeholder')),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.translate('done')),
          ),
        ],
      ),
    );
  }
}

class _ScheduleVisitSheet extends StatefulWidget {
  const _ScheduleVisitSheet({required this.t, required this.itemsController, required this.item});

  final AppLocalizations t;
  final ItemsController itemsController;
  final Item item;

  @override
  State<_ScheduleVisitSheet> createState() => _ScheduleVisitSheetState();
}

class _ScheduleVisitSheetState extends State<_ScheduleVisitSheet> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 120)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _save() {
    final now = DateTime.now();
    final date = _selectedDate ?? now;
    final time = _selectedTime ?? TimeOfDay.now();
    final scheduled = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    widget.itemsController.scheduleVisit(widget.item.id, scheduled, note: _noteController.text);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(widget.t.translate('visit_saved'))));
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final selectedDateText = _selectedDate == null
        ? t.translate('select_date')
        : '${_selectedDate!.year}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.day.toString().padLeft(2, '0')}';
    final selectedTimeText = _selectedTime == null
        ? t.translate('select_time')
        : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_available),
              const SizedBox(width: 8),
              Text(t.translate('schedule_visit'), style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(t.translate('select_date')),
            subtitle: Text(selectedDateText),
            trailing: IconButton(onPressed: _pickDate, icon: const Icon(Icons.calendar_today)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(t.translate('select_time')),
            subtitle: Text(selectedTimeText),
            trailing: IconButton(onPressed: _pickTime, icon: const Icon(Icons.schedule)),
          ),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(labelText: t.translate('note_optional')),
            minLines: 1,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: Text(t.translate('done')),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
