import 'dart:async';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/item.dart';
import '../models/visit_request.dart';

class ItemsController extends ChangeNotifier {
  ItemsController() {
    _items = List.of(mockItems);
    final prices = _items.map((e) => e.priceValue).toList();
    final minPrice = prices.reduce(min);
    final maxPrice = prices.reduce(max);
    _priceBounds = RangeValues(minPrice, maxPrice);
    _selectedPriceRange = _priceBounds;
    _filtered = _items.take(pageSize).toList();
    _restoreState();
  }

  final int pageSize = 6;
  int _page = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  List<Item> _items = [];
  List<Item> _filtered = [];
  final List<String> _favorites = [];
  final List<String> _compare = [];
  final List<String> _recentSearches = [];
  final List<String> _recentlyViewed = [];
  final List<VisitRequest> _visits = [];
  String _searchQuery = '';
  String? _category;
  String? _city;
  String _sort = 'recent';
  late RangeValues _selectedPriceRange;
  late RangeValues _priceBounds;
  final Completer<void> _readyCompleter = Completer<void>();

  List<Item> get items => _filtered;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  List<String> get favorites => _favorites;
  List<Item> get favoriteItems => _items.where((item) => _favorites.contains(item.id)).toList();
  List<String> get compare => _compare;
  List<String> get recentSearches => _recentSearches;
  List<Item> get recentlyViewedItems => _recentlyViewed
      .map((id) => _items.where((item) => item.id == id).toList())
      .where((matches) => matches.isNotEmpty)
      .map((matches) => matches.first)
      .toList();
  List<VisitRequest> get visits => List.unmodifiable(_visits);
  String? get category => _category;
  String? get city => _city;
  String get sort => _sort;
  RangeValues get selectedPriceRange => _selectedPriceRange;
  RangeValues get priceBounds => _priceBounds;
  Future<void> get ready => _readyCompleter.future;

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    _page = 1;
    _hasMore = true;
    _filtered = _applyFilters().take(pageSize).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _page += 1;
    final newItems = _applyFilters().skip((_page - 1) * pageSize).take(pageSize).toList();
    if (newItems.isEmpty) {
      _hasMore = false;
    } else {
      _filtered.addAll(newItems);
    }
    _isLoadingMore = false;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    _persistState();
    notifyListeners();
  }

  void removeFavorite(String id) {
    _favorites.remove(id);
    _persistState();
    notifyListeners();
  }

  void toggleCompare(String id) {
    if (_compare.contains(id)) {
      _compare.remove(id);
    } else {
      _compare.add(id);
    }
    _persistState();
    notifyListeners();
  }

  void removeFromCompare(String id) {
    _compare.remove(id);
    _persistState();
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    if (query.isNotEmpty) {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 6) {
        _recentSearches.removeLast();
      }
      _persistState();
    }
    _resetPagination();
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    _persistState();
    notifyListeners();
  }

  void clearRecentlyViewed() {
    _recentlyViewed.clear();
    _persistState();
    notifyListeners();
  }

  void markViewed(String id) {
    _recentlyViewed.remove(id);
    _recentlyViewed.insert(0, id);
    if (_recentlyViewed.length > 6) {
      _recentlyViewed.removeLast();
    }
    _persistState();
    notifyListeners();
  }

  void setCategory(String? value) {
    _category = value;
    _persistState();
    _resetPagination();
  }

  void setCity(String? value) {
    _city = value;
    _persistState();
    _resetPagination();
  }

  void setPriceRange(RangeValues values) {
    _selectedPriceRange = values;
    _persistState();
    _resetPagination();
  }

  void setSort(String value) {
    _sort = value;
    _persistState();
    _resetPagination();
  }

  VisitRequest scheduleVisit(String itemId, DateTime dateTime, {String? note}) {
    final request = VisitRequest(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      itemId: itemId,
      dateTime: dateTime,
      note: note?.trim().isEmpty ?? true ? null : note?.trim(),
    );
    _visits.add(request);
    _visits.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    _persistState();
    notifyListeners();
    return request;
  }

  void cancelVisit(String id) {
    _visits.removeWhere((visit) => visit.id == id);
    _persistState();
    notifyListeners();
  }

  Item? findItem(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  void clearFilters() {
    _category = null;
    _city = null;
    _selectedPriceRange = _priceBounds;
    _searchQuery = '';
    _persistState();
    _resetPagination();
  }

  List<Item> get comparedItems => _items.where((item) => _compare.contains(item.id)).toList();

  List<Item> _applyFilters() {
    Iterable<Item> results = _items;
    if (_category != null && _category!.isNotEmpty && _category != 'all') {
      results = results.where(
        (item) => item.type.toLowerCase() == _category!.toLowerCase(),
      );
    }
    if (_city != null && _city!.isNotEmpty) {
      results = results.where((item) => item.city.toLowerCase() == _city!.toLowerCase());
    }
    results = results.where(
      (item) => item.priceValue >= _selectedPriceRange.start && item.priceValue <= _selectedPriceRange.end,
    );
    if (_searchQuery.isNotEmpty) {
      results = results.where(
        (item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase())),
      );
    }
    if (_sort == 'priceLowHigh') {
      results = results.toList()
        ..sort((a, b) => a.priceValue.compareTo(b.priceValue));
    } else if (_sort == 'priceHighLow') {
      results = results.toList()
        ..sort((a, b) => b.priceValue.compareTo(a.priceValue));
    }
    return results.toList();
  }

  void _resetPagination() {
    _page = 1;
    _hasMore = true;
    _filtered = _applyFilters().take(pageSize).toList();
    notifyListeners();
  }

  Future<void> _restoreState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favs = prefs.getStringList('favorites') ?? [];
      final comps = prefs.getStringList('compare') ?? [];
      final savedCategory = prefs.getString('category');
      final savedCity = prefs.getString('city');
      final start = prefs.getDouble('priceStart');
      final end = prefs.getDouble('priceEnd');
      final savedSort = prefs.getString('sort');
      final savedSearches = prefs.getStringList('recentSearches') ?? [];
      final savedViewed = prefs.getStringList('recentlyViewed') ?? [];
      final savedVisits = prefs.getStringList('visits') ?? [];

      _favorites
        ..clear()
        ..addAll(favs);
      _compare
        ..clear()
        ..addAll(comps);
      _recentSearches
        ..clear()
        ..addAll(savedSearches.take(6));
      _recentlyViewed
        ..clear()
        ..addAll(savedViewed.take(6));
      if (savedCategory != null && savedCategory.isNotEmpty) {
        _category = savedCategory;
      }
      if (savedCity != null && savedCity.isNotEmpty) {
        _city = savedCity;
      }
      if (start != null && end != null) {
        _selectedPriceRange = RangeValues(start, end);
      }
      if (savedSort != null && savedSort.isNotEmpty) {
        _sort = savedSort;
      }
      _visits
        ..clear()
        ..addAll(
          savedVisits
              .map((json) {
                try {
                  return VisitRequest.fromMap(jsonDecode(json) as Map<String, dynamic>);
                } catch (_) {
                  return null;
                }
              })
              .whereType<VisitRequest>()
              .take(10),
        );
      _resetPagination();
    } finally {
      if (!_readyCompleter.isCompleted) {
        _readyCompleter.complete();
      }
    }
  }

  Future<void> _persistState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);
    await prefs.setStringList('compare', _compare);
    await prefs.setStringList('recentSearches', _recentSearches);
    await prefs.setStringList('recentlyViewed', _recentlyViewed);
    await prefs.setStringList('visits', _visits.map((visit) => jsonEncode(visit.toMap())).toList());
    if (_category != null) await prefs.setString('category', _category!);
    if (_city != null) await prefs.setString('city', _city!);
    await prefs.setString('sort', _sort);
    await prefs.setDouble('priceStart', _selectedPriceRange.start);
    await prefs.setDouble('priceEnd', _selectedPriceRange.end);
  }
}
