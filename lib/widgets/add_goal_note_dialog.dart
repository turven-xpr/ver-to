import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../models/goal_model.dart';

class AddGoalNoteDialog extends StatefulWidget {
  final GoalModel goal;
  final NoteModel? initialNote;
  final Function(String title, String content) onSave;

  const AddGoalNoteDialog({
    super.key,
    required this.goal,
    this.initialNote,
    required this.onSave,
  });

  @override
  State<AddGoalNoteDialog> createState() => _AddGoalNoteDialogState();
}

class _AddGoalNoteDialogState extends State<AddGoalNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialNote?.title ?? '');
    _contentController = TextEditingController(text: widget.initialNote?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialNote != null;
    final goalColor = Color(widget.goal.colorValue);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: goalColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.sticky_note_2_outlined, color: goalColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isEditing ? "Edit Wall Note" : "Add Wall Note",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2420),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: goalColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: goalColor.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("🧱", style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        widget.goal.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: goalColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title (Optional)",
                  hintText: "e.g. 25 Bricks Milestone, Strategy Note...",
                  prefixIcon: Icon(Icons.title, size: 20),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _contentController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: "Reflection / Note *",
                  hintText: "Write your thoughts, observations, or lesson learned while building this wall...",
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 50),
                    child: Icon(Icons.edit_note, size: 20),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Please enter your note";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSave(
                          _titleController.text.trim(),
                          _contentController.text.trim(),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goalColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(isEditing ? "Update Note" : "Save Note"),
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

