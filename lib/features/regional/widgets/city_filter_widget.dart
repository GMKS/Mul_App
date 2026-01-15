/// City Filter Widget
/// Location filter for city/district selection in regional feed

import 'package:flutter/material.dart';

class CityFilterWidget extends StatelessWidget {
  final String? selectedCity;
  final String? selectedDistrict;
  final String? selectedState;
  final VoidCallback onTap;

  const CityFilterWidget({
    super.key,
    this.selectedCity,
    this.selectedDistrict,
    this.selectedState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey[700]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on,
              size: 18,
              color: Colors.white70,
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                _getLocationText(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }

  String _getLocationText() {
    if (selectedCity != null) {
      return selectedCity!;
    } else if (selectedDistrict != null) {
      return selectedDistrict!;
    } else if (selectedState != null) {
      return selectedState!;
    }
    return 'Location';
  }
}

/// City filter chip for compact display
class CityFilterChip extends StatelessWidget {
  final String? city;
  final String? state;
  final VoidCallback onTap;

  const CityFilterChip({
    super.key,
    this.city,
    this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF).withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              city ?? state ?? 'Location',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}

/// City selection bottom sheet
class CitySelectionSheet extends StatefulWidget {
  final String? selectedCity;
  final String? selectedState;
  final Function(String city, String state, String? district) onCitySelected;

  const CitySelectionSheet({
    super.key,
    this.selectedCity,
    this.selectedState,
    required this.onCitySelected,
  });

  static Future<Map<String, String>?> show(
    BuildContext context, {
    String? selectedCity,
    String? selectedState,
  }) {
    return showModalBottomSheet<Map<String, String>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return CitySelectionSheet(
          selectedCity: selectedCity,
          selectedState: selectedState,
          onCitySelected: (city, state, district) {
            Navigator.pop(context, {
              'city': city,
              'state': state,
              if (district != null) 'district': district,
            });
          },
        );
      },
    );
  }

  @override
  State<CitySelectionSheet> createState() => _CitySelectionSheetState();
}

class _CitySelectionSheetState extends State<CitySelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedState;

  // Sample cities data - In production, this would come from an API
  static const Map<String, List<Map<String, String>>> _citiesByState = {
    'Telangana': [
      {'city': 'Hyderabad', 'district': 'Hyderabad'},
      {'city': 'Warangal', 'district': 'Warangal'},
      {'city': 'Nizamabad', 'district': 'Nizamabad'},
      {'city': 'Karimnagar', 'district': 'Karimnagar'},
      {'city': 'Khammam', 'district': 'Khammam'},
      {'city': 'Ramagundam', 'district': 'Peddapalli'},
    ],
    'Andhra Pradesh': [
      {'city': 'Visakhapatnam', 'district': 'Visakhapatnam'},
      {'city': 'Vijayawada', 'district': 'NTR'},
      {'city': 'Guntur', 'district': 'Guntur'},
      {'city': 'Tirupati', 'district': 'Tirupati'},
      {'city': 'Nellore', 'district': 'Nellore'},
      {'city': 'Kurnool', 'district': 'Kurnool'},
    ],
    'Karnataka': [
      {'city': 'Bengaluru', 'district': 'Bengaluru Urban'},
      {'city': 'Mysuru', 'district': 'Mysuru'},
      {'city': 'Mangaluru', 'district': 'Dakshina Kannada'},
      {'city': 'Hubli', 'district': 'Dharwad'},
      {'city': 'Belgaum', 'district': 'Belagavi'},
    ],
    'Tamil Nadu': [
      {'city': 'Chennai', 'district': 'Chennai'},
      {'city': 'Coimbatore', 'district': 'Coimbatore'},
      {'city': 'Madurai', 'district': 'Madurai'},
      {'city': 'Tiruchirappalli', 'district': 'Tiruchirappalli'},
      {'city': 'Salem', 'district': 'Salem'},
    ],
    'Maharashtra': [
      {'city': 'Mumbai', 'district': 'Mumbai'},
      {'city': 'Pune', 'district': 'Pune'},
      {'city': 'Nagpur', 'district': 'Nagpur'},
      {'city': 'Nashik', 'district': 'Nashik'},
      {'city': 'Aurangabad', 'district': 'Aurangabad'},
    ],
    'Delhi': [
      {'city': 'New Delhi', 'district': 'New Delhi'},
      {'city': 'North Delhi', 'district': 'North'},
      {'city': 'South Delhi', 'district': 'South'},
      {'city': 'East Delhi', 'district': 'East'},
      {'city': 'West Delhi', 'district': 'West'},
    ],
  };

  List<String> get _states => _citiesByState.keys.toList();

  List<Map<String, String>> get _filteredCities {
    final cities = _selectedState != null
        ? _citiesByState[_selectedState] ?? []
        : _citiesByState.values.expand((e) => e).toList();

    if (_searchQuery.isEmpty) return cities;

    return cities.where((city) {
      return city['city']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (city['district']
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedState = widget.selectedState;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.location_city, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  'Select City',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search city...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          const SizedBox(height: 12),

          // State filter chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _states.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = _selectedState == null;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedState = null);
                      },
                      selectedColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.grey[800],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    ),
                  );
                }

                final state = _states[index - 1];
                final isSelected = _selectedState == state;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(state),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(
                          () => _selectedState = isSelected ? null : state);
                    },
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: Colors.grey[800],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),
          const Divider(color: Colors.grey),

          // City list
          Expanded(
            child: _filteredCities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 48,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No cities found',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredCities.length,
                    itemBuilder: (context, index) {
                      final cityData = _filteredCities[index];
                      final city = cityData['city']!;
                      final district = cityData['district'];
                      final state = _getStateForCity(city);
                      final isSelected = city == widget.selectedCity;

                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.2)
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.location_city,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.white70,
                          ),
                        ),
                        title: Text(
                          city,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          '$state${district != null ? ' • $district' : ''}',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                              )
                            : null,
                        onTap: () {
                          widget.onCitySelected(city, state, district);
                        },
                      );
                    },
                  ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  String _getStateForCity(String city) {
    for (final entry in _citiesByState.entries) {
      if (entry.value.any((c) => c['city'] == city)) {
        return entry.key;
      }
    }
    return '';
  }
}
