// services/task_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/financial_models.dart';

class TaskService {
  static const String baseUrl = 'https://your-backend-name.onrender.com/tasks';
  final http.Client client;

  TaskService({http.Client? client}) : client = client ?? http.Client();

  Future<List<FarmTask>> fetchTasks({String? userId}) async {
    final url = userId != null && userId.isNotEmpty
        ? '$baseUrl?userId=$userId'
        : baseUrl;
    final response = await client.get(
      Uri.parse(url),
      headers: {'Cache-Control': 'no-cache'},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => FarmTask.fromJson(e)).toList();
    }
    if (response.statusCode == 304) {
      // No new data, return an empty list or keep the old data
      return [];
    }
    throw Exception('Failed to load tasks');
  }

  Future<FarmTask> addTask(FarmTask task) async {
    final response = await client.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );
    if (response.statusCode == 201) {
      return FarmTask.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to add task');
  }

  Future<void> deleteTask(String id) async {
    final response = await client.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }

  Future<FarmTask> updateTask(FarmTask task) async {
    final response = await client.put(
      Uri.parse('$baseUrl/${task.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );
    if (response.statusCode == 200) {
      return FarmTask.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to update task');
  }
}
