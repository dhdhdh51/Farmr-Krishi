import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:krishi_connect/models/tractor_model.dart';
import 'package:krishi_connect/models/tubewell_model.dart';
import 'package:krishi_connect/models/user_model.dart';
import 'package:krishi_connect/services/firestore_service.dart';
import 'package:krishi_connect/utils/constants.dart';

class ResourceManagementScreen extends StatefulWidget {
  const ResourceManagementScreen({super.key});

  @override
  State<ResourceManagementScreen> createState() =>
      _ResourceManagementScreenState();
}

class _ResourceManagementScreenState extends State<ResourceManagementScreen>
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
        title: const Text('Resource Management'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Tractors', icon: Icon(Icons.agriculture)),
            Tab(text: 'Tubewells', icon: Icon(Icons.water_drop)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTractorList(),
          _buildTubewellList(),
        ],
      ),
    );
  }

  Widget _buildTractorList() {
    return FutureBuilder<List<TractorModel>>(
      future: _firestoreService.getAllTractors(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final tractors = snapshot.data ?? [];
        if (tractors.isEmpty) {
          return const Center(child: Text('Koi tractor nahi mila'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: tractors.length,
          itemBuilder: (context, index) {
            final tractor = tractors[index];
            return Card(
              child: ListTile(
                leading:
                    const Icon(Icons.agriculture, color: Colors.orange, size: 32),
                title: Text('Owner: ${tractor.ownerName}'),
                subtitle: Text('Status: ${tractor.status}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: tractor.isActive,
                      onChanged: (val) async {
                        await _firestoreService
                            .updateTractor(tractor.id, {'isActive': val});
                        setState(() {});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _firestoreService.deleteTractor(tractor.id);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTubewellList() {
    return FutureBuilder<List<TubewellModel>>(
      future: _firestoreService.getAllTubewells(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final tubewells = snapshot.data ?? [];
        if (tubewells.isEmpty) {
          return const Center(child: Text('Koi tubewell nahi mila'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: tubewells.length,
          itemBuilder: (context, index) {
            final tubewell = tubewells[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.water_drop, color: Colors.blue, size: 32),
                title: Text('Owner: ${tubewell.ownerName}'),
                subtitle:
                    Text('Billing: ${tubewell.billingMode}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: tubewell.isActive,
                      onChanged: (val) async {
                        await _firestoreService
                            .updateTubewell(tubewell.id, {'isActive': val});
                        setState(() {});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _firestoreService.deleteTubewell(tubewell.id);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddDialog() {
    final isTractor = _tabController.index == 0;
    final nameController = TextEditingController();
    String selectedOwnerUid = '';
    String selectedOwnerName = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isTractor ? 'Add Tractor' : 'Add Tubewell'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder<List<UserModel>>(
                future: _firestoreService.getUsersByRole(
                  isTractor
                      ? AppConstants.roleTractorOwner
                      : AppConstants.roleTubewellOwner,
                ),
                builder: (context, snapshot) {
                  final users = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Owner'),
                    items: users
                        .map((u) => DropdownMenuItem(
                              value: u.uid,
                              child: Text(u.name),
                            ))
                        .toList(),
                    onChanged: (val) {
                      selectedOwnerUid = val ?? '';
                      selectedOwnerName =
                          users.firstWhere((u) => u.uid == val).name;
                    },
                  );
                },
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
                if (selectedOwnerUid.isEmpty) return;
                if (isTractor) {
                  await _firestoreService.addTractor(TractorModel(
                    id: '',
                    ownerUid: selectedOwnerUid,
                    ownerName: selectedOwnerName,
                  ));
                } else {
                  await _firestoreService.addTubewell(TubewellModel(
                    id: '',
                    ownerUid: selectedOwnerUid,
                    ownerName: selectedOwnerName,
                  ));
                }
                if (context.mounted) Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    nameController.dispose();
  }
}
