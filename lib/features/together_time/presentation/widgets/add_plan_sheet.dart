import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/clay/clay_button.dart';
import '../../../../shared/widgets/clay/together_surface.dart';
import '../../domain/models/together_model.dart';
import '../providers/together_plans_provider.dart';

/// Modal bottom sheet for adding romantic date plans, bucket list items, or occasions.
class AddPlanSheet extends ConsumerStatefulWidget {
  final TogetherPlanType defaultType;

  const AddPlanSheet(
      {super.key, this.defaultType = TogetherPlanType.dateNight});

  static Future<void> show(
    BuildContext context, {
    TogetherPlanType defaultType = TogetherPlanType.dateNight,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddPlanSheet(defaultType: defaultType),
    );
  }

  @override
  ConsumerState<AddPlanSheet> createState() => _AddPlanSheetState();
}

class _AddPlanSheetState extends ConsumerState<AddPlanSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  late TogetherPlanType _type;
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    _type = widget.defaultType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.partnerRose,
              onPrimary: AppColors.textInverse,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(togetherPlansProvider.notifier).addPlan(
          type: _type,
          title: _titleController.text.trim(),
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          targetDate: _targetDate,
        );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Added "${_titleController.text.trim()}" to Together Space.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      margin: EdgeInsets.only(bottom: keyboardBottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderMedium,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Add Together Plan',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Flexible(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                    // Plan Type Selector
                    Text(
                      'Category',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: TogetherPlanType.values.map((t) {
                        final isSelected = _type == t;
                        return ChoiceChip(
                          label: Text(t.label),
                          selected: isSelected,
                          selectedColor: AppColors.partnerRose,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.textInverse
                                : AppColors.textPrimary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : AppColors.borderSubtle,
                          ),
                          onSelected: (selected) {
                            if (selected) setState(() => _type = t);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Plan / Idea Title',
                        hintText: 'e.g., Candlelit dinner, See Northern Lights',
                        prefixIcon:
                            Icon(Icons.favorite_outline_rounded, size: 20),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a plan title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Notes
                    TextFormField(
                      controller: _descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Optional Notes & Details',
                        hintText: 'Add places, ideas or links...',
                        prefixIcon: Icon(Icons.notes_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Target Date (Optional)
                    TogetherSurface(
                      surfaceType: ClaySurfaceType.inset,
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded,
                              size: 20, color: AppColors.partnerRose),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _targetDate == null
                                  ? 'Set target date (optional)'
                                  : 'Target: ${DateFormat('MMMM d, yyyy').format(_targetDate!)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: _targetDate == null
                                    ? (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textTertiary)
                                    : (isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary),
                              ),
                            ),
                          ),
                          if (_targetDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () =>
                                  setState(() => _targetDate = null),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: ClayButton(
                  onPressed: _submit,
                  label: 'Add to Together Space',
                  color: AppColors.partnerRose,
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
