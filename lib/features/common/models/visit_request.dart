import 'package:flutter/material.dart';

class VisitRequest {
  VisitRequest({
    required this.id,
    required this.itemId,
    required this.dateTime,
    this.note,
  });

  final String id;
  final String itemId;
  final DateTime dateTime;
  final String? note;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'dateTime': dateTime.toIso8601String(),
      'note': note,
    };
  }

  factory VisitRequest.fromMap(Map<String, dynamic> map) {
    return VisitRequest(
      id: map['id'] as String,
      itemId: map['itemId'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      note: map['note'] as String?,
    );
  }

  String formatted(BuildContext context) {
    final timeOfDay = TimeOfDay.fromDateTime(dateTime);
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} • $hour:$minute';
  }
}
