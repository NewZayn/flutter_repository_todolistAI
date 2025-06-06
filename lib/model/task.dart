import 'package:intl/intl.dart';

class Task {
  final int id;
  final String userId;
  final String title;
  final String description;
  final int priority;
  final int? category;
  final int? state;
  final String? donedate;
  final String? createddate;
  final String? updateddate;
  final String? taskFrequence;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
    required this.state,
    this.donedate,
    this.createddate,
    this.updateddate,
    this.taskFrequence,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? 0,
      userId: json['userId'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 1,
      category: json['category'] ?? 1,
      state: json['state'] ?? 1,
      donedate: json['donedate'],
      createddate: json['createddate'],
      updateddate: json['updateddate'],
      taskFrequence: json['taskFrequence'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'priority': priority,
      'category': category,
      'state': state,
      'donedate': donedate,
      'createddate': createddate,
      'updateddate': updateddate,
      'taskFrequence': taskFrequence,
    };
  }
}
