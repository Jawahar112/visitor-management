const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

DateTime? parseDate(dynamic value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value.trim())?.toLocal();
}

String toIsoWithOffset(DateTime date) {
  final local = date.toLocal();
  final offset = local.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final hh = offset.inHours.abs().toString().padLeft(2, '0');
  final mm = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
  final base = local.toIso8601String().split('.').first;
  return '$base$sign$hh:$mm';
}

bool isSameDay(DateTime? a, DateTime b) {
  if (a == null) return false;
  final x = a.toLocal();
  final y = b.toLocal();
  return x.year == y.year && x.month == y.month && x.day == y.day;
}

String formatDate(DateTime date) {
  final l = date.toLocal();
  return '${l.day} ${_months[l.month - 1]} ${l.year}';
}

String formatDateTime(DateTime? date) {
  if (date == null) return '—';
  final l = date.toLocal();
  final hour = l.hour % 12 == 0 ? 12 : l.hour % 12;
  final minute = l.minute.toString().padLeft(2, '0');
  final suffix = l.hour >= 12 ? 'PM' : 'AM';
  return '${formatDate(l)}, $hour:$minute $suffix';
}
