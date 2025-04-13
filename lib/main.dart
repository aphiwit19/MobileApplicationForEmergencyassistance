import 'package:ballauto/Sceen/chats/chat_screen.dart';
import 'package:ballauto/Sceen/home/home.dart';
import 'package:ballauto/Sceen/menu/menu_screen.dart';
import 'package:ballauto/Sceen/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Sceen/auth/login_screen.dart';
import 'Sceen/contact/contacts_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/':
            (context) => StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  return const Home(); // ไปที่หน้า Home แทน MainLayout
                } else {
                  return const LoginScreen();
                }
              },
            ),
        '/home': (context) => const Home(),
        '/chat': (context) => const ChatScreen(),
        '/menu': (context) => const MenuScreen(),
        '/contacts': (context) => const ContactsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
