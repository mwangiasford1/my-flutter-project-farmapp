// test/services/task_service_test.dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:farmersapp/services/task_service.dart';
import 'package:farmersapp/models/financial_models.dart';

import 'task_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('TaskService', () {
    late TaskService taskService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      taskService = TaskService(client: mockClient);
    });

    test('fetchTasks returns a list of tasks for valid userId', () async {
      final mockTasks = [
        {
          "id": "1",
          "title": "Test Task",
          "description": "Test Desc",
          "dueDate": DateTime.now().toIso8601String(),
          "priority": "high",
          "status": "pending",
          "farmSection": null,
          "userId": "user123",
          "isRecurring": false,
          "recurrencePattern": null
        }
      ];

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockTasks), 200));

      final tasks = await taskService.fetchTasks(userId: "user123");
      expect(tasks, isA<List<FarmTask>>());
      expect(tasks.first.title, "Test Task");
    });

    test('addTask returns the created task', () async {
      final newTask = FarmTask(
        id: "2",
        title: "New Task",
        description: "New Desc",
        dueDate: DateTime.now(),
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        userId: "user123",
        isRecurring: false,
      );

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer(
          (_) async => http.Response(jsonEncode(newTask.toJson()), 201));

      final result = await taskService.addTask(newTask);
      expect(result.title, "New Task");
    });
  });
}
