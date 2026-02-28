import 'package:flutter/material.dart';
  import 'package:firebase_auth/firebase_auth.dart'; // Add this import at top


  
class AppProvider extends ChangeNotifier {
  // Language State
  bool isEnglish = true;

  void toggleLanguage() {
    isEnglish = !isEnglish;
    notifyListeners();
  }

  // Role State (Client, Admin, Engineer)
 String getUserRole(User? user) {
    if (user == null) return 'guest';
    
    String email = user.email ?? "";
    
   
    if (email.contains("engineer")) return 'engineer';
    return 'client';
  }


  // Auth State
  bool isLoggedIn = false;

  void login() {
    isLoggedIn = true;
    notifyListeners();
  }

  // --- General Labels ---
  String get welcomeText => isEnglish ? "Welcome to Chayekly" : "مرحباً بك في شايكلي";
  String get loginLabel => isEnglish ? "Login" : "تسجيل الدخول";
  String get emailHint => isEnglish ? "Email Address" : "البريد الإلكتروني";
  String get passHint => isEnglish ? "Password" : "كلمة المرور";
  String get loginBtn => isEnglish ? "Sign In" : "دخول";
  String get selectService => isEnglish ? "Select Inspection Service" : "اختر خدمة الفحص";
  
  // --- Form Labels ---
  String get nameLabel => isEnglish ? "Full Name" : "الاسم بالكامل";
  String get phoneLabel => isEnglish ? "Phone Number" : "رقم الهاتف";
  String get locationLabel => isEnglish ? "Location" : "الموقع";
  String get placeTypeLabel => isEnglish ? "Place Type" : "نوع العقار";
  String get areaLabel => isEnglish ? "Area (m²)" : "المساحة (متر)";
  String get dateLabel => isEnglish ? "Preferred Date" : "التاريخ المفضل";
  String get timeLabel => isEnglish ? "Preferred Time" : "الوقت المفضل";
  String get paymentLabel => isEnglish ? "Payment Method" : "طريقة الدفع";
  String get notesLabel => isEnglish ? "Additional Notes" : "ملاحظات إضافية";
  String get submitLabel => isEnglish ? "Submit Request" : "إرسال الطلب";
  String get cash => isEnglish ? "Cash" : "نقدي";
  String get card => isEnglish ? "Credit Card" : "بطاقة ائتمان";
  String get online => isEnglish ? "Online Wallet" : "محفظة إلكترونية";
  String get successTitle => isEnglish ? "Request Sent!" : "تم إرسال الطلب!";
  String get successMsg => isEnglish ? "Your request has been sent to the admin." : "تم إرسال طلبك إلى المسؤول.";

  // --- Admin Labels ---
  String get adminDash => isEnglish ? "Admin Dashboard" : "لوحة تحكم المشرف";
  String get pendingRequests => isEnglish ? "Pending Requests" : "الطلبات المعلقة";
  String get assignedRequests => isEnglish ? "Assigned Requests" : "الطلبات المعينة";
  String get viewDetails => isEnglish ? "View Details" : "عرض التفاصيل";
  String get assignEngineer => isEnglish ? "Assign Engineer" : "تعيين مهندس";
  String get status => isEnglish ? "Status" : "الحالة";
  String get pending => isEnglish ? "Pending" : "معلق";
  String get assigned => isEnglish ? "Assigned" : "معين";
  String get completed => isEnglish ? "Completed" : "مكتمل";

  // --- Engineer Labels ---
  String get engDash => isEnglish ? "Engineer Dashboard" : "لوحة المهندس";
  String get myJobs => isEnglish ? "My Assigned Jobs" : "المهام المسندة إلي";
  String get startInspection => isEnglish ? "Start Inspection" : "بدء الفحص";
  String get checklistTitle => isEnglish ? "Inspection Checklist" : "قائمة الفحص";
  String get itemPass => isEnglish ? "Pass" : "سليم";
  String get itemFail => isEnglish ? "Fail" : "عيوب";
  String get itemNotes => isEnglish ? "Notes" : "ملاحظات";
  String get submitReport => isEnglish ? "Submit Report" : "إرسال التقرير";
  String get reportSuccess => isEnglish ? "Report Submitted!" : "تم إرسال التقرير!";
}