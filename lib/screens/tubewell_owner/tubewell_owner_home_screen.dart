import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:krishi_connect/models/job_tubewell_model.dart';
import 'package:krishi_connect/models/expense_model.dart';
import 'package:krishi_connect/providers/auth_provider.dart';
import 'package:krishi_connect/providers/rate_provider.dart';
import 'package:krishi_connect/services/firestore_service.dart';
import 'package:krishi_connect/screens/tubewell_owner/water_session_screen.dart';
import 'package:krishi_connect/screens/common/profile_screen.dart';
import 'package:krishi_connect/screens/common/payment_history_screen.dart';
import 'package:krishi_connect/screens/common/add_expense_screen.dart';
import 'package:krishi_connect/screens/auth/login_screen.dart';
import 'package:krishi_connect/utils/constants.dart';

class TubewellOwnerHomeScreen extends StatefulWidget {
  const TubewellOwnerHomeScreen({super.key});

  @override
  State<TubewellOwnerHomeScreen> createState() =>
      _TubewellOwnerHomeScreenState();
}

class _TubewellOwnerHomeScreenState extends State<TubewellOwnerHomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<JobTubewellModel> _jobs = [];
  List<ExpenseModel> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null) {
      _jobs = await _firestoreService.getTubewellJobsByOwner(user.uid);
      _expenses = await _firestoreService.getExpensesByOwner(user.uid);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final user = authProvider.currentUser;

    final completedJobs =
        _jobs.where((j) => j.status == AppConstants.statusCompleted).toList();
    final pendingJobs =
        _jobs.where((j) => j.status == AppConstants.statusPending).toList();
    final inProgressJobs = _jobs
        .where((j) => j.status == AppConstants.statusInProgress)
        .toList();

    final totalRevenue =
        completedJobs.fold(0.0, (sum, j) => sum + j.priceCalculated);
    final totalHours =
        completedJobs.fold(0.0, (sum, j) => sum + j.totalMinutes) / 60;
    final totalBigha = completedJobs.fold(0.0, (sum, j) => sum + j.bigha);
    final totalElectricityKharcha = _expenses
        .where((e) => e.type == AppConstants.expenseElectricity)
        .fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tubewell Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WaterSessionScreen()),
          );
          _loadData();
        },
        icon: const Icon(Icons.water_drop),
        label: const Text('New Session'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome
                    Card(
                      color: Colors.blue.shade700,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.water_drop,
                                size: 40, color: Colors.white),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Namaste, ${user?.name ?? "Owner"}!',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Text('Tubewell Owner Dashboard',
                                      style: TextStyle(color: Colors.white70)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Hours',
                            '${totalHours.toStringAsFixed(1)}h',
                            Icons.access_time,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Total Bigha',
                            '${totalBigha.toStringAsFixed(1)}',
                            Icons.landscape,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Revenue',
                            'Rs ${totalRevenue.toStringAsFixed(0)}',
                            Icons.currency_rupee,
                            Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Bijli Kharcha',
                            'Rs ${totalElectricityKharcha.toStringAsFixed(0)}',
                            Icons.electric_bolt,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quick actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const PaymentHistoryScreen()),
                            ),
                            icon: const Icon(Icons.receipt_long),
                            label: const Text('Payments'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AddExpenseScreen()),
                              );
                              _loadData();
                            },
                            icon: const Icon(Icons.electric_bolt),
                            label: const Text('Bijli Kharcha'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Active sessions (in progress)
                    if (inProgressJobs.isNotEmpty) ...[
                      const Text(
                        'Active Sessions (Bijli ON)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...inProgressJobs.map(_buildActiveJobCard),
                      const SizedBox(height: 16),
                    ],

                    // Pending bookings
                    if (pendingJobs.isNotEmpty) ...[
                      const Text(
                        'Pending Bookings',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...pendingJobs.map(_buildPendingJobCard),
                      const SizedBox(height: 16),
                    ],

                    // Recent completed
                    const Text(
                      'Recent Completed',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (completedJobs.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Koi completed session nahi hai'),
                        ),
                      )
                    else
                      ...completedJobs.take(5).map(_buildCompletedJobCard),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveJobCard(JobTubewellModel job) {
    final elapsed = DateTime.now().difference(job.startTime);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes % 60;

    return Card(
      color: Colors.green.shade50,
      child: ListTile(
        leading: const Icon(Icons.water_drop, color: Colors.green, size: 32),
        title: Text('Farmer: ${job.farmerName}'),
        subtitle: Text(
          'Running: ${hours}h ${minutes}m\nMode: ${job.billingMode}',
        ),
        isThreeLine: true,
        trailing: ElevatedButton(
          onPressed: () async {
            final rateProvider =
                Provider.of<RateProvider>(context, listen: false);
            await rateProvider.loadRates();
            await _firestoreService.completeTubewellJob(
                job.id, rateProvider.rates);
            _loadData();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Stop'),
        ),
      ),
    );
  }

  Widget _buildPendingJobCard(JobTubewellModel job) {
    return Card(
      color: Colors.orange.shade50,
      child: ListTile(
        leading: const Icon(Icons.pending_actions, color: Colors.orange),
        title: Text('Farmer: ${job.farmerName}'),
        subtitle: Text('Mode: ${job.billingMode} | Bigha: ${job.bigha}'),
        trailing: ElevatedButton(
          onPressed: () async {
            // Start the job (change to in_progress)
            await _firestoreService.updateTubewellJob(job.id, {
              'status': AppConstants.statusInProgress,
              'startTime': DateTime.now(),
            });
            _loadData();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Start'),
        ),
      ),
    );
  }

  Widget _buildCompletedJobCard(JobTubewellModel job) {
    final hours = (job.totalMinutes / 60).toStringAsFixed(1);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text('Farmer: ${job.farmerName}'),
        subtitle: Text(
          'Hours: ${hours}h | Bigha: ${job.bigha}\n'
          '${DateFormat.yMMMd().format(job.startTime)}',
        ),
        isThreeLine: true,
        trailing: Text(
          'Rs ${job.priceCalculated.toStringAsFixed(0)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
