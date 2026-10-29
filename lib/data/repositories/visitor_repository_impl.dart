import 'package:visitor_management/data/datasources/visitor_data_source.dart';
import 'package:visitor_management/data/models/visitor_model.dart';
import 'package:visitor_management/domain/entities/visitor_entity.dart';
import 'package:visitor_management/core/exceptions/app_exceptions.dart';
import 'package:visitor_management/domain/repositories/visitor_repository.dart';



class VisitorRepositoryImpl implements VisitorRepository {
  VisitorRepositoryImpl(this._remote);
  final VisitorDataSource _remote;

  @override
  Future<List<VisitorEntity>> getVisitors() async =>
      (await _remote.getAll()).map((m) => m.toEntity()).toList();

  @override
  Future<VisitorEntity> getVisitorById(String id) async =>
      (await _remote.getById(id)).toEntity();

  @override
  Future<VisitorEntity> registerVisitor(VisitorDraft draft) async {
    final created =
        await _remote.create(VisitorModel.fromDraft(draft, DateTime.now()));
    return created.toEntity();
  }

  /// Re-reads the latest record first so an edit can never undo a check-in.
  @override
  Future<VisitorEntity> updateVisitorDetails(String id, VisitorDraft draft) async {
    final latest = (await _remote.getById(id)).toEntity();
    final saved =
        await _remote.update(VisitorModel.fromEntity(latest.withDetails(draft)));
    return saved.toEntity();
  }

  @override
  Future<void> deleteVisitor(String id) async {
    try {
      await _remote.delete(id);
    } on NotFoundException {
      // already gone on the server – treat as deleted
    }
  }

  /// Re-reads the latest record so stale screens or repeated scans cannot
  /// trigger a duplicate / out-of-order transition.
  @override
  Future<VisitorEntity> checkIn(String id) async {
    final latest = (await _remote.getById(id)).toEntity();
    if (!latest.canCheckIn) {
      throw BusinessRuleException(latest.checkInBlockedReason);
    }
    final saved = await _remote
        .update(VisitorModel.fromEntity(latest.markCheckedIn(DateTime.now())));
    return saved.toEntity();
  }

  @override
  Future<VisitorEntity> checkOut(String id) async {
    final latest = (await _remote.getById(id)).toEntity();
    if (!latest.canCheckOut) {
      throw BusinessRuleException(latest.checkOutBlockedReason);
    }
    final saved = await _remote
        .update(VisitorModel.fromEntity(latest.markCheckedOut(DateTime.now())));
    return saved.toEntity();
  }
}
