import 'package:flutter/material.dart';
import 'package:krishi_connect/models/user_model.dart';
import 'package:krishi_connect/services/firestore_service.dart';
import 'package:krishi_connect/utils/constants.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<UserModel> _tractorOwners = [];
  List<UserModel> _tubewellOwners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    _tractorOwners =
        await _firestoreService.getUsersByRole(AppConstants.roleTractorOwner);
    _tubewellOwners =
        await _firestoreService.getUsersByRole(AppConstants.roleTubewellOwner);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tractor Owners',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_tractorOwners.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Koi tractor owner nahi mila'),
                    ),
                  ..._tractorOwners.map((user) => _buildUserCard(user)),
                  const SizedBox(height: 24),
                  const Text(
                    'Tubewell Owners',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_tubewellOwners.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Koi tubewell owner nahi mila'),
                    ),
                  ..._tubewellOwners.map((user) => _buildUserCard(user)),
                ],
              ),
            ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isApproved ? Colors.green : Colors.orange,
          child: Icon(
            user.isApproved ? Icons.check : Icons.hourglass_empty,
            color: Colors.white,
          ),
        ),
        title: Text(user.name),
        subtitle: Text('Phone: ${user.phone}\nRole: ${user.role}'),
        isThreeLine: true,
        trailing: user.isApproved
            ? const Chip(
                label: Text('Approved'),
                backgroundColor: Color(0xFFE8F5E9),
              )
            : ElevatedButton(
                onPressed: () async {
                  await _firestoreService.approveUser(user.uid);
                  _loadUsers();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Approve'),
              ),
      ),
    );
  }
}
