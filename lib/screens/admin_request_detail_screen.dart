import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/app_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;

class AdminRequestDetailScreen extends StatefulWidget {
  final Map<String, dynamic> requestData;
  final String requestId;
  const AdminRequestDetailScreen(
      {super.key, required this.requestData, required this.requestId});

  @override
  State<AdminRequestDetailScreen> createState() =>
      _AdminRequestDetailScreenState();
}

class _AdminRequestDetailScreenState extends State<AdminRequestDetailScreen> {
  String? _selectedEngineerId;
  String? _selectedEngineerName; // Store the name to save to DB

  // --- PDF GENERATION LOGIC ---

  Future<pw.MemoryImage> _networkImage(String url) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    return pw.MemoryImage(bytes);
  }

  Future<void> _generatePdf() async {
    final doc = pw.Document();

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final isEnglish = appProvider.isEnglish;

    pw.MemoryImage? clientImg;
    pw.MemoryImage? defectImg;

    if (widget.requestData['clientPhotoUrl'] != null) {
      try {
        clientImg = await _networkImage(widget.requestData['clientPhotoUrl']);
      } catch (e) {
        // Error handled silently or could use a logger
      }
    }

    if (widget.requestData['defectPhotoUrl'] != null) {
      try {
        defectImg = await _networkImage(widget.requestData['defectPhotoUrl']);
      } catch (e) {
        // Error handled silently or could use a logger
      }
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        isEnglish ? "Chayekly Inspection Report" : "تقرير فحص شايكلي",
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text("Professional Engineering Services",
                          style: pw.TextStyle(
                              fontSize: 12, color: PdfColors.grey)),
                    ],
                  ),
                  pw.Text("Date: ${DateTime.now().toString().split(' ')[0]}"),
                ],
              ),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),

              pw.Text(isEnglish ? "Client Information" : "معلومات العميل",
                  style:
                      pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Row(children: [
                pw.Expanded(
                    child: pw.Text(
                        "Name: ${widget.requestData['clientName'] ?? 'N/A'}")),
                pw.Expanded(
                    child: pw.Text(
                        "Phone: ${widget.requestData['clientPhone'] ?? 'N/A'}")),
              ]),
              pw.SizedBox(height: 5),
              pw.Text(
                  "Location: ${widget.requestData['location'] ?? 'N/A'}"),
              pw.SizedBox(height: 5),
              pw.Text(
                  "Property Type: ${widget.requestData['placeType'] ?? 'N/A'}"),
              pw.SizedBox(height: 20),

              pw.Text(isEnglish ? "Property & Inspection Photos" : "صور العقار والفحص",
                  style:
                      pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  if (clientImg != null)
                    pw.Expanded(
                      child: pw.Container(
                        height: 150,
                        margin: const pw.EdgeInsets.only(right: 5),
                        child: pw.Image(clientImg, fit: pw.BoxFit.cover),
                      ),
                    ),
                  if (defectImg != null)
                    pw.Expanded(
                      child: pw.Container(
                        height: 150,
                        margin: const pw.EdgeInsets.only(left: 5),
                        child: pw.Image(defectImg, fit: pw.BoxFit.cover),
                      ),
                    ),
                  if (clientImg == null && defectImg == null)
                    pw.Text("No photos attached.",
                        style: pw.TextStyle(color: PdfColors.grey)),
                ],
              ),
              pw.SizedBox(height: 20),

              pw.Text(isEnglish ? "Inspection Checklist" : "قائمة الفحص",
                  style:
                      pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              if (widget.requestData['checklistResults'] != null)
                pw.Table(
                  border:
                      pw.TableBorder.all(width: 1, color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(4),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Item',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Status',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Notes',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...(widget.requestData['checklistResults'] as List).map((item) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(item['title']?.toString() ?? ''),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                                item['status']?.toString().toUpperCase() ?? ''),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(item['notes']?.toString() ?? '-'),
                          ),
                        ],
                      );
                    }),
                  ],
                )
              else
                pw.Text(isEnglish
                    ? "No checklist data available."
                    : "لا توجد بيانات للفحص."),

              pw.Spacer(),

              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text("Generated by Chayekly App",
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) => doc.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isEnglish = appProvider.isEnglish;

    String status = widget.requestData['status'] ?? 'pending';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? "Request Details" : "تفاصيل الطلب"),
        backgroundColor: AppColors.primary,
      ),
      body: Directionality(
        textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Chip(
                    label: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor:
                        status == 'pending' ? Colors.orange : Colors.green,
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionTitle(
                    isEnglish ? "Client Information" : "بيانات العميل", context),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.person,
                    widget.requestData['clientName'] ?? 'Unknown', context),
                _buildInfoRow(Icons.phone,
                    widget.requestData['clientPhone'] ?? 'No Phone', context),
                _buildInfoRow(Icons.location_on,
                    widget.requestData['location'] ?? 'No Location', context),

                const SizedBox(height: 20),

                _buildSectionTitle(
                    isEnglish ? "Requested Services" : "الخدمات المطلوبة", context),
                const SizedBox(height: 10),

                if (widget.requestData['selectedServices'] != null)
                  ...List.generate(
                    (widget.requestData['selectedServices'] as List).length,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.secondary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              (widget.requestData['selectedServices']
                                      as List)[index]
                                  .toString(),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Text(isEnglish ? "No services selected" : "لم يتم اختيار خدمات"),

                const SizedBox(height: 20),

                // --- DYNAMIC ASSIGNMENT SECTION ---
                if (status == 'pending') ...[
                  _buildSectionTitle(
                      isEnglish ? "Assign Engineer" : "تعيين مهندس", context),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      // Fetch users where role is 'engineer'
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('role', isEqualTo: 'engineer')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                isEnglish ? "No engineers found" : "لا يوجد مهندسين"),
                          );
                        }

                        return DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: Text(
                                isEnglish ? "Select Engineer" : "اختر مهندس"),
                            value: _selectedEngineerId,
                            isExpanded: true,
                            items: snapshot.data!.docs.map((doc) {
                              return DropdownMenuItem<String>(
                                value: doc.id, // The UID
                                child: Text(doc['name'] ?? 'Unknown Engineer'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                // Find the document to get the name
                                final selectedDoc = snapshot.data!.docs
                                    .firstWhere((doc) => doc.id == val);
                                setState(() {
                                  _selectedEngineerId = val;
                                  _selectedEngineerName = selectedDoc['name'];
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Assign Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success),
                      onPressed: _selectedEngineerId != null
                          ? () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (ctx) =>
                                    const Center(child: CircularProgressIndicator()),
                              );

                              try {
                                await FirebaseFirestore.instance
                                    .collection('requests')
                                    .doc(widget.requestId)
                                    .update({
                                      'status': 'assigned',
                                      'assignedEngineerId': _selectedEngineerId,
                                      'assignedEngineerName':
                                          _selectedEngineerName, // Use fetched name
                                    });

                                if (mounted) Navigator.of(context).pop();

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isEnglish
                                              ? "Engineer Assigned Successfully!"
                                              : "تم تعيين المهندس بنجاح!"),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                if (mounted) Navigator.of(context).pop();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Error: $e")));
                                }
                              }
                            }
                          : null,
                      child: Text(appProvider.assignEngineer,
                          style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                ],

                // 2. COMPLETED: Show Download Report Button
                if (status == 'completed') ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: Text(
                          isEnglish ? "Download Report" : "تحميل التقرير"),
                      onPressed: _generatePdf,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}