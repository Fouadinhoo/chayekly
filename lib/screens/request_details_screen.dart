import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../core/constants.dart';
import '../providers/app_provider.dart';
import '../providers/request_provider.dart';
import 'payment_screen.dart'; // <--- IMPORT PAYMENT SCREEN

class RequestDetailsScreen extends StatefulWidget {
  const RequestDetailsScreen({super.key});

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // State variables
  String? _placeType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _paymentMethod = "Cash"; // Default

  // Image Upload Variables
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage; 

  // Map Variables
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  LatLng? _currentLocation;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation(); // Get GPS location on load
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // --- IMAGE LOGIC ---
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadImage(File image, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  // --- MAP LOGIC ---
  void _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  // --- SUBMIT LOGIC (UPDATED) ---
  void _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final requestProvider = Provider.of<RequestProvider>(context, listen: false);

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      try {
        String? imageUrl;

        // 1. Upload Image if selected
        if (_pickedImage != null) {
          String fileName = "req_${DateTime.now().millisecondsSinceEpoch}.jpg";
          imageUrl = await _uploadImage(_pickedImage!, "client_uploads/$fileName");
        }

        // 2. Prepare Data Map
        final requestData = {
          'clientName': _nameController.text,
          'clientPhone': _phoneController.text,
          'location': _locationController.text,
          'placeType': _placeType,
          'area': _areaController.text,
          'preferredDate': _selectedDate?.toIso8601String(),
          'preferredTime': _selectedTime?.format(context),
          'paymentMethod': _paymentMethod, // 'Cash' or 'Card'
          'notes': _notesController.text,
          'selectedServices': requestProvider.selectedServiceIds.toList(),
          'totalPrice': requestProvider.finalTotal,
          'status': 'pending', // Default pending
          'createdAt': DateTime.now(),
          'clientPhotoUrl': ?imageUrl,
        };

        // 3. Handle Logic Based on Payment Method
        if (_paymentMethod == "Cash") {
          // --- CASH FLOW ---
          // Save to Firestore immediately
          await FirebaseFirestore.instance.collection('requests').add(requestData);

          if (mounted) Navigator.of(context).pop(); // Close loader

          if (mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(appProvider.successTitle),
                content: Text(appProvider.successMsg),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      if (mounted) Navigator.of(context).pop(); // Go back to home
                    },
                    child: const Text("OK"),
                  )
                ],
              ),
            );
          }
        } else {
          // --- CARD FLOW ---
          // Save to Firestore first to get the Document ID, then navigate to Payment Screen
          // This ensures the request exists in the system before payment
          var docRef = await FirebaseFirestore.instance.collection('requests').add(requestData);
          
          if (mounted) Navigator.of(context).pop(); // Close loader

          if (mounted) {
            // Navigate to Payment Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentScreen(
                  amountToPay: requestProvider.finalTotal,
                  requestId: docRef.id, // Pass the ID to update payment status later
                ),
              ),
            );
          }
        }

      } catch (e) {
        if (mounted) Navigator.of(context).pop();
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isEnglish = appProvider.isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? "Request Details" : "تفاصيل الطلب"),
        backgroundColor: AppColors.primary,
      ),
      body: Directionality(
        textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Name
                _buildTextField(
                  controller: _nameController,
                  label: appProvider.nameLabel,
                  icon: Icons.person,
                  validator: (val) => val!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 15),

                // Phone
                _buildTextField(
                  controller: _phoneController,
                  label: appProvider.phoneLabel,
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (val) => val!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 15),

                // --- REAL GOOGLE MAP ---
                Text(appProvider.locationLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _currentLocation == null
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _currentLocation!,
                            zoom: 14.4746,
                          ),
                          markers: _markers,
                          onMapCreated: (GoogleMapController controller) {
                            _mapController.complete(controller);
                          },
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          onTap: (LatLng position) {
                            setState(() {
                              _markers = {
                                Marker(
                                  markerId: MarkerId('selected_loc'),
                                  position: position,
                                  infoWindow: InfoWindow(
                                    title: isEnglish ? "Selected Location" : "الموقع المحدد",
                                    snippet: "${position.latitude}, ${position.longitude}",
                                  ),
                                ),
                              };
                              _locationController.text = "Lat: ${position.latitude.toStringAsFixed(5)}, Lng: ${position.longitude.toStringAsFixed(5)}";
                            });
                          },
                        ),
                ),
                const SizedBox(height: 15),

                // Place Type
                DropdownButtonFormField<String>(
                  initialValue: _placeType,
                  decoration: InputDecoration(
                    labelText: appProvider.placeTypeLabel,
                    prefixIcon: const Icon(Icons.apartment),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [
                    isEnglish ? "Apartment" : "شقة",
                    isEnglish ? "Villa" : "فيلا",
                    isEnglish ? "Office" : "مكتب",
                    isEnglish ? "Shop" : "محل",
                    isEnglish ? "Factory" : "مصنع",
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _placeType = val),
                  validator: (val) => val == null ? "Required" : null,
                ),
                const SizedBox(height: 15),

                // Area
                _buildTextField(
                  controller: _areaController,
                  label: appProvider.areaLabel,
                  icon: Icons.square_foot,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),

                // Date Picker
                InkWell(
                  onTap: () => _selectDate(context),
                  child: _buildTextField(
                    controller: TextEditingController(
                      text: _selectedDate == null 
                          ? "" 
                          : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                    ),
                    label: appProvider.dateLabel,
                    icon: Icons.calendar_today,
                    enabled: false,
                  ),
                ),
                const SizedBox(height: 15),

                // Time Picker
                InkWell(
                  onTap: () => _selectTime(context),
                  child: _buildTextField(
                    controller: TextEditingController(
                      text: _selectedTime?.format(context) ?? "",
                    ),
                    label: appProvider.timeLabel,
                    icon: Icons.access_time,
                    enabled: false,
                  ),
                ),
                const SizedBox(height: 15),

                // --- PAYMENT METHOD SECTION ---
                Text(appProvider.paymentLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        // ignore: deprecated_member_use
                        title: Text(appProvider.cash),
                        value: "Cash",
                        groupValue: _paymentMethod,
                        onChanged: (val) => setState(() => _paymentMethod = val!),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        // ignore: deprecated_member_use
                        title: Text(appProvider.card),
                        value: "Card",
                        groupValue: _paymentMethod,
                        onChanged: (val) => setState(() => _paymentMethod = val!),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                
                // --- NEW: PROCEED TO PAYMENT BUTTON (Only shows if Card selected) ---
                if (_paymentMethod == "Card") ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                      icon: const Icon(Icons.payment),
                      label: const Text("Proceed to Payment"),
                      onPressed: _submitRequest, // Logic handles navigation
                    ),
                  ),
                  const SizedBox(height: 15),
                ],

                // Notes
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: appProvider.notesLabel,
                    prefixIcon: const Icon(Icons.note),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 15),

                // Image Upload Section
                Text("Property Photos", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _pickedImage != null
                        ? Stack(
                            children: [
                              Positioned.fill(
                                child: Image.file(_pickedImage!, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => setState(() => _pickedImage = null),
                                ),
                              ),
                            ],
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                              Text("Tap to add photo"),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 30),

                // Submit Button (Hidden if Card is selected, because user must use "Proceed to Payment")
                if (_paymentMethod == "Cash")
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitRequest,
                      child: Text(appProvider.submitLabel, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    IconData? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        filled: true,
        fillColor: enabled ? AppColors.white : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}