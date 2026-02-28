import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/app_provider.dart';
import 'admin_request_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isEnglish = appProvider.isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(appProvider.adminDash),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Simple logout logic: pop until root
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Stats Header
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard("3", appProvider.pendingRequests, context),
                _buildStatCard("1", appProvider.assignedRequests, context),
              ],
            ),
          ),
          
          // Request List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('requests')
                  .orderBy('date', descending: true) // Sort by newest
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                   return Center(child: Text(isEnglish ? "No requests" : "لا توجد طلبات"));
                }

                final requests = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    final data = req.data() as Map<String, dynamic>;
                    
                    return _buildRequestCard(data, req.id, isEnglish, context, appProvider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String count, String label, BuildContext context) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
        Text(label, style: const TextStyle(color: AppColors.text)),
      ],
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req, String docId, bool isEnglish, BuildContext context, AppProvider appProvider) {
    // Note: Ensure your data access matches Firestore fields. 
    // E.g., req['clientName'], req['totalPrice'] etc.
    // You may need to adjust the keys inside this method to match your DB structure.
    
    Color statusColor = req['status'] == 'pending' ? Colors.orange : Colors.green;
    String statusText = req['status'] == 'pending' ? appProvider.pending : appProvider.assigned;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.secondary,
          child: Text(req['client'][0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(req['client'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${req['services'].join(', ')}"),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(req['date'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(width: 10),
                Icon(Icons.attach_money, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text("${req['total']} EGP", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                statusText,
                style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
                       onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminRequestDetailScreen(
                      requestData: req,         // The data map
                      requestId: docId,         // <--- ADD THIS LINE (Pass the document ID)
                    ),
                  ),
                );
              },
        ),
      );
    }
  }