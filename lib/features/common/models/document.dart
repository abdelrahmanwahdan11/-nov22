class Document {
  const Document({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    this.note,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String type;
  final String status;
  final String? note;
  final DateTime updatedAt;

  Document copyWith({String? title, String? type, String? status, String? note, DateTime? updatedAt}) {
    return Document(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'status': status,
      'note': note,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'] as String,
      title: map['title'] as String,
      type: map['type'] as String,
      status: map['status'] as String,
      note: map['note'] as String?,
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
