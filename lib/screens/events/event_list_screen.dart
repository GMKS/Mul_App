/// Event List Screen
/// Displays events and festivals with filtering options

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../controllers/event_controller.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize event controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventController>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildDateFilterChips(),
            _buildCategoryFilterChips(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllEventsTab(),
                  _buildLiveEventsTab(),
                  _buildFeaturedEventsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: _showSearch
                    ? TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search events...',
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.5)),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _showSearch = false;
                                _searchController.clear();
                              });
                              context.read<EventController>().loadEvents();
                            },
                          ),
                        ),
                        onSubmitted: (query) {
                          context.read<EventController>().searchEvents(query);
                        },
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '🎉',
                            style: TextStyle(fontSize: 24),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Events & Festivals',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showSearch = !_showSearch;
                  });
                },
                icon: Icon(
                  _showSearch ? Icons.close : Icons.search,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // Live events indicator
          Consumer<EventController>(
            builder: (context, controller, _) {
              if (controller.hasLiveEvents) {
                return Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${controller.liveEventsCount} LIVE Events',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterChips() {
    return Consumer<EventController>(
      builder: (context, controller, _) {
        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: const Color(0xFF16213e),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: DateFilter.values.map((filter) {
              final isSelected = controller.selectedDateFilter == filter;
              return GestureDetector(
                onTap: () => controller.setDateFilter(filter),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE91E63)
                        : const Color(0xFF1a1a2e),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : Colors.white24,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    filter.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCategoryFilterChips() {
    return Consumer<EventController>(
      builder: (context, controller, _) {
        return Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: const Color(0xFF16213e).withOpacity(0.5),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: EventCategory.values.map((category) {
              final isSelected = controller.selectedCategory == category;
              return GestureDetector(
                onTap: () => controller.setCategoryFilter(category),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF9B59B6)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(category.icon, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        category.displayName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTabs() {
    return Container(
      color: const Color(0xFF16213e),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFFE91E63),
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        tabs: const [
          Tab(text: 'All Events'),
          Tab(text: '🔴 Live'),
          Tab(text: '⭐ Featured'),
        ],
      ),
    );
  }

  Widget _buildAllEventsTab() {
    return Consumer<EventController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE91E63)),
          );
        }

        if (controller.events.isEmpty) {
          return _buildEmptyState(
              'No events found', 'Check back later for upcoming events');
        }

        return RefreshIndicator(
          onRefresh: () => controller.refresh(),
          color: const Color(0xFFE91E63),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.events.length,
            itemBuilder: (context, index) {
              return EventCard(
                event: controller.events[index],
                onTap: () => _navigateToDetail(controller.events[index]),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLiveEventsTab() {
    return Consumer<EventController>(
      builder: (context, controller, _) {
        final liveEvents = controller.liveEventsComputed;

        if (liveEvents.isEmpty) {
          return _buildEmptyState(
            'No live events right now',
            'Check the upcoming events section',
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadLiveEvents(),
          color: const Color(0xFFE91E63),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: liveEvents.length,
            itemBuilder: (context, index) {
              return EventCard(
                event: liveEvents[index],
                onTap: () => _navigateToDetail(liveEvents[index]),
                isLive: true,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFeaturedEventsTab() {
    return Consumer<EventController>(
      builder: (context, controller, _) {
        if (controller.featuredEvents.isEmpty) {
          return _buildEmptyState(
            'No featured events',
            'Featured events will appear here',
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadFeaturedEvents(),
          color: const Color(0xFFE91E63),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.featuredEvents.length,
            itemBuilder: (context, index) {
              return EventCard(
                event: controller.featuredEvents[index],
                onTap: () =>
                    _navigateToDetail(controller.featuredEvents[index]),
                isFeatured: true,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(event: event),
      ),
    );
  }
}

/// Event Card Widget
class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final bool isLive;
  final bool isFeatured;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.isLive = false,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF16213e),
          borderRadius: BorderRadius.circular(16),
          border: isLive
              ? Border.all(color: Colors.red, width: 2)
              : isFeatured
                  ? Border.all(color: Colors.amber, width: 2)
                  : null,
          boxShadow: [
            BoxShadow(
              color: isLive
                  ? Colors.red.withOpacity(0.3)
                  : Colors.black.withOpacity(0.2),
              blurRadius: isLive ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image
            if (event.imageUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    Image.network(
                      event.imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: const Color(0xFF1a1a2e),
                          child: Center(
                            child: Text(
                              event.categoryIcon,
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                        );
                      },
                    ),

                    // Status badges
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Row(
                        children: [
                          if (event.isLive) _buildBadge('🔴 LIVE', Colors.red),
                          if (event.isToday && !event.isLive)
                            _buildBadge('TODAY', Colors.orange),
                          if (event.isTomorrow)
                            _buildBadge('TOMORROW', Colors.blue),
                        ],
                      ),
                    ),

                    // Category badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${event.categoryIcon} ${event.category}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),

                    // Featured badge
                    if (event.isFeatured)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.black, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Featured',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Event details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    event.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Date and time
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: const Color(0xFFE91E63),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        event.formattedDate,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        color: const Color(0xFFE91E63),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        event.formattedTime,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: const Color(0xFFE91E63),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.locationName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Ticket price if available
                  if (event.ticketPrice != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            event.ticketPrice == 0
                                ? 'FREE'
                                : '₹${event.ticketPrice!.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
