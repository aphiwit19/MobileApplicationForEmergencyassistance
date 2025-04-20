import 'dart:async';
import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:ballauto/services/notification_service.dart';
import 'package:ballauto/services/settings_service.dart';

/// ฟังก์ชัน callback เริ่มต้นสำหรับ foreground service
void startCallback() {
  // ตั้ง TaskHandler ให้ FlutterForegroundTask รัน FallDetectionTaskHandler
  FlutterForegroundTask.setTaskHandler(FallDetectionTaskHandler());
}

/// คลาสจัดการงาน background สำหรับตรวจจับการล้ม
class FallDetectionTaskHandler extends TaskHandler {
  StreamSubscription<AccelerometerEvent>? _accSub;
  StreamSubscription<GyroscopeEvent>? _gyrSub;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    // เริ่มฟังค่า accelerometer
    _accSub = accelerometerEvents.listen((event) async {
      await _detectFall(event.x, event.y, event.z);
    });
    // เริ่มฟังค่า gyroscope
    _gyrSub = gyroscopeEvents.listen((event) async {
      await _detectFall(event.x, event.y, event.z);
    });
  }

  /// ฟังก์ชันตรวจจับการล้มจากค่าเซ็นเซอร์
  Future<void> _detectFall(double x, double y, double z) async {
    // อ่าน setting ก่อนดำเนินการตรวจจับ
    final enabled = await SettingsService.isFallDetectionEnabled();
    if (!enabled) return;
    final g = (x.abs() + y.abs() + z.abs()) / 9.81;
    debugPrint('FallDetectionTask: g=$g');
    if (g > 2.5) {
      // แสดง notification เมื่อตรวจจับการล้ม
      await NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Fall Detected',
        body: 'ตรวจพบการล้ม!',
      );
      debugPrint('Fall notification sent');
      // เริ่มนับถอยหลังแจ้งเหตุอัตโนมัติหากผู้ใช้เปิดฟีเจอร์
      if (enabled) {
        NotificationService.startSosCountdown(seconds: 10);
      }
    }
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    // สามารถใช้สำหรับงาน periodic ได้ ถ้าต้องการ
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // ยกเลิกการฟังเซ็นเซอร์เมื่อ service หยุดทำงาน
    await _accSub?.cancel();
    await _gyrSub?.cancel();
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {
    // ไม่ใช้ periodic event ในโค้ดนี้
  }
}
