/// Event Repository
/// Supabase repository for events and festivals

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';

class EventRepository {
  final SupabaseClient _supabase;
  static const String _tableName = 'events';

  EventRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  /// Fetch all approved and non-expired events
  Future<List<EventModel>> fetchEvents({
    String? distanceCategory,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    String? religion,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from(_tableName)
          .select()
          .eq('is_approved', true)
          .eq('is_expired', false);

      // Filter by distance category
      if (distanceCategory != null && distanceCategory.isNotEmpty) {
        query = query.eq('distance_category', distanceCategory);
      }

      // Filter by event category
      if (category != null && category.isNotEmpty && category != 'all') {
        query = query.eq('category', category);
      }

      // Filter by religion
      if (religion != null && religion.isNotEmpty) {
        query = query.eq('religion', religion);
      }

      // Filter by date range
      if (startDate != null) {
        query = query.gte('start_datetime', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('start_datetime', endDate.toIso8601String());
      }

      // Order and paginate
      final response = await query
          .order('start_datetime', ascending: true)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => EventModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching events: $e');
      // Return sample events for testing when Supabase is not available
      return _filterSampleEvents(
        distanceCategory: distanceCategory,
        category: category,
        startDate: startDate,
        endDate: endDate,
      );
    }
  }

  /// Fetch today's events
  Future<List<EventModel>> fetchTodayEvents({
    String? distanceCategory,
    String? category,
  }) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return fetchEvents(
      distanceCategory: distanceCategory,
      category: category,
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  /// Fetch tomorrow's events
  Future<List<EventModel>> fetchTomorrowEvents({
    String? distanceCategory,
    String? category,
  }) async {
    final now = DateTime.now();
    final startOfTomorrow =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final endOfTomorrow = startOfTomorrow.add(const Duration(days: 1));

    return fetchEvents(
      distanceCategory: distanceCategory,
      category: category,
      startDate: startOfTomorrow,
      endDate: endOfTomorrow,
    );
  }

  /// Fetch this week's events
  Future<List<EventModel>> fetchThisWeekEvents({
    String? distanceCategory,
    String? category,
  }) async {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return fetchEvents(
      distanceCategory: distanceCategory,
      category: category,
      startDate: startOfWeek,
      endDate: endOfWeek,
    );
  }

  /// Fetch this month's events
  Future<List<EventModel>> fetchThisMonthEvents({
    String? distanceCategory,
    String? category,
  }) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    return fetchEvents(
      distanceCategory: distanceCategory,
      category: category,
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  /// Fetch featured events
  Future<List<EventModel>> fetchFeaturedEvents({int limit = 5}) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('is_approved', true)
          .eq('is_expired', false)
          .eq('is_featured', true)
          .order('start_datetime', ascending: true)
          .limit(limit);

      return (response as List)
          .map((json) => EventModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching featured events: $e');
      return EventModel.getSampleEvents()
          .where((e) => e.isFeatured)
          .take(limit)
          .toList();
    }
  }

  /// Fetch live events (currently ongoing)
  Future<List<EventModel>> fetchLiveEvents() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('is_approved', true)
          .eq('is_expired', false)
          .lte('start_datetime', now)
          .gte('end_datetime', now)
          .order('start_datetime', ascending: true);

      return (response as List)
          .map((json) => EventModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching live events: $e');
      return EventModel.getSampleEvents().where((e) => e.isLive).toList();
    }
  }

  /// Fetch pending events for admin approval
  Future<List<EventModel>> fetchPendingEvents() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('is_approved', false)
          .eq('is_expired', false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => EventModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching pending events: $e');
      return [];
    }
  }

  /// Create a new event
  Future<EventModel?> createEvent(EventModel event) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert(event.toJson())
          .select()
          .single();

      return EventModel.fromJson(response);
    } catch (e) {
      print('Error creating event: $e');
      return null;
    }
  }

  /// Update an event
  Future<bool> updateEvent(EventModel event) async {
    try {
      await _supabase
          .from(_tableName)
          .update(event.toJson())
          .eq('id', event.id);
      return true;
    } catch (e) {
      print('Error updating event: $e');
      return false;
    }
  }

  /// Approve an event
  Future<bool> approveEvent(String eventId) async {
    try {
      await _supabase
          .from(_tableName)
          .update({'is_approved': true}).eq('id', eventId);
      return true;
    } catch (e) {
      print('Error approving event: $e');
      return false;
    }
  }

  /// Reject/Delete an event
  Future<bool> rejectEvent(String eventId, {String? reason}) async {
    try {
      // Optionally log rejection reason before deleting
      if (reason != null && reason.isNotEmpty) {
        print('Event $eventId rejected. Reason: $reason');
        // You could store rejection reason in a separate table if needed
      }
      await _supabase.from(_tableName).delete().eq('id', eventId);
      return true;
    } catch (e) {
      print('Error rejecting event: $e');
      return false;
    }
  }

  /// Mark event as expired
  Future<bool> markEventExpired(String eventId) async {
    try {
      await _supabase
          .from(_tableName)
          .update({'is_expired': true}).eq('id', eventId);
      return true;
    } catch (e) {
      print('Error marking event expired: $e');
      return false;
    }
  }

  /// Search events by title or description
  Future<List<EventModel>> searchEvents(String query) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('is_approved', true)
          .eq('is_expired', false)
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('start_datetime', ascending: true);

      return (response as List)
          .map((json) => EventModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error searching events: $e');
      return EventModel.getSampleEvents()
          .where((event) =>
              event.title.toLowerCase().contains(query.toLowerCase()) ||
              event.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  /// Filter sample events for testing
  List<EventModel> _filterSampleEvents({
    String? distanceCategory,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var events = EventModel.getSampleEvents();

    if (distanceCategory != null && distanceCategory.isNotEmpty) {
      events =
          events.where((e) => e.distanceCategory == distanceCategory).toList();
    }

    if (category != null && category.isNotEmpty && category != 'all') {
      events = events.where((e) => e.category == category).toList();
    }

    if (startDate != null) {
      events = events.where((e) => e.startDatetime.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      events = events.where((e) => e.startDatetime.isBefore(endDate)).toList();
    }

    return events;
  }
}
