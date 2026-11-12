import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/track_provider.dart';
import '../models/track_model.dart';

class AddTrackItemDialog extends StatefulWidget {
  final TrackItemModel? existingItem;

  const AddTrackItemDialog({super.key, this.existingItem});

  static Future<void> show(BuildContext context, {TrackItemModel? existingItem}) {
    return showDialog(
      context: context,
      builder: (_) => AddTrackItemDialog(existingItem: existingItem),
    );
  }

  @override
  State<AddTrackItemDialog> createState() => _AddTrackItemDialogState();
}

class _AddTrackItemDialogState extends State<AddTrackItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _selectedEmoji;
  late int _selectedColor;

  final List<String> _emojis = const [
    '❤️', '🏃', '🥗', '🧠', '💤', '💧', '🧘', '💪', '📖', '🎯', '✨', '🔥', '☕', '🌿', '📈', '⚡'
  ];

  final List<int> _colors = const [
    0xFFE53935, // Red
    0xFFD84315, // Brick Orange
    0xFFFB8C00, // Amber
    0xFF43A047, // Green
    0xFF00897B, // Teal
    0xFF1E88E5, // Blue
    0xFF5E35B1, // Purple
    0xFF8D6E63, // Brown
    0xFF546E7A, // Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingItem?.title ?? '');
    _descController = TextEditingController(text: widget.existingItem?.description ?? '');
    _selectedEmoji = widget.existingItem?.icon ?? '❤️';
    _selectedColor = widget.existingItem?.colorValue ?? 0xFFE53935;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(_selectedColor).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(_selectedEmoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 10),
          Text(
            isEditing ? "Edit Tracker" : "New Track Item",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Tracker Name *",
                  hintText: "e.g. Health, Deep Work, Nutrition",
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Please enter a tracker name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: "Description (optional)",
                  hintText: "What are you tracking here?",
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Text(
                "Choose Icon / Emoji",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5D5047)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _emojis.map((emoji) {
                  final isSelected = emoji == _selectedEmoji;
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFD84315).withValues(alpha: 0.2) : const Color(0xFFF2ECE6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFD84315) : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 20)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                "Theme Color",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5D5047)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colors.map((c) {
                  final isSelected = c == _selectedColor;
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => setState(() => _selectedColor = c),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black87 : Colors.white,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(_selectedColor),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final provider = Provider.of<TrackProvider>(context, listen: false);
              if (isEditing) {
                final updated = widget.existingItem!.copyWith(
                  title: _titleController.text.trim(),
                  description: _descController.text.trim(),
                  icon: _selectedEmoji,
                  colorValue: _selectedColor,
                );
                provider.updateTrackItem(updated);
              } else {
                provider.addTrackItem(
                  title: _titleController.text.trim(),
                  description: _descController.text.trim(),
                  icon: _selectedEmoji,
                  colorValue: _selectedColor,
                );
              }
              Navigator.pop(context);
            }
          },
          child: Text(isEditing ? "Save Changes" : "Create Tracker"),
        ),
      ],
    );
  }
}
