import 'package:flutter_test/flutter_test.dart';
import 'package:tasklistapp/dashboard/task_model.dart';

void main() {

  group('Task Model', () {

    test('toJson works', () {

      final task = Task(
        id: '1',
        userId: 'u1',
        title: 'Buy groceries',
        status: TaskStatus.pending,
        priority: TaskPriority.high,
        createdAt: DateTime(2024,1,1),
        category: 'Personal',
      );

      final json = task.toJson();

      expect(json['id'], '1');
      expect(json['user_id'], 'u1');
      expect(json['status'], 'pending');
      expect(json['priority'], 'high');
      expect(json['completed_at'], isNull);
    });

    test('fromJson works', () {

      final json = {
        'id': '1',
        'user_id': 'u1',
        'title': 'Task',
        'description': null,
        'status': 'completed',
        'priority': 'medium',
        'created_at': '2024-01-01T00:00:00.000Z',
        'completed_at': '2024-01-01T01:00:00.000Z',
        'category': 'Work',
      };

      final task = Task.fromJson(json);

      expect(task.id, '1');
      expect(task.status, TaskStatus.completed);
      expect(task.isCompleted, true);
    });

    test('toJson -> fromJson keeps data', () {

      final task = Task(
        id: 'x',
        userId: 'u',
        title: 'Test',
        createdAt: DateTime(2024,1,1),
      );

      final restored = Task.fromJson(task.toJson());

      expect(restored.id, task.id);
      expect(restored.title, task.title);
    });

    test('invalid status defaults to pending', () {

      final task = Task.fromJson({
        'id': '1',
        'user_id': 'u',
        'title': 'Task',
        'description': null,
        'status': 'invalid',
        'priority': 'medium',
        'created_at': '2024-01-01T00:00:00.000Z',
        'completed_at': null,
        'category': null,
      });

      expect(task.status, TaskStatus.pending);
    });

    test('copyWith updates fields', () {

      final task = Task(userId: 'u', title: 'Old');

      final updated = task.copyWith(title: 'New');

      expect(updated.title, 'New');
      expect(task.title, 'Old'); // original unchanged
    });


  });
}