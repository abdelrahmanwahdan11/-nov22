import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../common/controllers/items_controller.dart';
import '../common/models/offer.dart';
import '../settings/settings_page.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key, required this.itemsController});
  static const route = '/offers';

  final ItemsController itemsController;

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('offers')),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.setting),
            onPressed: () => Navigator.of(context).pushNamed(SettingsPage.route),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showOfferSheet(context),
        icon: const Icon(Icons.add),
        label: Text(t.translate('add_offer')),
      ),
      body: AnimatedBuilder(
        animation: widget.itemsController,
        builder: (context, _) {
          final offers = widget.itemsController.offers;
          if (offers.isEmpty) {
            return _EmptyOffers(t: t, onAdd: () => _showOfferSheet(context));
          }
          final statuses = ['draft', 'submitted', 'accepted', 'declined'];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: statuses
                .map(
                  (status) => _OfferSection(
                    title: t.translate('offer_status_$status'),
                    offers: widget.itemsController.offersByStatus(status),
                    itemsController: widget.itemsController,
                  ),
                )
                .where((section) => section.offers.isNotEmpty)
                .toList(),
          );
        },
      ),
    );
  }

  Future<void> _showOfferSheet(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final controller = widget.itemsController;
    final items = controller.allItems;
    if (items.isEmpty) return;
    String selectedItem = items.first.id;
    final amountController = TextEditingController(text: items.first.priceValue.toStringAsFixed(0));
    String status = 'draft';
    String note = '';
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sell_outlined),
                    const SizedBox(width: 8),
                    Text(t.translate('add_offer'), style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedItem,
                  items: items
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setSheetState(() => selectedItem = value ?? selectedItem),
                  decoration: InputDecoration(labelText: t.translate('catalog')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: t.translate('offer_amount'),
                    prefixText: '\$',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: status,
                  onChanged: (value) => setSheetState(() => status = value ?? status),
                  decoration: InputDecoration(labelText: t.translate('offer_status_label')),
                  items: const [
                    DropdownMenuItem(value: 'draft', child: Text('Draft')),
                    DropdownMenuItem(value: 'submitted', child: Text('Submitted')),
                    DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
                    DropdownMenuItem(value: 'declined', child: Text('Declined')),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: t.translate('offer_note'),
                    hintText: t.translate('note_hint'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (value) => note = value,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final amount = double.tryParse(amountController.text.trim()) ?? 0;
                      controller.createOffer(
                        itemId: selectedItem,
                        amount: amount,
                        status: status,
                        note: note,
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(t.translate('offer_saved'))));
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(t.translate('save')),
                  ),
                )
              ],
            ),
          );
        });
      },
    );
    amountController.dispose();
  }
}

class _OfferSection extends StatelessWidget {
  const _OfferSection({required this.title, required this.offers, required this.itemsController});

  final String title;
  final List<Offer> offers;
  final ItemsController itemsController;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (offers.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 6),
              Chip(label: Text('${offers.length}')),
            ],
          ),
          const SizedBox(height: 8),
          ...offers.map((offer) {
            final item = itemsController.findItem(offer.itemId);
            final statusLabel = t.translate('offer_status_${offer.status}');
            return Card(
              child: ListTile(
                title: Text(item?.name ?? t.translate('catalog')),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${t.translate('offer_amount')}: ${offer.amount.toStringAsFixed(0)}'),
                    Text('${t.translate('offer_status_label')}: $statusLabel'),
                    if (offer.note.isNotEmpty) Text(offer.note),
                    Text(
                      '${t.translate('offer_created')} ${offer.createdAt.toLocal().toString().substring(0, 16)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'remove') {
                      itemsController.removeOffer(offer.id);
                    } else if (value == 'accepted' || value == 'declined' || value == 'submitted' || value == 'draft') {
                      itemsController.updateOffer(offer.id, status: value);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'draft', child: Text(t.translate('offer_status_draft'))),
                    PopupMenuItem(value: 'submitted', child: Text(t.translate('offer_status_submitted'))),
                    PopupMenuItem(value: 'accepted', child: Text(t.translate('offer_status_accepted'))),
                    PopupMenuItem(value: 'declined', child: Text(t.translate('offer_status_declined'))),
                    const PopupMenuDivider(),
                    PopupMenuItem(value: 'remove', child: Text(t.translate('remove'))),
                  ],
                ),
              ),
            );
          })
        ],
      ),
    );
  }
}

class _EmptyOffers extends StatelessWidget {
  const _EmptyOffers({required this.t, required this.onAdd});

  final AppLocalizations t;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sell_outlined, size: 52),
            const SizedBox(height: 12),
            Text(t.translate('offers_empty'), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(t.translate('offers_hint'), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(t.translate('add_offer')),
            )
          ],
        ),
      ),
    );
  }
}
