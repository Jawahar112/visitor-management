import 'visitor_entity.dart';

class DashboardStats {
  const DashboardStats({
    required this.totalToday,
    required this.checkedInNow,
    required this.checkedOutToday,
  });

  final int totalToday;
  final int checkedInNow;
  final int checkedOutToday;

  factory DashboardStats.from(List<VisitorEntity> visitors, DateTime now) {
    bool sameDay(DateTime? d) {
      if (d == null) return false;
      final l = d.toLocal();
      final n = now.toLocal();
      return l.year == n.year && l.month == n.month && l.day == n.day;
    }

    return DashboardStats(
      totalToday: visitors.where((v) => sameDay(v.createdAt)).length,
      checkedInNow: visitors.where((v) => v.isCheckedIn).length,
      checkedOutToday:
          visitors.where((v) => v.isCheckedOut && sameDay(v.checkOutTime)).length,
    );
  }
}
