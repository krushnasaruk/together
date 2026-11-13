import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/clay/clay_button.dart';
import '../../../../shared/widgets/clay/together_surface.dart';
import '../../../../shared/widgets/components/together_feedback.dart';
import '../../../../shared/widgets/mascot/together_mascot.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../domain/models/event_model.dart';
import '../providers/event_provider.dart';

/// Bottom sheet dialog for creating and editing calendar events.
class EventFormSheet extends ConsumerStatefulWidget {
  final CalendarEvent? initialEvent;
  final DateTime? defaultDate;

  const EventFormSheet({
    super.key,
    this.initialEvent,
    this.defaultDate,
  });

  static Future<void> show(
    BuildContext context, {
    CalendarEvent? event,
    DateTime? defaultDate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EventFormSheet(
        initialEvent: event,
        defaultDate: defaultDate,
      ),
    );
  }

  @override
  ConsumerState<EventFormSheet> createState() => _EventFormSheetState();
}

class _EventFormSheetState extends ConsumerState<EventFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _locationController;

  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late EventCategory _category;
  late EventVisibility _visibility;
  late EventStatus _status;
  late RecurrenceFrequency _recurrence;

  @override
  void initState() {
    super.initState();
    final event = widget.initialEvent;
    final now = DateTime.now();

    _titleController = TextEditingController(text: event?.title ?? '');
    _descController = TextEditingController(text: event?.description ?? '');
    _locationController = TextEditingController(text: event?.location ?? '');

    _selectedDate = event?.startTime ?? widget.defaultDate ?? now;
    _startTime = event != null
        ? TimeOfDay.fromDateTime(event.startTime)
        : TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);
    _endTime = event != null
        ? TimeOfDay.fromDateTime(event.endTime)
        : TimeOfDay(hour: (now.hour + 2) % 24, minute: 0);

    _category = event?.category ?? EventCategory.personal;
    _visibility = event?.visibility ?? EventVisibility.shared;
    _status = event?.status ?? EventStatus.confirmed;
    _recurrence = event?.recurrence ?? RecurrenceFrequency.none;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.partnerSage,
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
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.partnerSage,
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
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveEvent() {
    if (!_formKey.currentState!.validate()) return;

    final startDateTime = _combineDateAndTime(_selectedDate, _startTime);
    var endDateTime = _combineDateAndTime(_selectedDate, _endTime);

    if (endDateTime.isBefore(startDateTime)) {
      endDateTime = startDateTime.add(const Duration(hours: 1));
    }

    final auth = ref.read(authProvider);
    final user = auth.currentUser;
    final isEditing = widget.initialEvent != null;

    final event = CalendarEvent(
      id: widget.initialEvent?.id ?? const Uuid().v4(),
      coupleId: user.coupleId ?? 'couple_workspace_01',
      ownerId: widget.initialEvent?.ownerId ?? user.uid,
      ownerName: widget.initialEvent?.ownerName ?? user.displayName,
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      startTime: startDateTime,
      endTime: endDateTime,
      category: _category,
      visibility: _visibility,
      status: _status,
      recurrence: _recurrence,
      version: widget.initialEvent?.version ?? 1,
      createdAt: widget.initialEvent?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (isEditing) {
      ref.read(eventProvider.notifier).updateEvent(event);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event updated & partner notified.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ref.read(eventProvider.notifier).addEvent(event);
      TogetherFeedback.showToast(
        context,
        message: 'Event scheduled & synchronized with partner.',
        pose: MisoPose.celebrating,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.initialEvent != null;
    final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
            children: [
              // Top drag bar & header
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderMedium,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      isEditing ? 'Edit Event' : 'New Life Event',
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

              // Scrollable Form Body
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                    // Title field
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Event Title',
                        hintText: 'e.g., Studio Critique, Dentist, Dinner Date',
                        prefixIcon: Icon(Icons.title_rounded, size: 20),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please provide an event title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date & Time Selectors (Inset Clay Surfaces)
                    Row(
                      children: [
                        Expanded(
                          child: TogetherSurface(
                            surfaceType: ClaySurfaceType.inset,
                            onTap: _pickDate,
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusMd),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 18, color: AppColors.partnerSage),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    DateFormat('MMM d, yyyy')
                                        .format(_selectedDate),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TogetherSurface(
                            surfaceType: ClaySurfaceType.inset,
                            onTap: () => _pickTime(isStart: true),
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusMd),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            child: Row(
                              children: [
                                Icon(Icons.schedule_rounded,
                                    size: 18,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary),
                                const SizedBox(width: 8),
                                Text(
                                  'Start: ${_startTime.format(context)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TogetherSurface(
                            surfaceType: ClaySurfaceType.inset,
                            onTap: () => _pickTime(isStart: false),
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusMd),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            child: Row(
                              children: [
                                Icon(Icons.schedule_rounded,
                                    size: 18,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary),
                                const SizedBox(width: 8),
                                Text(
                                  'End: ${_endTime.format(context)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Privacy & Visibility Selector (Tactile Raised Clay Surface)
                    Text(
                      'Visibility to Partner',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TogetherSurface(
                      surfaceType: ClaySurfaceType.raised,
                      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                      padding: EdgeInsets.zero,
                      borderColor: isDark
                          ? AppColors.darkDivider
                          : AppColors.borderSubtle,
                      child: Column(
                        children: [
                          RadioListTile<EventVisibility>(
                            value: EventVisibility.shared,
                            groupValue: _visibility,
                            activeColor: isDark
                                ? AppColors.darkPrimary
                                : AppColors.partnerSage,
                            title: const Text(
                              'Shared with Partner',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              'Partner sees title, time, and full details',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary),
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _visibility = val);
                              }
                            },
                          ),
                          const Divider(height: 1),
                          RadioListTile<EventVisibility>(
                            value: EventVisibility.private,
                            groupValue: _visibility,
                            activeColor: isDark
                                ? AppColors.darkPrimary
                                : AppColors.partnerSage,
                            title: const Text(
                              'Private (Busy Time Block)',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              'Partner only sees "Busy". Details and notes are hidden',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary),
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _visibility = val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Chips
                    Text(
                      'Category',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: EventCategory.values.map((cat) {
                        final isSelected = _category == cat;
                        return ChoiceChip(
                          avatar: Icon(
                            cat.icon,
                            size: 16,
                            color:
                                isSelected ? AppColors.textInverse : cat.color,
                          ),
                          label: Text(cat.label),
                          selected: isSelected,
                          selectedColor: cat.color,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.textInverse
                                : AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : AppColors.borderSubtle,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _category = cat);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Location & Description
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location / Venue',
                        hintText:
                            'e.g., Downtown Dental, Hall C, Trattoria Romana',
                        prefixIcon: Icon(Icons.place_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes / Description',
                        hintText: 'Add private or shared context...',
                        prefixIcon: Icon(Icons.notes_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Recurrence
                    DropdownButtonFormField<RecurrenceFrequency>(
                      value: _recurrence,
                      decoration: const InputDecoration(
                        labelText: 'Recurrence',
                        prefixIcon: Icon(Icons.repeat_rounded, size: 20),
                      ),
                      items: RecurrenceFrequency.values.map((r) {
                        return DropdownMenuItem(
                          value: r,
                          child: Text(r.label,
                              style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _recurrence = val);
                        }
                      },
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),

              // Bottom Save Action
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: ClayButton(
                  onPressed: _saveEvent,
                  label: isEditing ? 'Save Changes' : 'Schedule Event',
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
