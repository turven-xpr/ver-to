import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/goal_provider.dart';

class AddTaskDialog extends StatefulWidget {
  final TaskModel? initialTask;
  final String? preselectedGoalId;
  final Function(String title, String? desc, String? goalId, String priority, DateTime? dueDate) onSave;

  const AddTaskDialog({
    super.key,
    this.initialTask,
    this.preselectedGoalId,
    required this.onSave,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  String? _selectedGoalId;
  String _priority = 'medium';
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTask?.title ?? '');
    _descController = TextEditingController(text: widget.initialTask?.description ?? '');
    _selectedGoalId = widget.initialTask?.linkedGoalId ?? widget.preselectedGoalId;
    _priority = widget.initialTask?.priority ?? 'medium';
    // Default expired/due date to today at 23:59 PM (end of day) for new tasks
    final now = DateTime.now();
    _dueDate = widget.initialTask?.dueDate ??
        DateTime(now.year, now.month, now.day, 23, 59);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);
    final goals = goalProvider.goals;

    final isEditing = widget.initialTask != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? "Edit Task" : "New Task",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2420),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                autofocus: !isEditing,
                decoration: const InputDecoration(
                  labelText: "Task Title *",
                  hintText: "What do you want to achieve?",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Description (optional)",
                  hintText: "Add notes, steps, or context...",
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Link to Goal (Lays a Brick when completed):",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6E635C)),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String?>(
                value: _selectedGoalId,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text("Select a Goal (or standalone task)"),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text("None (Standalone Task)"),
                  ),
                  ...goals.map((g) {
                    return DropdownMenuItem<String?>(
                      value: g.id,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Color(g.colorValue),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          Text(g.title),
                        ],
                      ),
                    );
                  }),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedGoalId = val;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Priority:",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6E635C)),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _priority,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'low', child: Text("Low")),
                            DropdownMenuItem(value: 'medium', child: Text("Medium")),
                            DropdownMenuItem(value: 'high', child: Text("High")),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _priority = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Due Date (Expires at):",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6E635C)),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _dueDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) {
                              setState(() => _dueDate = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    23,
                                    59,
                                  ));
                            }
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2DDD7)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 18, color: Color(0xFFD84315)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _dueDate != null
                                        ? DateFormat('MMM d • 11:59 PM').format(_dueDate!)
                                        : "No Date",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _dueDate != null
                                          ? const Color(0xFF2E2420)
                                          : const Color(0xFF9E948D),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final title = _titleController.text.trim();
                      if (title.isEmpty) return;
                      widget.onSave(
                        title,
                        _descController.text.trim().isEmpty ? null : _descController.text.trim(),
                        _selectedGoalId,
                        _priority,
                        _dueDate,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD84315),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(isEditing ? "Save Changes" : "Create Task"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
