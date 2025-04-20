import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
          final numbers = snapshot.data!.docs;
          return ListView.builder(
            itemCount: numbers.length,
            itemBuilder: (context, index) {
              final data = numbers[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.phone),
                title: Text('${data['name']}: ${data['number']}'),
                subtitle: Text(data['category']),
              );
            },
          );
        },
      ),
    );
  }
}
