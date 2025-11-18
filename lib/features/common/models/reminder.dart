class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.category,
    required this.dueAt,
    this.note,
    this.done = false,
  });

  final String id;
  final String title;
  final String category;
  final DateTime dueAt;
  final String? note;
  final bool done;

  Reminder copyWith({String? title, String? category, DateTime? dueAt, String? note, bool? done}) {
    return Reminder(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      dueAt: dueAt ?? this.dueAt,
      note: note ?? this.note,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'dueAt': dueAt.toIso8601String(),
      'note': note,
      'done': done,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      dueAt: DateTime.tryParse(map['dueAt'] as String? ?? '') ?? DateTime.now(),
      note: map['note'] as String?,
      done: map['done'] as bool? ?? false,
    );
  }
}
