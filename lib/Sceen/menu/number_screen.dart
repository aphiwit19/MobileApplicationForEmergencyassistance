import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NumberScreen extends StatelessWidget {
  const NumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'เบอร์โทรฉุกเฉิน',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(230, 70, 70, 1),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('emergency_numbers')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('ไม่มีข้อมูลเบอร์โทรฉุกเฉิน'));
          }
          final docs = snapshot.data!.docs;
          final Map<String, List<Map<String, dynamic>>> grouped = {};
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final category = data['category'] as String;
            grouped.putIfAbsent(category, () => []).add(data);
          }
          final List<Widget> items = [];
          grouped.forEach((category, list) {
            items.add(Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ));
            for (var data in list) {
              items.add(ListTile(
                leading: const Icon(Icons.phone),
                title: Text("${data['name']}: ${data['number']}"),
                subtitle: Text(data['category']),
                onTap: () async {
                  final uri = Uri(scheme: 'tel', path: data['number']);
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
              ));
            }
          });
          return ListView(children: items);
        },
      ),
    );
  }
}
