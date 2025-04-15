import 'package:ballauto/Sceen/BottomNavigationBar/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';


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
      body: const Center(
        child: Text(
          'หน้าสำหรับเมนู',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1, // MenuScreen อยู่ที่ index 2
        onTap: (index) {},
      ),
    );
  }
}