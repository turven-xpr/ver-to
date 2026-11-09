import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../core/services/sync_service.dart';

class TaskProvider extends ChangeNotifier {
  final SyncService _syncService = SyncService();
  String _userId = 'guest_local_user';

  List<TaskModel> _tasks = [];
  List<TaskModel> get tasks => _tasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String q) {
    _searchQuery = q.trim().toLowerCase();
    notifyListeners();
  }

  void updateUserId(String userId) {
    if (_userId != userId) {
      _userId = userId;
      loadTasks();
    }
  }

  List<TaskModel> get uncompletedTasks {
    return _tasks.where((t) {
      final matchesSearch = _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery) ||
          (t.description?.toLowerCase().contains(_searchQuery) ?? false);
      return !t.isCompleted && matchesSearch;
    }).toList();
  }

  List<TaskModel> get completedTasks {
    return _tasks.where((t) {
      final matchesSearch = _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery) ||
          (t.description?.toLowerCase().contains(_searchQuery) ?? false);
      return t.isCompleted && matchesSearch;
    }).toList();
  }

  // --- DUOLINGO-STYLE STREAK CALCULATION (MINIMUM 3 TASKS / DAY) ---
  static const int minTasksForDailyStreak = 3;

  int get completedTasksTodayCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _tasks.where((t) =>
        t.isCompleted &&
        t.completedAt != null &&
        DateTime(t.completedAt!.year, t.completedAt!.month, t.completedAt!.day) == today
    ).length;
  }

  bool get isCompletedToday => completedTasksTodayCount >= minTasksForDailyStreak;

  Map<DateTime, int> get _dailyCompletedCounts {
    final map = <DateTime, int>{};
    for (final task in _tasks) {
      if (task.isCompleted && task.completedAt != null) {
        final d = DateTime(task.completedAt!.year, task.completedAt!.month, task.completedAt!.day);
        map[d] = (map[d] ?? 0) + 1;
      }
    }
    return map;
  }

  int get currentStreak {
    final counts = _dailyCompletedCounts;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    int streak = 0;
    DateTime checkDate;

    if ((counts[today] ?? 0) >= minTasksForDailyStreak) {
      streak = 1;
      checkDate = yesterday;
    } else if ((counts[yesterday] ?? 0) >= minTasksForDailyStreak) {
      // Streak from yesterday is preserved, awaiting today's 3 tasks
      streak = 1;
      checkDate = yesterday.subtract(const Duration(days: 1));
    } else {
      return 0;
    }

    while ((counts[checkDate] ?? 0) >= minTasksForDailyStreak) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Set<int> get completedDaysThisWeek {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final endOfWeek = monday.add(const Duration(days: 7));
    final counts = _dailyCompletedCounts;

    final set = <int>{};
    counts.forEach((date, count) {
      if (count >= minTasksForDailyStreak &&
          date.isAfter(monday.subtract(const Duration(seconds: 1))) &&
          date.isBefore(endOfWeek)) {
        set.add(date.weekday);
      }
    });
    return set;
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _syncService.loadTasks(_userId);

    if (_tasks.isEmpty) {
      final now = DateTime.now();
      final starterTasks = [
        TaskModel(
          title: 'Design Flutter responsive layouts & tabs',
          description: 'Set up navigation and state management',
          isCompleted: true,
          linkedGoalId: 'goal_flutter_mastery',
          priority: 'high',
          completedAt: now.subtract(const Duration(hours: 3)),
        ),
        TaskModel(
          title: 'Implement Brick Wall interactive visualizer',
          description: 'Custom masonry running-bond brick grid',
          isCompleted: true,
          linkedGoalId: 'goal_flutter_mastery',
          priority: 'high',
          completedAt: now.subtract(const Duration(hours: 1)),
        ),
        TaskModel(
          title: 'Connect Firebase Firestore offline sync',
          description: 'Ensure offline caching and auto-sync online',
          isCompleted: false,
          linkedGoalId: 'goal_flutter_mastery',
          priority: 'high',
          dueDate: now.add(const Duration(days: 1)),
        ),
        TaskModel(
          title: 'Run 5km morning jogging session',
          description: 'Pacing at 5:30/km',
          isCompleted: true,
          linkedGoalId: 'goal_fitness_marathon',
          priority: 'medium',
          completedAt: now.subtract(const Duration(days: 1)),
        ),
        TaskModel(
          title: 'Evening mobility & stretching routine',
          description: '20 minutes hip and back stretches',
          isCompleted: false,
          linkedGoalId: 'goal_fitness_marathon',
          priority: 'low',
        ),
      ];

      _tasks = starterTasks;
      await _syncService.saveLocalTasks(_userId, _tasks);
      for (var t in _tasks) {
        await _syncService.syncTask(_userId, t);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    String? description,
    String? linkedGoalId,
    String priority = 'medium',
    DateTime? dueDate,
  }) async {
    final now = DateTime.now();
    final defaultDue = DateTime(now.year, now.month, now.day, 23, 59);

    final task = TaskModel(
      title: title,
      description: description,
      linkedGoalId: linkedGoalId,
      priority: priority,
      dueDate: dueDate ?? defaultDue,
      isCompleted: false,
    );

    _tasks.insert(0, task);
    notifyListeners();

    await _syncService.saveLocalTasks(_userId, _tasks);
    await _syncService.syncTask(_userId, task);
  }

  Future<void> toggleTaskStatus(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final current = _tasks[index];
      final newStatus = !current.isCompleted;
      final updated = current.copyWith(
        isCompleted: newStatus,
        completedAt: newStatus ? DateTime.now() : null,
      );

      _tasks[index] = updated;
      notifyListeners();

      await _syncService.saveLocalTasks(_userId, _tasks);
      await _syncService.syncTask(_userId, updated);
    }
  }

  Future<void> updateTask(TaskModel updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();

      await _syncService.saveLocalTasks(_userId, _tasks);
      await _syncService.syncTask(_userId, updatedTask);
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();

    await _syncService.saveLocalTasks(_userId, _tasks);
    await _syncService.deleteTask(_userId, taskId);
  }

  Future<void> clearAllCompleted() async {
    final completed = _tasks.where((t) => t.isCompleted).toList();
    _tasks.removeWhere((t) => t.isCompleted);
    notifyListeners();

    await _syncService.saveLocalTasks(_userId, _tasks);
    for (var t in completed) {
      await _syncService.deleteTask(_userId, t.id);
    }
  }
}
