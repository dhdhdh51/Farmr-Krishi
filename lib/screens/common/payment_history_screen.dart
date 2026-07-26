import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:krishi_connect/models/payment_model.dart';
import 'package:krishi_connect/providers/auth_provider.dart';
import 'package:krishi_connect/services/firestore_service.dart';
import 'package:krishi_connect/utils/constants.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<PaymentModel> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null) {
      if (user.role == AppConstants.roleAdmin) {
        _payments = await _firestoreService.getAllPayments();
      } else {
        _payments = await _firestoreService.getPaymentsForUser(user.uid);
      }
    }
    setState(() => _isLoading = false);
  }

  void _showUpdatePaymentDialog(PaymentModel payment) {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user == null) return;

    // Only farmer or owner can update payment
    if (user.uid != payment.farmerUid && user.uid != payment.ownerUid) return;

    String selectedMode = 'cash';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Payment Update'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Amount: Rs ${payment.amount.toStringAsFixed(0)}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedMode,
                decoration: const InputDecoration(labelText: 'Payment Mode'),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'upi', child: Text('UPI')),
                ],
                onChanged: (val) => selectedMode = val ?? 'cash',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _firestoreService.updatePaymentStatus(
                  payment.id,
                  AppConstants.paymentPaid,
                  selectedMode,
                );
                if (context.mounted) Navigator.pop(context);
                _loadPayments();
              },
              child: const Text('Mark Paid'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final user = authProvider.currentUser;

    final totalPaid = _payments
        .where((p) => p.status == AppConstants.paymentPaid)
        .fold(0.0, (sum, p) => sum + p.amount);
    final totalPending = _payments
        .where((p) => p.status == AppConstants.paymentPending)
        .fold(0.0, (sum, p) => sum + p.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFFE8F5E9),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummary(
                          'Paid', 'Rs ${totalPaid.toStringAsFixed(0)}', Colors.green),
                      _buildSummary('Pending',
                          'Rs ${totalPending.toStringAsFixed(0)}', Colors.orange),
                      _buildSummary(
                          'Total', '${_payments.length}', Colors.blue),
                    ],
                  ),
                ),
                // Payment list
                Expanded(
                  child: _payments.isEmpty
                      ? const Center(
                          child: Text('Koi payment record nahi hai'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _payments.length,
                          itemBuilder: (context, index) {
                            final payment = _payments[index];
                            final isFarmer =
                                user?.uid == payment.farmerUid;
                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  payment.status == AppConstants.paymentPaid
                                      ? Icons.check_circle
                                      : Icons.pending,
                                  color:
                                      payment.status == AppConstants.paymentPaid
                                          ? Colors.green
                                          : Colors.orange,
                                ),
                                title: Text(
                                  isFarmer
                                      ? 'To: ${payment.ownerName}'
                                      : 'From: ${payment.farmerName}',
                                ),
                                subtitle: Text(
                                  '${payment.jobType} | ${payment.paymentMode}\n'
                                  '${DateFormat.yMMMd().format(payment.createdAt)}',
                                ),
                                isThreeLine: true,
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Rs ${payment.amount.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: payment.status ==
                                                AppConstants.paymentPaid
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                    if (payment.status ==
                                        AppConstants.paymentPending)
                                      const Text('Pending',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.orange)),
                                  ],
                                ),
                                onTap: payment.status ==
                                        AppConstants.paymentPending
                                    ? () =>
                                        _showUpdatePaymentDialog(payment)
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummary(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
