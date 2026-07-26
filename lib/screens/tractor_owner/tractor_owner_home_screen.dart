import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:krishi_connect/models/job_tractor_model.dart';
import 'package:krishi_connect/providers/auth_provider.dart';
import 'package:krishi_connect/providers/rate_provider.dart';
import 'package:krishi_connect/services/firestore_service.dart';
import 'package:krishi_connect/screens/tractor_owner/log_tractor_job_screen.dart';
import 'package:krishi_connect/screens/common/profile_screen.dart';
import 'package:krishi_connect/screens/common/payment_history_screen.dart';
import 'package:krishi_connect/screens/common/add_expense_screen.dart';
import 'package:krishi_connect/screens/auth/login_screen.dart';
import 'package:krishi_connect/utils/constants.dart';

class TractorOwnerHomeScreen extends StatefulWidget {
  const TractorOwnerHomeScreen({super.key});

  @override
  State<TractorOwnerHomeScreen> createState() => _TractorOwnerHomeScreenState();
}

class _TractorOwnerHomeScreenState extends State<TractorOwnerHomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<JobTractorModel> _jobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null) {
      _jobs = await _firestoreService.getTractorJobsByOwner(user.uid);
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
    final totalRevenue =
        completedJobs.fold(0.0, (sum, j) => sum + j.priceCalculated);
    final flatJobs =
        completedJobs.where((j) => j.pricingMode == AppConstants.pricingFlat).length;
    final bighaJobs =
        completedJobs.where((j) => j.pricingMode == AppConstants.pricingPerBigha).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tractor Dashboard'),
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
            MaterialPageRoute(builder: (_) => const LogTractorJobScreen()),
          );
          _loadJobs();
        },
        icon: const Icon(Icons.add),
        label: const Text('Naya Job Log'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadJobs,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome
                    Card(
                      color: Colors.orange.shade700,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.agriculture,
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
                                  const Text('Tractor Owner Dashboard',
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
                            'Total Jobs',
                            '${completedJobs.length}',
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Revenue',
                            'Rs ${totalRevenue.toStringAsFixed(0)}',
                            Icons.currency_rupee,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Pending',
                            '${pendingJobs.length}',
                            Icons.hourglass_empty,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Flat Jobs',
                            '$flatJobs',
                            Icons.payments,
                            Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Bigha Jobs',
                            '$bighaJobs',
                            Icons.landscape,
                            Colors.teal,
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
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AddExpenseScreen()),
                            ),
                            icon: const Icon(Icons.add_card),
                            label: const Text('Add Kharcha'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Pending jobs
                    if (pendingJobs.isNotEmpty) ...[
                      const Text(
                        'Pending Jobs',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...pendingJobs.map((job) => _buildPendingJobCard(job)),
                      const SizedBox(height: 16),
                    ],

                    // Recent completed
                    const Text(
                      'Recent Completed Jobs',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (completedJobs.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Koi completed job nahi hai'),
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

  Widget _buildPendingJobCard(JobTractorModel job) {
    return Card(
      color: Colors.orange.shade50,
      child: ListTile(
        leading: const Icon(Icons.pending_actions, color: Colors.orange),
        title: Text('Farmer: ${job.farmerName}'),
        subtitle: Text(
          'Mode: ${job.pricingMode} | Bigha: ${job.bigha}\n'
          '${DateFormat.yMMMd().add_jm().format(job.startTime)}',
        ),
        isThreeLine: true,
        trailing: ElevatedButton(
          onPressed: () async {
            final rateProvider =
                Provider.of<RateProvider>(context, listen: false);
            await rateProvider.loadRates();
            await _firestoreService.completeTractorJob(
                job.id, rateProvider.rates);
            _loadJobs();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Complete'),
        ),
      ),
    );
  }

  Widget _buildCompletedJobCard(JobTractorModel job) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text('Farmer: ${job.farmerName}'),
        subtitle: Text(
          'Mode: ${job.pricingMode} | Bigha: ${job.bigha}\n'
          '${DateFormat.yMMMd().format(job.startTime)}',
        ),
        isThreeLine: true,
        trailing: Text(
          'Rs ${job.priceCalculated.toStringAsFixed(0)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
      ),
    );
  }
}
