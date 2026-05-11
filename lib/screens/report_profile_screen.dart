import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_text_styles.dart';

class ReportProfileScreen extends StatefulWidget {
  const ReportProfileScreen({super.key});

  @override
  State<ReportProfileScreen> createState() => _ReportProfileScreenState();
}

class _ReportProfileScreenState extends State<ReportProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final detailsController = TextEditingController();

  String? _selectedReason;

  static const List<String> _reasons = [
    'Inappropriate content',
    'Harassment or bullying',
    'Fake Profile',
    'Spam or Scam',
    'Offensive language',
    'Other',
  ];

  @override
  void dispose() {
    usernameController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    if (value.trim().length < 2) return 'Username is too short';
    return null;
  }

  String? _validateDetails(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please describe the issue';
    if (value.trim().length < 10) return 'Please provide at least 10 characters';
    return null;
  }

  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to submit a report')),
        );
      }
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'reporterUid': user.uid,
        'reportedUsername': usernameController.text.trim(),
        'reason': _selectedReason,
        'details': detailsController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 10));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e')),
        );
      }
      return;
    }

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Report Submitted', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Thanks for helping keep the community safe.',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textHint),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.primary),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.error),
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
        title: Text('Report a Profile', style: AppTextStyles.title),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 600 ? 560.0 : constraints.maxWidth;
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPaddings.lg,
                    vertical: AppPaddings.lg,
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Help us keep the community safe by reporting inappropriate profiles.',
                          style: AppTextStyles.subtitle,
                        ),
                        const SizedBox(height: AppPaddings.lg),
                        Text('Username to Report', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppPaddings.sm),
                        TextFormField(
                          controller: usernameController,
                          validator: _validateUsername,
                          style: TextStyle(color: AppColors.textPrimary),
                          decoration: _inputDecoration('Enter username'),
                        ),
                        const SizedBox(height: AppPaddings.lg),
                        Text('Reason for Report', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppPaddings.sm),
                        RadioGroup<String>(
                          groupValue: _selectedReason,
                          onChanged: (value) => setState(() => _selectedReason = value),
                          child: Column(
                            children: _reasons.map((reason) => _buildReasonTile(reason)).toList(),
                          ),
                        ),
                        const SizedBox(height: AppPaddings.lg),
                        Text('Additional Details', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppPaddings.sm),
                        TextFormField(
                          controller: detailsController,
                          validator: _validateDetails,
                          maxLines: 5,
                          style: TextStyle(color: AppColors.textPrimary),
                          decoration: _inputDecoration('Provide additional details...'),
                        ),
                        const SizedBox(height: AppPaddings.xl),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            ),
                            child: Text('Save Changes', style: AppTextStyles.button),
                          ),
                        ),
                        const SizedBox(height: AppPaddings.md),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReasonTile(String reason) {
    final isSelected = _selectedReason == reason;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPaddings.sm),
      child: InkWell(
        onTap: () => setState(() => _selectedReason = reason),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          ),
          child: Row(
            children: [
              Radio<String>(value: reason),
              const SizedBox(width: AppPaddings.sm),
              Expanded(child: Text(reason, style: AppTextStyles.body)),
            ],
          ),
        ),
      ),
    );
  }
}
