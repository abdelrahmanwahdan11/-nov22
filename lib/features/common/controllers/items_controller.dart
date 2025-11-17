import 'package:flutter/material.dart';

import '../models/item.dart';

class ItemsController extends ChangeNotifier {
  ItemsController() {
    _items = List.of(mockItems);
    _filtered = _items.take(pageSize).toList();
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

  List<Item> get items => _filtered;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  List<String> get favorites => _favorites;
  List<String> get compare => _compare;
  String? get category => _category;
  String? get city => _city;

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
    notifyListeners();
  }

  void toggleCompare(String id) {
    if (_compare.contains(id)) {
      _compare.remove(id);
    } else {
      _compare.add(id);
    }
    notifyListeners();
  }

  void removeFromCompare(String id) {
    _compare.remove(id);
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _resetPagination();
  }

  void setCategory(String? value) {
    _category = value;
    _resetPagination();
  }

  void setCity(String? value) {
    _city = value;
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
}
