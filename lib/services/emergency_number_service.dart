import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/emergency_number_model.dart'; // ตรวจสอบ path ให้ถูกต้อง

class EmergencyNumberService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('emergency_numbers');

  // ดึงข้อมูลเบอร์โทรฉุกเฉินทั้งหมด
  Stream<List<EmergencyNumberModel>> getEmergencyNumbers() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EmergencyNumberModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // อัปโหลดข้อมูลเบอร์โทรฉุกเฉิน
  Future<void> addEmergencyNumber(EmergencyNumberModel number) async {
    final id = number.name.replaceAll('/', '-');
    await _collection.doc(id).set(number.toMap());
  }
}