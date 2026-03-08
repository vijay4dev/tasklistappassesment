import 'package:supabase_flutter/supabase_flutter.dart';
import '../dashboard/task_model.dart';

class SupabaseService {

  final SupabaseClient client = Supabase.instance.client;
  static const String tasksTable = "tasks";

  // ───── AUTH ─────

  User? get currentUser => client.auth.currentUser;

  Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) {
    return client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {"full_name": fullName} : null,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() {
    return client.auth.signOut();
  }

  Future<void> resetPassword(String email) {
    return client.auth.resetPasswordForEmail(email);
  }

  // ───── TASK METHODS ─────

  Future<List<Task>> fetchTasks() async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception("User not logged in");

    final data = await client
        .from(tasksTable)
        .select()
        .eq("user_id", userId)
        .order("created_at", ascending: false);

    return (data as List)
        .map((e) => Task.fromJson(e))
        .toList();
  }

  Future<Task> createTask(Task task) async {
    final data = await client
        .from(tasksTable)
        .insert(task.toJson())
        .select()
        .single();

    return Task.fromJson(data);
  }

  Future<Task> updateTask(Task task) async {
    final data = await client
        .from(tasksTable)
        .update(task.toJson())
        .eq("id", task.id)
        .select()
        .single();

    return Task.fromJson(data);
  }

  Future<void> deleteTask(String taskId) async {
    await client
        .from(tasksTable)
        .delete()
        .eq("id", taskId);
  }

  Future<Task> toggleTaskStatus(Task task) async {

    final status = task.isCompleted
        ? TaskStatus.pending
        : TaskStatus.completed;

    final updatedTask = task.copyWith(
      status: status,
      completedAt: status == TaskStatus.completed
          ? DateTime.now()
          : null,
      clearCompletedAt: status == TaskStatus.pending,
    );

    return updateTask(updatedTask);
  }
}