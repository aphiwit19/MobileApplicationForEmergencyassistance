import 'package:cloud_firestore/cloud_firestore.dart';

class SosHistory {
  final DateTime timestamp;
  final List<String> phoneNumbers; // เปลี่ยนจาก contactCount เป็น phoneNumbers
  final String status;
  final String message;

  SosHistory({
    required this.timestamp,
    required this.phoneNumbers,
    required this.status,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'phoneNumbers': phoneNumbers, // บันทึกเป็น List
      'status': status,
      'message': message,
    };
  }

  factory SosHistory.fromMap(Map<String, dynamic> map) {
    return SosHistory(
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      phoneNumbers: List<String>.from(map['phoneNumbers'] ?? []), // ดึง List ของเบอร์
      status: map['status'] as String,
      message: map['message'] as String? ?? 'ไม่มีข้อความ',
    );
  }
}