// uuid package se import — random unique ID generate karta hai
import 'package:uuid/uuid.dart';

// ─── Enums ─────────────────────────────────────────────────────────────────
// Enum use karo String ke bajaye — typo se bachate hain
// Galti se 'compelted' likhne ki jagah compiler pakad lega

enum TaskPriority { low, medium, high }
enum TaskStatus   { pending, completed }

// ─── Task Class ─────────────────────────────────────────────────────────────
class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;   // ? matlab nullable — hona zaroori nahi
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? completedAt; // Sirf tab set hoga jab complete karo
  final String? category;

  // ─── Constructor ─────────────────────────────────────────────
  Task({
    String? id,           // Optional — agar nahi diya toh auto-generate
    required this.userId, // required = ye pass karna MUST hai
    required this.title,
    this.description,     // Optional fields mein 'required' nahi hota
    this.status   = TaskStatus.pending,    // Default value
    this.priority = TaskPriority.medium,   // Default value
    DateTime? createdAt,
    this.completedAt,
    this.category,
  })  : id        = id ?? const Uuid().v4(),    // Null hoga toh UUID generate karo
        createdAt = createdAt ?? DateTime.now(); // Null hoga toh abhi ki time

  // ─── Computed property ───────────────────────────────────────
  // Getter — field nahi hai, calculate hota hai
  bool get isCompleted => status == TaskStatus.completed;

  // ─── copyWith ────────────────────────────────────────────────
  // Flutter mein objects IMMUTABLE hone chahiye (final fields).
  // Kuch update karna ho toh naya object banate hain changed fields ke saath.
  // Dart mein built-in copyWith nahi hai — khud likhna padta hai.
  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? completedAt,
    String? category,
    bool clearCompletedAt = false, // Yeh special flag hai
  }) {
    return Task(
      id:          id          ?? this.id,
      userId:      userId      ?? this.userId,
      title:       title       ?? this.title,
      description: description ?? this.description,
      status:      status      ?? this.status,
      priority:    priority    ?? this.priority,
      createdAt:   createdAt   ?? this.createdAt,
      // clearCompletedAt = true matlab null set karo
      // warna naya value ya purana value use karo
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      category:    category    ?? this.category,
    );
  }

  // ─── toJson ──────────────────────────────────────────────────
  // Supabase ko data bhejne ke liye Map<String, dynamic> chahiye
  // Dart object → JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id':           id,
      'user_id':      userId,        // DB column name: user_id (snake_case)
      'title':        title,
      'description':  description,
      'status':       status.name,   // enum.name → 'pending' ya 'completed'
      'priority':     priority.name,
      'created_at':   createdAt.toIso8601String(), // DateTime → String
      'completed_at': completedAt?.toIso8601String(), // null-safe
      'category':     category,
    };
  }

  // ─── fromJson ─────────────────────────────────────────────────
  // Supabase se data aata hai as Map — usse Task object mein convert karo
  // JSON Map → Dart object
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id:     json['id']      as String,
      userId: json['user_id'] as String,
      title:  json['title']   as String,
      description: json['description'] as String?,

      // String se enum banana — firstWhere se match karo
      // orElse: agar koi match nahi mila toh default do (data corruption se bachao)
      status: TaskStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'pending'),
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == (json['priority'] as String? ?? 'medium'),
        orElse: () => TaskPriority.medium,
      ),

      createdAt: DateTime.parse(json['created_at'] as String),

      // Null check pehle — agar null nahi hai toh parse karo
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,

      category: json['category'] as String?,
    );
  }
}