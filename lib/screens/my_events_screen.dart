import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';
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
  final _eventService = EventService();
  late TabController tabController;
  final searchController = TextEditingController();

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<List<Event>> get _registeredStream =>
      _eventService.registeredByUser(_uid);

  Stream<List<Event>> get _createdStream => _eventService.createdByUser(_uid);

  Stream<List<Event>> get _pastStream => _eventService.pastAttendedByUser(_uid);

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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: AppColors.primary),
          const SizedBox(height: AppPaddings.md),
          Text('No Events Yet', style: AppTextStyles.title),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: AppPaddings.md),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.zero,
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: event),
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
                child: event.imageUrl.isNotEmpty
                    ? Image.network(event.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(Icons.event, color: AppColors.primary))
                    : Icon(Icons.event, color: AppColors.primary),
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
                    if (event.category.isNotEmpty)
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
            ],
          ),
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
      itemBuilder: (context, index) => _buildEventCard(filtered[index]),
    );
  }

  Widget _buildStreamTab(Stream<List<Event>> stream, {bool upcomingOnly = false}) {
    return StreamBuilder<List<Event>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading events', style: AppTextStyles.body));
        }
        var events = snapshot.data ?? const <Event>[];
        if (upcomingOnly) {
          final now = DateTime.now();
          events = events.where((e) => e.dateTime == null || e.dateTime!.isAfter(now)).toList();
        }
        return _buildEventList(events);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
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
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: AppStrings.searchHint,
                hintStyle: TextStyle(color: AppColors.textHint),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
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
                _buildStreamTab(_registeredStream, upcomingOnly: true),
                _buildStreamTab(_createdStream),
                _buildStreamTab(_pastStream),
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
