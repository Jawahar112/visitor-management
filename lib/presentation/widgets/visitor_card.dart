import 'package:flutter/material.dart';
import 'package:visitor_management/domain/entities/visitor_entity.dart';

import 'status_chip.dart';

class VisitorCard extends StatelessWidget {
  const VisitorCard({
    super.key,
    required this.visitor,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final VisitorEntity visitor;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final initial =
        visitor.name.isEmpty ? '?' : visitor.name.characters.first.toUpperCase();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            ListTile(
              isThreeLine: true,
              leading: CircleAvatar(child: Text(initial)),
              title: Text(
                visitor.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.phone_outlined, size: 15, color: muted),
                      const SizedBox(width: 6),
                      Text(visitor.mobile),
                    ]),
                    const SizedBox(height: 2),
                    Row(children: [
                      Icon(Icons.apartment_outlined, size: 15, color: muted),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${visitor.project} · ${visitor.visitorType}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              trailing: StatusChip(status: visitor.status),
            ),
            if (onEdit != null || onDelete != null)
              Padding(
                padding: const EdgeInsets.only(right: 4, bottom: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        tooltip: 'Edit',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: onEdit,
                      ),
                    if (onDelete != null)
                      IconButton(
                        tooltip: 'Delete',
                        icon: Icon(Icons.delete_outline,
                            color: Colors.red.shade600),
                        onPressed: onDelete,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
