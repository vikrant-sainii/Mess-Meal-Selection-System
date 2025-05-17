import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminApprovalScreen extends StatelessWidget {
  const AdminApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('Pending Approvals', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('admin_approval')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text('No pending requests', style: TextStyle(color: Colors.white)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index].data() as Map<String, dynamic>;
              return _buildRequestCard(request, requests[index].id, context);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, String docId, BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1), // Semi-transparent for glassmorphism
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.transparent, // Transparent background to show glassmorphism
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mess ID: ${request['messId']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                _buildComparisonRow('Name', request['currentName'], request['requestedName']),
                const SizedBox(height: 8),
                _buildComparisonRow('Phone', request['currentPhone'], request['requestedPhone']),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () => _handleApproval(false, docId, request, context),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.green.withOpacity(0.3), // Slight shadow for elevation effect
                          elevation: 6, // Elevated button effect
                        ),
                        onPressed: () => _handleApproval(true, docId, request, context),
                        child: const Text('Approve'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonRow(String label, String current, String requested) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text('$label:', style: const TextStyle(color: Colors.white70))),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(current, style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.red)),
              Text(requested, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleApproval(bool approved, String docId, Map<String, dynamic> request, BuildContext context) async {
    final batch = FirebaseFirestore.instance.batch();
    final approvalRef = FirebaseFirestore.instance.collection('admin_approval').doc(docId);

    // Update the approval status and processed information
    batch.update(approvalRef, {
      'status': approved ? 'approved' : 'rejected',
      'processedAt': FieldValue.serverTimestamp(),
      'processedBy': 'admin_user_id', // Replace with actual admin ID
    });

    if (approved) {
      final clientRef = FirebaseFirestore.instance.collection('client').doc(request['messId']);
      // Update client data after approval
      batch.update(clientRef, {
        'name': request['requestedName'],
        'mobile': request['requestedPhone'],
      });
    }

    try {
      await batch.commit();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approved ? 'Request approved' : 'Request rejected'),
          backgroundColor: approved ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }
}