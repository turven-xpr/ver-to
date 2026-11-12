import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/track_provider.dart';
import '../models/track_model.dart';

class AddTrackEntryDialog extends StatefulWidget {
  final String trackItemId;
  final TrackEntryModel? existingEntry;

  const AddTrackEntryDialog({
    super.key,
    required this.trackItemId,
    this.existingEntry,
  });

  static Future<void> show(BuildContext context, {
    required String trackItemId,
    TrackEntryModel? existingEntry,
  }) {
    return showDialog(
      context: context,
      builder: (_) => AddTrackEntryDialog(
        trackItemId: trackItemId,
        existingEntry: existingEntry,
      ),
    );
  }

  @override
  State<AddTrackEntryDialog> createState() => _AddTrackEntryDialogState();
}

class _AddTrackEntryDialogState extends State<AddTrackEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _customTagController;
  late DateTime _selectedDateTime;
  String? _selectedTag;
  int? _selectedRating;

  final List<String> _suggestedTags = const [
    'Workout', 'Nutrition', 'Hydration', 'Sleep', 'Deep Work', 'Habit', 'Mood', 'Reflection'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingEntry?.title ?? '');
    _contentController = TextEditingController(text: widget.existingEntry?.content ?? '');
    _customTagController = TextEditingController();
    _selectedDateTime = widget.existingEntry?.timestamp ?? DateTime.now();
    _selectedTag = widget.existingEntry?.tag;
    _selectedRating = widget.existingEntry?.rating;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _customTagController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingEntry != null;
    final trackProvider = Provider.of<TrackProvider>(context, listen: false);
    final currentItem = trackProvider.selectedItem;
    final color = currentItem != null ? Color(currentItem.colorValue) : const Color(0xFFD84315);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(currentItem?.icon ?? '📝', style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isEditing ? "Edit Track Note" : "Log in ${currentItem?.title ?? 'Tracker'}",
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
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
                  labelText: "Title / Summary *",
                  hintText: "e.g. 5km Morning Run, 8h Quality Sleep",
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Please enter a title or summary";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: "Observations & Details *",
                  hintText: "Write your notes, feelings, metrics, reflections...",
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Please enter your notes";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              // Date & Time Picker Row
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _pickDateTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F3EE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2DDD7)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 18, color: Color(0xFF756A63)),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM d, yyyy • h:mm a').format(_selectedDateTime),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3E342F)),
                      ),
                      const Spacer(),
                      const Text(
                        "Change",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD84315)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Rating / Score (1 to 5)
              Row(
                children: [
                  const Text(
                    "Rating / Energy:",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5D5047)),
                  ),
                  const Spacer(),
                  Row(
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      final isSelected = _selectedRating != null && _selectedRating! >= starValue;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (_selectedRating == starValue) {
                              _selectedRating = null;
                            } else {
                              _selectedRating = starValue;
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Icon(
                            isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: isSelected ? Colors.amber.shade700 : const Color(0xFFBDB6AF),
                            size: 24,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Tags Selector
              const Text(
                "Category Tag",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5D5047)),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _suggestedTags.map((tag) {
                  final isSelected = _selectedTag == tag;
                  return ChoiceChip(
                    label: Text(tag, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : const Color(0xFF4A403A))),
                    selected: isSelected,
                    selectedColor: color,
                    backgroundColor: const Color(0xFFEFE9E2),
                    showCheckmark: false,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTag = selected ? tag : null;
                      });
                    },
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
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final provider = Provider.of<TrackProvider>(context, listen: false);
              if (isEditing) {
                final updated = widget.existingEntry!.copyWith(
                  title: _titleController.text.trim(),
                  content: _contentController.text.trim(),
                  timestamp: _selectedDateTime,
                  tag: _selectedTag,
                  rating: _selectedRating,
                );
                provider.updateTrackEntry(updated);
              } else {
                provider.addTrackEntry(
                  trackItemId: widget.trackItemId,
                  title: _titleController.text.trim(),
                  content: _contentController.text.trim(),
                  timestamp: _selectedDateTime,
                  tag: _selectedTag,
                  rating: _selectedRating,
                );
              }
              Navigator.pop(context);
            }
          },
          child: Text(isEditing ? "Save Changes" : "Log Note"),
        ),
      ],
    );
  }
}
