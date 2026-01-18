/// Event Controller
/// State management for events and festivals

import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';

class EventController extends ChangeNotifier {
  final EventRepository _repository;

  List<EventModel> _events = [];
  List<EventModel> _todayEvents = [];
  List<EventModel> _tomorrowEvents = [];
  List<EventModel> _liveEvents = [];
  List<EventModel> _featuredEvents = [];
  List<EventModel> _pendingEvents = [];

  bool _isLoading = false;
  String? _error;
  DateFilter _selectedDateFilter = DateFilter.all;
  EventCategory _selectedCategory = EventCategory.all;
  String? _selectedDistanceCategory;

  EventController({EventRepository? repository})
      : _repository = repository ?? EventRepository();

  // Getters
  List<EventModel> get events => _events;
  List<EventModel> get todayEvents => _todayEvents;
  List<EventModel> get tomorrowEvents => _tomorrowEvents;
  List<EventModel> get liveEvents => _liveEvents;
  List<EventModel> get featuredEvents => _featuredEvents;
  List<EventModel> get pendingEvents => _pendingEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateFilter get selectedDateFilter => _selectedDateFilter;
  EventCategory get selectedCategory => _selectedCategory;
  String? get selectedDistanceCategory => _selectedDistanceCategory;

  /// Computed property: Events happening today
  List<EventModel> get todayEventsComputed =>
      _events.where((e) => e.isToday).toList();

  /// Computed property: Events happening tomorrow
  List<EventModel> get tomorrowEventsComputed =>
      _events.where((e) => e.isTomorrow).toList();

  /// Computed property: Live events (currently ongoing)
  List<EventModel> get liveEventsComputed =>
      _events.where((e) => e.isLive).toList();

  /// Computed property: Upcoming events
  List<EventModel> get upcomingEvents =>
      _events.where((e) => e.isUpcoming).toList();

  /// Computed property: This week events
  List<EventModel> get thisWeekEvents =>
      _events.where((e) => e.isThisWeek).toList();

  /// Computed property: This month events
  List<EventModel> get thisMonthEvents =>
      _events.where((e) => e.isThisMonth).toList();

  /// Check if any event is live
  bool get hasLiveEvents => _events.any((e) => e.isLive);

  /// Get count of today's events
  int get todayEventsCount => todayEventsComputed.length;

  /// Get count of live events
  int get liveEventsCount => liveEventsComputed.length;

  /// Initialize and load all events
  Future<void> initialize() async {
    await Future.wait([
      loadEvents(),
      loadTodayEvents(),
      loadTomorrowEvents(),
      loadLiveEvents(),
      loadFeaturedEvents(),
    ]);
  }

  /// Load events with current filters
  Future<void> loadEvents() async {
    _setLoading(true);
    _clearError();

    try {
      DateTime? startDate;
      DateTime? endDate;
      final now = DateTime.now();

      // Calculate date range based on filter
      switch (_selectedDateFilter) {
        case DateFilter.today:
          startDate = DateTime(now.year, now.month, now.day);
          endDate = startDate.add(const Duration(days: 1));
          break;
        case DateFilter.tomorrow:
          startDate = DateTime(now.year, now.month, now.day)
              .add(const Duration(days: 1));
          endDate = startDate.add(const Duration(days: 1));
          break;
        case DateFilter.thisWeek:
          startDate = DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: now.weekday - 1));
          endDate = startDate.add(const Duration(days: 7));
          break;
        case DateFilter.thisMonth:
          startDate = DateTime(now.year, now.month, 1);
          endDate = DateTime(now.year, now.month + 1, 1);
          break;
        case DateFilter.all:
          startDate = null;
          endDate = null;
          break;
      }

      _events = await _repository.fetchEvents(
        distanceCategory: _selectedDistanceCategory,
        category: _selectedCategory == EventCategory.all
            ? null
            : _selectedCategory.name,
        startDate: startDate,
        endDate: endDate,
      );

      notifyListeners();
    } catch (e) {
      _setError('Failed to load events: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load today's events
  Future<void> loadTodayEvents() async {
    try {
      _todayEvents = await _repository.fetchTodayEvents(
        distanceCategory: _selectedDistanceCategory,
      );
      notifyListeners();
    } catch (e) {
      print('Error loading today events: $e');
    }
  }

  /// Load tomorrow's events
  Future<void> loadTomorrowEvents() async {
    try {
      _tomorrowEvents = await _repository.fetchTomorrowEvents(
        distanceCategory: _selectedDistanceCategory,
      );
      notifyListeners();
    } catch (e) {
      print('Error loading tomorrow events: $e');
    }
  }

  /// Load live events
  Future<void> loadLiveEvents() async {
    try {
      _liveEvents = await _repository.fetchLiveEvents();
      notifyListeners();
    } catch (e) {
      print('Error loading live events: $e');
    }
  }

  /// Load featured events
  Future<void> loadFeaturedEvents() async {
    try {
      _featuredEvents = await _repository.fetchFeaturedEvents();
      notifyListeners();
    } catch (e) {
      print('Error loading featured events: $e');
    }
  }

  /// Load pending events for admin
  Future<void> loadPendingEvents() async {
    _setLoading(true);
    try {
      _pendingEvents = await _repository.fetchPendingEvents();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load pending events: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set date filter and reload events
  Future<void> setDateFilter(DateFilter filter) async {
    if (_selectedDateFilter != filter) {
      _selectedDateFilter = filter;
      notifyListeners();
      await loadEvents();
    }
  }

  /// Set category filter and reload events
  Future<void> setCategoryFilter(EventCategory category) async {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
      await loadEvents();
    }
  }

  /// Set distance category filter and reload events
  Future<void> setDistanceCategory(String? category) async {
    if (_selectedDistanceCategory != category) {
      _selectedDistanceCategory = category;
      notifyListeners();
      await loadEvents();
    }
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    _selectedDateFilter = DateFilter.all;
    _selectedCategory = EventCategory.all;
    _selectedDistanceCategory = null;
    notifyListeners();
    await loadEvents();
  }

  /// Search events
  Future<void> searchEvents(String query) async {
    if (query.isEmpty) {
      await loadEvents();
      return;
    }

    _setLoading(true);
    try {
      _events = await _repository.searchEvents(query);
      notifyListeners();
    } catch (e) {
      _setError('Search failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Approve an event (admin action)
  Future<bool> approveEvent(String eventId) async {
    try {
      final success = await _repository.approveEvent(eventId);
      if (success) {
        _pendingEvents.removeWhere((e) => e.id == eventId);
        notifyListeners();
        await loadEvents();
      }
      return success;
    } catch (e) {
      _setError('Failed to approve event: $e');
      return false;
    }
  }

  /// Reject an event (admin action)
  Future<bool> rejectEvent(String eventId, {String? reason}) async {
    try {
      final success = await _repository.rejectEvent(eventId, reason: reason);
      if (success) {
        _pendingEvents.removeWhere((e) => e.id == eventId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Failed to reject event: $e');
      return false;
    }
  }

  /// Create a new event
  Future<EventModel?> createEvent(EventModel event) async {
    try {
      final createdEvent = await _repository.createEvent(event);
      if (createdEvent != null) {
        await loadEvents();
      }
      return createdEvent;
    } catch (e) {
      _setError('Failed to create event: $e');
      return null;
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    await initialize();
  }

  /// Get events for notification (today at 8 AM, tomorrow at 7 PM)
  List<EventModel> getEventsForNotification({
    required bool isToday,
    String? distanceCategory,
  }) {
    final events = isToday ? todayEventsComputed : tomorrowEventsComputed;

    if (distanceCategory != null && distanceCategory.isNotEmpty) {
      return events
          .where((e) => e.distanceCategory == distanceCategory)
          .toList();
    }

    return events;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
