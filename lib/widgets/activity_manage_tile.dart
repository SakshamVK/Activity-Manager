import 'package:flutter/material.dart';

import '../constants/categories.dart';
import '../models/activity.dart';
import '../theme/styles.dart';

class ActivityManageTile extends StatelessWidget {
  const ActivityManageTile({
    super.key,
    required this.activity,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  final Activity activity;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final category = Categories.fromId(activity.categoryId);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppStyle.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppStyle.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 32,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: category.color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                Icons.drag_indicator_rounded,
                color: AppStyle.textMuted,
                size: 22,
              ),
            ),
          ),
          Expanded(
            child: Text(
              activity.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppStyle.text,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Edit activity',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: AppStyle.goldLight),
          ),
          IconButton(
            tooltip: 'Delete activity',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppStyle.red),
          ),
        ],
      ),
    );
  }
}
