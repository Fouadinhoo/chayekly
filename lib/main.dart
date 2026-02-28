import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'core/constants.dart'; 
import 'providers/app_provider.dart'; 
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/engineer_dashboard_screen.dart';
import 'screens/client_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: const ChayeklyApp(),
    ),
  );
}

class ChayeklyApp extends StatelessWidget {
  const ChayeklyApp({super.key});

 @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Checking connection...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        // 2. No user logged in -> Show Login
        if (!snapshot.hasData) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(context), // Extract theme to a method or keep inline
            home: const LoginScreen(),
          );
        }

        // 3. User IS logged in -> Check Role
        final user = snapshot.data!;
        final role = appProvider.getUserRole(user);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(context),
          home: _getHomeScreen(role),
        );
      },
    );
  }

  // Helper to keep code clean
  ThemeData _buildTheme(BuildContext context) {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.secondary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _getHomeScreen(String role) {
    switch (role) {
      case 'admin':
        return const AdminDashboardScreen();
      case 'engineer':
        return const EngineerDashboardScreen();
      case 'client':
      default:
        return const ClientHomeScreen();
    }
  }
}