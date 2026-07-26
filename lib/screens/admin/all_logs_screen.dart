import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:krishi_connect/models/job_tractor_model.dart';
import 'package:krishi_connect/models/job_tubewell_model.dart';
import 'package:krishi_connect/services/firestore_service.dart';

class AllLogsScreen extends StatefulWidget {
  const AllLogsScreen({super.key});

  @override
  State<AllLogsScreen> createState() => _AllLogsScreenState();
}

class _AllLogsScreenState extends State<AllLogsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('All Logs'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Jutayi (Tractor)'),
            Tab(text: 'Pani (Tubewell)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTractorLogs(),
          _buildTubewellLogs(),
        ],
      ),
    );
  }

  Widget _buildTractorLogs() {
    return FutureBuilder<List<JobTractorModel>>(
      future: _firestoreService.getAllTractorJobs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final jobs = snapshot.data ?? [];
        if (jobs.isEmpty) {
          return const Center(child: Text('Koi jutayi log nahi mila'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return Card(
              child: ListTile(
                leading: _buildStatusIcon(job.status),
                title: Text('${job.farmerName} → ${job.ownerName}'),
                subtitle: Text(
                  'Mode: ${job.pricingMode} | Bigha: ${job.bigha}\n'
                  'Date: ${DateFormat.yMMMd().add_jm().format(job.startTime)}\n'
                  'Price: Rs ${job.priceCalculated.toStringAsFixed(0)}',
                ),
                isThreeLine: true,
                trailing: Chip(
                  label: Text(
                    job.status,
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: _getStatusColor(job.status),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTubewellLogs() {
    return FutureBuilder<List<JobTubewellModel>>(
      future: _firestoreService.getAllTubewellJobs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final jobs = snapshot.data ?? [];
        if (jobs.isEmpty) {
          return const Center(child: Text('Koi pani log nahi mila'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            final hours = (job.totalMinutes / 60).toStringAsFixed(1);
            return Card(
              child: ListTile(
                leading: _buildStatusIcon(job.status),
                title: Text('${job.farmerName} → ${job.ownerName}'),
                subtitle: Text(
                  'Mode: ${job.billingMode} | Bigha: ${job.bigha} | Hours: $hours\n'
                  'Date: ${DateFormat.yMMMd().add_jm().format(job.startTime)}\n'
                  'Price: Rs ${job.priceCalculated.toStringAsFixed(0)}',
                ),
                isThreeLine: true,
                trailing: Chip(
                  label: Text(
                    job.status,
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: _getStatusColor(job.status),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'in_progress':
        return const Icon(Icons.timelapse, color: Colors.orange);
      case 'cancelled':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.pending, color: Colors.grey);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green.shade100;
      case 'in_progress':
        return Colors.orange.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }
}
