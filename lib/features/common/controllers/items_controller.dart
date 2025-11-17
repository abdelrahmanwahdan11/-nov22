import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/item.dart';

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
  String _searchQuery = '';
  String? _category;
  String? _city;
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
  String? get category => _category;
  String? get city => _city;
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
    _resetPagination();
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

      _favorites
        ..clear()
        ..addAll(favs);
      _compare
        ..clear()
        ..addAll(comps);
      if (savedCategory != null && savedCategory.isNotEmpty) {
        _category = savedCategory;
      }
      if (savedCity != null && savedCity.isNotEmpty) {
        _city = savedCity;
      }
      if (start != null && end != null) {
        _selectedPriceRange = RangeValues(start, end);
      }
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
    if (_category != null) await prefs.setString('category', _category!);
    if (_city != null) await prefs.setString('city', _city!);
    await prefs.setDouble('priceStart', _selectedPriceRange.start);
    await prefs.setDouble('priceEnd', _selectedPriceRange.end);
  }
}
