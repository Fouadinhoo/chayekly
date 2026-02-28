import 'package:flutter/material.dart';

class ServiceItem {
  final String id;
  final String nameEn;
  final String nameAr;
  final double price; // Base price in EGP
  final IconData icon;

  ServiceItem({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.price,
    required this.icon,
  });
}