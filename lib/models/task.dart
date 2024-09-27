enum TaskStatus { done, doing, needToDo }

class Task {
  int? id;
  String title;
  String description;
  DateTime deadline;
  TaskStatus status;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.deadline,
    this.status = TaskStatus.needToDo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'status': status.index,  // Store enum as an integer
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      deadline: DateTime.parse(map['deadline']),
      status: TaskStatus.values[map['status']],
    );
  }
}
