import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visitor_management/domain/entities/visitor_entity.dart';
import 'package:visitor_management/domain/entities/visitor_status.dart';
import 'package:visitor_management/presentation/providers/visitor_providers.dart';
import 'package:visitor_management/common/utils/ui_helpers.dart';
import 'package:visitor_management/common/widgets/empty_state_widget.dart';
import 'package:visitor_management/common/widgets/error_view.dart';
import 'package:visitor_management/common/widgets/loading_view.dart';
import 'package:visitor_management/presentation/widgets/visitor_card.dart';



class VisitorListScreen extends ConsumerStatefulWidget {
  const VisitorListScreen({super.key});

  @override
  ConsumerState<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends ConsumerState<VisitorListScreen> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openDetails(VisitorEntity v) => context.push('/visitors/${v.id}');

  void _openForm([VisitorEntity? v]) => context.push('/visitors/register', extra: v);

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(visitorListProvider);
    final query = ref.watch(searchQueryProvider);
    final statusFilter = ref.watch(statusFilterProvider);
    final reload = ref.read(visitorListProvider.notifier).load;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitors'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: list.isLoading ? null : reload,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Register'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                controller: _search,
                onChanged: ref.read(searchQueryProvider.notifier).set,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search by name or mobile number',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _search.clear();
                            ref.read(searchQueryProvider.notifier).set('');
                          },
                        ),
                ),
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  for (final status in <String?>[null, ...VisitorStatus.all])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status ?? 'All'),
                        selected: statusFilter == status,
                        onSelected: (_) =>
                            ref.read(statusFilterProvider.notifier).set(status),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(child: _content(list, query, statusFilter, reload)),
          ],
        ),
      ),
    );
  }

  Widget _content(AsyncValue<List<VisitorEntity>> list, String query,
      String? statusFilter, Future<void> Function() reload) {
    if (!list.hasData) {
      return list.hasError
          ? ErrorView(message: errorMessage(list.error!), onRetry: reload)
          : const LoadingView(message: 'Loading visitors…');
    }

    final items = ref.watch(filteredVisitorsProvider);
    final showBanner = list.hasError && !list.isLoading;

    if (items.isEmpty) {
      final filtering = query.trim().isNotEmpty || statusFilter != null;
      return EmptyStateWidget(
        icon: filtering ? Icons.search_off : Icons.person_off_outlined,
        title: filtering ? 'No matching visitors' : 'No visitor records yet',
        message: filtering
            ? 'Try a different name, number or filter.'
            : 'Register your first visitor to get started.',
        actionLabel: filtering ? null : 'Register Visitor',
        onAction: filtering ? null : _openForm,
      );
    }

    final offset = showBanner ? 1 : 0;
    return RefreshIndicator(
      onRefresh: reload,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        itemCount: items.length + offset,
        itemBuilder: (context, index) {
          if (showBanner && index == 0) {
            return InlineErrorBanner(
                message: errorMessage(list.error!), onRetry: reload);
          }
          final v = items[index - offset];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: VisitorCard(
              visitor: v,
              onTap: () => _openDetails(v),
              onEdit: () => _openForm(v),
              onDelete: () => deleteVisitorFlow(context, ref, v),
            ),
          );
        },
      ),
    );
  }
}
