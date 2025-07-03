import '../models/task_model.dart';
import 'database_service.dart';

class TaskService {
  final DatabaseService _databaseService = DatabaseService();

  // Get tasks stream for a user
  Stream<List<TaskModel>> getTasksStream(String userId) {
    return _databaseService.getTasksStream(userId);
  }

  // Add a new task
  Future<void> addTask(TaskModel task) async {
    try {
      await _databaseService.insertTask(task);
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la tâche: ${e.toString()}');
    }
  }

  // Update a task
  Future<void> updateTask(TaskModel task) async {
    try {
      await _databaseService.updateTask(task);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la tâche: ${e.toString()}');
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _databaseService.deleteTask(taskId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la tâche: ${e.toString()}');
    }
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(TaskModel task) async {
    try {
      TaskStatus newStatus = task.status == TaskStatus.completed
          ? TaskStatus.pending
          : TaskStatus.completed;

      DateTime? completedAt = newStatus == TaskStatus.completed
          ? DateTime.now()
          : null;

      TaskModel updatedTask = task.copyWith(
        status: newStatus,
        completedAt: completedAt,
      );

      await updateTask(updatedTask);
    } catch (e) {
      throw Exception('Erreur lors du changement de statut: ${e.toString()}');
    }
  }

  // Get task statistics
  Future<Map<String, int>> getTaskStats(String userId) async {
    try {
      return await _databaseService.getTaskStats(userId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques: ${e.toString()}');
    }
  }
}