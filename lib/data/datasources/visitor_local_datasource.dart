import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:visitor_management/data/datasources/visitor_data_source.dart';
import 'package:visitor_management/data/models/visitor_model.dart';
import 'package:visitor_management/core/exceptions/app_exceptions.dart';


/// Local "database": all visitors are stored as one JSON list on the device.
/// Same contract as the remote source, so it can be swapped in with one line.
class VisitorLocalDataSource implements VisitorDataSource {
  static const _listKey = 'visitors_v1';
  static const _counterKey = 'visitors_next_id';

  Future<SharedPreferences>? _prefsFuture;
  Future<SharedPreferences> get _prefs =>
      _prefsFuture ??= SharedPreferences.getInstance();

  // Runs read-modify-write operations one at a time so two quick actions
  // (e.g. a double scan) can never overwrite each other.
  Future<void> _tail = Future.value();
  Future<T> _synchronized<T>(Future<T> Function() action) {
    final result = _tail.then((_) => action());
    _tail = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<List<VisitorModel>> _read() async {
    final raw = (await _prefs).getString(_listKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return [
        for (final item in decoded)
          if (item is Map)
            VisitorModel.fromJson(Map<String, dynamic>.from(item)),
      ];
    } on FormatException {
      throw  AppException('Local database is corrupted.');
    }
  }

  Future<void> _write(List<VisitorModel> list) async {
    await (await _prefs)
        .setString(_listKey, jsonEncode([for (final m in list) m.toJson()]));
  }

  @override
  Future<List<VisitorModel>> getAll() => _synchronized(_read);

  @override
  Future<VisitorModel> getById(String id) => _synchronized(() async {
        final list = await _read();
        for (final m in list) {
          if (m.id == id) return m;
        }
        throw  NotFoundException();
      });

  @override
  Future<VisitorModel> create(VisitorModel model) => _synchronized(() async {
        final prefs = await _prefs;
        final list = await _read();

        // Local stand-in for a server-generated id: VIS001, VIS002, ...
        final next = (prefs.getInt(_counterKey) ?? list.length) + 1;
        final id = 'VIS${next.toString().padLeft(3, '0')}';

        final saved = VisitorModel.fromJson(
            {...model.toJson(includeId: false), 'id': id});
        await _write([...list, saved]);
        await prefs.setInt(_counterKey, next);
        return saved;
      });

  @override
  Future<VisitorModel> update(VisitorModel model) => _synchronized(() async {
        final list = await _read();
        final i = list.indexWhere((m) => m.id == model.id);
        if (i < 0) throw  NotFoundException();
        list[i] = model;
        await _write(list);
        return model;
      });

  @override
  Future<void> delete(String id) => _synchronized(() async {
        final list = await _read();
        final before = list.length;
        list.removeWhere((m) => m.id == id);
        if (list.length == before) throw  NotFoundException();
        await _write(list);
      });
}