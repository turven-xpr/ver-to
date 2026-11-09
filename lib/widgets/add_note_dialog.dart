import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';

class AddNoteDialog extends StatefulWidget {
  final NoteModel? initialNote;
  final String? initialPeriod;
  final Function(String periodType, DateTime date, String title, String content) onSave;

  const AddNoteDialog({
    super.key,
    this.initialNote,
    this.initialPeriod,
    required this.onSave,
  });

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _periodType;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialNote?.title ?? '');
    _contentController = TextEditingController(text: widget.initialNote?.content ?? '');
    _periodType = widget.initialNote?.periodType ?? widget.initialPeriod ?? 'day';
    _date = widget.initialNote?.date ?? DateTime.now();
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
                    isEditing ? "Edit Note" : "Write Journal Note",
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
              const Text(
                "Chronicle Period:",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6E635C)),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'day', label: Text("Day"), icon: Icon(Icons.wb_sunny_outlined, size: 16)),
                  ButtonSegment(value: 'week', label: Text("Week"), icon: Icon(Icons.calendar_view_week, size: 16)),
                  ButtonSegment(value: 'month', label: Text("Month"), icon: Icon(Icons.calendar_month, size: 16)),
                ],
                selected: {_periodType},
                onSelectionChanged: (val) {
                  setState(() => _periodType = val.first);
                },
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) {
                    setState(() => _date = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2DDD7)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event, size: 18, color: Color(0xFF8F847D)),
                      const SizedBox(width: 8),
                      Text(
                        "Date: ${DateFormat('EEEE, MMMM d, yyyy').format(_date)}",
                        style: const TextStyle(fontSize: 13, color: Color(0xFF2E2420)),
                      ),
                      const Spacer(),
                      const Icon(Icons.edit, size: 14, color: Color(0xFF8F847D)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _titleController,
                autofocus: !isEditing,
                decoration: const InputDecoration(
                  labelText: "Headline / Title *",
                  hintText: "e.g., Daily Wins & Reflections",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: "Note Body *",
                  hintText: "Write your thoughts, milestones, or lessons learned...",
                  alignLabelWithHint: true,
                ),
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
                      final content = _contentController.text.trim();
                      if (title.isEmpty || content.isEmpty) return;
                      widget.onSave(_periodType, _date, title, content);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD84315),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(isEditing ? "Save Changes" : "Save Note"),
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
