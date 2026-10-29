import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visitor_management/core/exceptions/error_mapper.dart';
import 'package:visitor_management/domain/entities/visitor_entity.dart';
import 'package:visitor_management/presentation/providers/visitor_providers.dart';

final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

void showGlobalSnack(String message, {bool isError = true}) {
  rootMessengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red.shade700 : null,
    ));
}


void showSnack(ScaffoldMessengerState messenger, String message,
    {bool isError = false}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red.shade700 : null,
    ));
}

String errorMessage(Object error) => mapError(error).message;

extension VisitorListAsync on AsyncValue<List<VisitorEntity>> {
  bool get hasData => valueOrNull != null;
}

Future<bool> confirmDelete(BuildContext context, VisitorEntity visitor) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete visitor?'),
      content: Text(
          '${visitor.name} (ID: ${visitor.id}) will be permanently removed. '
          'This cannot be undone.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<bool> deleteVisitorFlow(
    BuildContext context, WidgetRef ref, VisitorEntity visitor) async {
  final messenger = ScaffoldMessenger.of(context);
  final notifier = ref.read(visitorListProvider.notifier);
  if (!await confirmDelete(context, visitor)) return false;
  try {
    await notifier.delete(visitor.id);
    showSnack(messenger, 'Visitor deleted');
    return true;
  } catch (e) {
    showSnack(messenger, errorMessage(e), isError: true);
    return false;
  }
}
