import '../models/task.dart';
import '../services/database_service.dart';

class TaskService {
  Future<List<Task>> getTasks({TaskStatus? filterStatus, bool sortByDeadline = false}) async {
    List<Task> tasks = await DatabaseService().getTasks(filterStatus: filterStatus, sortByDeadline: sortByDeadline);

    if (sortByDeadline) {
      tasks.sort((a, b) => a.deadline.compareTo(b.deadline));  // Sort by DateTime
    }

    return tasks;
  }

  Future<void> addTask(Task task) async {
    await DatabaseService().addTask(task);
  }

  Future<void> updateTask(Task task) async {
    await DatabaseService().updateTask(task);
  }

  Future<void> deleteTask(int id) async {
    await DatabaseService().deleteTask(id);
  }
}
