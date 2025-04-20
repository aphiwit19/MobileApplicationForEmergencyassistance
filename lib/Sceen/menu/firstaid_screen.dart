import 'package:flutter/material.dart';
import '../../services/first_aid_service.dart';
import '../../model/first_aid_model.dart';

class FirstAidScreen extends StatelessWidget {
  const FirstAidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirstAidService service = FirstAidService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ปฐมพยาบาลเบื้องต้น',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(230, 70, 70, 1),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<FirstAidModel>>(
        stream: service.getFirstAidList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ไม่มีข้อมูลการปฐมพยาบาล'));
          }
          final firstAidList = snapshot.data!;
          return ListView.builder(
            itemCount: firstAidList.length,
            itemBuilder: (context, index) {
              final firstAid = firstAidList[index];
              return ListTile(
                title: Text(firstAid.title),
                subtitle: Text(firstAid.description),
              );
            },
          );
        },
      ),
    );
  }
}