import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:krishi_connect/models/job_tractor_model.dart';
import 'package:krishi_connect/models/job_tubewell_model.dart';
import 'package:krishi_connect/providers/auth_provider.dart';
import 'package:krishi_connect/services/firestore_service.dart';

class FarmerHistoryScreen extends StatefulWidget {
  const FarmerHistoryScreen({super.key});

  @override
  State<FarmerHistoryScreen> createState() => _FarmerHistoryScreenState();
}

class _FarmerHistoryScreenState extends State<FarmerHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  List<JobTractorModel> _tractorJobs = [];
  List<JobTubewellModel> _tubewellJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null) {
      _tractorJobs =
          await _firestoreService.getTractorJobsByFarmer(user.uid);
      _tubewellJobs =
          await _firestoreService.getTubewellJobsByFarmer(user.uid);
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meri History'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Jutayi (Tractor)', icon: Icon(Icons.agriculture)),
            Tab(text: 'Pani (Tubewell)', icon: Icon(Icons.water_drop)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTractorHistory(),
                _buildTubewellHistory(),
              ],
            ),
    );
  }

  Widget _buildTractorHistory() {
    if (_tractorJobs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.agriculture, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Koi jutayi nahi hui abhi tak',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    double totalKharcha =
        _tractorJobs.fold(0, (sum, j) => sum + j.priceCalculated);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFFFF3E0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Total Jutayi', '${_tractorJobs.length}'),
              _buildStat('Total Kharcha', 'Rs ${totalKharcha.toStringAsFixed(0)}'),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _tractorJobs.length,
            itemBuilder: (context, index) {
              final job = _tractorJobs[index];
              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.agriculture,
                    color: job.status == 'completed'
                        ? Colors.green
                        : Colors.orange,
                  ),
                  title: Text('Owner: ${job.ownerName}'),
                  subtitle: Text(
                    'Mode: ${job.pricingMode} | Bigha: ${job.bigha}\n'
                    'Date: ${DateFormat.yMMMd().format(job.startTime)}\n'
                    'Status: ${job.status}',
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
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTubewellHistory() {
    if (_tubewellJobs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Koi pani supply nahi hui abhi tak',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    double totalKharcha =
        _tubewellJobs.fold(0, (sum, j) => sum + j.priceCalculated);
    double totalHours =
        _tubewellJobs.fold(0, (sum, j) => sum + j.totalMinutes) / 60;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFE3F2FD),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Total Sessions', '${_tubewellJobs.length}'),
              _buildStat('Total Hours', '${totalHours.toStringAsFixed(1)}h'),
              _buildStat('Total Kharcha', 'Rs ${totalKharcha.toStringAsFixed(0)}'),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _tubewellJobs.length,
            itemBuilder: (context, index) {
              final job = _tubewellJobs[index];
              final hours = (job.totalMinutes / 60).toStringAsFixed(1);
              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.water_drop,
                    color: job.status == 'completed'
                        ? Colors.green
                        : Colors.orange,
                  ),
                  title: Text('Owner: ${job.ownerName}'),
                  subtitle: Text(
                    'Mode: ${job.billingMode} | Hours: ${hours}h | Bigha: ${job.bigha}\n'
                    'Date: ${DateFormat.yMMMd().format(job.startTime)}\n'
                    'Status: ${job.status}',
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
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
