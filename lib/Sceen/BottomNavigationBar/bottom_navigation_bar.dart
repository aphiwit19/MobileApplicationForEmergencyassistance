import 'package:flutter/material.dart'; // นำเข้า Material Design Widgets

// CustomBottomNavigationBar เป็น Widget สำหรับแถบด้านล่าง
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex; // สถานะของไอคอนที่ถูกเลือก
  final Function(int) onTap; // ฟังก์ชันที่เรียกเมื่อผู้ใช้กดไอคอน

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // ฟังก์ชันสำหรับจัดการการนำทางตาม index
  void _navigateToPage(BuildContext context, int index) {
    final routes = [
      '/home',
      
      '/menu',
      '/contacts',
      '/profile',
    ];
    if (index != currentIndex) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        onTap(index); // เรียก onTap ที่ส่งเข้ามา
        _navigateToPage(context, index); // จัดการการนำทาง
      },
      selectedItemColor: Colors.redAccent,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'หน้าแรก',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'เมนู',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'ผู้ติดต่อ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'โปรไฟล์',
        ),
      ],
    );
  }
}