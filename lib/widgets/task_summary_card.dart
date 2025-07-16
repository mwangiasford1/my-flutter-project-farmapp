// widgets/task_summary_card.dart
import 'package:flutter/material.dart';
import '../models/financial_models.dart';

class TaskSummaryCard extends StatelessWidget {
  final List<FarmTask> upcomingTasks;
  final List<FarmTask> overdueTasks;

  const TaskSummaryCard({
    super.key,
    required this.upcomingTasks,
    required this.overdueTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tasks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.task, color: Colors.blue[600]),
              ],
            ),
            const SizedBox(height: 16),
            if (overdueTasks.isNotEmpty) ...[
              _buildTaskSection(context, 'Overdue', overdueTasks, Colors.red),
              const SizedBox(height: 12),
            ],
            if (upcomingTasks.isNotEmpty) ...[
              _buildTaskSection(
                context,
                'Upcoming',
                upcomingTasks,
                Colors.orange,
              ),
            ],
            if (overdueTasks.isEmpty && upcomingTasks.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No tasks due',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskSection(
    BuildContext context,
    String title,
    List<FarmTask> tasks,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              '$title (${tasks.length})',
              style: TextStyle(fontWeight: FontWeight.w500, color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...tasks.take(3).map((task) => _buildTaskTile(task, color)),
        if (tasks.length > 3) ...[
          const SizedBox(height: 8),
          Text(
            'And ${tasks.length - 3} more...',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildTaskTile(FarmTask task, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(_getPriorityIcon(task.priority), size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _formatDate(task.dueDate),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.flag;
      case TaskPriority.medium:
        return Icons.flag;
      case TaskPriority.high:
        return Icons.flag;
      case TaskPriority.urgent:
        return Icons.warning;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return '${difference.abs()} days ago';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else {
      return 'In $difference days';
    }
  }
}
