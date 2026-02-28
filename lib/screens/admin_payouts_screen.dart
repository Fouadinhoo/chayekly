import 'package:flutter/material.dart';

class AdminPayoutsScreen extends StatefulWidget {
  const AdminPayoutsScreen({super.key});

  @override
  State<AdminPayoutsScreen> createState() => _AdminPayoutsScreenState();
}

class _AdminPayoutsScreenState extends State<AdminPayoutsScreen> {
  // Mock data representing the list of payouts.
  // The errors typically occur when data comes from a source like Firebase
  // where the map or its values can be null.
  final List<Map<String, dynamic>?> _payouts = [
    {
      'id': '1',
      'userName': 'John Doe',
      'amount': 150.00,
      'status': 'pending',
    },
    {
      'id': '2',
      'userName': 'Jane Smith',
      'amount': 320.50,
      'status': 'pending',
    },
    null, // Simulating a null entry to demonstrate the fix
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Payouts"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _payouts.length,
        itemBuilder: (context, index) {
          // Retrieve the data for the current item
          final Map<String, dynamic>? data = _payouts[index];

          // --- FIX FOR LINES 33, 34, 39: Unchecked use of nullable value ---
          // The receiver 'data' can be null. We must check if it is null before
          // using the '[]' operator.
          if (data == null) {
            return const Card(
              child: ListTile(
                title: Text("Invalid Payout Data"),
                leading: Icon(Icons.error_outline, color: Colors.red),
              ),
            );
          }

          // Line 33: Accessing 'userName'. Safe because we checked for null above.
          final String userName = data['userName'] ?? 'Unknown User';

          // Line 34: Accessing 'amount'. 
          // FIX FOR "unused local variable": We use 'total' in the UI below.
          final double total = (data['amount'] as num?)?.toDouble() ?? 0.0;

          // Line 39: Accessing 'status'. Safe because we checked for null above.
          final String status = data['status'] ?? 'Unknown';

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.account_balance_wallet),
              ),
              title: Text(
                userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  // FIX FOR "unused local variable": Using 'total' here.
                  Text(
                    "Amount: \$${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Status: ${status.toUpperCase()}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  _approvePayout(data['id'], userName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Pay"),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _approvePayout(String? payoutId, String userName) async {
    if (payoutId == null) return;

    // Simulate an async operation (e.g., API call or Database update)
    await Future.delayed(const Duration(seconds: 1));

    // --- FIX FOR LINE 50: Use BuildContext synchronously ---
    // We must check if the widget is still mounted before using the context
    // after an asynchronous gap.
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payout for $userName approved!"),
        backgroundColor: Colors.green,
      ),
    );
    
    // If you intended to navigate back, this is where it would go:
    // Navigator.pop(context);
  }
}