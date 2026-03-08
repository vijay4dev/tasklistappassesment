import 'package:flutter/foundation.dart';
import 'package:tasklistapp/services/supabaseservices.dart';
import '../dashboard/task_model.dart';


enum TaskFilter { all, pending, completed }

class TaskProvider extends ChangeNotifier {

  final SupabaseService _service = SupabaseService();

  List<Task> _tasks = [];
  bool _loading = false;
  String? _error;

  TaskFilter _filter = TaskFilter.all;
  String _search = "";

  // ───── Getters ─────

  List<Task> get tasks => _applyFilter();

  bool get isLoading => _loading;

  String? get error => _error;

  int get total => _tasks.length;

  int get completed =>
      _tasks.where((t) => t.isCompleted).length;

  int get pending =>
      _tasks.where((t) => !t.isCompleted).length;

  // ───── Filter Logic ─────

  List<Task> _applyFilter() {

    List<Task> list = _tasks;

    if (_search.isNotEmpty) {
      list = list.where((t) =>
          t.title.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }

    if (_filter == TaskFilter.pending) {
      return list.where((t) => !t.isCompleted).toList();
    }

    if (_filter == TaskFilter.completed) {
      return list.where((t) => t.isCompleted).toList();
    }

    return list;
  }

  void setFilter(TaskFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  // ───── Fetch Tasks ─────

  Future<void> fetchTasks() async {

    try {

      _loading = true;
      notifyListeners();

      _tasks = await _service.fetchTasks();

    } catch (_) {

      _error = "Failed to load tasks";

    } finally {

      _loading = false;
      notifyListeners();
    }
  }

  // ───── Add Task ─────

  Future<void> addTask(Task task) async {

    try {

      final created = await _service.createTask(task);

      _tasks.insert(0, created);

      notifyListeners();

    } catch (_) {

      _error = "Failed to add task";
      notifyListeners();
    }
  }

  // ───── Update Task ─────

  Future<void> updateTask(Task task) async {

    try {

      final updated = await _service.updateTask(task);

      final index =
          _tasks.indexWhere((t) => t.id == task.id);

      if (index != -1) {
        _tasks[index] = updated;
        notifyListeners();
      }

    } catch (_) {

      _error = "Update failed";
      notifyListeners();
    }
  }

  // ───── Delete Task ─────

  Future<void> deleteTask(String id) async {

    final index =
        _tasks.indexWhere((t) => t.id == id);

    if (index == -1) return;

    final removed = _tasks.removeAt(index);

    notifyListeners();

    try {

      await _service.deleteTask(id);

    } catch (_) {

      _tasks.insert(index, removed);
      notifyListeners();
    }
  }

  // ───── Toggle Status ─────

  Future<void> toggle(Task task) async {

    final index =
        _tasks.indexWhere((t) => t.id == task.id);

    if (index == -1) return;

    final newStatus =
        task.isCompleted ? TaskStatus.pending : TaskStatus.completed;

    final updated =
        task.copyWith(status: newStatus);

    _tasks[index] = updated;

    notifyListeners();

    try {

      final serverTask =
          await _service.toggleTaskStatus(task);

      _tasks[index] = serverTask;

      notifyListeners();

    } catch (_) {

      _tasks[index] = task;
      notifyListeners();
    }
  }

  void clear() {

    _tasks.clear();
    _search = "";
    _filter = TaskFilter.all;

    notifyListeners();
  }
}