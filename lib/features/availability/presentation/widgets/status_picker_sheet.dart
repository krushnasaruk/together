import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/clay/clay_button.dart';
import '../../../../shared/widgets/clay/together_surface.dart';
import '../../../../shared/widgets/components/together_feedback.dart';
import '../../../../shared/widgets/mascot/together_mascot.dart';
import '../../../notifications/domain/models/notification_model.dart';
import '../providers/status_provider.dart';

/// Modal bottom sheet allowing users to voluntarily broadcast their quick status.
class StatusPickerSheet extends ConsumerStatefulWidget {
  const StatusPickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const StatusPickerSheet(),
    );
  }

  @override
  ConsumerState<StatusPickerSheet> createState() => _StatusPickerSheetState();
}

class _StatusPickerSheetState extends ConsumerState<StatusPickerSheet> {
  QuickStatusPreset _selectedPreset = QuickStatusPreset.freeNow;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitStatus() {
    ref.read(statusProvider.notifier).setStatus(
          preset: _selectedPreset,
          customNote: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );

    Navigator.of(context).pop();
    TogetherFeedback.showToast(
      context,
      message:
          'Status broadcasted: ${_selectedPreset.title} ${_selectedPreset.emoji}',
      pose: MisoPose.wave,
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Quick Status Update',
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
                  Text(
                    'Share your current availability without continuous GPS tracking.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),

                  // Presets Grid
                  ...QuickStatusPreset.values.map((preset) {
                    final isSelected = _selectedPreset == preset;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TogetherSurface(
                        surfaceType: isSelected
                            ? ClaySurfaceType.raised
                            : ClaySurfaceType.flat,
                        onTap: () {
                          setState(() {
                            _selectedPreset = preset;
                          });
                        },
                        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                        color: isSelected
                            ? (isDark
                                ? const Color(0xFF3B483D)
                                : AppColors.partnerSageLight)
                            : (isDark
                                ? AppColors.darkSurface
                                : AppColors.surface),
                        borderColor: isSelected
                            ? AppColors.partnerSage
                            : (isDark
                                ? AppColors.darkDivider
                                : AppColors.borderSubtle),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Text(
                              preset.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    preset.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? (isDark
                                              ? AppColors.darkPrimary
                                              : AppColors.partnerSageDark)
                                          : (isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.textPrimary),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    preset.subtitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.partnerSage,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),

                  // Custom Note
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Add optional short note',
                      hintText: 'e.g., Grabbed matcha, heading back now!',
                      prefixIcon:
                          Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Submit Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ClayButton(
                onPressed: _submitStatus,
                label: 'Update Status & Inform Partner',
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
