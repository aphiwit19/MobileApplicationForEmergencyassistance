import 'package:cloud_firestore/cloud_firestore.dart';

class SosHistory {
  final DateTime timestamp;
  final List<String> phoneNumbers; // เปลี่ยนจาก contactCount เป็น phoneNumbers
  final String status;
  final String message;
  final String userName;
  final String userPhone;
  final String? userGender;
  final String? userBloodType;
  final String userDisease;
  final String userAllergy;

  SosHistory({
    required this.timestamp,
    required this.phoneNumbers,
    required this.status,
    required this.message,
    required this.userName,
    required this.userPhone,
    required this.userGender,
    required this.userBloodType,
    required this.userDisease,
    required this.userAllergy,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'phoneNumbers': phoneNumbers, // บันทึกเป็น List
      'status': status,
      'message': message,
      'userName': userName,
      'userPhone': userPhone,
      'userGender': userGender,
      'userBloodType': userBloodType,
      'userDisease': userDisease,
      'userAllergy': userAllergy,
    };
  }

  factory SosHistory.fromMap(Map<String, dynamic> map) {
    return SosHistory(
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      phoneNumbers: List<String>.from(map['phoneNumbers'] ?? []), // ดึง List ของเบอร์
      status: map['status'] as String,
      message: map['message'] as String? ?? 'ไม่มีข้อความ',
      userName: map['userName'] as String? ?? '',
      userPhone: map['userPhone'] as String? ?? '',
      userGender: map['userGender'] as String?,
      userBloodType: map['userBloodType'] as String?,
      userDisease: map['userDisease'] as String? ?? '',
      userAllergy: map['userAllergy'] as String? ?? '',
    );
  }
}