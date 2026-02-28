import 'package:flutter/material.dart';
import '../models/service_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestProvider extends ChangeNotifier {
  // List to store services
  final List<ServiceItem> _services = [];

  // Get services from Firestore
  Stream<QuerySnapshot> getServicesStream() {
  return FirebaseFirestore.instance.collection('services').snapshots();
}

  // State to track selected service IDs
  final Set<String> _selectedServiceIds = {};

  Set<String> get selectedServiceIds => _selectedServiceIds;

  // Method to toggle selection
  void toggleService(String serviceId) {
    if (_selectedServiceIds.contains(serviceId)) {
      _selectedServiceIds.remove(serviceId);
    } else {
      _selectedServiceIds.add(serviceId);
    }
    notifyListeners();
  }

  // Calculate Total Price
  double get totalPrice {
    double total = 0;
    for (var service in _services) {
      if (_selectedServiceIds.contains(service.id)) {
        total += service.price;
      }
    }
    return total;
  }

  // Get selected service objects (for later use in form submission)
  List<ServiceItem> get selectedServices {
    return _services.where((s) => _selectedServiceIds.contains(s.id)).toList();
  }
  
  // App Percentage (e.g., 10% service fee)
  double get appPercentage => 0.10; 
  double get serviceFee => totalPrice * appPercentage;
  double get finalTotal => totalPrice + serviceFee;
}