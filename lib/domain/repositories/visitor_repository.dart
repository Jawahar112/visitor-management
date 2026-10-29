import '../entities/visitor_entity.dart';

abstract class VisitorRepository {
  Future<List<VisitorEntity>> getVisitors();
  Future<VisitorEntity> getVisitorById(String id);
  Future<VisitorEntity> registerVisitor(VisitorDraft draft);
  Future<VisitorEntity> updateVisitorDetails(String id, VisitorDraft draft);
  Future<void> deleteVisitor(String id);

  Future<VisitorEntity> checkIn(String id);
  Future<VisitorEntity> checkOut(String id);
}
