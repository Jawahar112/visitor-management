class VisitorStatus {
  VisitorStatus._();
  static const String registered = 'Registered';
  static const String checkedIn = 'Checked In';
  static const String checkedOut = 'Checked Out';
  static const List<String> all = [registered, checkedIn, checkedOut];
}
