import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../models/service_item.dart';
import '../providers/app_provider.dart';
import '../providers/request_provider.dart';
import 'request_details_screen.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  // Placeholder Construction Images (Replace these URLs with your real hosted images)
  final List<String> bannerImages = const [
    "https://images.unsplash.com/photo-1541888946425-d81bb19240f5?auto=format&fit=crop&w=800&q=80", // Construction
    "https://images.unsplash.com/photo-1504307651254-35680f356dfd?auto=format&fit=crop&w=800&q=80", // Architect
    "https://images.unsplash.com/photo-1581094794329-c8112a89af12?auto=format&fit=crop&w=800&q=80", // Blueprint
  ];

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final requestProvider = Provider.of<RequestProvider>(context);
    final isEnglish = appProvider.isEnglish;

    return Scaffold(
      // --- TASK 3: LOGO IN APP BAR ---
      appBar: AppBar(
        title: Row(
          children: [
            // You can use an Image.asset here if you have a logo file in assets
            const Icon(Icons.engineering, color: AppColors.white), 
            const SizedBox(width: 10),
            Text(isEnglish ? "Chayekly" : "شايكلي", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show Brief/About dialog
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(isEnglish ? "About Us" : "من نحن"),
                  content: Text(isEnglish 
                      ? "Chayekly provides top-tier engineering inspection services using expert engineers and advanced technology to ensure your property is safe and sound."
                      : "شايكلي تخدمك بأفضل خدمات فحص الهندسة باستخدام خبراء ومعدات متطورة لضمان سلامة ممتلكاتك."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // --- TASK 5: DYNAMIC CONSTRUCTION IMAGES CAROUSEL ---
          SizedBox(
            height: 200,
            width: double.infinity,
            child: PageView.builder(
              itemCount: bannerImages.length,
              itemBuilder: (context, index) {
                return Image.network(
                  bannerImages[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.broken_image)),
                  ),
                );
              },
            ),
          ),
          
          // --- TASK 5: SERVICE BRIEF ---
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              children: [
                Text(isEnglish ? "Our Expertise" : "خبرتنا", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 5),
                Text(
                  isEnglish 
                      ? "We inspect structural integrity, electrical systems, plumbing, and finishing quality to ensure your investment is secure."
                      : "نفحص السلامة الهيكلية، الأنظمة الكهربائية، والسباكة وجودة التشطيبات لضمان أمان استثمارك.",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Instructions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              isEnglish 
                  ? "Choose the inspection items you need:" 
                  : "اختر عناصر الفحص التي تحتاجها:",
              style: const TextStyle(fontSize: 16, color: AppColors.text),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Services Grid (Unchanged from before)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('services').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text(isEnglish ? "No services found" : "لا توجد خدمات"));
                }

                final services = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final doc = services[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    final service = ServiceItem(
                      id: doc.id,
                      nameEn: data['name_en'] ?? 'Unknown',
                      nameAr: data['name_ar'] ?? 'غير معروف',
                      price: (data['price'] ?? 0).toDouble(),
                      icon: Icons.construction,
                    );
                    
                    final isSelected = requestProvider.selectedServiceIds.contains(service.id);

                    return ServiceCard(
                      service: service,
                      isSelected: isSelected,
                      onTap: () => requestProvider.toggleService(service.id),
                      isEnglish: isEnglish,
                    );
                  },
                );
              },
            ),
          ),

          // Total Price Bar (Unchanged)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isEnglish ? "Subtotal:" : "المجموع الفرعي:"),
                    Text("${requestProvider.totalPrice.toStringAsFixed(0)} EGP"),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isEnglish ? "Service Fee (10%):" : "رسوم الخدمة (10%):"),
                    Text("${requestProvider.serviceFee.toStringAsFixed(0)} EGP"),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEnglish ? "Total:" : "الإجمالي:",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      "${requestProvider.finalTotal.toStringAsFixed(0)} EGP",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18, 
                        color: AppColors.secondary
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: requestProvider.selectedServiceIds.isEmpty
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RequestDetailsScreen()),
                            );
                          },
                    child: Text(isEnglish ? "Next Step" : "الخطوة التالية"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ServiceCard Widget (Keep as is)
class ServiceCard extends StatelessWidget {
  final ServiceItem service;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isEnglish;

  const ServiceCard({
    super.key,
    required this.service,
    required this.isSelected,
    required this.onTap,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              service.icon,
              size: 40,
              color: isSelected ? AppColors.primary : AppColors.grey,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                isEnglish ? service.nameEn : service.nameAr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : AppColors.text,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "${service.price.toStringAsFixed(0)} EGP",
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}