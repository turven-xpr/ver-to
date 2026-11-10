import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/note_model.dart';
import '../../models/goal_model.dart';
import '../../providers/goal_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/note_provider.dart';
import '../../widgets/brick_wall_view.dart';
import '../../widgets/add_goal_dialog.dart';
import '../../widgets/add_task_dialog.dart';
import '../../widgets/add_goal_note_dialog.dart';

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
    final noteProvider = Provider.of<NoteProvider>(context);

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
    final goalNotes = noteProvider.getNotesForGoal(currentGoal.id);

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

            // ==================== WALL NOTES SECTION ====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit_note, size: 20, color: Color(currentGoal.colorValue)),
                      const SizedBox(width: 6),
                      Text(
                        "Wall Notes & Reflections (${goalNotes.length})",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2420),
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => _openAddGoalNoteDialog(context, currentGoal),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text("Add Note", style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: Color(currentGoal.colorValue),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            if (goalNotes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5DFD9)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.sticky_note_2_outlined, size: 30, color: Color(currentGoal.colorValue).withOpacity(0.5)),
                      const SizedBox(height: 6),
                      const Text(
                        "No notes added to this wall yet.",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4A403A)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Keep milestone reflections, lessons learned, or strategy notes right here under the wall.",
                        style: TextStyle(fontSize: 12, color: Color(0xFF8F847D)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => _openAddGoalNoteDialog(context, currentGoal),
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text("Add First Note", style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(currentGoal.colorValue),
                          side: BorderSide(color: Color(currentGoal.colorValue).withOpacity(0.5)),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: goalNotes.length,
                itemBuilder: (context, idx) {
                  final note = goalNotes[idx];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5DFD9)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Color(currentGoal.colorValue),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      note.title.isNotEmpty ? note.title : "Reflection",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E2420),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              DateFormat("MMM d, y • HH:mm").format(note.createdAt),
                              style: const TextStyle(fontSize: 11, color: Color(0xFF8F847D)),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 16, color: Color(0xFF8F847D)),
                              padding: EdgeInsets.zero,
                              onSelected: (val) {
                                if (val == 'edit') {
                                  _openEditGoalNoteDialog(context, currentGoal, note);
                                } else if (val == 'delete') {
                                  _confirmDeleteNote(context, note);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 16),
                                      SizedBox(width: 8),
                                      Text("Edit Note", style: TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text("Delete", style: TextStyle(fontSize: 13, color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          note.content,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: Color(0xFF4A403A),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 20),

            // ==================== LINKED TASKS SECTION ====================
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

  void _openAddGoalNoteDialog(BuildContext context, GoalModel currentGoal) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AddGoalNoteDialog(
        goal: currentGoal,
        onSave: (title, content) {
          noteProvider.addGoalNote(
            goalId: currentGoal.id,
            title: title,
            content: content,
          );
        },
      ),
    );
  }

  void _openEditGoalNoteDialog(BuildContext context, GoalModel currentGoal, NoteModel note) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AddGoalNoteDialog(
        goal: currentGoal,
        initialNote: note,
        onSave: (title, content) {
          noteProvider.updateNote(note.copyWith(
            title: title,
            content: content,
          ));
        },
      ),
    );
  }

  void _confirmDeleteNote(BuildContext context, NoteModel note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Note?"),
        content: const Text("Are you sure you want to delete this wall note?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<NoteProvider>(context, listen: false).deleteNote(note.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Delete"),
          ),
        ],
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
