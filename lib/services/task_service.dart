import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get tasks stream for a user
  Stream<List<TaskModel>> getTasksStream(String userId) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Add a new task
  Future<void> addTask(TaskModel task) async {
    try {
      await _firestore.collection('tasks').add(task.toMap());
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la tâche: ${e.toString()}');
    }
  }

  // Update a task
  Future<void> updateTask(TaskModel task) async {
    try {
      await _firestore
          .collection('tasks')
          .doc(task.id)
          .update(task.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la tâche: ${e.toString()}');
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
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
      QuerySnapshot snapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .get();

      int totalTasks = snapshot.docs.length;
      int completedTasks = snapshot.docs
          .where((doc) => doc.data() is Map<String, dynamic> && 
                        (doc.data() as Map<String, dynamic>)['status'] == 'completed')
          .length;
      int pendingTasks = totalTasks - completedTasks;

      return {
        'total': totalTasks,
        'completed': completedTasks,
        'pending': pendingTasks,
      };
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques: ${e.toString()}');
    }
  }
}