import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/app_provider.dart';
import 'inspection_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EngineerDashboardScreen extends StatelessWidget {
  const EngineerDashboardScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isEnglish = appProvider.isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(appProvider.engDash),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appProvider.myJobs,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Filter: Status is 'assigned' AND assigned to 'eng1' (Our Mock User)
                stream: FirebaseFirestore.instance
                    .collection('requests')
                    .where('status', isEqualTo: 'assigned')
                    .where('assignedEngineerId', isEqualTo: 'eng1') 
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text(isEnglish ? "No jobs assigned yet." : "لا توجد مهام مسندة بعد."));
                  }

                  final jobs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      final data = job.data() as Map<String, dynamic>;
                      
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: Text(data['clientName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['location'] ?? 'No Location'),
                              const SizedBox(height: 5),
                              Text(
                                (data['selectedServices'] as List).join(', '), 
                                style: const TextStyle(color: AppColors.secondary)
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // We pass the real data and the Document ID
                                builder: (_) => InspectionScreen(
                                  jobData: data, 
                                  jobId: job.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
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
}