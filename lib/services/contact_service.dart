import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/contact.dart';

class ContactService {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  // เพิ่มผู้ติดต่อ
  Future<void> addContact(String name, String phone) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('กรุณาล็อกอินก่อน');
      }

      // ตรวจสอบจำนวนผู้ติดต่อที่มีอยู่
      final contactsSnapshot = await _userCollection
          .doc(user.uid)
          .collection('contacts')
          .get();
      if (contactsSnapshot.docs.length >= 5) {
        throw Exception('ไม่สามารถเพิ่มผู้ติดต่อได้ เกินจำนวนสูงสุด 5 รายชื่อ');
      }

      // สร้าง Contact object
      final contact = Contact(
        name: name,
        phone: phone,
        addedAt: DateTime.now(),
      );

      // สร้าง ID ที่ไม่ซ้ำสำหรับผู้ติดต่อ (ใช้ timestamp หรือวิธีอื่น)
      final contactId = DateTime.now().millisecondsSinceEpoch.toString();

      // เพิ่มผู้ติดต่อใน Firestore
      await _userCollection
          .doc(user.uid)
          .collection('contacts')
          .doc(contactId)
          .set(contact.toMap());
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการเพิ่มผู้ติดต่อ: $e');
    }
  }

  // ดึงรายชื่อผู้ติดต่อ
  Future<List<Contact>> getContacts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('กรุณาล็อกอินก่อน');
      }

      final query = await _userCollection
          .doc(user.uid)
          .collection('contacts')
          .orderBy('addedAt', descending: true)
          .get();

      return query.docs
          .map((doc) => Contact.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการดึงรายชื่อผู้ติดต่อ: $e');
    }
  }

  // ลบผู้ติดต่อ
  Future<void> deleteContact(String contactId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('กรุณาล็อกอินก่อน');
      }

      await _userCollection
          .doc(user.uid)
          .collection('contacts')
          .doc(contactId)
          .delete();
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการลบผู้ติดต่อ: $e');
    }
  }

  // แก้ไขชื่อผู้ติดต่อ
  Future<void> updateContactName(String contactId, String newName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('กรุณาล็อกอินก่อน');
      }

      await _userCollection
          .doc(user.uid)
          .collection('contacts')
          .doc(contactId)
          .update({'name': newName});
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการแก้ไขชื่อผู้ติดต่อ: $e');
    }
  }
}