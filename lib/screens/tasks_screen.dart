// screens/tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/financial_provider.dart';
import '../models/financial_models.dart';
import '../providers/auth_provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FinancialProvider>(context, listen: false).loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Consumer<FinancialProvider>(
                builder: (context, financial, child) {
                  print(
                      'Loaded tasks: ${Provider.of<FinancialProvider>(context, listen: false).tasks}');
                  final tasks = financial.tasks;
                  if (tasks.isEmpty) {
                    return const Center(
                      child: Text('No tasks yet.',
                          style: TextStyle(color: Colors.grey)),
                    );
                  }
                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Card(
                        child: ListTile(
                          title: Text(task.title),
                          subtitle: Text(
                              'Due: \\${task.dueDate.toLocal().toString().split(' ')[0]}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  final result =
                                      await showDialog<Map<String, dynamic>>(
                                    context: context,
                                    builder: (context) =>
                                        AddEditTaskDialog(task: task),
                                  );
                                  if (result != null) {
                                    final updatedTask = FarmTask(
                                      id: task.id,
                                      title: result['title'],
                                      description: task.description,
                                      dueDate: result['dueDate'],
                                      priority: task.priority,
                                      status: task.status,
                                      farmSection: task.farmSection,
                                      userId: task.userId,
                                      isRecurring: task.isRecurring,
                                      recurrencePattern: task.recurrencePattern,
                                    );
                                    await Provider.of<FinancialProvider>(
                                            context,
                                            listen: false)
                                        .updateTask(updatedTask);
                                  }
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await Provider.of<FinancialProvider>(context,
                                          listen: false)
                                      .deleteTask(task.id ?? '');
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Task'),
                onPressed: () async {
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => const AddEditTaskDialog(),
                  );
                  if (result != null) {
                    final provider =
                        Provider.of<FinancialProvider>(context, listen: false);
                    final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);
                    await provider.addTask(
                      FarmTask(
                        id: null, // Let backend generate or use a UUID
                        title: (result['title'] ?? '').toString(),
                        description: '',
                        dueDate: result['dueDate'],
                        priority: TaskPriority.medium,
                        status: TaskStatus.pending,
                        farmSection: '', // Ensure non-null
                        userId: authProvider.userId ?? '', // Ensure non-null
                        isRecurring: false,
                        recurrencePattern: '',
                      ),
                    );
                    await provider.loadTasks(); // Refresh from backend
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddEditTaskDialog extends StatefulWidget {
  final FarmTask? task;
  const AddEditTaskDialog({super.key, this.task});

  @override
  State<AddEditTaskDialog> createState() => _AddEditTaskDialogState();
}

class _AddEditTaskDialogState extends State<AddEditTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late DateTime _dueDate;

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _dueDate = widget.task?.dueDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter a title' : null,
              onSaved: (value) => _title = value ?? '',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Due: '),
                TextButton(
                  child: Text('${_dueDate.toLocal()}'.split(' ')[0]),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _dueDate = picked);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text(widget.task == null ? 'Add' : 'Update'),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();
              Navigator.of(context).pop({'title': _title, 'dueDate': _dueDate});
            }
          },
        ),
      ],
    );
  }
}
