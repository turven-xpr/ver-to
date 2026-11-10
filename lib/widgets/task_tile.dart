import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/goal_provider.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onMarkIncomplete;
  final VoidCallback? onRestore;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.onMarkIncomplete,
    this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);
    final linkedGoal = goalProvider.getGoalById(task.linkedGoalId);

    Color priorityColor;
    switch (task.priority.toLowerCase()) {
      case 'high':
        priorityColor = const Color(0xFFD32F2F);
        break;
      case 'low':
        priorityColor = const Color(0xFF1976D2);
        break;
      default:
        priorityColor = const Color(0xFFF57C00);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.isCompleted ? const Color(0xFFE8E4DF) : const Color(0xFFDFD9D2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: task.isIncompleted
                        ? InkWell(
                            onTap: onRestore ?? onToggle,
                            child: const Icon(
                              Icons.remove_circle,
                              size: 22,
                              color: Color(0xFFE65100),
                            ),
                          )
                        : Checkbox(
                            value: task.isCompleted,
                            onChanged: (_) => onToggle(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            activeColor: linkedGoal != null
                                ? Color(linkedGoal.colorValue)
                                : const Color(0xFFD84315),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: task.isCompleted
                              ? const Color(0xFF9E948D)
                              : task.isIncompleted
                                  ? const Color(0xFF8D6E63)
                                  : const Color(0xFF2E2420),
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      if (task.description != null && task.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: task.isCompleted
                                ? const Color(0xFFB5ADA6)
                                : const Color(0xFF6B6059),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (task.isIncompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE0B2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.remove_circle_outline, size: 10, color: Color(0xFFE65100)),
                                  SizedBox(width: 4),
                                  Text(
                                    "INCOMPLETED",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE65100),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              task.priority.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: priorityColor,
                              ),
                            ),
                          ),
                          if (linkedGoal != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color(linkedGoal.colorValue).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text("🧱 ", style: TextStyle(fontSize: 10)),
                                  Text(
                                    linkedGoal.title,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(linkedGoal.colorValue),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (task.dueDate != null)
                            Builder(
                              builder: (context) {
                                final isExpired = task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isExpired
                                        ? const Color(0xFFFFEBEE)
                                        : const Color(0xFFF0EBE5),
                                    borderRadius: BorderRadius.circular(6),
                                    border: isExpired
                                        ? Border.all(color: const Color(0xFFFFCDD2), width: 1)
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isExpired ? Icons.alarm_off : Icons.access_time,
                                        size: 11,
                                        color: isExpired ? Colors.red.shade700 : const Color(0xFF756A63),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('MMM d • h:mm a').format(task.dueDate!),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                                          color: isExpired ? Colors.red.shade700 : const Color(0xFF756A63),
                                        ),
                                      ),
                                      if (isExpired) ...[
                                        const SizedBox(width: 4),
                                        Text(
                                          "EXPIRED",
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.red.shade700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF8F847D)),
                  padding: EdgeInsets.zero,
                  onSelected: (val) {
                    if (val == 'edit') {
                      onEdit();
                    } else if (val == 'delete') {
                      onDelete();
                    } else if (val == 'mark_incomplete') {
                      onMarkIncomplete?.call();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Task marked as incompleted and moved to Overview"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else if (val == 'restore') {
                      onRestore?.call();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Task restored to active tasks"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text("Edit Task"),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text("Delete", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                    if (task.isIncompleted)
                      const PopupMenuItem(
                        value: 'restore',
                        child: Row(
                          children: [
                            Icon(Icons.restore, size: 18, color: Color(0xFF2E7D32)),
                            SizedBox(width: 8),
                            Text("Restore to Active", style: TextStyle(color: Color(0xFF2E7D32))),
                          ],
                        ),
                      )
                    else
                      const PopupMenuItem(
                        value: 'mark_incomplete',
                        child: Row(
                          children: [
                            Icon(Icons.remove_circle_outline, size: 18, color: Color(0xFFE65100)),
                            SizedBox(width: 8),
                            Text("Mark as incomplete", style: TextStyle(color: Color(0xFFE65100))),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
