import 'package:flutter/material.dart';
import '../models/goal_model.dart';

class AddGoalDialog extends StatefulWidget {
  final GoalModel? initialGoal;
  final Function(String title, String? desc, int targetBricks, int colorValue) onSave;

  const AddGoalDialog({
    super.key,
    this.initialGoal,
    required this.onSave,
  });

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _bricksController;
  int _selectedColorValue = 0xFFD84315;

  final List<int> _colorOptions = const [
    0xFFD84315, // Terracotta Brick
    0xFF2E7D32, // Emerald Forest
    0xFF1565C0, // Deep Sapphire
    0xFFF57F17, // Warm Amber
    0xFF6A1B9A, // Royal Purple
    0xFFC2185B, // Rose Magenta
    0xFF37474F, // Slate Stone
  ];

  final List<int> _brickPresets = [25, 50, 100, 150];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialGoal?.title ?? '');
    _descController = TextEditingController(text: widget.initialGoal?.description ?? '');
    _bricksController = TextEditingController(
      text: widget.initialGoal != null ? widget.initialGoal!.targetBricks.toString() : '100',
    );
    _selectedColorValue = widget.initialGoal?.colorValue ?? 0xFFD84315;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _bricksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialGoal != null;

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
                    isEditing ? "Edit Goal" : "New Brick Wall Goal",
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
                  labelText: "Goal Title *",
                  hintText: "e.g., Read 30 Books or Master Flutter",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Description (optional)",
                  hintText: "What does completing this wall signify?",
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Total Bricks to Build (1 Brick = 1 Task):",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6E635C)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _brickPresets.map((preset) {
                  final isSelected = _bricksController.text == preset.toString();
                  return ChoiceChip(
                    label: Text("$preset Bricks"),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        _bricksController.text = preset.toString();
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _bricksController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Custom Number of Bricks",
                  hintText: "e.g., 75, 100",
                  prefixIcon: Icon(Icons.architecture, size: 20),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Wall Brick Color Theme:",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6E635C)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: _colorOptions.map((c) {
                  final isSelected = _selectedColorValue == c;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorValue = c),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 18, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
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
                      final target = int.tryParse(_bricksController.text.trim()) ?? 100;
                      widget.onSave(
                        title,
                        _descController.text.trim().isEmpty ? null : _descController.text.trim(),
                        target > 0 ? target : 100,
                        _selectedColorValue,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(_selectedColorValue),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(isEditing ? "Save Changes" : "Erect Goal Wall"),
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
