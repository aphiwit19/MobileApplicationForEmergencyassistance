import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class SmsService {
  // ใส่ username และ password ของคุณ
  final String username = "apirebmp";
  final String password = "Aphiwit@2546"; // เปลี่ยนเป็นรหัสผ่าน THSMS ของคุณ
  final String baseUrl = "https://thsms.com/api/rest";

  Future<void> sendSms(List<String> phoneNumbers, String message) async {
    try {
      // ตรวจสอบและกรองเบอร์โทรศัพท์
      final formattedNumbers = phoneNumbers
          .map((phone) {
            // ลบช่องว่างและอักขระพิเศษ
            phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
            // ตรวจสอบว่าเบอร์ขึ้นต้นด้วย 0 และมีความยาว 10 หลัก
            if (phone.startsWith('0') && phone.length == 10) {
              return phone; // THSMS V1 ใช้รูปแบบ 0xxxxxxxxx เช่น 0628707868
            }
            return null; // ถ้าไม่ถูกต้อง คืนค่า null
          })
          .where((phone) => phone != null) // กรองเฉพาะเบอร์ที่ถูกต้อง
          .cast<String>()
          .toList();

      // ตรวจสอบว่าไม่มีเบอร์เลยหลังกรอง
      if (formattedNumbers.isEmpty) {
        throw Exception("ไม่มีเบอร์โทรศัพท์ที่ถูกต้องสำหรับส่ง SMS");
      }

      // THSMS V1 รองรับการส่ง SMS ทีละเบอร์เท่านั้น ดังนั้นต้องวนลูป
      for (String phone in formattedNumbers) {
        // สร้าง Query Parameters สำหรับส่ง SMS
        final queryParams = {
          "username": username,
          "password": password,
          "method": "send",
          "from": "Direct SMS", // ใช้ Sender Name ที่ THSMS รองรับ เช่น SMS
          "to": phone, // ส่งไปยังเบอร์ เช่น 0628707868
          "message": message, // ข้อความ เช่น "สวัดดีจาากแอพsos"
        };

        // ส่ง HTTP GET Request
        final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
        final response = await http.get(uri);

        if (response.statusCode == 200) {
          // THSMS V1 คืนค่า Response เป็น XML ต้องแปลง
          final document = xml.XmlDocument.parse(response.body);
          final status = document.findAllElements('status').first.text;
          if (status == "success") {
            print("SMS sent successfully to $phone: ${response.body}");
          } else {
            throw Exception("Failed to send SMS to $phone: ${response.body}");
          }
        } else {
          throw Exception("Failed to send SMS to $phone: ${response.statusCode} - ${response.body}");
        }
      }
    } catch (e) {
      throw Exception("Error sending SMS: $e");
    }
  }

  // ฟังก์ชันตรวจสอบเครดิต
  Future<double> checkCredit() async {
    try {
      // สร้าง Query Parameters สำหรับตรวจสอบเครดิต
      final queryParams = {
        "username": username,
        "password": password,
        "method": "credit",
      };

      // ส่ง HTTP GET Request
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // THSMS V1 คืนค่า Response เป็น XML ต้องแปลง
        final document = xml.XmlDocument.parse(response.body);
        final amount = document.findAllElements('amount').first.text;
        return double.parse(amount);
      } else {
        throw Exception("Failed to check credit: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Error checking credit: $e");
    }
  }
}