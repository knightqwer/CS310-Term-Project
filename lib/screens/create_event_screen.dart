import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_text_styles.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final capacityController = TextEditingController();

  String? selectedCategory;
  String? selectedLocation;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

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
            colorScheme: const ColorScheme.dark(
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
            colorScheme: const ColorScheme.dark(
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

  void handlePublish() {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedCategory == null ||
        selectedDate == null ||
        selectedTime == null ||
        selectedLocation == null ||
        capacityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event published successfully!')),
    );
    Navigator.pop(context);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.textSecondary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: const OutlineInputBorder(
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
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
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
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('Event Title'),
                    ),
                    const SizedBox(height: AppPaddings.md),
                    TextField(
                      controller: descriptionController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      maxLines: 3,
                      decoration: _inputDecoration('Description'),
                    ),
                    const SizedBox(height: AppPaddings.md),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textPrimary),
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
                      initialValue: selectedLocation,
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textPrimary),
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
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Capacity'),
                    ),
                    const SizedBox(height: AppPaddings.xl),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: handlePublish,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        child: Text('Publish Event', style: AppTextStyles.button),
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
