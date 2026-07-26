import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:krishi_connect/models/expense_model.dart';
import 'package:krishi_connect/providers/auth_provider.dart';
import 'package:krishi_connect/services/firestore_service.dart';
import 'package:krishi_connect/utils/constants.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _expenseType = AppConstants.expenseDiesel;
  bool _isSaving = false;

  Future<void> _saveExpense() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount daalein')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final user = authProvider.currentUser!;

    final expense = ExpenseModel(
      id: '',
      ownerUid: user.uid,
      ownerName: user.name,
      type: _expenseType,
      amount: double.parse(_amountController.text),
      date: DateTime.now(),
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );

    await _firestoreService.addExpense(expense);

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense saved!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppAuthProvider>(context).currentUser;
    // Determine expense types based on role
    final isTubewellOwner = user?.role == AppConstants.roleTubewellOwner;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Kharcha (Expense)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kharcha Type:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (!isTubewellOwner)
                  ChoiceChip(
                    label: const Text('Diesel'),
                    avatar: const Icon(Icons.local_gas_station, size: 16),
                    selected: _expenseType == AppConstants.expenseDiesel,
                    onSelected: (_) =>
                        setState(() => _expenseType = AppConstants.expenseDiesel),
                  ),
                ChoiceChip(
                  label: const Text('Bijli (Electricity)'),
                  avatar: const Icon(Icons.electric_bolt, size: 16),
                  selected: _expenseType == AppConstants.expenseElectricity,
                  onSelected: (_) => setState(
                      () => _expenseType = AppConstants.expenseElectricity),
                ),
                ChoiceChip(
                  label: const Text('Maintenance'),
                  avatar: const Icon(Icons.build, size: 16),
                  selected: _expenseType == AppConstants.expenseMaintenance,
                  onSelected: (_) => setState(
                      () => _expenseType = AppConstants.expenseMaintenance),
                ),
                ChoiceChip(
                  label: const Text('Other'),
                  avatar: const Icon(Icons.more_horiz, size: 16),
                  selected: _expenseType == AppConstants.expenseOther,
                  onSelected: (_) =>
                      setState(() => _expenseType = AppConstants.expenseOther),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (Rs)',
                hintText: 'e.g., 500',
                prefixIcon: Icon(Icons.currency_rupee),
                prefixText: 'Rs ',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'e.g., 20 litre diesel, bijli bill June...',
                prefixIcon: Icon(Icons.note),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveExpense,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: const Text('Save Kharcha',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
