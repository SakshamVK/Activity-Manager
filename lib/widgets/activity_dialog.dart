import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/categories.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';
import '../providers/category_provider.dart';
import '../theme/styles.dart';

class ActivityDialog extends ConsumerStatefulWidget {
  const ActivityDialog({super.key, this.activity});

  final Activity? activity;

  @override
  ConsumerState<ActivityDialog> createState() => _ActivityDialogState();
}

class _ActivityDialogState extends ConsumerState<ActivityDialog> {
  late final TextEditingController _titleController;
  late int _selectedCategoryId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.activity?.title ?? '',
    );
    _titleController.addListener(_handleTextChanged);
    _selectedCategoryId =
        widget.activity?.categoryId ?? Categories.dailyActivities.id;
  }

  @override
  void dispose() {
    _titleController
      ..removeListener(_handleTextChanged)
      ..dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _saving) {
      return;
    }

    setState(() {
      _saving = true;
    });

    final notifier = ref.read(activityProvider.notifier);
    final activities = ref.read(activityProvider);

    if (widget.activity == null) {
      final nextId = activities.isEmpty
          ? 1
          : activities
                    .map((activity) => activity.id)
                    .reduce(
                      (current, next) => current > next ? current : next,
                    ) +
                1;
      final categoryActivities =
          activities
              .where((activity) => activity.categoryId == _selectedCategoryId)
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));
      final nextOrder = categoryActivities.isEmpty
          ? 1
          : categoryActivities.last.order + 1;

      await notifier.addActivity(
        Activity(
          id: nextId,
          title: title,
          categoryId: _selectedCategoryId,
          order: nextOrder,
        ),
      );
    } else {
      final activity = widget.activity!;
      final categoryChanged = activity.categoryId != _selectedCategoryId;
      final targetCategoryActivities =
          activities
              .where(
                (item) =>
                    item.categoryId == _selectedCategoryId &&
                    item.id != activity.id,
              )
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));
      final nextOrder = categoryChanged
          ? (targetCategoryActivities.isEmpty
                ? 1
                : targetCategoryActivities.last.order + 1)
          : activity.order;

      await notifier.editActivity(
        id: activity.id,
        title: title,
        categoryId: _selectedCategoryId,
        order: nextOrder,
      );

      if (categoryChanged) {
        final refreshedActivities = ref.read(activityProvider);
        final oldCategoryActivities =
            refreshedActivities
                .where(
                  (item) =>
                      item.categoryId == activity.categoryId &&
                      item.id != activity.id,
                )
                .toList()
              ..sort((a, b) => a.order.compareTo(b.order));
        final newCategoryActivities =
            refreshedActivities
                .where((item) => item.categoryId == _selectedCategoryId)
                .toList()
              ..sort((a, b) => a.order.compareTo(b.order));

        if (oldCategoryActivities.isNotEmpty) {
          await notifier.reorderCategory(oldCategoryActivities);
        }

        await notifier.reorderCategory(newCategoryActivities);
      }
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final canSave = _titleController.text.trim().isNotEmpty && !_saving;

    return AlertDialog(
      backgroundColor: AppStyle.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.activity == null ? 'Add Activity' : 'Edit Activity',
        style: const TextStyle(
          color: AppStyle.text,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              style: const TextStyle(color: AppStyle.text),
              decoration: InputDecoration(
                labelText: 'Activity Name',
                labelStyle: const TextStyle(color: AppStyle.textDim),
                filled: true,
                fillColor: AppStyle.surface2,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppStyle.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppStyle.goldLight),
                ),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              isExpanded: true,
              dropdownColor: AppStyle.surface,
              style: const TextStyle(color: AppStyle.text),
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: const TextStyle(color: AppStyle.textDim),
                filled: true,
                fillColor: AppStyle.surface2,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppStyle.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppStyle.goldLight),
                ),
              ),
              items: categories
                  .map(
                    (category) => DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.title),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: canSave ? _save : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppStyle.gold,
            foregroundColor: AppStyle.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(_saving ? 'Saving...' : 'Save'),
        ),
      ],
    );
  }
}
