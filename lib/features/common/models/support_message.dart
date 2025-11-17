import 'package:intl/intl.dart';

class SupportMessage {
  SupportMessage({
    required this.id,
    required this.title,
    required this.details,
    required this.topic,
    required this.resolved,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String details;
  final String topic;
  final bool resolved;
  final DateTime createdAt;

  SupportMessage copyWith({bool? resolved}) {
    return SupportMessage(
      id: id,
      title: title,
      details: details,
      topic: topic,
      resolved: resolved ?? this.resolved,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'details': details,
      'topic': topic,
      'resolved': resolved,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory SupportMessage.fromMap(Map<String, dynamic> map) {
    return SupportMessage(
      id: map['id'] as String,
      title: map['title'] as String,
      details: map['details'] as String,
      topic: map['topic'] as String,
      resolved: map['resolved'] as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  String formattedDate() => DateFormat.yMMMd().add_jm().format(createdAt);
}
