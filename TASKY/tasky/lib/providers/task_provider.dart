import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, int> _stats = {'total': 0, 'completed': 0, 'pending': 0};

  List<TaskModel> get tasks => _tasks;
  List<TaskModel> get pendingTasks => _tasks.where((task) => task.status == TaskStatus.pending).toList();
  List<TaskModel> get completedTasks => _tasks.where((task) => task.status == TaskStatus.completed).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, int> get stats => _stats;

  void loadTasks(String userId) {
    _taskService.getTasksStream(userId).listen(
      (tasks) {
        _tasks = tasks;
        _updateStats();
        notifyListeners();
      },
      onError: (error) {
        _setError(error.toString());
      },
    );
  }

  Future<bool> addTask({
    required String title,
    required String description,
    required String userId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      TaskModel newTask = TaskModel(
        id: '', // Will be set by Firestore
        title: title,
        description: description,
        status: TaskStatus.pending,
        createdAt: DateTime.now(),
        userId: userId,
      );

      await _taskService.addTask(newTask);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateTask({
    required String taskId,
    required String title,
    required String description,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      TaskModel? taskToUpdate = _tasks.firstWhere((task) => task.id == taskId);
      
      TaskModel updatedTask = taskToUpdate.copyWith(
        title: title,
        description: description,
      );

      await _taskService.updateTask(updatedTask);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    _setLoading(true);
    _clearError();

    try {
      await _taskService.deleteTask(taskId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> toggleTaskCompletion(TaskModel task) async {
    _clearError();

    try {
      await _taskService.toggleTaskCompletion(task);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> loadStats(String userId) async {
    try {
      _stats = await _taskService.getTaskStats(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _updateStats() {
    _stats = {
      'total': _tasks.length,
      'completed': completedTasks.length,
      'pending': pendingTasks.length,
    };
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}