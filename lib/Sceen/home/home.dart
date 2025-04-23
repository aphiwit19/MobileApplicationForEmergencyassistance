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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    "ต้องการขอความช่วยเหลือ หรือไม่?",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
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
                          boxShadow: [
                            BoxShadow(
                              color: Color(
                                0xFFE64646,
                              ).withOpacity(0.3), // สีของหมอก (เงา)
                              blurRadius: 20, // ความเบลอของหมอก
                              spreadRadius: 5, // การกระจายของหมอก
                              offset: Offset(
                                0,
                                10,
                              ), // ตำแหน่งของหมอก (0, 0 = รอบวงกลม)
                            ),
                          ],
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
                SizedBox(height: 100),
                Text(
                  "กดปุ่ม SOS เพื่อขอความช่วยเหลือ",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0, // Home อยู่ที่ index 0
        onTap: (index) {}, // ไม่ต้องทำอะไรเพิ่ม เพราะ _navigateToPage จัดการให้
      ),
    );
  }
}
