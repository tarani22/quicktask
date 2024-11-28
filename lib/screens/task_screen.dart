import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class Task extends ParseObject {
  Task() : super('Task');
  Task.clone() : this();

  @override
  Task clone(Map<String, dynamic> map) => Task.clone()..fromJson(map);

  String get title => get<String>('title') ?? '';
  set title(String value) => set<String>('title', value);

  String get description => get<String>('description') ?? '';
  set description(String value) => set<String>('description', value);

  DateTime? get dueDate => get<DateTime?>('dueDate');
  set dueDate(DateTime? value) => set<DateTime?>('dueDate', value);

  bool get isCompleted => get<bool>('isCompleted') ?? false;
  set isCompleted(bool value) => set<bool>('isCompleted', value);
}

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  ParseUser? currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadTasks();
  }

  Future<void> _getCurrentUser() async {
    currentUser = await ParseUser.currentUser() as ParseUser?;
    setState(() {});
  }

  Future<void> _signOut() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    await user?.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _loadTasks() async {
    final query = QueryBuilder<Task>(Task())
      ..whereEqualTo('user', await ParseUser.currentUser());
    final response = await query.query();
    
    if (response.success && response.results != null) {
      setState(() {
        _tasks = response.results!.cast<Task>();
        _isLoading = false;
      });
    }
  }

  Future<void> _addTask() async {
    if (_titleController.text.isNotEmpty) {
      final task = Task()
        ..title = _titleController.text
        ..description = _descriptionController.text
        ..dueDate = _selectedDate
        ..isCompleted = false
        ..set('user', await ParseUser.currentUser());

      final response = await task.save();
      if (response.success) {
        setState(() {
          _tasks.add(task);
        });
        _titleController.clear();
        _descriptionController.clear();
        _selectedDate = null;
        if (mounted) Navigator.pop(context);
      }
    }
  }

  Future<void> _toggleTaskComplete(Task task, bool? value) async {
    task.isCompleted = value ?? false;
    final response = await task.save();
    if (response.success) {
      setState(() {});
    }
  }

  Future<void> _deleteTask(Task task) async {
    final response = await task.delete();
    if (response.success) {
      setState(() {
        _tasks.remove(task);
      });
    }
  }

  void _showAddTaskModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No Due Date'
                        : 'Due: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}',
                  ),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Select Due Date'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _addTask,
              child: const Text('Add Task'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (bool? value) => _toggleTaskComplete(task, value),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.description),
                        if (task.dueDate != null)
                          Text(
                            'Due: ${DateFormat('MMM dd, yyyy').format(task.dueDate!)}',
                            style: TextStyle(
                              color: task.dueDate!.isBefore(DateTime.now())
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteTask(task),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskModal,
        child: const Icon(Icons.add),
      ),
    );
  }
} 