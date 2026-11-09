import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_tile.dart';
import '../../widgets/add_task_dialog.dart';

class TasksTab extends StatelessWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.uncompletedTasks;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F0),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: (val) => taskProvider.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: "Search tasks...",
                      prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF8F847D)),
                      suffixIcon: taskProvider.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => taskProvider.setSearchQuery(''),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5DFD9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5DFD9)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Active Tasks (${tasks.length})",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2420),
                        ),
                      ),
                      Text(
                        "${taskProvider.completedTasks.length} Completed",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8F847D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (taskProvider.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (tasks.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFECE6E0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: Color(0xFF8F847D),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "All caught up!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2420),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "No active tasks right now. Tap '+' below to add one.",
                      style: TextStyle(fontSize: 13, color: Color(0xFF7A706A)),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final task = tasks[index];
                  return TaskTile(
                    task: task,
                    onToggle: () => taskProvider.toggleTaskStatus(task.id),
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
                childCount: tasks.length,
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AddTaskDialog(
              onSave: (title, desc, goalId, priority, dueDate) {
                taskProvider.addTask(
                  title: title,
                  description: desc,
                  linkedGoalId: goalId,
                  priority: priority,
                  dueDate: dueDate,
                );
              },
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Task"),
      ),
    );
  }
}
