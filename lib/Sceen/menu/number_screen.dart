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
    // จัดเรียงหมวดหมู่แบบไดนามิกตามตัวอักษร
    final keys = grouped.keys.toList()..sort((a, b) => a.compareTo(b));
    for (var category in keys) {
      final list = [...grouped[category]!]..sort((a, b) {
        final an = (a['name'] ?? '').toString();
        final bn = (b['name'] ?? '').toString();
        return an.compareTo(bn);
      });
      // เพิ่มชื่อหมวดหมู่
      items.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: _getDeterministicCategoryColor(category),
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

  // ฟังก์ชันกำหนดสีตามชื่อหมวดแบบ deterministic (หมวดเดียวกันได้สีเดิมเสมอ)
  Color _getDeterministicCategoryColor(String category) {
    final palette = <Color>[
      Colors.red,      // แดง
      Colors.blue,     // น้ำเงิน
      Colors.green,    // เขียว
      Colors.orange,   // ส้ม
      Colors.purple,   // ม่วง
      Colors.pink,     // ชมพู
      Colors.cyan,     // ฟ้า
    ];

    final hash = _fnv1aHash(category);
    final index = hash % palette.length;
    return palette[index];
  }

  // FNV-1a 32-bit hash เพื่อความคงที่ข้ามอุปกรณ์/รีสตาร์ท
  int _fnv1aHash(String input) {
    const int fnvPrime = 0x01000193; // 16777619
    const int offsetBasis = 0x811C9DC5; // 2166136261
    int hash = offsetBasis;
    for (int i = 0; i < input.length; i++) {
      hash ^= input.codeUnitAt(i);
      hash = (hash * fnvPrime) & 0xFFFFFFFF;
    }
    return hash;
  }
}