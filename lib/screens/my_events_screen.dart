import 'package:flutter/material.dart';
import '../models/event.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_routes.dart';
import '../utils/app_strings.dart';
import '../utils/app_text_styles.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final searchController = TextEditingController();

  final List<Event> registeredEvents = [
    const Event(
      id: 'r1',
      title: 'Study Session',
      date: 'Apr 14, 2026',
      location: 'Information Center',
      category: 'Study',
    ),
    const Event(
      id: 'r2',
      title: 'Hackathon Kickoff',
      date: 'Apr 20, 2026',
      location: 'FENS Building',
      category: 'Hackathon',
    ),
    const Event(
      id: 'r3',
      title: 'Basketball Match',
      date: 'Apr 22, 2026',
      location: 'Sports Center',
      category: 'Sports',
    ),
  ];

  final List<Event> createdEvents = [
    const Event(
      id: 'c1',
      title: 'CS Study Group',
      date: 'Apr 18, 2026',
      location: 'Library',
      category: 'Study',
    ),
  ];

  final List<Event> pastEvents = [
    const Event(
      id: 'p1',
      title: 'Welcome Week Party',
      date: 'Sep 15, 2025',
      location: 'Student Center',
      category: 'Social',
    ),
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void removeEvent(List<Event> source, Event event) {
    setState(() {
      source.removeWhere((e) => e.id == event.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed "${event.title}"')),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, size: 64, color: AppColors.primary),
          const SizedBox(height: AppPaddings.md),
          Text('No Events Yet', style: AppTextStyles.title),
        ],
      ),
    );
  }

  Widget _buildEventCard(List<Event> source, Event event) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: AppPaddings.md),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.border),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(Icons.event, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: AppPaddings.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppPaddings.xs),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          event.date,
                          style: AppTextStyles.bodySecondary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          event.location,
                          style: AppTextStyles.bodySecondary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppPaddings.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppPaddings.sm, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      event.category,
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => removeEvent(source, event),
              tooltip: 'Remove',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(List<Event> events) {
    final query = searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? events
        : events.where((e) => e.title.toLowerCase().contains(query)).toList();

    if (filtered.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppPaddings.md, vertical: AppPaddings.sm),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildEventCard(events, filtered[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Events', style: AppTextStyles.title),
        bottom: TabBar(
          controller: tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Registered'),
            Tab(text: 'Created'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppPaddings.md),
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: AppStrings.searchHint,
                hintStyle: TextStyle(color: AppColors.textHint),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _buildEventList(registeredEvents),
                _buildEventList(createdEvents),
                _buildEventList(pastEvents),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createEvent),
        child: const Icon(Icons.add),
      ),
    );
  }
}
