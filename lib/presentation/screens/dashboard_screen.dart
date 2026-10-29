import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visitor_management/common/utils/date_utils.dart';
import 'package:visitor_management/core/theme.dart';
import 'package:visitor_management/domain/entities/visitor_status.dart';
import 'package:visitor_management/presentation/providers/visitor_providers.dart';
import 'package:visitor_management/common/utils/ui_helpers.dart';
import 'package:visitor_management/common/widgets/custom_button.dart';
import 'package:visitor_management/presentation/widgets/dashboard_stat_card.dart';
import 'package:visitor_management/common/widgets/error_view.dart';
import 'package:visitor_management/common/widgets/loading_view.dart';



class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(visitorListProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final reload = ref.read(visitorListProvider.notifier).load;
    final theme = Theme.of(context);

    Widget body;
    if (!list.hasData) {
      body = list.hasError
          ? ErrorView(message: errorMessage(list.error!), onRetry: reload)
          : const LoadingView(message: 'Loading visitors…');
    } else {
      body = RefreshIndicator(
        onRefresh: reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (list.hasError && !list.isLoading)
              InlineErrorBanner(
                  message: errorMessage(list.error!), onRetry: reload),
            Text('Today · ${formatDate(DateTime.now())}',
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: DashboardStatCard(
                      label: 'Total Visitors Today',
                      value: stats.totalToday,
                      icon: Icons.how_to_reg_outlined,
                      color: AppTheme.statusColor(VisitorStatus.registered),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DashboardStatCard(
                      label: 'Currently Checked In',
                      value: stats.checkedInNow,
                      icon: Icons.login,
                      color: AppTheme.statusColor(VisitorStatus.checkedIn),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DashboardStatCard(
                      label: 'Checked Out Today',
                      value: stats.checkedOutToday,
                      icon: Icons.logout,
                      color: AppTheme.statusColor(VisitorStatus.checkedOut),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('Quick actions', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            AppButton(
              label: 'Register Visitor',
              icon: Icons.person_add_alt_1,
              onPressed: () => context.go('/visitors/register')
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Scan QR Code',
              icon: Icons.qr_code_scanner,
              onPressed: () => {context.go('/scan')},
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Visitor List',
              icon: Icons.groups_outlined,
              type: AppButtonType.outlined,
              onPressed: () => {context.go('/visitors')},
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: list.isLoading ? null : reload,
          ),
        ],
      ),
      body: SafeArea(child: body),
    );
  }
}
