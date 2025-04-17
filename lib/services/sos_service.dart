import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ballauto/services/sms_service.dart';
import 'package:ballauto/services/contact_service.dart';
import 'package:ballauto/model/sos_history.dart';

class SosService {
  final SmsService _smsService = SmsService();
  final ContactService _contactService = ContactService();
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> sendSos() async {
    try {
      // ดึงรายชื่อผู้ติดต่อ
      final contacts = await _contactService.getContacts();
      if (contacts.isEmpty) {
        throw Exception('ไม่พบผู้ติดต่อ');
      }

      // ดึงหมายเลขโทรศัพท์
      final phoneNumbers = contacts.map((contact) => contact.phone).toList();

      // สร้างข้อความ SOS
      final user = FirebaseAuth.instance.currentUser;
      final message = user != null
          ? "แจ้งเหตุฉุกเฉินจาก ${user.email ?? 'ผู้ใช้'} กรุณาติดต่อกลับด่วน!"
          : "แจ้งเหตุฉุกเฉิน กรุณาติดต่อกลับด่วน!";

      // ส่ง SMS
      await _smsService.sendSms(phoneNumbers, message);

      // บันทึกประวัติการแจ้งเหตุ
      if (user != null) {
        final sosHistory = SosHistory(
          timestamp: DateTime.now(),
          phoneNumbers: phoneNumbers,
          status: 'success',
          message: message,
        );
        await _userCollection
            .doc(user.uid)
            .collection('sos_history')
            .add(sosHistory.toMap());
      }
    } catch (e) {
      // บันทึกประวัติเมื่อเกิดข้อผิดพลาด
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final sosHistory = SosHistory(
          timestamp: DateTime.now(),
          phoneNumbers: [],
          status: 'failed',
          message: "การส่งข้อความล้มเหลว",
        );
        await _userCollection
            .doc(user.uid)
            .collection('sos_history')
            .add(sosHistory.toMap());
      }
      rethrow; // ส่งข้อผิดพลาดกลับไป
    }
  }
}