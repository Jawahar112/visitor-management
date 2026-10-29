import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visitor_management/data/datasources/visitor_data_source.dart';
import 'package:visitor_management/data/datasources/visitor_remote_datasource.dart';
import 'package:visitor_management/data/repositories/visitor_repository_impl.dart';
import 'package:visitor_management/domain/entities/dashboard_stats.dart';
import 'package:visitor_management/domain/entities/visitor_entity.dart';
import 'package:visitor_management/core/exceptions/app_exceptions.dart';
import 'package:visitor_management/domain/repositories/visitor_repository.dart';



final visitorDataSourceProvider =
    Provider<VisitorDataSource>((ref) => VisitorRemoteDataSource());

final visitorRepositoryProvider = Provider<VisitorRepository>(
    (ref) => VisitorRepositoryImpl(ref.read(visitorDataSourceProvider)));

class VisitorListNotifier extends Notifier<AsyncValue<List<VisitorEntity>>> {
  bool _loading = false;

  VisitorRepository get _repo => ref.read(visitorRepositoryProvider);

  @override
  AsyncValue<List<VisitorEntity>> build() {
    Future.microtask(load);
    return const AsyncValue.loading();
  }

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    state = const AsyncLoading<List<VisitorEntity>>().copyWithPrevious(state);
    final result = await AsyncValue.guard(() async {
      final list = await _repo.getVisitors();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
    state = result.copyWithPrevious(state);
    _loading = false;
  }

  Future<VisitorEntity> register(VisitorDraft draft) async {
    final created = await _repo.registerVisitor(draft);
    _upsert(created);
    return created;
  }

  Future<VisitorEntity> updateDetails(String id, VisitorDraft draft) async {
    final saved = await _repo.updateVisitorDetails(id, draft);
    _upsert(saved);
    return saved;
  }

  Future<void> delete(String id) async {
    await _repo.deleteVisitor(id);
    state = AsyncData(
        [for (final v in _current) if (v.id != id) v]);
  }

  /// Used by the QR scanner: always asks the server, then caches the result.
  Future<VisitorEntity> fetchById(String id) async {
    final visitor = await _repo.getVisitorById(id);
    _upsert(visitor);
    return visitor;
  }

  Future<VisitorEntity> checkIn(String id) =>
      _transition(id, () => _repo.checkIn(id));

  Future<VisitorEntity> checkOut(String id) =>
      _transition(id, () => _repo.checkOut(id));

  Future<VisitorEntity> _transition(
      String id, Future<VisitorEntity> Function() action) async {
    final busy = ref.read(busyVisitorIdsProvider.notifier);
    if (!busy.tryAdd(id)) {
      throw  BusinessRuleException(
          'Another action is already in progress for this visitor.');
    }
    try {
      final updated = await action();
      _upsert(updated);
      return updated;
    } on BusinessRuleException catch (_) {
      rethrow;
    } finally {
      busy.remove(id);
    }
  }

  List<VisitorEntity> get _current => state.valueOrNull ?? const [];

  void _upsert(VisitorEntity visitor) {
    final list = [..._current];
    final i = list.indexWhere((v) => v.id == visitor.id);
    if (i >= 0) {
      list[i] = visitor;
    } else {
      list.insert(0, visitor);
    }
    state = AsyncData(list);
  }
}

final visitorListProvider =
    NotifierProvider<VisitorListNotifier, AsyncValue<List<VisitorEntity>>>(
        VisitorListNotifier.new);

class BusyIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  bool tryAdd(String id) {
    if (state.contains(id)) return false;
    state = {...state, id};
    return true;
  }

  void remove(String id) => state = {...state}..remove(id);
}

final busyVisitorIdsProvider =
    NotifierProvider<BusyIdsNotifier, Set<String>>(BusyIdsNotifier.new);

final visitorBusyProvider = Provider.family<bool, String>(
    (ref, id) => ref.watch(busyVisitorIdsProvider).contains(id));

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String value) => state = value;
}

class StatusFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);
final statusFilterProvider =
    NotifierProvider<StatusFilterNotifier, String?>(StatusFilterNotifier.new);

final filteredVisitorsProvider = Provider<List<VisitorEntity>>((ref) {
  final all = ref.watch(visitorListProvider).valueOrNull ?? const [];
  final q = ref.watch(searchQueryProvider).trim().toLowerCase();
  final status = ref.watch(statusFilterProvider);
  return all.where((v) {
    if (status != null && v.status != status) return false;
    if (q.isEmpty) return true;
    return v.name.toLowerCase().contains(q) || v.mobile.contains(q);
  }).toList();
});

final dashboardStatsProvider = Provider<DashboardStats>((ref) =>
    DashboardStats.from(
        ref.watch(visitorListProvider).valueOrNull ?? const [], DateTime.now()));

final visitorByIdProvider = Provider.family<VisitorEntity?, String>((ref, id) {
  final list = ref.watch(visitorListProvider).valueOrNull ?? const [];
  for (final v in list) {
    if (v.id == id) return v;
  }
  return null;
});
