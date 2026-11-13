import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/partner_switcher_badge.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../events/domain/models/event_model.dart';
import '../../../events/presentation/providers/event_provider.dart';
import '../../../events/presentation/widgets/event_details_sheet.dart';
import '../../../events/presentation/widgets/event_form_sheet.dart';

/// Combined Shared Calendar screen offering Month, Week, Day, and Timeline views.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  int _selectedViewIndex = 0; // 0: Month, 1: Week, 2: Day, 3: Timeline
  DateTime _focusedDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  final List<String> _viewTitles = ['Month', 'Week', 'Day', 'Timeline'];

  void _previousPeriod() {
    setState(() {
      if (_selectedViewIndex == 0) {
        // Month
        _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1, 1);
      } else if (_selectedViewIndex == 1) {
        // Week
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
        _focusedDate = _selectedDate;
      } else {
        // Day
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
        _focusedDate = _selectedDate;
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      if (_selectedViewIndex == 0) {
        // Month
        _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1, 1);
      } else if (_selectedViewIndex == 1) {
        // Week
        _selectedDate = _selectedDate.add(const Duration(days: 7));
        _focusedDate = _selectedDate;
      } else {
        // Day
        _selectedDate = _selectedDate.add(const Duration(days: 1));
        _focusedDate = _selectedDate;
      }
    });
  }

  void _goToToday() {
    setState(() {
      _focusedDate = DateTime.now();
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final allEvents = ref.watch(eventProvider);
    final auth = ref.watch(authProvider);
    final currentUserId = auth.currentUser.uid;

    final headerText = _selectedViewIndex == 0
        ? DateFormat('MMMM yyyy').format(_focusedDate)
        : DateFormat('EEE, MMM d, yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Text('Shared Calendar'),
            SizedBox(width: 8),
            PartnerSwitcherBadge(),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded),
            tooltip: 'Go to Today',
            onPressed: _goToToday,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // View Switcher Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Container(
              height: 38,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: List.generate(_viewTitles.length, (index) {
                  final isSelected = _selectedViewIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedViewIndex = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.surface
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _viewTitles[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Date Navigator Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: _previousPeriod,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      headerText,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: _nextPeriod,
                ),
              ],
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                _buildLegendItem('You (Alex)', AppColors.partnerSage),
                const SizedBox(width: 14),
                _buildLegendItem('Partner (Taylor)', AppColors.partnerRose),
                const SizedBox(width: 14),
                _buildLegendItem('Together', AppColors.togetherBlue),
                const Spacer(),
                const Icon(Icons.lock_outline_rounded,
                    size: 12, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                const Text('Private = Busy',
                    style:
                        TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              ],
            ),
          ),
          const Divider(),

          // Dynamic Calendar Body View
          Expanded(
            child: _buildCurrentView(allEvents, currentUserId),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            EventFormSheet.show(context, defaultDate: _selectedDate),
        backgroundColor: AppColors.partnerSage,
        foregroundColor: AppColors.textInverse,
        elevation: 1,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildCurrentView(
      List<CalendarEvent> allEvents, String currentUserId) {
    switch (_selectedViewIndex) {
      case 0:
        return _buildMonthView(allEvents, currentUserId);
      case 1:
        return _buildWeekView(allEvents, currentUserId);
      case 2:
        return _buildDayView(allEvents, currentUserId);
      case 3:
      default:
        return _buildTimelineView(allEvents, currentUserId);
    }
  }

  // MONTH VIEW
  Widget _buildMonthView(List<CalendarEvent> allEvents, String currentUserId) {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final daysInMonth =
        DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    final selectedDayEvents = allEvents.where((e) {
      return e.startTime.year == _selectedDate.year &&
          e.startTime.month == _selectedDate.month &&
          e.startTime.day == _selectedDate.day;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return ListView(
      children: [
        // Days of Week Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
              return SizedBox(
                width: 32,
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Month Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.15,
          ),
          itemCount: 35, // 5 weeks displayed
          itemBuilder: (context, index) {
            final dayNumber = index - startWeekday + 1;
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox();
            }

            final cellDate =
                DateTime(_focusedDate.year, _focusedDate.month, dayNumber);
            final isSelected = cellDate.year == _selectedDate.year &&
                cellDate.month == _selectedDate.month &&
                cellDate.day == _selectedDate.day;
            final isToday = cellDate.year == DateTime.now().year &&
                cellDate.month == DateTime.now().month &&
                cellDate.day == DateTime.now().day;

            final dayEvents = allEvents.where((e) {
              return e.startTime.year == cellDate.year &&
                  e.startTime.month == cellDate.month &&
                  e.startTime.day == cellDate.day;
            }).toList();

            final hasAlex = dayEvents.any((e) => e.ownerId == 'user_alex');
            final hasTaylor = dayEvents.any((e) => e.ownerId == 'user_taylor');
            final hasTogether = dayEvents.any((e) => e.ownerName.contains('&'));

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = cellDate;
                });
              },
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.partnerSageLight
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isToday
                      ? Border.all(color: AppColors.partnerSage, width: 1.5)
                      : (isSelected
                          ? Border.all(
                              color: AppColors.partnerSage.withOpacity(0.5))
                          : null),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$dayNumber',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected || isToday
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
                            ? AppColors.partnerSageDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (hasAlex) _buildDot(AppColors.partnerSage),
                        if (hasTaylor) _buildDot(AppColors.partnerRose),
                        if (hasTogether) _buildDot(AppColors.togetherBlue),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const Divider(),

        // Events list for selected date
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Text(
                'Schedule for ${DateFormat('MMMM d').format(_selectedDate)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                '${selectedDayEvents.length} event(s)',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        if (selectedDayEvents.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No events scheduled for this day.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...selectedDayEvents.map(
            (event) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              child: _buildEventTile(event, currentUserId),
            ),
          ),
        const SizedBox(height: 30),
      ],
    );
  }

  // WEEK VIEW
  Widget _buildWeekView(List<CalendarEvent> allEvents, String currentUserId) {
    final startOfWeek =
        _selectedDate.subtract(Duration(days: _selectedDate.weekday % 7));
    final weekDays =
        List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: weekDays.map((day) {
        final isSelected = day.year == _selectedDate.year &&
            day.month == _selectedDate.month &&
            day.day == _selectedDate.day;
        final dayEvents = allEvents.where((e) {
          return e.startTime.year == day.year &&
              e.startTime.month == day.month &&
              e.startTime.day == day.day;
        }).toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceElevated : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  isSelected ? AppColors.partnerSage : AppColors.borderSubtle,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    DateFormat('EEEE, MMM d').format(day),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.partnerSageDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (dayEvents.isEmpty)
                    const Text('Free day',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textTertiary)),
                ],
              ),
              if (dayEvents.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...dayEvents
                    .map((event) => _buildEventTile(event, currentUserId)),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  // DAY VIEW (Timeline Hour Slots & Overlaps)
  Widget _buildDayView(List<CalendarEvent> allEvents, String currentUserId) {
    final dayEvents = allEvents.where((e) {
      return e.startTime.year == _selectedDate.year &&
          e.startTime.month == _selectedDate.month &&
          e.startTime.day == _selectedDate.day;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final hours = List.generate(16, (i) => i + 7); // 7:00 AM to 10:00 PM

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: hours.length,
      itemBuilder: (context, index) {
        final hour = hours[index];
        final timeStr = DateFormat('h a').format(DateTime(2026, 1, 1, hour));

        final slotEvents = dayEvents.where((e) {
          return e.startTime.hour <= hour && e.endTime.hour >= hour;
        }).toList();

        final hasOverlap = slotEvents.length > 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 55,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  timeStr,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textTertiary),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasOverlap
                        ? AppColors.partnerRoseLight
                        : AppColors.borderSubtle,
                    width: hasOverlap ? 1.5 : 1,
                  ),
                ),
                child: slotEvents.isEmpty
                    ? const SizedBox(
                        height: 24,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('—',
                              style: TextStyle(color: AppColors.borderMedium)),
                        ),
                      )
                    : Column(
                        children: [
                          if (hasOverlap)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      size: 13, color: AppColors.statusTentative),
                                  SizedBox(width: 4),
                                  Text(
                                    'Schedule Overlap / Coinciding commitments',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.statusTentative),
                                  ),
                                ],
                              ),
                            ),
                          ...slotEvents
                              .map((e) => _buildEventTile(e, currentUserId)),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  // TIMELINE VIEW
  Widget _buildTimelineView(
      List<CalendarEvent> allEvents, String currentUserId) {
    final sorted = List<CalendarEvent>.from(allEvents)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = sorted[index];
        return _buildEventTile(event, currentUserId);
      },
    );
  }

  Widget _buildEventTile(CalendarEvent event, String currentUserId) {
    final isMasked = event.isMaskedFor(currentUserId);
    final title = event.displayTitleFor(currentUserId);
    final location = event.displayLocationFor(currentUserId);
    final timeStr =
        '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}';

    final partnerColor = event.ownerId == 'user_alex'
        ? AppColors.partnerSage
        : (event.ownerId == 'user_taylor'
            ? AppColors.partnerRose
            : AppColors.togetherBlue);

    return InkWell(
      onTap: () => EventDetailsSheet.show(context, event),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 34,
              decoration: BoxDecoration(
                color: isMasked ? AppColors.textTertiary : partnerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontStyle:
                                isMasked ? FontStyle.italic : FontStyle.normal,
                            color: isMasked
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isMasked)
                        const Icon(Icons.lock_outline_rounded,
                            size: 13, color: AppColors.textTertiary),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        timeStr,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                      if (location != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '• $location',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textTertiary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
