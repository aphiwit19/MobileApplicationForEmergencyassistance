import 'package:ballauto/Sceen/menu/firstaid_screen.dart';
import 'package:ballauto/Sceen/menu/location_screen.dart';
import 'package:ballauto/Sceen/menu/number_screen.dart';
import 'package:flutter/material.dart';
import 'package:ballauto/Sceen/BottomNavigationBar/bottom_navigation_bar.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'เมนู',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(230, 70, 70, 1),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('บริการฉุกเฉินใกล้ฉัน'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LocationScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('เบอร์โทรฉุกเฉิน'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NumberScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.health_and_safety),
            title: const Text('ปฐมพยาบาลเบื้องต้น'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FirstAidScreen()),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1, // MenuScreen อยู่ที่ index 2
        onTap: (index) {},
      ),
    );
  }
}

