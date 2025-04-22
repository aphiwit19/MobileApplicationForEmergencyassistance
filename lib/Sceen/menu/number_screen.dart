import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NumberScreen extends StatelessWidget {
  const NumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ส่วน AppBar
      appBar: AppBar(
        title: const Text(
          'เบอร์โทรฉุกเฉิน',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(230, 70, 70, 1),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[200],

      // ส่วน Body
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('emergency_numbers')
                .snapshots(),
        builder: (context, snapshot) {
          // กรณีข้อมูลกำลังโหลด
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // กรณีไม่มีข้อมูล
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('ไม่มีข้อมูลเบอร์โทรฉุกเฉิน'));
          }

          // ดึงข้อมูลจาก Firestore
          final docs = snapshot.data!.docs;

          // จัดกลุ่มข้อมูลตามหมวดหมู่
          final grouped = _groupDataByCategory(docs);

          // สร้างรายการ Widget
          final items = _buildGroupedItems(grouped);

          // แสดงรายการทั้งหมดใน ListView
          return ListView(children: items);
        },
      ),
    );
  }

  // ฟังก์ชันจัดกลุ่มข้อมูลตามหมวดหมู่
  Map<String, List<Map<String, dynamic>>> _groupDataByCategory(
    List<QueryDocumentSnapshot> docs,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final category = data['category'] as String;
      grouped.putIfAbsent(category, () => []).add(data);
    }
    return grouped;
  }

  // ฟังก์ชันสร้างรายการ Widget สำหรับแต่ละกลุ่ม
  List<Widget> _buildGroupedItems(
    Map<String, List<Map<String, dynamic>>> grouped,
  ) {
    final List<Widget> items = [];
    // จัดเรียงหมวดหมู่ตามลำดับที่กำหนด
    final orderedCategories = [
      'แจ้งเหตุด่วนเหตุร้าย',
      'การแพทย์และโรงพยาบาล',
      'หน่วยงานและองค์กรทั่วไป',
      'การท่องเที่ยว',
    ];
    final keys = [
      ...orderedCategories.where((k) => grouped.containsKey(k)),
      ...grouped.keys.where((k) => !orderedCategories.contains(k)),
    ];
    for (var category in keys) {
      final list = grouped[category]!;
      // เพิ่มชื่อหมวดหมู่
      items.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: _getCategoryColor(category),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );

      // เพิ่มรายการเบอร์โทรในแต่ละหมวดหมู่
      for (var data in list) {
        items.add(
          Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.phone, color: Colors.red),
              title: Text(data['name']),
              trailing: Text(
                data['number'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              onTap: () async {
                final uri = Uri(scheme: 'tel', path: data['number']);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
            ),
          ),
        );
      }
    }
    return items;
  }

   // ฟังก์ชันกำหนดสีพื้นหลังตามหมวดหมู่
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'การแพทย์และโรงพยาบาล':
        return Colors.blueAccent;
      case 'แจ้งเหตุด่วนเหตุร้าย':
        return Colors.redAccent;
      case 'หน่วยงานและองค์กรทั่วไป':
        return Colors.orangeAccent;
      case 'การท่องเที่ยว':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
