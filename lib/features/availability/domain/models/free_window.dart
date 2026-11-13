/// Represents a potential shared free window between two partners.
class FreeWindow {
  final DateTime start;
  final DateTime end;
  final Duration duration;
  final bool containsTentative;
  final String suggestion;

  const FreeWindow({
    required this.start,
    required this.end,
    required this.duration,
    this.containsTentative = false,
    required this.suggestion,
  });

  String get formattedTime {
    final startStr = _formatHour(start);
    final endStr = _formatHour(end);
    final durMin = duration.inMinutes;
    final durStr = durMin >= 60
        ? '${durMin ~/ 60}h ${durMin % 60 > 0 ? '${durMin % 60}m' : ''}'
        : '${durMin}m';
    return '$startStr – $endStr ($durStr)';
  }

  static String _formatHour(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }
}
