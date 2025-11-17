import 'dart:convert';

import 'package:flutter/material.dart';

class SavedSearch {
  SavedSearch({
    required this.id,
    required this.query,
    this.category,
    this.city,
    this.minPrice,
    this.maxPrice,
    this.alertsEnabled = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String query;
  final String? category;
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final bool alertsEnabled;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'query': query,
        'category': category,
        'city': city,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'alertsEnabled': alertsEnabled,
        'createdAt': createdAt.toIso8601String(),
      };

  String toJson() => jsonEncode(toMap());

  static SavedSearch fromMap(Map<String, dynamic> map) {
    return SavedSearch(
      id: map['id'] as String,
      query: map['query'] as String,
      category: map['category'] as String?,
      city: map['city'] as String?,
      minPrice: (map['minPrice'] as num?)?.toDouble(),
      maxPrice: (map['maxPrice'] as num?)?.toDouble(),
      alertsEnabled: map['alertsEnabled'] as bool? ?? true,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static SavedSearch fromJson(String json) {
    return SavedSearch.fromMap(jsonDecode(json) as Map<String, dynamic>);
  }

  RangeValues? get range =>
      minPrice != null && maxPrice != null ? RangeValues(minPrice!, maxPrice!) : null;

  bool matches(String normalizedQuery, {String? category, String? city, RangeValues? range}) {
    final rangeMatch = range == null || (minPrice == range.start && maxPrice == range.end);
    return query.toLowerCase() == normalizedQuery.toLowerCase() &&
        (this.category ?? '') == (category ?? '') &&
        (this.city ?? '') == (city ?? '') &&
        rangeMatch;
  }
}
