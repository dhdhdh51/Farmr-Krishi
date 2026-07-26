import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:krishi_connect/models/payment_model.dart';
import 'package:krishi_connect/models/expense_model.dart';
import 'package:krishi_connect/services/firestore_service.dart';

class RevenueReportScreen extends StatefulWidget {
  const RevenueReportScreen({super.key});

  @override
  State<RevenueReportScreen> createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends State<RevenueReportScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  double _totalRevenue = 0;
  double _totalExpenses = 0;
  double _netProfit = 0;
  List<PaymentModel> _payments = [];
  List<ExpenseModel> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _payments = await _firestoreService.getAllPayments();
    _expenses = await _firestoreService.getAllExpenses();

    _totalRevenue = _payments
        .where((p) => p.status == 'paid')
        .fold(0, (sum, p) => sum + p.amount);
    _totalExpenses = _expenses.fold(0, (sum, e) => sum + e.amount);
    _netProfit = _totalRevenue - _totalExpenses;

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs ');
    return Scaffold(
      appBar: AppBar(title: const Text('Revenue / Kharcha Report')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSummaryCard(
                    'Total Revenue (Paid)',
                    formatter.format(_totalRevenue),
                    Icons.trending_up,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryCard(
                    'Total Kharcha (Expenses)',
                    formatter.format(_totalExpenses),
                    Icons.trending_down,
                    Colors.red,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryCard(
                    'Net Profit',
                    formatter.format(_netProfit),
                    Icons.account_balance_wallet,
                    _netProfit >= 0 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Recent Payments',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._payments.take(10).map(_buildPaymentTile),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Recent Expenses',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._expenses.take(10).map(_buildExpenseTile),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(
      String title, String amount, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          amount,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentTile(PaymentModel payment) {
    return Card(
      child: ListTile(
        dense: true,
        title: Text('${payment.farmerName} → ${payment.ownerName}'),
        subtitle: Text(
          '${payment.jobType} | ${DateFormat.yMMMd().format(payment.createdAt)}',
        ),
        trailing: Text(
          'Rs ${payment.amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: payment.status == 'paid' ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseTile(ExpenseModel expense) {
    return Card(
      child: ListTile(
        dense: true,
        title: Text('${expense.type} - ${expense.ownerName}'),
        subtitle: Text(DateFormat.yMMMd().format(expense.date)),
        trailing: Text(
          'Rs ${expense.amount.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
