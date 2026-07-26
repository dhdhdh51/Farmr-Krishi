import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String ownerUid;
  final String ownerName;
  final String type; // diesel, electricity, maintenance, other
  final double amount;
  final DateTime date;
  final String? note;

  ExpenseModel({
    required this.id,
    required this.ownerUid,
    required this.ownerName,
    required this.type,
    required this.amount,
    required this.date,
    this.note,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String id) {
    return ExpenseModel(
      id: id,
      ownerUid: map['ownerUid'] ?? '',
      ownerName: map['ownerName'] ?? '',
      type: map['type'] ?? 'other',
      amount: (map['amount'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerUid': ownerUid,
      'ownerName': ownerName,
      'type': type,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'note': note,
    };
  }
}
