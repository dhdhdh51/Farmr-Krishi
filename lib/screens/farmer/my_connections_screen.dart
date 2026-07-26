import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:krishi_connect/models/connection_model.dart';
import 'package:krishi_connect/providers/auth_provider.dart';
import 'package:krishi_connect/services/firestore_service.dart';
import 'package:krishi_connect/utils/constants.dart';

class MyConnectionsScreen extends StatefulWidget {
  const MyConnectionsScreen({super.key});

  @override
  State<MyConnectionsScreen> createState() => _MyConnectionsScreenState();
}

class _MyConnectionsScreenState extends State<MyConnectionsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<ConnectionModel> _connections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConnections();
  }

  Future<void> _loadConnections() async {
    setState(() => _isLoading = true);
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null) {
      _connections = await _firestoreService.getConnectionsForFarmer(user.uid);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final tractorConnections = _connections
        .where((c) => c.ownerRole == AppConstants.roleTractorOwner)
        .toList();
    final tubewellConnections = _connections
        .where((c) => c.ownerRole == AppConstants.roleTubewellOwner)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Connections')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _connections.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Koi connection nahi hai',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Search se owners ko connect karein',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tractorConnections.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.agriculture, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(
                              'Tractor Owners (${tractorConnections.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...tractorConnections.map(_buildConnectionCard),
                        const SizedBox(height: 24),
                      ],
                      if (tubewellConnections.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.water_drop, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'Tubewell Owners (${tubewellConnections.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...tubewellConnections.map(_buildConnectionCard),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildConnectionCard(ConnectionModel connection) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: connection.ownerRole == AppConstants.roleTractorOwner
              ? Colors.orange
              : Colors.blue,
          child: Text(
            connection.ownerName.isNotEmpty
                ? connection.ownerName[0].toUpperCase()
                : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(connection.ownerName),
        subtitle: Text(
          connection.ownerRole == AppConstants.roleTractorOwner
              ? 'Tractor Owner'
              : 'Tubewell Owner',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () async {
            await _firestoreService.removeConnection(connection.id);
            _loadConnections();
          },
        ),
      ),
    );
  }
}
