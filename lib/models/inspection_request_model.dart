class InspectionRequest {
  final String requestId;
  final String clientId;
  final String clientName;
  final String clientPhone;
  final String locationAddress; // Storing string address for simplicity
  final double latitude;
  final double longitude;
  final String placeType; // Apartment, Villa, etc.
  final double area;
  final DateTime preferredDate;
  final String preferredTime;
  final List<String> selectedServices;
  final double totalPrice;
  final String paymentMethod;
  final String? notes;
  final String status; // 'pending', 'assigned', 'completed', 'cancelled'
  final String? assignedEngineerId;

  InspectionRequest({
    required this.requestId,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.locationAddress,
    required this.latitude,
    required this.longitude,
    required this.placeType,
    required this.area,
    required this.preferredDate,
    required this.preferredTime,
    required this.selectedServices,
    required this.totalPrice,
    required this.paymentMethod,
    this.notes,
    this.status = 'pending',
    this.assignedEngineerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'clientId': clientId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'locationAddress': locationAddress,
      'latitude': latitude,
      'longitude': longitude,
      'placeType': placeType,
      'area': area,
      'preferredDate': preferredDate.toIso8601String(),
      'preferredTime': preferredTime,
      'selectedServices': selectedServices,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'status': status,
      'assignedEngineerId': assignedEngineerId,
    };
  }
}