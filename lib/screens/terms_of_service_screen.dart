import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms of Service")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Terms of Service", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text(
              "By using the Chayekly application, you agree to comply with and be bound by the following terms and conditions.",
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 20),
            Text("1. Accounts", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account."),
            SizedBox(height: 20),
            Text("2. Services", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Chayekly provides inspection services. We reserve the right to modify or discontinue the service at any time without notice."),
            SizedBox(height: 20),
            Text("3. User Conduct", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("You agree not to use the service for any unlawful purpose or to solicit others to perform unlawful acts."),
            SizedBox(height: 40),
            Text("Contact", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("For inquiries, contact us at legal@chayekly.com"),
          ],
        ),
      ),
    );
  }
}