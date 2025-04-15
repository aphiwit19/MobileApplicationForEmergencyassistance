import 'package:ballauto/services/contact_service.dart';
import 'package:ballauto/services/sms_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SosConfirmationScreen extends StatefulWidget {
  const SosConfirmationScreen({super.key});

  @override
  State<SosConfirmationScreen> createState() => _SosConfirmationScreenState();
}

class _SosConfirmationScreenState extends State<SosConfirmationScreen> {
  int _countdown = 5;
  late Timer _timer;
  bool _isLoading = false;
  final ContactService _contactService = ContactService();
  final SmsService _smsService = SmsService();

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer.cancel();
        setState(() {
          _isLoading = true;
        });

        try {
          final contacts = await _contactService.getContacts();
          if (contacts.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ไม่พบผู้ติดต่อ'),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.pop(context);
            return;
          }

          // ตรวจสอบเครดิตก่อนส่ง
          final contactCount = contacts.length;
          final remainingCredit = await _smsService.checkCredit();
          if (contactCount > remainingCredit) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('เครดิตไม่เพียงพอ กรุณาเติมเครดิต'),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.pop(context);
            return;
          }

          // ส่ง SMS
          final phoneNumbers = contacts.map((contact) => contact.phone).toList();
          await _smsService.sendSms(phoneNumbers, "สวัดดีจาากแอพsos");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ส่ง SMS เรียบร้อยแล้ว'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เกิดข้อผิดพลาดในการส่ง SMS: $e'),
              backgroundColor: Colors.red,
            ),
          );
        } finally {
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                "ระบบจะแจ้งเหตุฉุกเฉินเมื่อหมดเวลานับถอยหลังหมด",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$_countdown',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(230, 70, 70, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            if (_isLoading)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            if (!_isLoading)
              ElevatedButton(
                onPressed: () {
                  _timer.cancel();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "ยกเลิก",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}