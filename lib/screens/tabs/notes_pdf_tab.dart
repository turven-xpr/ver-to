import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/note_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/add_note_dialog.dart';
import '../../widgets/pdf_preview_screen.dart';

class NotesPdfTab extends StatelessWidget {
  const NotesPdfTab({super.key});

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);
    final goalProvider = Provider.of<GoalProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final notes = noteProvider.currentFilteredNotes;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F0),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3E2723), Color(0xFF5D4037)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.menu_book,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Export Life Book (PDF)",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Compile your day/week/month notes & goal achievements into a printable book.",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final author = authProvider.user?.displayName ?? "Life Builder";
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => PdfPreviewScreen(
                                  buildPdf: () => noteProvider.exportPdfBook(
                                    authorName: author,
                                    goals: goalProvider.goals,
                                    tasks: taskProvider.tasks,
                                  ),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB300),
                            foregroundColor: const Color(0xFF2E2420),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          child: const Text(
                            "Export",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'day',
                        label: Text("Days (${noteProvider.notes.where((n) => n.periodType == 'day' && n.linkedGoalId == null).length})"),
                        icon: const Icon(Icons.wb_sunny_outlined, size: 16),
                      ),
                      ButtonSegment(
                        value: 'week',
                        label: Text("Weeks (${noteProvider.notes.where((n) => n.periodType == 'week' && n.linkedGoalId == null).length})"),
                        icon: const Icon(Icons.calendar_view_week, size: 16),
                      ),
                      ButtonSegment(
                        value: 'month',
                        label: Text("Months (${noteProvider.notes.where((n) => n.periodType == 'month' && n.linkedGoalId == null).length})"),
                        icon: const Icon(Icons.calendar_month, size: 16),
                      ),
                      ButtonSegment(
                        value: 'goal',
                        label: Text("Walls (${noteProvider.notes.where((n) => n.linkedGoalId != null).length})"),
                        icon: const Icon(Icons.foundation, size: 16),
                      ),
                    ],
                    selected: {noteProvider.selectedPeriod},
                    onSelectionChanged: (val) {
                      noteProvider.setSelectedPeriod(val.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          if (notes.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.note_alt_outlined,
                      size: 48,
                      color: Color(0xFF9E948D),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No ${noteProvider.selectedPeriod} notes yet",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A403A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Write thoughts for this ${noteProvider.selectedPeriod} to include in your book.",
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
                  final note = notes[index];
                  final linkedGoal = note.linkedGoalId != null
                      ? goalProvider.goals.where((g) => g.id == note.linkedGoalId).firstOrNull
                      : null;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEBE5DF)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD84315).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _formatNoteDate(note.periodType, note.date),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD84315),
                                    ),
                                  ),
                                ),
                                if (linkedGoal != null) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Color(linkedGoal.colorValue).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text("🧱", style: TextStyle(fontSize: 10)),
                                        const SizedBox(width: 4),
                                        Text(
                                          linkedGoal.title,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(linkedGoal.colorValue),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF8F847D)),
                              padding: EdgeInsets.zero,
                              onSelected: (val) {
                                if (val == 'edit') {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AddNoteDialog(
                                      initialNote: note,
                                      onSave: (type, date, title, content) {
                                        noteProvider.updateNote(note.copyWith(
                                          periodType: type,
                                          date: date,
                                          title: title,
                                          content: content,
                                        ));
                                      },
                                    ),
                                  );
                                } else if (val == 'delete') {
                                  noteProvider.deleteNote(note.id);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(value: 'edit', child: Text("Edit Note")),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          note.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E2420),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          note.content,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5E544E),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: notes.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AddNoteDialog(
              initialPeriod: noteProvider.selectedPeriod,
              onSave: (type, date, title, content) {
                noteProvider.addNote(
                  periodType: type,
                  date: date,
                  title: title,
                  content: content,
                );
              },
            ),
          );
        },
        icon: const Icon(Icons.edit_note),
        label: const Text("Write Note"),
      ),
    );
  }

  String _formatNoteDate(String periodType, DateTime date) {
    if (periodType == 'day') {
      return DateFormat('EEE, MMM d, yyyy').format(date);
    } else if (periodType == 'week') {
      return "Week of ${DateFormat('MMM d, yyyy').format(date)}";
    } else {
      return DateFormat('MMMM yyyy').format(date);
    }
  }
}
