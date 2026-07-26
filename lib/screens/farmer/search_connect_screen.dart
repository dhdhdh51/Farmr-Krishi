import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:krishi_connect/models/user_model.dart';
import 'package:krishi_connect/models/connection_model.dart';
import 'package:krishi_connect/providers/auth_provider.dart';
import 'package:krishi_connect/services/firestore_service.dart';
import 'package:krishi_connect/utils/constants.dart';

class SearchConnectScreen extends StatefulWidget {
  const SearchConnectScreen({super.key});

  @override
  State<SearchConnectScreen> createState() => _SearchConnectScreenState();
}

class _SearchConnectScreenState extends State<SearchConnectScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  String _searchType = 'name'; // name or phone
  String _ownerRole = AppConstants.roleTractorOwner;
  List<UserModel> _results = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);

    if (_searchType == 'name') {
      _results = await _firestoreService.searchUsersByName(query, _ownerRole);
    } else {
      // Phone search
      final user =
          await _firestoreService.getUserByPhone(query, _ownerRole);
      _results = user != null ? [user] : [];
    }

    setState(() => _isSearching = false);
  }

  Future<void> _connect(UserModel owner) async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final farmer = authProvider.currentUser;
    if (farmer == null) return;

    final connection = ConnectionModel(
      id: '',
      farmerUid: farmer.uid,
      ownerUid: owner.uid,
      ownerRole: owner.role,
      ownerName: owner.name,
      farmerName: farmer.name,
      connectedAt: DateTime.now(),
    );

    await _firestoreService.addConnection(connection);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${owner.name} se connect ho gaye!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search / Connect')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Owner role filter
            const Text(
              'Kisko dhundhna hai?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: AppConstants.roleTractorOwner,
                  label: Text('Tractor Owner'),
                  icon: Icon(Icons.agriculture),
                ),
                ButtonSegment(
                  value: AppConstants.roleTubewellOwner,
                  label: Text('Tubewell Owner'),
                  icon: Icon(Icons.water_drop),
                ),
              ],
              selected: {_ownerRole},
              onSelectionChanged: (val) =>
                  setState(() => _ownerRole = val.first),
            ),
            const SizedBox(height: 16),

            // Search type
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Naam se'),
                  selected: _searchType == 'name',
                  onSelected: (_) => setState(() => _searchType = 'name'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Phone se'),
                  selected: _searchType == 'phone',
                  onSelected: (_) => setState(() => _searchType = 'phone'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search field
            TextField(
              controller: _searchController,
              keyboardType: _searchType == 'phone'
                  ? TextInputType.phone
                  : TextInputType.text,
              decoration: InputDecoration(
                labelText:
                    _searchType == 'name' ? 'Naam search karein' : 'Phone number daalein',
                hintText: _searchType == 'name' ? 'e.g. Rajesh' : 'e.g. 9876543210',
                prefixIcon: Icon(
                    _searchType == 'name' ? Icons.person_search : Icons.phone),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 16),

            // Results
            if (_isSearching) const Center(child: CircularProgressIndicator()),

            if (!_isSearching && _results.isEmpty && _searchController.text.isNotEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Koi nahi mila', style: TextStyle(color: Colors.grey)),
                ),
              ),

            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final user = _results[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF2E7D32),
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(user.name),
                      subtitle: Text('Phone: ${user.phone}'),
                      trailing: ElevatedButton.icon(
                        onPressed: () => _connect(user),
                        icon: const Icon(Icons.link, size: 16),
                        label: const Text('Connect'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
