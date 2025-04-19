import 'package:ballauto/Sceen/BottomNavigationBar/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ballauto/services/notification_service.dart';
import 'sos_confirmation_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                "คุณต้องการความช่วยเหลือฉุกเฉิน ใช่ไหม55?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 80),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SosConfirmationScreen(),
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 216, 215, 1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(246, 135, 133, 1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(230, 70, 70, 1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    "SOS",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 80),
            Text(
              "กดปุ่ม SOS เพื่อขอความช่วยเหลือ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0, // Home อยู่ที่ index 0
        onTap: (index) {}, // ไม่ต้องทำอะไรเพิ่ม เพราะ _navigateToPage จัดการให้
      ),
    );
  }
}
