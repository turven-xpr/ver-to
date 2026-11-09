import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/note_model.dart';
import '../../models/goal_model.dart';
import '../../models/task_model.dart';

class PdfService {
  static Future<Uint8List> generateJournalBook({
    required String authorName,
    required List<NoteModel> notes,
    required List<GoalModel> goals,
    required List<TaskModel> tasks,
  }) async {
    final pdf = pw.Document();

    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final monthFormat = DateFormat('MMMM yyyy');

    final dailyNotes = notes.where((n) => n.periodType == 'day').toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final weeklyNotes = notes.where((n) => n.periodType == 'week').toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final monthlyNotes = notes.where((n) => n.periodType == 'month').toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Cover Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.brown900, width: 3),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            padding: const pw.EdgeInsets.all(36),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  children: [
                    pw.SizedBox(height: 20),
                    pw.Text(
                      "THE CHRONICLES",
                      style: pw.TextStyle(
                        fontSize: 16,
                        letterSpacing: 4,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      "BRICK BY BRICK",
                      style: pw.TextStyle(
                        fontSize: 34,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.brown900,
                        letterSpacing: 2,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      "Daily, Weekly & Monthly Life Journal",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontStyle: pw.FontStyle.italic,
                        color: PdfColors.brown600,
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Container(
                      width: 140,
                      height: 2,
                      color: PdfColors.brown400,
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.orange50,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.brown200),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        "Summary of Records",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 14,
                          color: PdfColors.brown800,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text("Goals Tracked: ${goals.length}"),
                      pw.Text("Total Tasks: ${tasks.length} (${tasks.where((t) => t.isCompleted).length} completed)"),
                      pw.Text("Journal Entries: ${notes.length}"),
                    ],
                  ),
                ),
                pw.Column(
                  children: [
                    pw.Text(
                      "COMPILED BY",
                      style: pw.TextStyle(
                        fontSize: 11,
                        letterSpacing: 2,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      authorName,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.brown900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      "Exported on ${DateFormat('MMMM d, yyyy').format(DateTime.now())}",
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    // Section 1: Goals & Brick Wall Achievements
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildPdfHeader("Part I: Goals & Brick Wall Progress"),
        footer: (context) => _buildPdfFooter(context),
        build: (context) => [
          pw.Header(
            level: 1,
            text: "Brick Wall Goals",
            textStyle: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.brown900),
          ),
          pw.Paragraph(
            text: "Goals are completed brick by brick. Every completed task lays a foundation brick toward the goal.",
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 12),
          if (goals.isEmpty)
            pw.Text("No goals recorded yet.", style: pw.TextStyle(fontStyle: pw.FontStyle.italic))
          else
            ...goals.map((goal) {
              final goalTasks = tasks.where((t) => t.linkedGoalId == goal.id).toList();
              final completedBricks = goalTasks.where((t) => t.isCompleted).length;
              final percent = goal.targetBricks > 0
                  ? ((completedBricks / goal.targetBricks) * 100).clamp(0, 100).toStringAsFixed(1)
                  : '0';

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          goal.title,
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.brown900),
                        ),
                        pw.Text(
                          "$percent% Complete",
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.deepOrange700),
                        ),
                      ],
                    ),
                    if (goal.description != null && goal.description!.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(goal.description!, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                    pw.SizedBox(height: 8),
                    pw.Text(
                      "Bricks Laid: $completedBricks / ${goal.targetBricks} | Tasks Linked: ${goalTasks.length}",
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );

    // Section 2: Daily Notes
    if (dailyNotes.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          header: (context) => _buildPdfHeader("Part II: Daily Notes"),
          footer: (context) => _buildPdfFooter(context),
          build: (context) => [
            pw.Header(
              level: 1,
              text: "Daily Notes & Daily Thoughts",
              textStyle: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.brown900),
            ),
            ...dailyNotes.map((note) => _buildNoteEntry(note, dateFormat.format(note.date))),
          ],
        ),
      );
    }

    // Section 3: Weekly Notes
    if (weeklyNotes.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          header: (context) => _buildPdfHeader("Part III: Weekly Reviews"),
          footer: (context) => _buildPdfFooter(context),
          build: (context) => [
            pw.Header(
              level: 1,
              text: "Weekly Reviews & Planning",
              textStyle: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.brown900),
            ),
            ...weeklyNotes.map((note) => _buildNoteEntry(note, "Week of ${dateFormat.format(note.date)}")),
          ],
        ),
      );
    }

    // Section 4: Monthly Notes
    if (monthlyNotes.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          header: (context) => _buildPdfHeader("Part IV: Monthly Retrospectives"),
          footer: (context) => _buildPdfFooter(context),
          build: (context) => [
            pw.Header(
              level: 1,
              text: "Monthly Retrospectives",
              textStyle: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.brown900),
            ),
            ...monthlyNotes.map((note) => _buildNoteEntry(note, monthFormat.format(note.date))),
          ],
        ),
      );
    }

    return pdf.save();
  }

  static pw.Widget _buildPdfHeader(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text("Brick by Brick — Life Book", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          pw.Text(title, style: const pw.TextStyle(fontSize: 9, color: PdfColors.brown700)),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 16),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text("Private & Confidential", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
          pw.Text("Page ${context.pageNumber} of ${context.pagesCount}",
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        ],
      ),
    );
  }

  static pw.Widget _buildNoteEntry(NoteModel note, String formattedDate) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.grey200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                note.title,
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.brown900),
              ),
              pw.Text(
                formattedDate,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            note.content,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800, lineSpacing: 2),
          ),
        ],
      ),
    );
  }
}
