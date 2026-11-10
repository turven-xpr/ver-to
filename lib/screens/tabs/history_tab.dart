import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_tile.dart';
import '../../widgets/add_task_dialog.dart';
import '../../widgets/streak_modal.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  int _selectedSegment = 0; // 0: Completed, 1: Pending, 2: Incompleted

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    final completed = taskProvider.completedTasks;
    final uncompleted = taskProvider.uncompletedTasks;
    final incompleted = taskProvider.incompletedTasks;
    final total = taskProvider.tasks.length;
    final rate = total > 0 ? ((completed.length / total) * 100).toInt() : 0;

    final List<TaskModel> displayTasks;
    if (_selectedSegment == 0) {
      displayTasks = completed;
    } else if (_selectedSegment == 1) {
      displayTasks = uncompleted;
    } else {
      displayTasks = incompleted;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F0),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  // Duolingo-style Streak Hero Card
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => StreakModal.show(context),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6D00), Color(0xFFFF3D00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF3D00).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Text("🔥", style: TextStyle(fontSize: 28)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${taskProvider.currentStreak} DAY STREAK!",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  taskProvider.isCompletedToday
                                      ? "3+ tasks completed today! Streak secured."
                                      : "${taskProvider.completedTasksTodayCount}/3 tasks done today. Finish ${3 - taskProvider.completedTasksTodayCount} more to extend!",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEBE5DF)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Task Completion Analytics",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E2420),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "$rate% Done",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricTile(
                                title: "Total",
                                value: "$total",
                                icon: Icons.format_list_bulleted,
                                color: const Color(0xFF5E544E),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildMetricTile(
                                title: "Completed",
                                value: "${completed.length}",
                                icon: Icons.check_circle_outline,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildMetricTile(
                                title: "Pending",
                                value: "${uncompleted.length}",
                                icon: Icons.hourglass_top,
                                color: const Color(0xFF1565C0),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildMetricTile(
                                title: "Incomplete",
                                value: "${incompleted.length}",
                                icon: Icons.remove_circle_outline,
                                color: const Color(0xFFE65100),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<int>(
                          segments: [
                            ButtonSegment(
                              value: 0,
                              label: Text("Completed (${completed.length})"),
                              icon: const Icon(Icons.done_all, size: 16),
                            ),
                            ButtonSegment(
                              value: 1,
                              label: Text("Pending (${uncompleted.length})"),
                              icon: const Icon(Icons.pending_actions, size: 16),
                            ),
                            ButtonSegment(
                              value: 2,
                              label: Text("Incompleted (${incompleted.length})"),
                              icon: const Icon(Icons.remove_circle_outline, size: 16),
                            ),
                          ],
                          selected: {_selectedSegment},
                          onSelectionChanged: (val) {
                            setState(() => _selectedSegment = val.first);
                          },
                        ),
                      ),
                      if (_selectedSegment == 0 && completed.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_sweep, color: Colors.red),
                          tooltip: "Clear All Completed",
                          onPressed: () => _confirmClearCompleted(context, taskProvider),
                        ),
                      ],
                      if (_selectedSegment == 2 && incompleted.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_sweep, color: Colors.red),
                          tooltip: "Clear All Incompleted",
                          onPressed: () => _confirmClearIncompleted(context, taskProvider),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (displayTasks.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _selectedSegment == 0
                          ? Icons.checklist_rtl
                          : _selectedSegment == 1
                              ? Icons.celebration_outlined
                              : Icons.thumb_up_alt_outlined,
                      size: 48,
                      color: const Color(0xFF9E948D),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedSegment == 0
                          ? "No completed tasks yet"
                          : _selectedSegment == 1
                              ? "No pending tasks!"
                              : "No incompleted tasks!",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A403A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedSegment == 0
                          ? "Complete tasks in Tab 1 to build your history."
                          : _selectedSegment == 1
                              ? "Great job! You've completed all tasks."
                              : "No tasks have been marked as incompleted.",
                      style: const TextStyle(fontSize: 12, color: Color(0xFF7A706A)),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final task = displayTasks[index];
                  return TaskTile(
                    task: task,
                    onToggle: () => taskProvider.toggleTaskStatus(task.id),
                    onRestore: () => taskProvider.restoreTask(task.id),
                    onMarkIncomplete: () => taskProvider.markAsIncompleted(task.id),
                    onEdit: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AddTaskDialog(
                          initialTask: task,
                          onSave: (title, desc, goalId, priority, dueDate) {
                            taskProvider.updateTask(task.copyWith(
                              title: title,
                              description: desc,
                              linkedGoalId: goalId,
                              clearLinkedGoal: goalId == null,
                              priority: priority,
                              dueDate: dueDate,
                            ));
                          },
                        ),
                      );
                    },
                    onDelete: () => taskProvider.deleteTask(task.id),
                  );
                },
                childCount: displayTasks.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: Color(0xFF6E635C)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _confirmClearCompleted(BuildContext context, TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Clear Completed Tasks?"),
        content: const Text("This will permanently delete all finished tasks."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              taskProvider.clearAllCompleted();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Clear All"),
          ),
        ],
      ),
    );
  }

  void _confirmClearIncompleted(BuildContext context, TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Clear Incompleted Tasks?"),
        content: const Text("This will permanently delete all incompleted tasks."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              taskProvider.clearAllIncompleted();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Clear All"),
          ),
        ],
      ),
    );
  }
}
