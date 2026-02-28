import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/app_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class InspectionScreen extends StatefulWidget {
  final Map<String, dynamic> jobData;
  final String jobId; 
  const InspectionScreen({super.key, required this.jobData, required this.jobId});

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  // Mock Checklist items
  final List<Map<String, dynamic>> _checklistItems = [
    {"title": "Check Main Valve", "status": "pending", "notes": ""},
    {"title": "Inspect Pipes for Leaks", "status": "pending", "notes": ""},
    {"title": "Check Water Pressure", "status": "pending", "notes": ""},
    {"title": "Drainage System Flow", "status": "pending", "notes": ""},
  ];

  // Image Picking Variables
  final ImagePicker _picker = ImagePicker();
  File? _defectImage;

  // Helper to upload image and get URL
  Future<String?> _uploadImage(File image, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> _pickDefectImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _defectImage = File(image.path);
      });
    }
  }

  // --- UPDATED SUBMIT LOGIC ---
  Future<void> _submitRequest() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Upload Defect Photo if selected
      String? defectPhotoUrl;
      if (_defectImage != null) {
        String fileName = "inspection_${widget.jobId}_${DateTime.now().millisecondsSinceEpoch}.jpg";
        defectPhotoUrl = await _uploadImage(_defectImage!, "inspection_photos/$fileName");
      }

      // 2. Prepare Checklist Data
      List<Map<String, dynamic>> checklistData = _checklistItems.map((item) => {
        'title': item['title'],
        'status': item['status'],
        'notes': item['notes'],
      }).toList();

      // 3. Prepare Update Map
      Map<String, dynamic> updateData = {
        'status': 'completed',
        'checklistResults': checklistData,
        'completedAt': DateTime.now().toIso8601String(),
      };

      // 4. Add Photo URL if it exists
      if (defectPhotoUrl != null) {
        updateData['defectPhotoUrl'] = defectPhotoUrl;
      }

      // 5. UPDATE the request to 'completed'
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.jobId)
          .update(updateData);

      // --- NEW: CALCULATE ENGINEER EARNINGS (UBER PAY LOGIC) ---
      final requestPrice = (widget.jobData['totalPrice'] ?? 0).toDouble();
      final commissionRate = 0.80; // Engineer gets 80%, App keeps 20%
      final engineerEarnings = requestPrice * commissionRate;
      final engineerId = widget.jobData['assignedEngineerId'];

      if (engineerId != null) {
        // Get the Engineer's current financial record
        final userRef = FirebaseFirestore.instance.collection('users').doc(engineerId);
        final docSnapshot = await userRef.get();

        if (docSnapshot.exists) {
          final currentPending = (docSnapshot.data()?['pendingBalance'] ?? 0).toDouble();
          final currentTotal = (docSnapshot.data()?['totalEarnings'] ?? 0).toDouble();

          // Update their balance
          await userRef.update({
            'pendingBalance': currentPending + engineerEarnings,
            'totalEarnings': currentTotal + engineerEarnings,
          });
        }
      }
      // -----------------------------------------------------------------

      // Close loading
      if (mounted) Navigator.of(context).pop();
      
      // Show Success
      if (mounted) {
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appProvider.reportSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context); // Go back to dashboard
      }
    } catch (e) {
      // Close loading
      if (mounted) Navigator.of(context).pop();
      
      // Show Error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isEnglish = appProvider.isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(appProvider.checklistTitle),
        backgroundColor: AppColors.primary,
      ),
      body: Directionality(
        textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
        child: Column(
          children: [
            // Job Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.jobData['clientName'] ?? 'Unknown Client', 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.jobData['location'] ?? 'No Location Provided',
                  ),
                ],
              ),
            ),

            // Checklist
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _checklistItems.length,
                itemBuilder: (context, index) {
                  final item = _checklistItems[index];
                  return _buildChecklistItem(item, index, isEnglish, appProvider);
                },
              ),
            ),

            // --- NEW: Inspection Photo Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Inspection Photo", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDefectImage,
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _defectImage != null
                          ? Stack(
                              children: [
                                Positioned.fill(child: Image.file(_defectImage!, fit: BoxFit.cover)),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () => setState(() => _defectImage = null),
                                  ),
                                ),
                              ],
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                                  Text("Tap to take photo"),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // Submit Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                  onPressed: _submitRequest,
                  child: Text(appProvider.submitReport, style: const TextStyle(fontSize: 18)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(Map<String, dynamic> item, int index, bool isEnglish, AppProvider appProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // Pass / Fail Buttons
            Row(
              children: [
                // Pass Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _checklistItems[index]['status'] = 'pass';
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: item['status'] == 'pass' ? Colors.green : null,
                      foregroundColor: item['status'] == 'pass' ? Colors.white : Colors.green,
                      side: const BorderSide(color: Colors.green),
                    ),
                    child: Text(appProvider.itemPass),
                  ),
                ),
                const SizedBox(width: 10),
                // Fail Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _checklistItems[index]['status'] = 'fail';
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: item['status'] == 'fail' ? Colors.red : null,
                      foregroundColor: item['status'] == 'fail' ? Colors.white : Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: Text(appProvider.itemFail),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Notes Input
            TextField(
              decoration: InputDecoration(
                hintText: appProvider.itemNotes,
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.all(10),
              ),
              onChanged: (val) {
                _checklistItems[index]['notes'] = val;
              },
            ),
          ],
        ),
      ),
    );
  }
}