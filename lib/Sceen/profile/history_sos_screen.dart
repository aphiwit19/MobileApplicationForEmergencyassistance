import 'package:ballauto/Sceen/BottomNavigationBar/bottom_navigation_bar.dart';
import 'package:ballauto/model/sos_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistorySosScreen extends StatelessWidget {
  const HistorySosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'กรุณาล็อกอินก่อน',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ประวัติการแจ้งเหตุ',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(230, 70, 70, 1),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[200],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('sos_history')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'เกิดข้อผิดพลาดในการโหลดข้อมูล',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'ยังไม่มีประวัติการแจ้งเหตุ',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            );
          }

          final history = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final sosData = SosHistory.fromMap(
                history[index].data() as Map<String, dynamic>,
              );
              final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(sosData.timestamp);

              return Card(
                color: Colors.white,
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Icon(
                    sosData.status == 'success' ? Icons.check_circle : Icons.error,
                    color: sosData.status == 'success' ? Colors.green : Colors.red,
                    size: 40,
                  ),
                  title: Text(
                    'แจ้งเหตุเมื่อ: $formattedDate',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ส่งถึง: ${sosData.phoneNumbers.isNotEmpty ? sosData.phoneNumbers.join(', ') : 'ไม่มีผู้ติดต่อ'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        'สถานะ: ${sosData.status == 'success' ? 'สำเร็จ' : 'ล้มเหลว'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        'ข้อความ: ${sosData.message}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

    );
  }
}