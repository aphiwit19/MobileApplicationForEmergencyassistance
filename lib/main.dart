import 'package:ballauto/Sceen/home/home.dart';
import 'package:ballauto/Sceen/menu/menu_screen.dart';
import 'package:ballauto/Sceen/profile/profile_screen.dart';
import 'package:ballauto/Sceen/profile/history_sos_screen.dart';
import 'package:ballauto/scripts/seed_emergency_numbers.dart';
import 'package:ballauto/scripts/seed_first_aid.dart';
import 'package:ballauto/scripts/seed_emergency_guides.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Sceen/auth/login_screen.dart';
import 'Sceen/contact/contacts_screen.dart';
import 'package:ballauto/config/service_initializer.dart';

// Global key for showing SnackBar from any context
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeServices();  // Setup Firebase, notifications, service, and fall detection

  // await seedEmergencyNumbers(); // Seed emergency numbers into Firestore (optional) //ไม่ใช้ awiat เพราะต้องรอการโหลด ทำให้รันค้าง
  // await seedFirstAidData(); // Seed first aid data into Firestore (optional)
  // await seedEmergencyGuides(); // Seed emergency guides into Firestore (optional)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // กำหนด key สำหรับ ScaffoldMessenger
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  return const Home();
                } else {
                  return const LoginScreen();
                }
              },
            ),
        '/home': (context) => const Home(),
        '/menu': (context) => const MenuScreen(),
        '/contacts': (context) => const ContactsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/history_sos': (context) => const HistorySosScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}