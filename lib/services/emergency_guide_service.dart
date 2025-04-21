import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/emergency_guide_model.dart';

class EmergencyGuideService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('emergency_guides');

  /// ดึงข้อมูลคู่มือสถานการณ์ฉุกเฉินทั้งหมดเป็น Stream
  Stream<List<EmergencyGuideModel>> getEmergencyGuides() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              EmergencyGuideModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// เพิ่มหรืออัปเดตเอกสารคู่มือสถานการณ์ฉุกเฉิน
  Future<void> addEmergencyGuide(EmergencyGuideModel guide) async {
    final id = guide.title.replaceAll('/', '-');
    await _collection.doc(id).set(guide.toMap());
  }
}
