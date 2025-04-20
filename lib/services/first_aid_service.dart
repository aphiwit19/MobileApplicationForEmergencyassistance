import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/first_aid_model.dart';

class FirstAidService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('first_aid');

  // ดึงข้อมูลการปฐมพยาบาลทั้งหมด
  Stream<List<FirstAidModel>> getFirstAidList() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return FirstAidModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // อัปโหลดข้อมูลการปฐมพยาบาล
  Future<void> addFirstAid(FirstAidModel firstAid) async {
    await _collection.doc(firstAid.title).set(firstAid.toMap());
  }
}