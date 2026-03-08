import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tasklistapp/app/app_theme.dart';
import 'package:tasklistapp/widgets/commonwidgets.dart';
import '../dashboard/task_model.dart';
import '../dashboard/task_provider.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback? onEdit;

  const TaskTile({
    super.key,
    required this.task,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {

    final provider = context.read<TaskProvider>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Slidable(
        key: ValueKey(task.id),

        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.45,

          children: [

            if (onEdit != null)
              SlidableAction(
                onPressed: (_) => onEdit!(),
                backgroundColor: AppTheme.secondaryColor,
                icon: Icons.edit,
                label: "Edit",
              ),

            SlidableAction(
              onPressed: (_) => _delete(context, provider),
              backgroundColor: AppTheme.errorColor,
              icon: Icons.delete,
              label: "Delete",
            ),
          ],
        ),

        child: _TaskCard(task: task),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    TaskProvider provider,
  ) async {

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Task"),
        content: Text('Delete "${task.title}"?'),

        actions: [

          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await provider.deleteTask(task.id);
    }
  }
}

class _TaskCard extends StatelessWidget {

  final Task task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {

    final provider = context.read<TaskProvider>();

    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),

      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: task.isCompleted
              ? AppTheme.successColor
              : Colors.grey.shade300,
        ),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(16),

        onTap: () => provider.toggle(task),

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [

              _Check(task: task),

              const SizedBox(width: 14),

              Expanded(child: _TaskContent(task: task)),

            ],
          ),
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {

  final Task task;

  const _Check({required this.task});

  @override
  Widget build(BuildContext context) {

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),

      width: 24,
      height: 24,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        border: Border.all(
          color: task.isCompleted
              ? AppTheme.successColor
              : Colors.grey,
          width: 2,
        ),

        color: task.isCompleted
            ? AppTheme.successColor
            : Colors.transparent,
      ),

      child: task.isCompleted
          ? const Icon(Icons.check,
              color: Colors.white,
              size: 14)
          : null,
    );
  }
}

class _TaskContent extends StatelessWidget {

  final Task task;

  const _TaskContent({required this.task});

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(
          task.title,

          style: theme.textTheme.titleMedium?.copyWith(
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : null,
          ),
        ),

        if (task.description != null)
          Text(
            task.description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

        const SizedBox(height: 6),

        Row(
          children: [

            PriorityBadge(priority: task.priority.name),

            if (task.category != null) ...[
              const SizedBox(width: 6),

              Text(task.category!,
                  style: const TextStyle(fontSize: 11)),
            ],

            const Spacer(),

            Text(
              DateFormat('MMM d')
                  .format(task.createdAt),

              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}