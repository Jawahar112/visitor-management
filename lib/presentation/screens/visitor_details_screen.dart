import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:visitor_management/common/utils/date_utils.dart';
import 'package:visitor_management/domain/entities/visitor_entity.dart';
import 'package:visitor_management/presentation/providers/visitor_providers.dart';
import 'package:visitor_management/common/utils/ui_helpers.dart';
import 'package:visitor_management/common/widgets/custom_button.dart';
import 'package:visitor_management/common/widgets/empty_state_widget.dart';
import 'package:visitor_management/presentation/widgets/status_chip.dart';



class VisitorDetailsScreen extends ConsumerWidget {
  const VisitorDetailsScreen({super.key, required this.visitorId});
  final String visitorId;

  Future<void> _runAction(
      BuildContext context, WidgetRef ref, VisitorEntity v) async {
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(visitorListProvider.notifier);
    try {
      if (v.canCheckIn) {
        await notifier.checkIn(v.id);
        showSnack(messenger, '${v.name} checked in');
      } else if (v.canCheckOut) {
        await notifier.checkOut(v.id);
        showSnack(messenger, '${v.name} checked out');
      }
    } catch (e) {
      showSnack(messenger, errorMessage(e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = ref.watch(visitorByIdProvider(visitorId));

    if (v == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Visitor Details')),
        body: const EmptyStateWidget(
          icon: Icons.person_off_outlined,
          title: 'Visitor not found',
          message: 'This visitor may have been deleted.',
        ),
      );
    }

    final theme = Theme.of(context);
    final busy = ref.watch(visitorBusyProvider(visitorId));

    Widget? action;
    if (v.canCheckIn) {
      action = AppButton(
        label: 'Check In',
        icon: Icons.login,
        isLoading: busy,
        onPressed: () => _runAction(context, ref, v),
      );
    } else if (v.canCheckOut) {
      action = AppButton(
        label: 'Check Out',
        icon: Icons.logout,
        isLoading: busy,
        onPressed: () => _runAction(context, ref, v),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Details'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/visitors/register', extra: v),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final deleted = await deleteVisitorFlow(context, ref, v);
              if (deleted) navigator.pop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(v.name,
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                          ),
                          StatusChip(status: v.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(Icons.phone_outlined, 'Mobile', v.mobile),
                      _InfoRow(Icons.email_outlined, 'Email', v.email ?? '—'),
                      _InfoRow(Icons.badge_outlined, 'Visitor type', v.visitorType),
                      _InfoRow(Icons.apartment_outlined, 'Project', v.project),
                      _InfoRow(Icons.edit_note, 'Purpose', v.purpose),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Visitor QR Code', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: QrImageView(
                          data: v.id,
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Visitor ID: ${v.id}',
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Visit activity', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      _InfoRow(Icons.event_available_outlined, 'Registered',
                          formatDateTime(v.createdAt)),
                      _InfoRow(Icons.login, 'Checked in',
                          formatDateTime(v.checkInTime)),
                      _InfoRow(Icons.logout, 'Checked out',
                          formatDateTime(v.checkOutTime)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (action != null)
                action
              else
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 10),
                      Expanded(child: Text('Visit completed. No further action.')),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          SizedBox(
            width: 96,
            child: Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
