import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_dimens.dart';
import '../utils/app_routes.dart';
import '../widgets/event_card.dart';
import '../widgets/category_chip.dart';

class EventFeedScreen extends StatefulWidget {
  const EventFeedScreen({super.key});

  @override
  State<EventFeedScreen> createState() => _EventFeedScreenState();
}

class _EventFeedScreenState extends State<EventFeedScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Study',
    'Sports',
    'Social',
    'Hackathon',
    'Other',
  ];

  // Firestore stream — only upcoming events, ordered by dateTime
  Stream<List<Event>> get _eventsStream {
    return FirebaseFirestore.instance
        .collection('events')
        .where('dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }

  // Client-side filtering applied over the stream results
  List<Event> _applyFilters(List<Event> events) {
    return events.where((event) {
      final matchesCategory = _selectedCategory == 'All' ||
          event.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          event.title
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          event.location
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              backgroundColor: AppColors.surface,
              elevation: innerBoxIsScrolled ? 2 : 0,
              floating: true,
              snap: true,
              automaticallyImplyLeading: false,
              title: Text('GatherUp', style: AppTextStyles.displayMedium),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_outlined,
                      color: AppColors.textPrimary,
                      size: AppDimens.iconLG),
                  onPressed: () => Navigator.of(context)
                      .pushNamed(AppRoutes.notifications),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(112),
                child: Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.paddingMD,
                    0,
                    AppDimens.paddingMD,
                    AppDimens.paddingSM,
                  ),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: AppDimens.paddingSM),
                      _buildCategoryRow(),
                    ],
                  ),
                ),
              ),
            ),
          ],
          // StreamBuilder for real-time Firestore updates
          body: StreamBuilder<List<Event>>(
            stream: _eventsStream,
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Error state
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: AppDimens.paddingMD),
                      Text('Something went wrong',
                          style: AppTextStyles.titleMedium),
                      const SizedBox(height: AppDimens.paddingXS),
                      Text(snapshot.error.toString(),
                          style: AppTextStyles.bodySmall,
                          textAlign: TextAlign.center),
                    ],
                  ),
                );
              }

              final allEvents = snapshot.data ?? [];
              final filtered = _applyFilters(allEvents);

              // Empty state
              if (filtered.isEmpty) {
                return _buildEmptyState();
              }

              // Data state
              return _buildEventList(filtered);
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Search events...',
        hintStyle: AppTextStyles.bodyMedium,
        prefixIcon: const Icon(Icons.search,
            color: AppColors.textSecondary, size: AppDimens.iconLG),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close,
                    color: AppColors.textSecondary,
                    size: AppDimens.iconMD),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingMD, vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      onChanged: (val) => setState(() => _searchQuery = val),
    );
  }

  Widget _buildCategoryRow() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppDimens.paddingSM),
        itemBuilder: (_, index) {
          final cat = _categories[index];
          return CategoryChip(
            label: cat,
            isSelected: _selectedCategory == cat,
            onTap: () => setState(() => _selectedCategory = cat),
          );
        },
      ),
    );
  }

  Widget _buildEventList(List<Event> events) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    if (isWide) {
      return GridView.builder(
        padding: AppDimens.screenPadding,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppDimens.paddingMD,
          mainAxisSpacing: AppDimens.paddingMD,
          childAspectRatio: 0.85,
        ),
        itemCount: events.length,
        itemBuilder: (_, index) => _buildEventCard(events[index]),
      );
    }

    return ListView.separated(
      padding: AppDimens.screenPadding,
      itemCount: events.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppDimens.paddingMD),
      itemBuilder: (_, index) => _buildEventCard(events[index]),
    );
  }

  Widget _buildEventCard(Event event) {
    return EventCard(
      event: event,
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.eventDetail,
        arguments: event,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_outlined,
              size: 64, color: AppColors.textHint),
          const SizedBox(height: AppDimens.paddingMD),
          Text('No events found', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimens.paddingXS),
          Text(
            'Try a different category or search term',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      backgroundColor: AppColors.surface,
      elevation: 8,
      onTap: (index) {
        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.of(context).pushNamed(AppRoutes.myEvents);
            break;
          case 2:
            Navigator.of(context).pushNamed(AppRoutes.createEvent);
            break;
          case 3:
            Navigator.of(context).pushNamed(AppRoutes.profile);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'My Events'),
        BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Create'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile'),
      ],
    );
  }
}
