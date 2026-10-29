import 'package:dio/dio.dart';
import 'package:visitor_management/core/app_config.dart';
import 'package:visitor_management/core/network/dio_instance.dart';
import 'package:visitor_management/data/datasources/visitor_data_source.dart';
import 'package:visitor_management/data/models/visitor_model.dart';

class VisitorRemoteDataSource implements VisitorDataSource {
  VisitorRemoteDataSource({Dio? dioClient}) : _dio = dioClient ?? dio;

  final Dio _dio;

  String _path(String id) =>
      '${AppConfig.visitorsPath}/${Uri.encodeComponent(id)}';

  /// GET /visitors
  @override
  Future<List<VisitorModel>> getAll() async {
    final res = await _dio.get(AppConfig.visitorsPath);
    return (res.data as List)
        .map((e) => VisitorModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// GET /visitors/{id}
  @override
  Future<VisitorModel> getById(String id) async {
    final res = await _dio.get(_path(id));
    return VisitorModel.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// POST /visitors
  @override 
  Future<VisitorModel> create(VisitorModel model) async {
    final res = await _dio.post(
      AppConfig.visitorsPath,
      data: model.toJson(includeId: false),
    );
    return VisitorModel.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// PUT /visitors/{id}
  @override 
  Future<VisitorModel> update(VisitorModel model) async {
    final res = await _dio.put(_path(model.id), data: model.toJson());
    return VisitorModel.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// DELETE /visitors/{id}
  @override 
  Future<void> delete(String id) async {
    await _dio.delete(_path(id));
  }
}