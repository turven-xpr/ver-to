import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal_model.dart';
import '../models/task_model.dart';
import '../core/services/sync_service.dart';

class GoalProvider extends ChangeNotifier {
  final SyncService _syncService = SyncService();
  String _userId = 'guest_local_user';

  List<GoalModel> _goals = [];
  List<GoalModel> get goals => _goals;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void updateUserId(String userId) {
    if (_userId != userId) {
      _userId = userId;
      loadGoals();
    }
  }

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();

    _goals = await _syncService.loadGoals(_userId);

    final prefs = await SharedPreferences.getInstance();
    final hasSeeded = prefs.getBool('seeded_goals_$_userId') ?? false;

    if (_goals.isEmpty && !hasSeeded && _userId == 'guest_local_user') {
      await prefs.setBool('seeded_goals_$_userId', true);
      final starterGoals = [
        GoalModel(
          id: 'goal_flutter_mastery',
          title: 'Master Flutter & Full-Stack Apps',
          description: '100 bricks representing tasks towards mastery',
          targetBricks: 100,
          colorValue: 0xFFD84315,
        ),
        GoalModel(
          id: 'goal_fitness_marathon',
          title: 'Physical Health & Consistency',
          description: 'Each brick = 1 completed daily workout or run',
          targetBricks: 50,
          colorValue: 0xFF2E7D32,
        ),
      ];
      _goals = starterGoals;
      await _syncService.saveLocalGoals(_userId, _goals);
      for (var g in _goals) {
        await _syncService.syncGoal(_userId, g);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  GoalModel? getGoalById(String? id) {
    if (id == null) return null;
    try {
      return _goals.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  int getCompletedBricksForGoal(String goalId, List<TaskModel> allTasks) {
    return allTasks.where((t) => t.linkedGoalId == goalId && t.isCompleted).length;
  }

  List<TaskModel> getTasksForGoal(String goalId, List<TaskModel> allTasks) {
    return allTasks.where((t) => t.linkedGoalId == goalId).toList();
  }

  Future<void> addGoal({
    required String title,
    String? description,
    required int targetBricks,
    required int colorValue,
  }) async {
    final goal = GoalModel(
      title: title,
      description: description,
      targetBricks: targetBricks > 0 ? targetBricks : 100,
      colorValue: colorValue,
    );

    _goals.insert(0, goal);
    notifyListeners();

    await _syncService.saveLocalGoals(_userId, _goals);
    await _syncService.syncGoal(_userId, goal);
  }

  Future<void> updateGoal(GoalModel updatedGoal) async {
    final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
    if (index != -1) {
      _goals[index] = updatedGoal;
      notifyListeners();

      await _syncService.saveLocalGoals(_userId, _goals);
      await _syncService.syncGoal(_userId, updatedGoal);
    }
  }

  Future<void> deleteGoal(String goalId) async {
    _goals.removeWhere((g) => g.id == goalId);
    notifyListeners();

    await _syncService.saveLocalGoals(_userId, _goals);
    await _syncService.deleteGoal(_userId, goalId);
  }
}
