import 'package:cloud_firestore/cloud_firestore.dart';

class TodoModel {
  String? id;
  String title;
  bool isDone;
  String? assignedTo;
  DateTime createdAt;

  TodoModel({
    this.id,
    required this.title,
    required this.isDone,
    this.assignedTo,
    required this.createdAt,
  });

  factory TodoModel.fromMap(Map<String, dynamic> map, String docId) {
    return TodoModel(
      id: docId,
      title: map['title'] ?? '',
      isDone: map['isDone'] ?? false,
      assignedTo: map['assignedTo'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isDone': isDone,
      'assignedTo': assignedTo,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}