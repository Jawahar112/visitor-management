import 'visitor_status.dart';

/// Pure business object – knows nothing about JSON, Dio or Flutter.
class VisitorEntity {
  const VisitorEntity({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    required this.visitorType,
    required this.project,
    required this.purpose,
    required this.status,
    required this.createdAt,
    this.checkInTime,
    this.checkOutTime,
  });

  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String visitorType;
  final String project;
  final String purpose;
  final String status;
  final DateTime createdAt;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  bool get isRegistered => status == VisitorStatus.registered;
  bool get isCheckedIn => status == VisitorStatus.checkedIn;
  bool get isCheckedOut => status == VisitorStatus.checkedOut;

  bool get canCheckIn => isRegistered;
  bool get canCheckOut => isCheckedIn;

  String get checkInBlockedReason => isCheckedIn
      ? 'Visitor is already checked in.'
      : 'This visit is already completed and cannot be checked in again.';

  String get checkOutBlockedReason => isRegistered
      ? 'Visitor has not checked in yet, so cannot check out.'
      : 'Visitor is already checked out.';

  VisitorEntity markCheckedIn(DateTime at) => _copy(
      status: VisitorStatus.checkedIn, checkInTime: at);

  VisitorEntity markCheckedOut(DateTime at) => _copy(
      status: VisitorStatus.checkedOut, checkOutTime: at);

  VisitorEntity withDetails(VisitorDraft d) => VisitorEntity(
        id: id,
        name: d.name,
        mobile: d.mobile,
        email: d.email,
        visitorType: d.visitorType,
        project: d.project,
        purpose: d.purpose,
        status: status,
        createdAt: createdAt,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
      );

  VisitorEntity _copy({
    required String status,
    DateTime? checkInTime,
    DateTime? checkOutTime,
  }) =>
      VisitorEntity(
        id: id,
        name: name,
        mobile: mobile,
        email: email,
        visitorType: visitorType,
        project: project,
        purpose: purpose,
        status: status,
        createdAt: createdAt,
        checkInTime: checkInTime ?? this.checkInTime,
        checkOutTime: checkOutTime ?? this.checkOutTime,
      );
}

class VisitorDraft {
  const VisitorDraft({
    required this.name,
    required this.mobile,
    this.email,
    required this.visitorType,
    required this.project,
    required this.purpose,
  });

  final String name;
  final String mobile;
  final String? email;
  final String visitorType;
  final String project;
  final String purpose;
}
