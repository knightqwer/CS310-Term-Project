import 'package:flutter/material.dart';

class EventFeedScreen extends StatefulWidget {
  const EventFeedScreen({super.key});

  @override
  State<EventFeedScreen> createState() => _EventFeedScreenState();
}

class _EventFeedScreenState extends State<EventFeedScreen> {
  int _selectedIndex = 0;
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Study',
    'Sports',
    'Social',
    'Hackathon',
    'Workshop',
    'Music',
  ];

  final List<Map<String, dynamic>> _events = [
    {
      'title': 'CS Study Group',
      'category': 'Study',
      'location': 'Library Room 3',
      'date': 'Apr 14, 14:00',
    },
    {
      'title': 'Campus Football',
      'category': 'Sports',
      'location': 'Main Field',
      'date': 'Apr 15, 16:00',
    },
    {
      'title': 'Spring Hackathon',
      'category': 'Hackathon',
      'location': 'FENS Building',
      'date': 'Apr 20, 09:00',
    },
    {
      'title': 'Board Game Night',
      'category': 'Social',
      'location': 'Student Center',
      'date': 'Apr 16, 19:00',
    },
    {
      'title': 'Guitar Workshop',
      'category': 'Workshop',
      'location': 'Arts Room B',
      'date': 'Apr 17, 15:00',
    },
  ];

  List<Map<String, dynamic>> get _filteredEvents {
    final query = _searchController.text.toLowerCase();
    return _events.where((event) {
      final matchesCategory =
          _selectedCategory == 'All' || event['category'] == _selectedCategory;
      final matchesSearch =
          query.isEmpty || event['title'].toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'GatherUp',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'NEARBY EVENTS',
                hintStyle: const TextStyle(
                  letterSpacing: 1.2,
                  color: Colors.black45,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.black45),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  selectedColor: Colors.black87,
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide.none,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filteredEvents.isEmpty
                ? const Center(
                    child: Text(
                      'No events found.',
                      style: TextStyle(color: Colors.black45),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredEvents.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final event = _filteredEvents[index];
                      return InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.event, color: Colors.black54),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event['title'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${event['location']} · ${event['date']}',
                                      style: const TextStyle(
                                        color: Colors.black45,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  event['category'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.black38,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
