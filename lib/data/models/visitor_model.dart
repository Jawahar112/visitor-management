

import 'package:visitor_management/common/utils/date_utils.dart';
import 'package:visitor_management/domain/entities/visitor_entity.dart';
import 'package:visitor_management/domain/entities/visitor_status.dart';

class VisitorModel {
  const VisitorModel({
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
  final String createdAt;
  final String? checkInTime;
  final String? checkOutTime;

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString().trim() ?? '';
    String? nullable(dynamic v) {
      final s = str(v);
      return s.isEmpty ? null : s;
    }

    final id = str(json['id']);
    if (id.isEmpty) throw const FormatException('Visitor record has no id');
    final status = str(json['status']);

    return VisitorModel(
      id: id,
      name: str(json['name']),
      mobile: str(json['mobile']),
      email: nullable(json['email']),
      visitorType: str(json['visitor_type']),
      project: str(json['project']),
      purpose: str(json['purpose']),
      status: status.isEmpty ? VisitorStatus.registered : status,
      createdAt: str(json['created_at']),
      checkInTime: nullable(json['check_in_time']),
      checkOutTime: nullable(json['check_out_time']),
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) => {
        if (includeId) 'id': id,
        'name': name,
        'mobile': mobile,
        'email': email,
        'visitor_type': visitorType,
        'project': project,
        'purpose': purpose,
        'status': status,
        'created_at': createdAt,
        'check_in_time': checkInTime,
        'check_out_time': checkOutTime,
      };

  VisitorEntity toEntity() => VisitorEntity(
        id: id,
        name: name,
        mobile: mobile,
        email: email,
        visitorType: visitorType,
        project: project,
        purpose: purpose,
        status: status,
        createdAt: parseDate(createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0),
        checkInTime: parseDate(checkInTime),
        checkOutTime: parseDate(checkOutTime),
      );

  factory VisitorModel.fromEntity(VisitorEntity e) => VisitorModel(
        id: e.id,
        name: e.name,
        mobile: e.mobile,
        email: e.email,
        visitorType: e.visitorType,
        project: e.project,
        purpose: e.purpose,
        status: e.status,
        createdAt: toIsoWithOffset(e.createdAt),
        checkInTime:
            e.checkInTime == null ? null : toIsoWithOffset(e.checkInTime!),
        checkOutTime:
            e.checkOutTime == null ? null : toIsoWithOffset(e.checkOutTime!),
      );

  factory VisitorModel.fromDraft(VisitorDraft d, DateTime createdAt) =>
      VisitorModel(
        id: '',
        name: d.name,
        mobile: d.mobile,
        email: d.email,
        visitorType: d.visitorType,
        project: d.project,
        purpose: d.purpose,
        status: VisitorStatus.registered,
        createdAt: toIsoWithOffset(createdAt),
      );
}
