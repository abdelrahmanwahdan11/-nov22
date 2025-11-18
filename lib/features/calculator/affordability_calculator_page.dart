import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/app_scope.dart';
import '../../core/widgets/item_card.dart';
import '../../core/widgets/skeleton_card.dart';
import '../common/controllers/items_controller.dart';
import '../item_details/item_details_page.dart';
import '../settings/settings_page.dart';

class AffordabilityCalculatorPage extends StatelessWidget {
  const AffordabilityCalculatorPage({super.key, required this.itemsController});

  static const route = '/affordability';

  final ItemsController itemsController;

  double _monthlyPayment({
    required double price,
    required double downPaymentPercent,
    required double rate,
    required int years,
  }) {
    final principal = price * (1 - downPaymentPercent / 100);
    final monthlyRate = rate / 12 / 100;
    final months = years * 12;
    if (monthlyRate == 0) return principal / months;
    final powFactor = pow(1 + monthlyRate, months);
    return principal * monthlyRate * powFactor / (powFactor - 1);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final app = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('affordability_calculator')),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.setting),
            onPressed: () => Navigator.of(context).pushNamed(SettingsPage.route),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: app,
        builder: (context, _) {
          final price = app.calcHomePrice;
          final down = app.calcDownPayment;
          final rate = app.calcRate;
          final years = app.calcYears;
          final monthly = _monthlyPayment(price: price, downPaymentPercent: down, rate: rate, years: years);
          final withinBudget = monthly <= app.budgetTarget;
          final matches = itemsController.allItems
              .where((item) => item.priceValue <= price && item.priceValue >= price * 0.5)
              .take(4)
              .toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(t.translate('planning_intro'), style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calculate_outlined, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(t.translate('apply_numbers'),
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _SliderTile(
                        label: t.translate('home_price'),
                        value: price,
                        min: 50000,
                        max: 1500000,
                        divisions: 30,
                        format: (v) => 'USD ${v.toStringAsFixed(0)}',
                        onChanged: (v) => app.updateCalculator(price: v),
                      ),
                      _SliderTile(
                        label: t.translate('down_payment'),
                        value: down,
                        min: 0,
                        max: 80,
                        divisions: 16,
                        format: (v) => '${v.toStringAsFixed(0)}%',
                        onChanged: (v) => app.updateCalculator(downPayment: v),
                      ),
                      _SliderTile(
                        label: t.translate('interest_rate'),
                        value: rate,
                        min: 0,
                        max: 20,
                        divisions: 20,
                        format: (v) => '${v.toStringAsFixed(1)}%',
                        onChanged: (v) => app.updateCalculator(rate: v),
                      ),
                      _SliderTile(
                        label: t.translate('loan_years'),
                        value: years.toDouble(),
                        min: 5,
                        max: 35,
                        divisions: 30,
                        format: (v) => '${v.toStringAsFixed(0)}y',
                        onChanged: (v) => app.updateCalculator(years: v.round()),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Chip(
                            avatar: Icon(
                              withinBudget ? Icons.check_circle : Icons.warning_amber_rounded,
                              color: withinBudget ? Colors.green : Colors.orange,
                            ),
                            label: Text(
                                withinBudget ? t.translate('within_budget') : t.translate('over_budget')),
                          ),
                          const SizedBox(width: 12),
                          Chip(
                            label: Text('${t.translate('budget_target')}: ${app.budgetTarget.toStringAsFixed(0)}'),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(t.translate('estimated_payment'),
                          style: Theme.of(context).textTheme.titleMedium),
                      Text('USD ${monthly.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: withinBudget
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.orange,
                              )),
                      const SizedBox(height: 8),
                      Text(t.translate('calculator_hint'),
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(t.translate('recommendations'),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (matches.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.translate('no_recommendations'),
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        const SkeletonCard(),
                      ],
                    ),
                  ),
                )
              else
                ...matches.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ItemCard(
                      item: item,
                      onTap: () => Navigator.of(context)
                          .pushNamed(ItemDetailsPage.route, arguments: item),
                      onToggleFavorite: () => itemsController.toggleFavorite(item.id),
                      onToggleCompare: () => itemsController.toggleCompare(item.id),
                      isFavorite: itemsController.favorites.contains(item.id),
                      isInCompare: itemsController.compare.contains(item.id),
                      note: itemsController.itemNotes[item.id],
                      compact: AppScope.of(context).compactCards,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.format,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) format;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(format(value), style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: format(value),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
