import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:krishi_connect/providers/auth_provider.dart';
import 'package:krishi_connect/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user =
        Provider.of<AppAuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user == null) return;

    final authService = AuthService();
    await authService.updateProfile(user.uid, {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
    });

    // Update local state
    final updated = user.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    authProvider.setUser(updated);

    setState(() {
      _isEditing = false;
      _isSaving = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppAuthProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('User data not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF2E7D32),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Chip(
                    avatar: const Icon(Icons.verified_user, size: 16),
                    label: Text(
                      _getRoleLabel(user.role),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: const Color(0xFFE8F5E9),
                  ),
                  const SizedBox(height: 32),

                  // Fields
                  TextField(
                    controller: _nameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Naam (Name)',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      hintText: user.email ?? 'Not set',
                    ),
                    controller:
                        TextEditingController(text: user.email ?? 'Not set'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Account Created',
                      prefixIcon: const Icon(Icons.calendar_today),
                      hintText: '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                    ),
                    controller: TextEditingController(
                      text:
                          '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (_isEditing) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveProfile,
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
                        label: const Text('Save'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() => _isEditing = false),
                      child: const Text('Cancel'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'farmer':
        return 'Farmer (Kisan)';
      case 'tractor_owner':
        return 'Tractor Owner';
      case 'tubewell_owner':
        return 'Tubewell Owner';
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }
}
