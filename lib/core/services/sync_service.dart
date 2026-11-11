import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/task_model.dart';
import '../../models/goal_model.dart';
import '../../models/note_model.dart';
import '../config/firebase_config.dart';

class SyncService {
  static const String _tasksKey = 'cached_tasks_v1';
  static const String _goalsKey = 'cached_goals_v1';
  static const String _notesKey = 'cached_notes_v1';

  FirebaseFirestore? get _firestore {
    if (FirebaseConfig.isInitialized && Firebase.apps.isNotEmpty) {
      try {
        return FirebaseFirestore.instance;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // ---------------- TASKS ----------------
  Future<List<TaskModel>> loadTasks(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('${_tasksKey}_$userId');

    List<TaskModel> localTasks = [];
    if (jsonStr != null) {
      try {
        final List list = jsonDecode(jsonStr);
        localTasks = list.map((e) => TaskModel.fromMap(e)).toList();
      } catch (e) {
        debugPrint("Error parsing cached tasks: $e");
      }
    }

    final firestore = _firestore;
    if (FirebaseConfig.isInitialized && firestore != null && userId != 'guest_local_user') {
      try {
        final snapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('tasks')
            .get(const GetOptions(source: Source.serverAndCache));

        if (snapshot.docs.isNotEmpty) {
          final remoteTasks = snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
              .toList();
          await saveLocalTasks(userId, remoteTasks);
          return remoteTasks;
        } else if (localTasks.isNotEmpty) {
          // First time syncing this user: upload local tasks to remote
          for (var t in localTasks) {
            await syncTask(userId, t);
          }
          return localTasks;
        }
      } catch (e) {
        debugPrint("Notice: Fetching remote tasks from Firestore fallback: $e");
      }
    }

    return localTasks;
  }

  Future<void> saveLocalTasks(String userId, List<TaskModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(tasks.map((t) => t.toMap()).toList());
    await prefs.setString('${_tasksKey}_$userId', jsonStr);
  }

  Future<void> syncTask(String userId, TaskModel task) async {
    final firestore = _firestore;
    if (FirebaseConfig.isInitialized && firestore != null && userId != 'guest_local_user') {
      try {
        await firestore
            .collection('users')
            .doc(userId)
            .collection('tasks')
            .doc(task.id)
            .set(task.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint("Firestore task sync queued offline: $e");
      }
    }
  }

  Future<void> deleteTask(String userId, String taskId) async {
    final firestore = _firestore;
    if (FirebaseConfig.isInitialized && firestore != null && userId != 'guest_local_user') {
      try {
        await firestore
            .collection('users')
            .doc(userId)
            .collection('tasks')
            .doc(taskId)
            .delete();
      } catch (e) {
        debugPrint("Firestore task delete queued offline: $e");
      }
    }
  }

  // ---------------- GOALS ----------------
  Future<List<GoalModel>> loadGoals(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('${_goalsKey}_$userId');

    List<GoalModel> localGoals = [];
    if (jsonStr != null) {
      try {
        final List list = jsonDecode(jsonStr);
        localGoals = list.map((e) => GoalModel.fromMap(e)).toList();
      } catch (e) {
        debugPrint("Error parsing cached goals: $e");
      }
    }

    final firestore = _firestore;
    if (FirebaseConfig.isInitialized && firestore != null && userId != 'guest_local_user') {
      try {
        final snapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('goals')
            .get(const GetOptions(source: Source.serverAndCache));

        if (snapshot.docs.isNotEmpty) {
          final remoteGoals = snapshot.docs
              .map((doc) => GoalModel.fromMap(doc.data(), doc.id))
              .toList();
          await saveLocalGoals(userId, remoteGoals);
          return remoteGoals;
        } else if (localGoals.isNotEmpty) {
          for (var g in localGoals) {
            await syncGoal(userId, g);
          }
          return localGoals;
        }
      } catch (e) {
        debugPrint("Notice: Fetching remote goals from Firestore fallback: $e");
      }
    }

    return localGoals;
  }

  Future<void> saveLocalGoals(String userId, List<GoalModel> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(goals.map((g) => g.toMap()).toList());
    await prefs.setString('${_goalsKey}_$userId', jsonStr);
  }

  Future<void> syncGoal(String userId, GoalModel goal) async {
    final firestore = _firestore;
    if (FirebaseConfig.isInitialized && firestore != null && userId != 'guest_local_user') {
      try {
        await firestore
            .collection('users')
            .doc(userId)
            .collection('goals')
            .doc(goal.id)
            .set(goal.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint("Firestore goal sync queued offline: $e");
      }
    }
  }

  Future<void> deleteGoal(String userId, String goalId) async {
    final firestore = _firestore;
    if (FirebaseConfig.isInitialized && firestore != null && userId != 'guest_local_user') {
      try {
        await firestore
            .collection('users')
            .doc(userId)
            .collection('goals')
            .doc(goalId)
            .delete();
      } catch (e) {
        debugPrint("Firestore goal delete queued offline: $e");
      }
    }
  }

  // ---------------- NOTES ----------------
  Future<List<NoteModel>> loadNotes(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('${_notesKey}_$userId');

    List<NoteModel> localNotes = [];
    if (jsonStr != null) {
      try {
        final List list = jsonDecode(jsonStr);
        localNotes = list.map((e) => NoteModel.fromMap(e)).toList();
      } catch (e) {
        debugPrint("Error parsing cached notes: $e");
      }
    }

    final firestore = _firestore;
    if (FirebaseConfig.isInitialized && firestore != null && userId != 'guest_local_user') {
      try {
        final snapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('notes')
            .get(const GetOptions(source: Source.serverAndCache));

        if (snapshot.docs.isNotEmpty) {
          final remoteNotes = snapshot.docs
              .map((doc) => NoteModel.fromMap(doc.data(), doc.id))
              .toList();
          await saveLocalNotes(userId, remoteNotes);
          return remoteNotes;
        } else if (localNotes.isNotEmpty) {
          for (var n in localNotes) {
            await syncNote(userId, n);
          }
          return localNotes;
        }
      } catch (e) {
        debugPrint("Notice: Fetching remote notes from Firestore fallback: $e");
      }
    }

    return localNotes;
  }

  Future<void> saveLocalNotes(String userId, List<NoteModel> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(notes.map((n) => n.toMap()).toList());
    await prefs.setString('${_notesKey}_$userId', jsonStr);
  }

  Future<void> syncNote(String userId, NoteModel note) async {
    final firestore = _firestore;
    if (FirebaseConfig.isInitialized && firestore != null && userId != 'guest_local_user') {
      try {
        await firestore
            .collection('users')
            .doc(userId)
            .collection('notes')
            .doc(note.id)
            .set(note.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint("Firestore note sync queued offline: $e");
      }
    }
  }

  Future<void> deleteNote(String userId, String noteId) async {
    final firestore = _firestore;
    if (FirebaseConfig.isInitialized && firestore != null && userId != 'guest_local_user') {
      try {
        await firestore
            .collection('users')
            .doc(userId)
            .collection('notes')
            .doc(noteId)
            .delete();
      } catch (e) {
        debugPrint("Firestore note delete queued offline: $e");
      }
    }
  }
}
