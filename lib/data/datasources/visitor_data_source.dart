// data/datasources/visitor_data_source.dart

import 'package:visitor_management/data/models/visitor_model.dart';

abstract class VisitorDataSource {
  Future<List<VisitorModel>> getAll();
  Future<VisitorModel> getById(String id);
  Future<VisitorModel> create(VisitorModel model);
  Future<VisitorModel> update(VisitorModel model);
  Future<void> delete(String id);
}