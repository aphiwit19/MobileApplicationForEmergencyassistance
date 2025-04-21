import 'package:flutter/material.dart';
import '../../services/emergency_guide_service.dart';
import '../../model/emergency_guide_model.dart';

class EmergencyGuideScreen extends StatelessWidget {
  const EmergencyGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = EmergencyGuideService();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'คู่มือสถานการณ์ฉุกเฉิน',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(230, 70, 70, 1),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<EmergencyGuideModel>>(
        stream: service.getEmergencyGuides(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('ไม่มีข้อมูลคู่มือสถานการณ์ฉุกเฉิน'));
          }
          final guides = snapshot.data!;
          return ListView.builder(
            itemCount: guides.length,
            itemBuilder: (context, index) {
              final guide = guides[index];
              return ListTile(
                title: Text(guide.title),
                subtitle: Text(guide.description),
              );
            },
          );
        },
      ),
    );
  }
}
