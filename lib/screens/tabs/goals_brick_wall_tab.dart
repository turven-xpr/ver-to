import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/brick_wall_view.dart';
import '../../widgets/add_goal_dialog.dart';
import '../../widgets/add_task_dialog.dart';

class GoalsBrickWallTab extends StatefulWidget {
  const GoalsBrickWallTab({super.key});

  @override
  State<GoalsBrickWallTab> createState() => _GoalsBrickWallTabState();
}

class _GoalsBrickWallTabState extends State<GoalsBrickWallTab> {
  int _selectedGoalIndex = 0;

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    final goals = goalProvider.goals;

    if (goalProvider.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F4F0),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (goals.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F4F0),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("🧱", style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text(
                "No Goal Walls Built Yet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Create a goal and start laying bricks with each task!",
                style: TextStyle(color: Color(0xFF7A706A)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _openAddGoalDialog(context),
                icon: const Icon(Icons.add),
                label: const Text("Create Goal Wall"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD84315),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedGoalIndex >= goals.length) {
      _selectedGoalIndex = 0;
    }
    final currentGoal = goals[_selectedGoalIndex];
    final linkedTasks = taskProvider.tasks.where((t) => t.linkedGoalId == currentGoal.id).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 52,
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: goals.length + 1,
                itemBuilder: (context, index) {
                  if (index == goals.length) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ActionChip(
                        avatar: const Icon(Icons.add, size: 16),
                        label: const Text("New Goal"),
                        onPressed: () => _openAddGoalDialog(context),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFDFD9D2)),
                      ),
                    );
                  }

                  final goal = goals[index];
                  final isSelected = index == _selectedGoalIndex;
                  final goalColor = Color(goal.colorValue);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(goal.title),
                      selected: isSelected,
                      selectedColor: goalColor.withOpacity(0.18),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? goalColor : const Color(0xFFDFD9D2),
                        width: isSelected ? 1.5 : 1,
                      ),
                      labelStyle: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? goalColor : const Color(0xFF4A403A),
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedGoalIndex = index);
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AddGoalDialog(
                          initialGoal: currentGoal,
                          onSave: (title, desc, target, color) {
                            goalProvider.updateGoal(currentGoal.copyWith(
                              title: title,
                              description: desc,
                              targetBricks: target,
                              colorValue: color,
                            ));
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text("Edit Goal", style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF7A706A),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: () {
                      _confirmDeleteGoal(context, currentGoal);
                    },
                    icon: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                    label: const Text("Delete Wall", style: TextStyle(fontSize: 12, color: Colors.red)),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
            BrickWallView(
              goal: currentGoal,
              linkedTasks: linkedTasks,
              onAddTask: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AddTaskDialog(
                    preselectedGoalId: currentGoal.id,
                    onSave: (title, desc, goalId, priority, dueDate) {
                      taskProvider.addTask(
                        title: title,
                        description: desc,
                        linkedGoalId: goalId ?? currentGoal.id,
                        priority: priority,
                        dueDate: dueDate,
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Tasks Linked to This Wall (${linkedTasks.length})",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2420),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (linkedTasks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "No tasks connected to this goal yet. Add tasks to start building!",
                  style: TextStyle(fontSize: 13, color: Color(0xFF8F847D), fontStyle: FontStyle.italic),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: linkedTasks.length,
                itemBuilder: (context, idx) {
                  final task = linkedTasks[idx];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5DFD9)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          task.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                          size: 18,
                          color: task.isCompleted ? Color(currentGoal.colorValue) : const Color(0xFF9E948D),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 13,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              color: task.isCompleted ? const Color(0xFF9E948D) : const Color(0xFF2E2420),
                            ),
                          ),
                        ),
                        if (task.isCompleted)
                          const Text(
                            "🧱 1 Brick",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD84315)),
                          ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddGoalDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("New Goal Wall"),
      ),
    );
  }

  void _openAddGoalDialog(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AddGoalDialog(
        onSave: (title, desc, target, color) {
          goalProvider.addGoal(
            title: title,
            description: desc,
            targetBricks: target,
            colorValue: color,
          );
        },
      ),
    );
  }

  void _confirmDeleteGoal(BuildContext context, dynamic currentGoal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Goal Wall?"),
        content: Text("Are you sure you want to delete '${currentGoal.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<GoalProvider>(context, listen: false).deleteGoal(currentGoal.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
