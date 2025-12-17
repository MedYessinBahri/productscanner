import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedFilter = 'Tous';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteHistoryItem(String docId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('scans')
          .doc(docId)
          .delete();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enregistrement supprimé')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _clearAllHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer'),
        content: const Text('Voulez-vous vraiment supprimer tout l\'historique?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final batch = _firestore.batch();
        final snapshot = await _firestore
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .collection('scans')
            .get();

        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Historique effacé')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${e.toString()}')),
          );
        }
      }
    }
  }

  Stream<QuerySnapshot> _getHistoryStream() {
    Query query = _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection('scans')
        .orderBy('timestamp', descending: true);

    // Apply filter
    if (_selectedFilter == 'Code-barres') {
      query = query.where('type', isEqualTo: 'barcode');
    } else if (_selectedFilter == 'Images') {
      query = query.where('type', isEqualTo: 'image');
    } else if (_selectedFilter == 'Aujourd\'hui') {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      query = query.where('timestamp', isGreaterThanOrEqualTo: startOfDay);
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearAllHistory,
            tooltip: 'Effacer tout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(_auth.currentUser?.uid)
                  .collection('scans')
                  .snapshots(),
              builder: (context, snapshot) {
                final totalScans = snapshot.hasData ? snapshot.data!.docs.length : 0;
                
                // Count this month's scans
                final now = DateTime.now();
                final startOfMonth = DateTime(now.year, now.month, 1);
                final thisMonthScans = snapshot.hasData
                    ? snapshot.data!.docs.where((doc) {
                        final timestamp = (doc['timestamp'] as Timestamp).toDate();
                        return timestamp.isAfter(startOfMonth);
                      }).length
                    : 0;

                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Total Scans',
                        value: totalScans.toString(),
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Ce mois',
                        value: thisMonthScans.toString(),
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
            const SizedBox(height: 16),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tous'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Code-barres'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Images'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Aujourd\'hui'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // History List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getHistoryStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Erreur: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 80,
                            color: colorScheme.onBackground.withOpacity(0.3),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Aucun historique',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Commencez à scanner des produits',
                            style: TextStyle(
                              color: colorScheme.onBackground.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter by search query
                  var docs = snapshot.data!.docs;
                  if (_searchQuery.isNotEmpty) {
                    docs = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final result = (data['result'] as String? ?? '').toLowerCase();
                      return result.contains(_searchQuery);
                    }).toList();
                  }

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('Aucun résultat trouvé'),
                    );
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return _buildHistoryItem(doc.id, data, context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == label,
      onSelected: (bool value) {
        setState(() {
          _selectedFilter = label;
        });
      },
    );
  }

  Widget _buildStatCard(
      BuildContext context, {
        required String title,
        required String value,
        required Color color,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.assessment, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String docId, Map<String, dynamic> data, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isBarcode = data['type'] == 'barcode';
    final timestamp = (data['timestamp'] as Timestamp).toDate();
    final result = data['result'] as String? ?? 'Inconnu';

    return Dismissible(
      key: Key(docId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteHistoryItem(docId);
      },
      child: Card(
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isBarcode
                  ? colorScheme.primary.withOpacity(0.1)
                  : colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              isBarcode ? Icons.qr_code : Icons.image,
              color: isBarcode ? colorScheme.primary : colorScheme.secondary,
            ),
          ),
          title: Text(
            isBarcode ? 'Scan code-barres' : 'Identification image',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                result.length > 50 ? '${result.substring(0, 50)}...' : result,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(timestamp),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: colorScheme.onBackground.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui, ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hier, ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}