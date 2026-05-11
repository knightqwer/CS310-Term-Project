import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../services/user_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_text_styles.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _eventService = EventService();
  final _userService = UserService();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final capacityController = TextEditingController();

  String? selectedCategory;
  String? selectedLocation;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool _isPublishing = false;

  final List<String> categories = [
    'Academic',
    'Sports',
    'Social',
    'Career',
    'Workshop',
    'Other',
  ];

  final List<String> locations = [
    'FENS Building',
    'FASS Building',
    'SOM Building',
    'Sports Center',
    'Student Center',
    'Library',
    'Cafeteria',
    'Other',
  ];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    capacityController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  Future<void> handlePublish() async {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        selectedCategory == null ||
        selectedDate == null ||
        selectedTime == null ||
        selectedLocation == null ||
        capacityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final maxAttendees = int.tryParse(capacityController.text.trim());
    if (maxAttendees == null || maxAttendees <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Capacity must be a positive number')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to create an event')),
      );
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final combined = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final event = Event(
        id: '',
        title: titleController.text.trim(),
        imageUrl: '',
        status: 'upcoming',
        dateTime: combined,
        location: selectedLocation!,
        organizer: user.displayName ?? '',
        organizerUid: user.uid,
        attendeeCount: 0,
        maxAttendees: maxAttendees,
        description: descriptionController.text.trim(),
        category: selectedCategory!,
        tags: const [],
        attendeeUids: const [],
        createdBy: user.uid,
        createdAt: DateTime.now(),
      );

      await _eventService.createEvent(event.toMap());
      await _userService.updateUser(user.uid, {
        'eventsCreated': FieldValue.increment(1),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event published successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish event: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.textSecondary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.primary),
      ),
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
        title: Text('Create an Event', style: AppTextStyles.title),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 600 ? 560.0 : constraints.maxWidth;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppPaddings.lg, vertical: AppPaddings.md),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Fill in the details to create a new event',
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: AppPaddings.lg),
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('Event Title'),
                    ),
                    const SizedBox(height: AppPaddings.md),
                    TextField(
                      controller: descriptionController,
                      style: TextStyle(color: AppColors.textPrimary),
                      maxLines: 3,
                      decoration: _inputDecoration('Description'),
                    ),
                    const SizedBox(height: AppPaddings.md),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      dropdownColor: AppColors.surface,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('Category'),
                      icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                      items: categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (value) => setState(() => selectedCategory = value),
                    ),
                    const SizedBox(height: AppPaddings.md),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: AppPaddings.md),
                              decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 20),
                                  const SizedBox(width: AppPaddings.sm),
                                  Text(
                                    selectedDate != null
                                        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                        : 'Date',
                                    style: TextStyle(
                                      color: selectedDate != null ? AppColors.textPrimary : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppPaddings.md),
                        Expanded(
                          child: GestureDetector(
                            onTap: pickTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: AppPaddings.md),
                              decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time, color: AppColors.textSecondary, size: 20),
                                  const SizedBox(width: AppPaddings.sm),
                                  Text(
                                    selectedTime != null
                                        ? selectedTime!.format(context)
                                        : 'Time',
                                    style: TextStyle(
                                      color: selectedTime != null ? AppColors.textPrimary : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppPaddings.md),
                    DropdownButtonFormField<String>(
                      value: selectedLocation,
                      dropdownColor: AppColors.surface,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('Location'),
                      icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                      items: locations.map((loc) {
                        return DropdownMenuItem(value: loc, child: Text(loc));
                      }).toList(),
                      onChanged: (value) => setState(() => selectedLocation = value),
                    ),
                    const SizedBox(height: AppPaddings.md),
                    TextField(
                      controller: capacityController,
                      style: TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Capacity'),
                    ),
                    const SizedBox(height: AppPaddings.xl),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isPublishing ? null : handlePublish,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        child: _isPublishing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text('Publish Event', style: AppTextStyles.button),
                      ),
                    ),
                    const SizedBox(height: AppPaddings.lg),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
