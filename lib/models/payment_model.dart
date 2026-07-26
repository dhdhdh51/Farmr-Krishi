import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String relatedJobId;
  final String jobType; // tractor, tubewell
  final String farmerUid;
  final String farmerName;
  final String ownerUid;
  final String ownerName;
  final double amount;
  final String paymentMode; // cash, upi, pending
  final String status; // paid, pending, partial
  final DateTime? paidAt;
  final String? note;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.relatedJobId,
    required this.jobType,
    required this.farmerUid,
    required this.farmerName,
    required this.ownerUid,
    required this.ownerName,
    required this.amount,
    this.paymentMode = 'pending',
    this.status = 'pending',
    this.paidAt,
    this.note,
    required this.createdAt,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map, String id) {
    return PaymentModel(
      id: id,
      relatedJobId: map['relatedJobId'] ?? '',
      jobType: map['jobType'] ?? '',
      farmerUid: map['farmerUid'] ?? '',
      farmerName: map['farmerName'] ?? '',
      ownerUid: map['ownerUid'] ?? '',
      ownerName: map['ownerName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      paymentMode: map['paymentMode'] ?? 'pending',
      status: map['status'] ?? 'pending',
      paidAt: (map['paidAt'] as Timestamp?)?.toDate(),
      note: map['note'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'relatedJobId': relatedJobId,
      'jobType': jobType,
      'farmerUid': farmerUid,
      'farmerName': farmerName,
      'ownerUid': ownerUid,
      'ownerName': ownerName,
      'amount': amount,
      'paymentMode': paymentMode,
      'status': status,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
