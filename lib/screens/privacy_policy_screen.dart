import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart'; // Optional: Keep if you plan to make emails clickable later

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Privacy Policy", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text("Last updated: October 2023", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),
            Text(
              "At Chayekly, we take your privacy seriously. This policy describes how we collect and use your data.",
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 20),
            Text("1. Information We Collect", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("We collect information you provide directly to us, such as when you create an account, request a service, or communicate with us. This includes:\n- Name and contact information\n- Location data\n- Payment information\n- Photos you upload for inspection purposes."),
            SizedBox(height: 20),
            Text("2. How We Use Your Information", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("We use the information to process your requests, improve our services, and communicate with you regarding your inspection."),
            SizedBox(height: 20),
            Text("3. Security", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("We implement reasonable security measures to protect your information. However, no method of transmission over the Internet is 100% secure."),
            SizedBox(height: 40),
            Text("Contact Us", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("If you have any questions, contact us at support@chayekly.com"),
          ],
        ),
      ),
    );
  }
}