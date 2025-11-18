import 'dart:convert';

class Offer {
  Offer({
    required this.id,
    required this.itemId,
    required this.amount,
    required this.status,
    this.note = '',
    required this.createdAt,
  });

  final String id;
  final String itemId;
  final double amount;
  final String status;
  final String note;
  final DateTime createdAt;

  Offer copyWith({String? status, String? note}) {
    return Offer(
      id: id,
      itemId: itemId,
      amount: amount,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'amount': amount,
      'status': status,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String toJson() => jsonEncode(toMap());

  static Offer fromJson(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return Offer.fromMap(map);
  }

  factory Offer.fromMap(Map<String, dynamic> map) {
    return Offer(
      id: map['id']?.toString() ?? '',
      itemId: map['itemId']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      status: map['status']?.toString() ?? 'draft',
      note: map['note']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
