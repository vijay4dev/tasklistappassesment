import 'package:uuid/uuid.dart';


enum TaskPriority { low, medium, high }
enum TaskStatus   { pending, completed }

class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;   
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? completedAt; 
  final String? category;

  
  Task({
    String? id,          
    required this.userId,
    required this.title,
    this.description,     
    this.status   = TaskStatus.pending,    
    this.priority = TaskPriority.medium,   
    DateTime? createdAt,
    this.completedAt,
    this.category,
  })  : id        = id ?? const Uuid().v4(),    
        createdAt = createdAt ?? DateTime.now(); 

  bool get isCompleted => status == TaskStatus.completed;


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
    bool clearCompletedAt = false, 
  }) {
    return Task(
      id:          id          ?? this.id,
      userId:      userId      ?? this.userId,
      title:       title       ?? this.title,
      description: description ?? this.description,
      status:      status      ?? this.status,
      priority:    priority    ?? this.priority,
      createdAt:   createdAt   ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      category:    category    ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':           id,
      'user_id':      userId,        
      'title':        title,
      'description':  description,
      'status':       status.name,   
      'priority':     priority.name,
      'created_at':   createdAt.toIso8601String(), 
      'completed_at': completedAt?.toIso8601String(), 
      'category':     category,
    };
  }

  
  
  
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id:     json['id']      as String,
      userId: json['user_id'] as String,
      title:  json['title']   as String,
      description: json['description'] as String?,

      
      
      status: TaskStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'pending'),
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == (json['priority'] as String? ?? 'medium'),
        orElse: () => TaskPriority.medium,
      ),

      createdAt: DateTime.parse(json['created_at'] as String),

      
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,

      category: json['category'] as String?,
    );
  }
}