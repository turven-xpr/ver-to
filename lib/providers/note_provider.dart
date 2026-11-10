import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../models/goal_model.dart';
import '../models/task_model.dart';
import '../core/services/sync_service.dart';
import '../core/services/pdf_service.dart';

class NoteProvider extends ChangeNotifier {
  final SyncService _syncService = SyncService();
  String _userId = 'guest_local_user';

  List<NoteModel> _notes = [];
  List<NoteModel> get notes => _notes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedPeriod = 'day';
  String get selectedPeriod => _selectedPeriod;

  void setSelectedPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  void updateUserId(String userId) {
    if (_userId != userId) {
      _userId = userId;
      loadNotes();
    }
  }

  List<NoteModel> get currentFilteredNotes {
    if (_selectedPeriod == 'goal') {
      return _notes.where((n) => n.linkedGoalId != null).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return _notes.where((n) => n.periodType == _selectedPeriod && n.linkedGoalId == null).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<NoteModel> getNotesForGoal(String goalId) {
    return _notes.where((n) => n.linkedGoalId == goalId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    _notes = await _syncService.loadNotes(_userId);

    if (_notes.isEmpty) {
      final now = DateTime.now();
      final starterNotes = [
        NoteModel(
          periodType: 'day',
          date: now,
          title: 'Daily Focus: Architecture and Brick Metaphor',
          content: 'Finished drafting the brick wall goal system. Building habit momentum one brick at a time creates a tangible sense of accomplishment that simple checklists often lack.',
        ),
        NoteModel(
          periodType: 'day',
          date: now.subtract(const Duration(days: 1)),
          title: 'Morning Momentum & Coffee Thoughts',
          content: 'Woke up early at 6:30 AM. Clear morning skies. Prioritized the two hardest tasks before checking emails. Feeling productive and energized.',
        ),
        NoteModel(
          periodType: 'week',
          date: now.subtract(Duration(days: now.weekday - 1)),
          title: 'Weekly Retrospective: High Focus & Consistency',
          content: 'Major milestones reached this week. 12 tasks completed across development and personal health. Key takeaway: batching similar tasks together saves 2+ hours of context switching.',
        ),
        NoteModel(
          periodType: 'month',
          date: DateTime(now.year, now.month, 1),
          title: 'Monthly Review: Foundation Laid',
          content: 'This month has been about establishing solid foundations. Laid down over 40 bricks towards the quarterly goal. Ready for the next phase of expansion.',
        ),
      ];

      _notes = starterNotes;
      await _syncService.saveLocalNotes(_userId, _notes);
      for (var n in _notes) {
        await _syncService.syncNote(_userId, n);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNote({
    required String periodType,
    required DateTime date,
    required String title,
    required String content,
    String? linkedGoalId,
  }) async {
    final note = NoteModel(
      periodType: periodType,
      date: date,
      title: title,
      content: content,
      linkedGoalId: linkedGoalId,
    );

    _notes.insert(0, note);
    notifyListeners();

    await _syncService.saveLocalNotes(_userId, _notes);
    await _syncService.syncNote(_userId, note);
  }

  Future<void> addGoalNote({
    required String goalId,
    required String content,
    String? title,
  }) async {
    final note = NoteModel(
      periodType: 'day',
      date: DateTime.now(),
      title: (title != null && title.trim().isNotEmpty) ? title.trim() : 'Wall Reflection',
      content: content.trim(),
      linkedGoalId: goalId,
    );

    _notes.insert(0, note);
    notifyListeners();

    await _syncService.saveLocalNotes(_userId, _notes);
    await _syncService.syncNote(_userId, note);
  }

  Future<void> updateNote(NoteModel updatedNote) async {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();

      await _syncService.saveLocalNotes(_userId, _notes);
      await _syncService.syncNote(_userId, updatedNote);
    }
  }

  Future<void> deleteNote(String noteId) async {
    _notes.removeWhere((n) => n.id == noteId);
    notifyListeners();

    await _syncService.saveLocalNotes(_userId, _notes);
    await _syncService.deleteNote(_userId, noteId);
  }

  Future<Uint8List> exportPdfBook({
    required String authorName,
    required List<GoalModel> goals,
    required List<TaskModel> tasks,
  }) async {
    return await PdfService.generateJournalBook(
      authorName: authorName,
      notes: _notes,
      goals: goals,
      tasks: tasks,
    );
  }
}

