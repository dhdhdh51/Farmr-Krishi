import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:krishi_connect/models/user_model.dart';
import 'package:krishi_connect/models/tractor_model.dart';
import 'package:krishi_connect/models/tubewell_model.dart';
import 'package:krishi_connect/models/connection_model.dart';
import 'package:krishi_connect/models/job_tractor_model.dart';
import 'package:krishi_connect/models/job_tubewell_model.dart';
import 'package:krishi_connect/models/payment_model.dart';
import 'package:krishi_connect/models/expense_model.dart';
import 'package:krishi_connect/models/rate_model.dart';
import 'package:krishi_connect/utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== RATES ====================

  Future<RateModel> getRates() async {
    final doc = await _db.doc(AppConstants.ratesDocument).get();
    if (!doc.exists) {
      return RateModel();
    }
    return RateModel.fromMap(doc.data()!);
  }

  Future<void> updateRates(RateModel rates) async {
    await _db.doc(AppConstants.ratesDocument).set(rates.toMap());
  }

  // ==================== USERS ====================

  Future<List<UserModel>> getUsersByRole(String role) async {
    final snapshot = await _db
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: role)
        .get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<UserModel?> getUserByPhone(String phone, String role) async {
    final snapshot = await _db
        .collection(AppConstants.usersCollection)
        .where('phone', isEqualTo: phone)
        .where('role', isEqualTo: role)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return UserModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
  }

  Future<List<UserModel>> searchUsersByName(String name, String role) async {
    final snapshot = await _db
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: role)
        .get();
    // Client-side filter for name search (case-insensitive)
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .where((user) => user.name.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  Future<void> approveUser(String uid) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({'isApproved': true});
  }

  // ==================== TRACTORS ====================

  Future<List<TractorModel>> getAllTractors() async {
    final snapshot = await _db
        .collection(AppConstants.tractorsCollection)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => TractorModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<TractorModel>> getTractorsByOwner(String ownerUid) async {
    final snapshot = await _db
        .collection(AppConstants.tractorsCollection)
        .where('ownerUid', isEqualTo: ownerUid)
        .get();
    return snapshot.docs
        .map((doc) => TractorModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<String> addTractor(TractorModel tractor) async {
    final doc = await _db
        .collection(AppConstants.tractorsCollection)
        .add(tractor.toMap());
    return doc.id;
  }

  Future<void> updateTractor(String id, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.tractorsCollection).doc(id).update(data);
  }

  Future<void> deleteTractor(String id) async {
    await _db.collection(AppConstants.tractorsCollection).doc(id).delete();
  }

  // ==================== TUBEWELLS ====================

  Future<List<TubewellModel>> getAllTubewells() async {
    final snapshot = await _db
        .collection(AppConstants.tubewellsCollection)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => TubewellModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<TubewellModel>> getTubewellsByOwner(String ownerUid) async {
    final snapshot = await _db
        .collection(AppConstants.tubewellsCollection)
        .where('ownerUid', isEqualTo: ownerUid)
        .get();
    return snapshot.docs
        .map((doc) => TubewellModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<String> addTubewell(TubewellModel tubewell) async {
    final doc = await _db
        .collection(AppConstants.tubewellsCollection)
        .add(tubewell.toMap());
    return doc.id;
  }

  Future<void> updateTubewell(String id, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.tubewellsCollection).doc(id).update(data);
  }

  Future<void> deleteTubewell(String id) async {
    await _db.collection(AppConstants.tubewellsCollection).doc(id).delete();
  }

  // ==================== CONNECTIONS ====================

  Future<List<ConnectionModel>> getConnectionsForFarmer(String farmerUid) async {
    final snapshot = await _db
        .collection(AppConstants.connectionsCollection)
        .where('farmerUid', isEqualTo: farmerUid)
        .get();
    return snapshot.docs
        .map((doc) => ConnectionModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> addConnection(ConnectionModel connection) async {
    // Check if connection already exists
    final existing = await _db
        .collection(AppConstants.connectionsCollection)
        .where('farmerUid', isEqualTo: connection.farmerUid)
        .where('ownerUid', isEqualTo: connection.ownerUid)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return; // Already connected

    await _db
        .collection(AppConstants.connectionsCollection)
        .add(connection.toMap());
  }

  Future<void> removeConnection(String connectionId) async {
    await _db
        .collection(AppConstants.connectionsCollection)
        .doc(connectionId)
        .delete();
  }

  // ==================== TRACTOR JOBS ====================

  Future<String> createTractorJob(JobTractorModel job) async {
    final doc = await _db
        .collection(AppConstants.jobsTractorCollection)
        .add(job.toMap());
    return doc.id;
  }

  Future<void> updateTractorJob(String id, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.jobsTractorCollection)
        .doc(id)
        .update(data);
  }

  Future<List<JobTractorModel>> getTractorJobsByFarmer(String farmerUid) async {
    final snapshot = await _db
        .collection(AppConstants.jobsTractorCollection)
        .where('farmerUid', isEqualTo: farmerUid)
        .orderBy('startTime', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => JobTractorModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<JobTractorModel>> getTractorJobsByOwner(String ownerUid) async {
    final snapshot = await _db
        .collection(AppConstants.jobsTractorCollection)
        .where('ownerUid', isEqualTo: ownerUid)
        .orderBy('startTime', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => JobTractorModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<JobTractorModel>> getAllTractorJobs() async {
    final snapshot = await _db
        .collection(AppConstants.jobsTractorCollection)
        .orderBy('startTime', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => JobTractorModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Complete tractor job with price calculation
  Future<void> completeTractorJob(String jobId, RateModel rates) async {
    final doc = await _db
        .collection(AppConstants.jobsTractorCollection)
        .doc(jobId)
        .get();
    if (!doc.exists) return;

    final job = JobTractorModel.fromMap(doc.data()!, doc.id);
    double price = 0;

    if (job.pricingMode == AppConstants.pricingFlat) {
      price = rates.pricePerJutayi;
    } else {
      price = job.bigha * rates.pricePerBighaTractor;
    }

    final now = DateTime.now();
    await _db.collection(AppConstants.jobsTractorCollection).doc(jobId).update({
      'endTime': Timestamp.fromDate(now),
      'priceCalculated': price,
      'status': AppConstants.statusCompleted,
    });

    // Create payment entry
    await createPayment(PaymentModel(
      id: '',
      relatedJobId: jobId,
      jobType: 'tractor',
      farmerUid: job.farmerUid,
      farmerName: job.farmerName,
      ownerUid: job.ownerUid,
      ownerName: job.ownerName,
      amount: price,
      status: AppConstants.paymentPending,
      createdAt: now,
    ));
  }

  // ==================== TUBEWELL JOBS ====================

  Future<String> createTubewellJob(JobTubewellModel job) async {
    final doc = await _db
        .collection(AppConstants.jobsTubewellCollection)
        .add(job.toMap());
    return doc.id;
  }

  Future<void> updateTubewellJob(String id, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.jobsTubewellCollection)
        .doc(id)
        .update(data);
  }

  Future<List<JobTubewellModel>> getTubewellJobsByFarmer(String farmerUid) async {
    final snapshot = await _db
        .collection(AppConstants.jobsTubewellCollection)
        .where('farmerUid', isEqualTo: farmerUid)
        .orderBy('startTime', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => JobTubewellModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<JobTubewellModel>> getTubewellJobsByOwner(String ownerUid) async {
    final snapshot = await _db
        .collection(AppConstants.jobsTubewellCollection)
        .where('ownerUid', isEqualTo: ownerUid)
        .orderBy('startTime', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => JobTubewellModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<JobTubewellModel>> getAllTubewellJobs() async {
    final snapshot = await _db
        .collection(AppConstants.jobsTubewellCollection)
        .orderBy('startTime', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => JobTubewellModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Complete tubewell job with price calculation
  Future<void> completeTubewellJob(String jobId, RateModel rates) async {
    final doc = await _db
        .collection(AppConstants.jobsTubewellCollection)
        .doc(jobId)
        .get();
    if (!doc.exists) return;

    final job = JobTubewellModel.fromMap(doc.data()!, doc.id);
    final now = DateTime.now();
    final totalMinutes = now.difference(job.startTime).inMinutes.toDouble();
    double price = 0;

    if (job.billingMode == AppConstants.billingHourly) {
      final hours = totalMinutes / 60;
      price = hours * rates.pricePerHourWater;
    } else {
      price = job.bigha * rates.pricePerBighaWater;
    }

    await _db.collection(AppConstants.jobsTubewellCollection).doc(jobId).update({
      'endTime': Timestamp.fromDate(now),
      'totalMinutes': totalMinutes,
      'priceCalculated': price,
      'status': AppConstants.statusCompleted,
    });

    // Create payment entry
    await createPayment(PaymentModel(
      id: '',
      relatedJobId: jobId,
      jobType: 'tubewell',
      farmerUid: job.farmerUid,
      farmerName: job.farmerName,
      ownerUid: job.ownerUid,
      ownerName: job.ownerName,
      amount: price,
      status: AppConstants.paymentPending,
      createdAt: now,
    ));
  }

  // ==================== PAYMENTS ====================

  Future<void> createPayment(PaymentModel payment) async {
    await _db.collection(AppConstants.paymentsCollection).add(payment.toMap());
  }

  Future<List<PaymentModel>> getPaymentsForUser(String uid) async {
    // Get payments where user is either farmer or owner
    final asFarmer = await _db
        .collection(AppConstants.paymentsCollection)
        .where('farmerUid', isEqualTo: uid)
        .get();
    final asOwner = await _db
        .collection(AppConstants.paymentsCollection)
        .where('ownerUid', isEqualTo: uid)
        .get();

    final allDocs = [...asFarmer.docs, ...asOwner.docs];
    // Remove duplicates
    final seen = <String>{};
    final unique = allDocs.where((doc) => seen.add(doc.id)).toList();

    return unique
        .map((doc) => PaymentModel.fromMap(doc.data(), doc.id))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<PaymentModel>> getAllPayments() async {
    final snapshot = await _db
        .collection(AppConstants.paymentsCollection)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => PaymentModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updatePaymentStatus(
      String paymentId, String status, String mode) async {
    final data = <String, dynamic>{
      'status': status,
      'paymentMode': mode,
    };
    if (status == AppConstants.paymentPaid) {
      data['paidAt'] = Timestamp.fromDate(DateTime.now());
    }
    await _db
        .collection(AppConstants.paymentsCollection)
        .doc(paymentId)
        .update(data);
  }

  // ==================== EXPENSES ====================

  Future<void> addExpense(ExpenseModel expense) async {
    await _db.collection(AppConstants.expensesCollection).add(expense.toMap());
  }

  Future<List<ExpenseModel>> getExpensesByOwner(String ownerUid) async {
    final snapshot = await _db
        .collection(AppConstants.expensesCollection)
        .where('ownerUid', isEqualTo: ownerUid)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ExpenseModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<ExpenseModel>> getAllExpenses() async {
    final snapshot = await _db
        .collection(AppConstants.expensesCollection)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ExpenseModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ==================== AUTH SETTINGS ====================

  Future<Map<String, dynamic>> getAuthSettings() async {
    final doc = await _db.doc(AppConstants.settingsAuthDocument).get();
    if (!doc.exists) {
      return {'otpRequired': false, 'otpForPhoneLogin': false};
    }
    return doc.data()!;
  }

  Future<void> updateAuthSettings(Map<String, dynamic> settings) async {
    await _db.doc(AppConstants.settingsAuthDocument).set(settings);
  }
}
