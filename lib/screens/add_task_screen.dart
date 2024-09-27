import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;

  const AddTaskScreen({Key? key, this.task}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _deadline = DateTime.now();
  TaskStatus _status = TaskStatus.needToDo;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _deadline = widget.task!.deadline;
      _status = widget.task!.status;
    }
  }

  void _submitTask() async {
    if (_titleController.text.isEmpty) return;

    final task = Task(
      id: widget.task?.id,
      title: _titleController.text,
      description: _descriptionController.text,
      deadline: _deadline,
      status: _status,
    );

    if (widget.task == null) {
      await DatabaseService().addTask(task);
    } else {
      await DatabaseService().updateTask(task);
    }

    Navigator.pop(context);
  }

  void _deleteTask() async {
    if (widget.task != null) {
      await DatabaseService().deleteTask(widget.task!.id!);
      Navigator.pop(context); // Go back to task list after deletion
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _deadline) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        actions: [
          if (widget.task != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteTask, // Add delete action
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Task Title'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            Text('Deadline: ${_deadline.toLocal()}'.split(' ')[0]),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickDate,
              child: Text('Select Deadline'),
            ),
            SizedBox(height: 20),
            DropdownButton<TaskStatus>(
              value: _status,
              onChanged: (TaskStatus? newStatus) {
                setState(() {
                  _status = newStatus!;
                });
              },
              items: TaskStatus.values.map((TaskStatus status) {
                return DropdownMenuItem<TaskStatus>(
                  value: status,
                  child: Text(
                    status == TaskStatus.done
                        ? 'Done'
                        : status == TaskStatus.doing
                        ? 'Doing'
                        : 'Need to Do',
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitTask,
              child: Text(widget.task == null ? 'Add Task' : 'Update Task'),
            ),
          ],
        ),
      ),
    );
  }
}
