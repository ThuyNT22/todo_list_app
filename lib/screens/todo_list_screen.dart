import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../models/task.dart';
import 'add_task_screen.dart';
import 'login_screen.dart';

class TodoListScreen extends StatefulWidget {
  final String username;

  TodoListScreen({required this.username});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  int _currentPage = 1;
  int _tasksPerPage = 8;  // Set default tasks per page
  bool _sortByTask = false;
  bool _sortByDeadline = false;
  bool _ascending = true;
  TaskStatus? _filterStatus;  // Store the filter status

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    List<Task> tasks = await _taskService.getTasks(filterStatus: _filterStatus);
    setState(() {
      _tasks = tasks;
    });
    _sortTasks();  // Apply sorting if needed
  }

  void _sortTasks() {
    setState(() {
      if (_sortByTask) {
        _tasks.sort((a, b) => _ascending
            ? a.title.compareTo(b.title)
            : b.title.compareTo(a.title));
      } else if (_sortByDeadline) {
        _tasks.sort((a, b) => _ascending
            ? a.deadline.compareTo(b.deadline)
            : b.deadline.compareTo(a.deadline));
      }
    });
  }

  void _toggleSortByTask() {
    setState(() {
      _sortByTask = true;
      _sortByDeadline = false;
      _ascending = !_ascending;  // Toggle ascending/descending
    });
    _sortTasks();
  }

  void _toggleSortByDeadline() {
    setState(() {
      _sortByTask = false;
      _sortByDeadline = true;
      _ascending = !_ascending;  // Toggle ascending/descending
    });
    _sortTasks();
  }

  void _filterByStatus(TaskStatus? status) {
    setState(() {
      _filterStatus = status;
    });
    _loadTasks();
  }

  void _toggleDone(Task task) async {
    task.status = TaskStatus.done;
    await _taskService.updateTask(task);
    _loadTasks();
  }

  // Pagination logic
  List<Task> _getPaginatedTasks() {
    int startIndex = (_currentPage - 1) * _tasksPerPage;
    int endIndex = startIndex + _tasksPerPage;
    return _tasks.sublist(startIndex, endIndex > _tasks.length ? _tasks.length : endIndex);
  }

  void _nextPage() {
    if (_currentPage * _tasksPerPage < _tasks.length) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _prevPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    _tasksPerPage = (screenHeight / 100).floor();  // Dynamically fit tasks based on screen height

    List<Task> paginatedTasks = _getPaginatedTasks();

    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Todo List",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // Display the Task Table with Sortable Headers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Task Header with Sort Icon
                  InkWell(
                    onTap: _toggleSortByTask,
                    child: Row(
                      children: [
                        Text("Task", style: TextStyle(fontWeight: FontWeight.bold)),
                        Icon(_sortByTask
                            ? (_ascending ? Icons.arrow_upward : Icons.arrow_downward)
                            : Icons.sort),
                      ],
                    ),
                  ),
                  // Deadline Header with Sort Icon
                  InkWell(
                    onTap: _toggleSortByDeadline,
                    child: Row(
                      children: [
                        Text("Deadline", style: TextStyle(fontWeight: FontWeight.bold)),
                        Icon(_sortByDeadline
                            ? (_ascending ? Icons.arrow_upward : Icons.arrow_downward)
                            : Icons.sort),
                      ],
                    ),
                  ),
                  // Status Header with Filter
                  DropdownButton<TaskStatus?>(
                    hint: Text('All task'),
                    value: _filterStatus,
                    onChanged: _filterByStatus,
                    items: [
                      DropdownMenuItem<TaskStatus?>(
                        value: null,
                        child: Text('All'),
                      ),
                      ...TaskStatus.values.map((TaskStatus status) {
                        return DropdownMenuItem<TaskStatus?>(
                          value: status,
                          child: Text(status == TaskStatus.done
                              ? 'Done'
                              : status == TaskStatus.doing
                              ? 'Doing'
                              : 'Need to Do'),
                        );
                      }).toList(),
                    ],
                  ),
                  Text("Update", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Divider(),
              // Display Task Data in Rows
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: paginatedTasks.length,
                itemBuilder: (context, index) {
                  final task = paginatedTasks[index];
                  Color bgColor;
                  Color textColor = Colors.black;

                  // Set background color and text color based on task status and deadline
                  if (task.status == TaskStatus.done) {
                    bgColor = Colors.lightGreen[100]!;
                  } else if (task.status == TaskStatus.doing) {
                    bgColor = Colors.yellow[100]!;
                  } else {
                    bgColor = Colors.white;
                  }

                  if (task.deadline.isBefore(DateTime.now()) && task.status != TaskStatus.done) {
                    textColor = Colors.red;
                  }

                  return Container(
                    color: bgColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(task.title)),  // Task
                        Expanded(
                          child: Text(
                            '${task.deadline.toLocal().day}/${task.deadline.toLocal().month}/${task.deadline.toLocal().year}',
                          ),  // Deadline
                        ),
                        Expanded(
                          child: Text(
                            task.status == TaskStatus.done
                                ? 'Done'
                                : task.status == TaskStatus.doing
                                ? 'Doing'
                                : 'Need to Do',
                          ),  // Status
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              // Checkbox to mark task as done
                              Checkbox(
                                value: task.status == TaskStatus.done,
                                onChanged: (value) {
                                  if (value == true) {
                                    _toggleDone(task);
                                  }
                                },
                              ),
                              // Edit button
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => AddTaskScreen(task: task)),
                                  ).then((value) => _loadTasks());
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Pagination Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _prevPage,
                    child: Text("Previous"),
                  ),
                  Text("Page $_currentPage of ${(_tasks.length / _tasksPerPage).ceil()}"),
                  TextButton(
                    onPressed: _nextPage,
                    child: Text("Next"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTaskScreen()),
          ).then((value) => _loadTasks());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
