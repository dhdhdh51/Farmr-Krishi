import 'package:cloud_firestore/cloud_firestore.dart';

class JobTractorModel {
  final String id;
  final String tractorId;
  final String ownerUid;
  final String ownerName;
  final String farmerUid;
  final String farmerName;
  final String pricingMode; // flat, per_bigha
  final double bigha;
  final DateTime startTime;
  final DateTime? endTime;
  final double priceCalculated;
  final String status; // pending, in_progress, completed, cancelled

  JobTractorModel({
    required this.id,
    required this.tractorId,
    required this.ownerUid,
    required this.ownerName,
    required this.farmerUid,
    required this.farmerName,
    required this.pricingMode,
    this.bigha = 0,
    required this.startTime,
    this.endTime,
    this.priceCalculated = 0,
    this.status = 'pending',
  });

  factory JobTractorModel.fromMap(Map<String, dynamic> map, String id) {
    return JobTractorModel(
      id: id,
      tractorId: map['tractorId'] ?? '',
      ownerUid: map['ownerUid'] ?? '',
      ownerName: map['ownerName'] ?? '',
      farmerUid: map['farmerUid'] ?? '',
      farmerName: map['farmerName'] ?? '',
      pricingMode: map['pricingMode'] ?? 'flat',
      bigha: (map['bigha'] ?? 0).toDouble(),
      startTime: (map['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (map['endTime'] as Timestamp?)?.toDate(),
      priceCalculated: (map['priceCalculated'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tractorId': tractorId,
      'ownerUid': ownerUid,
      'ownerName': ownerName,
      'farmerUid': farmerUid,
      'farmerName': farmerName,
      'pricingMode': pricingMode,
      'bigha': bigha,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'priceCalculated': priceCalculated,
      'status': status,
    };
  }

  JobTractorModel copyWith({
    DateTime? endTime,
    double? priceCalculated,
    String? status,
  }) {
    return JobTractorModel(
      id: id,
      tractorId: tractorId,
      ownerUid: ownerUid,
      ownerName: ownerName,
      farmerUid: farmerUid,
      farmerName: farmerName,
      pricingMode: pricingMode,
      bigha: bigha,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      priceCalculated: priceCalculated ?? this.priceCalculated,
      status: status ?? this.status,
    );
  }
}
