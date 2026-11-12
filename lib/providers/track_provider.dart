import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/track_model.dart';
import '../core/services/sync_service.dart';

class TrackProvider extends ChangeNotifier {
  final SyncService _syncService = SyncService();
  String _userId = 'guest_local_user';

  List<TrackItemModel> _items = [];
  List<TrackItemModel> get items => _items;

  List<TrackEntryModel> _entries = [];
  List<TrackEntryModel> get entries => _entries;

  String? _selectedItemId;
  String? get selectedItemId => _selectedItemId;

  TrackItemModel? get selectedItem {
    if (_items.isEmpty) return null;
    if (_selectedItemId == null) return _items.first;
    try {
      return _items.firstWhere((i) => i.id == _selectedItemId);
    } catch (_) {
      return _items.first;
    }
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String q) {
    _searchQuery = q.trim().toLowerCase();
    notifyListeners();
  }

  void selectItem(String? itemId) {
    _selectedItemId = itemId;
    _searchQuery = '';
    notifyListeners();
  }

  void updateUserId(String userId) {
    if (_userId != userId) {
      _userId = userId;
      loadData();
    }
  }

  int getEntryCountForItem(String itemId) {
    return _entries.where((e) => e.trackItemId == itemId).length;
  }

  List<TrackEntryModel> get entriesForSelectedItem {
    final activeId = selectedItem?.id;
    if (activeId == null) return [];

    return _entries.where((e) {
      final matchesItem = e.trackItemId == activeId;
      final matchesSearch = _searchQuery.isEmpty ||
          e.title.toLowerCase().contains(_searchQuery) ||
          e.content.toLowerCase().contains(_searchQuery) ||
          (e.tag?.toLowerCase().contains(_searchQuery) ?? false);
      return matchesItem && matchesSearch;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _items = await _syncService.loadTrackItems(_userId);
    _entries = await _syncService.loadTrackEntries(_userId);

    final prefs = await SharedPreferences.getInstance();
    final hasSeeded = prefs.getBool('seeded_tracking_$_userId') ?? false;

    if (_items.isEmpty && !hasSeeded && _userId == 'guest_local_user') {
      await prefs.setBool('seeded_tracking_$_userId', true);

      final healthItem = TrackItemModel(
        id: 'track_health_wellness',
        title: 'Health & Wellness',
        description: 'Track nutrition, hydration, sleep & workouts',
        icon: '❤️',
        colorValue: 0xFFE53935,
      );

      final mindItem = TrackItemModel(
        id: 'track_mind_focus',
        title: 'Mind & Focus',
        description: 'Deep work sessions, reading, and mental energy',
        icon: '🧠',
        colorValue: 0xFF1E88E5,
      );

      final habitsItem = TrackItemModel(
        id: 'track_daily_habits',
        title: 'Daily Habits',
        description: 'Consistent routines, meditation & reflection',
        icon: '✨',
        colorValue: 0xFF43A047,
      );

      _items = [healthItem, mindItem, habitsItem];
      await _syncService.saveLocalTrackItems(_userId, _items);
      for (var item in _items) {
        await _syncService.syncTrackItem(_userId, item);
      }

      final now = DateTime.now();
      final starterEntries = [
        TrackEntryModel(
          trackItemId: healthItem.id,
          title: '30m Jogging & Morning Hydration',
          content: 'Completed 4.5km morning jog at a steady pace. Drank 1L water immediately after with electrolytes. Energy feeling at 9/10.',
          timestamp: now.subtract(const Duration(hours: 4)),
          tag: 'Workout',
          rating: 5,
        ),
        TrackEntryModel(
          trackItemId: healthItem.id,
          title: 'Sleep quality & Recovery',
          content: 'Slept 7h 45m. Woke up refreshed without alarm. Resting heart rate normal at 58 bpm.',
          timestamp: now.subtract(const Duration(hours: 14)),
          tag: 'Sleep',
          rating: 4,
        ),
        TrackEntryModel(
          trackItemId: mindItem.id,
          title: '2-hour Deep Work Block',
          content: 'Completed architecture layout and state management wiring without notifications or phone distractions. Reached high flow state.',
          timestamp: now.subtract(const Duration(hours: 2)),
          tag: 'Deep Work',
          rating: 5,
        ),
      ];

      _entries = starterEntries;
      await _syncService.saveLocalTrackEntries(_userId, _entries);
      for (var entry in _entries) {
        await _syncService.syncTrackEntry(_userId, entry);
      }
    }

    if (_items.isNotEmpty) {
      if (_selectedItemId == null || !_items.any((i) => i.id == _selectedItemId)) {
        _selectedItemId = _items.first.id;
      }
    } else {
      _selectedItemId = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- Track Items CRUD ---
  Future<void> addTrackItem({
    required String title,
    String description = '',
    String icon = '📋',
    int colorValue = 0xFFD84315,
  }) async {
    final item = TrackItemModel(
      title: title.trim(),
      description: description.trim(),
      icon: icon.trim().isEmpty ? '📋' : icon.trim(),
      colorValue: colorValue,
    );

    _items.add(item);
    _selectedItemId = item.id;
    notifyListeners();

    await _syncService.saveLocalTrackItems(_userId, _items);
    await _syncService.syncTrackItem(_userId, item);
  }

  Future<void> updateTrackItem(TrackItemModel updated) async {
    final idx = _items.indexWhere((i) => i.id == updated.id);
    if (idx != -1) {
      _items[idx] = updated;
      notifyListeners();

      await _syncService.saveLocalTrackItems(_userId, _items);
      await _syncService.syncTrackItem(_userId, updated);
    }
  }

  Future<void> deleteTrackItem(String itemId) async {
    _items.removeWhere((i) => i.id == itemId);

    // Also remove entries associated with this track item
    final removedEntries = _entries.where((e) => e.trackItemId == itemId).toList();
    _entries.removeWhere((e) => e.trackItemId == itemId);

    if (_selectedItemId == itemId) {
      _selectedItemId = _items.isNotEmpty ? _items.first.id : null;
    }

    notifyListeners();

    await _syncService.saveLocalTrackItems(_userId, _items);
    await _syncService.deleteTrackItem(_userId, itemId);

    await _syncService.saveLocalTrackEntries(_userId, _entries);
    for (var re in removedEntries) {
      await _syncService.deleteTrackEntry(_userId, re.id);
    }
  }

  // --- Track Entries CRUD ---
  Future<void> addTrackEntry({
    required String trackItemId,
    required String title,
    required String content,
    DateTime? timestamp,
    String? tag,
    int? rating,
  }) async {
    final entry = TrackEntryModel(
      trackItemId: trackItemId,
      title: title.trim(),
      content: content.trim(),
      timestamp: timestamp ?? DateTime.now(),
      tag: tag?.trim().isEmpty == true ? null : tag?.trim(),
      rating: rating,
    );

    _entries.insert(0, entry);
    notifyListeners();

    await _syncService.saveLocalTrackEntries(_userId, _entries);
    await _syncService.syncTrackEntry(_userId, entry);
  }

  Future<void> updateTrackEntry(TrackEntryModel updated) async {
    final idx = _entries.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _entries[idx] = updated;
      notifyListeners();

      await _syncService.saveLocalTrackEntries(_userId, _entries);
      await _syncService.syncTrackEntry(_userId, updated);
    }
  }

  Future<void> deleteTrackEntry(String entryId) async {
    _entries.removeWhere((e) => e.id == entryId);
    notifyListeners();

    await _syncService.saveLocalTrackEntries(_userId, _entries);
    await _syncService.deleteTrackEntry(_userId, entryId);
  }
}
