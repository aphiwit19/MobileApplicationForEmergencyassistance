import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ballauto/services/sms_service.dart';
import 'package:ballauto/services/contact_service.dart';
import 'package:ballauto/services/user_service.dart';
import 'package:ballauto/model/sos_history.dart';
import 'package:ballauto/model/user_profile.dart';

class SosService {
  final SmsService _smsService = SmsService();
  final ContactService _contactService = ContactService();
  final UserService _userService = UserService();
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

      // ดึงตำแหน่งปัจจุบัน
      final position = await _getCurrentPosition();
      final locationMessage =
          "ตำแหน่งปัจจุบัน: https://www.google.com/maps?q=${position.latitude},${position.longitude}";

      // ดึงข้อมูลผู้ใช้
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('ไม่พบผู้ใช้ที่ล็อกอิน');
      final UserProfile? profileTmp = await _userService.getUserProfile(user.uid);
      if (profileTmp == null) throw Exception('ไม่พบข้อมูลโปรไฟล์ผู้ใช้');
      final UserProfile profile = profileTmp;

      // สร้างข้อความ SOS
      final String helpHeader = "ขอความช่วยเหลือฉุกเฉิน\nชื่อ: ${profile.name}\nเบอร์: ${profile.phone}\nเพศ: ${profile.gender ?? 'ไม่ระบุ'}\nกรุ๊ปเลือด: ${profile.bloodType ?? 'ไม่ระบุ'}\nโรคประจำตัว: ${profile.disease}\nอาการแพ้: ${profile.allergy}";
      final message = "$helpHeader\n$locationMessage";

      // ส่ง SMS
      await _smsService.sendSms(phoneNumbers, message);

      // บันทึกประวัติการแจ้งเหตุ
      final sosHistory = SosHistory(
        timestamp: DateTime.now(),
        phoneNumbers: phoneNumbers,
        status: 'success',
        message: message,
        userName: profile.name,
        userPhone: profile.phone,
        userGender: profile.gender,
        userBloodType: profile.bloodType,
        userDisease: profile.disease,
        userAllergy: profile.allergy,
      );
      await _userCollection
          .doc(user.uid)
          .collection('sos_history')
          .add(sosHistory.toMap());
    } catch (e) {
      // บันทึกประวัติเมื่อเกิดข้อผิดพลาด
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final profile = await _userService.getUserProfile(user.uid)
            ?? UserProfile(name: '', phone: '', gender: null, bloodType: null, disease: '', allergy: '');
        final sosHistory = SosHistory(
          timestamp: DateTime.now(),
          phoneNumbers: [],
          status: 'failed',
          message: "การส่งข้อความล้มเหลว",
          userName: profile.name,
          userPhone: profile.phone,
          userGender: profile.gender,
          userBloodType: profile.bloodType,
          userDisease: profile.disease,
          userAllergy: profile.allergy,
        );
        await _userCollection
            .doc(user.uid)
            .collection('sos_history')
            .add(sosHistory.toMap());
      }
      rethrow; // ส่งข้อผิดพลาดกลับไป
    }
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // ตรวจสอบว่า Location Service เปิดอยู่หรือไม่
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // ตรวจสอบสิทธิ์การเข้าถึงตำแหน่ง
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // ดึงตำแหน่งปัจจุบัน
    return await Geolocator.getCurrentPosition();
  }
}