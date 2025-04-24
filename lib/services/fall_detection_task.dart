import 'dart:async';
import 'dart:isolate';
import 'dart:math';
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
  double _lastAccMag = 0.0;
  double _lastGyroMag = 0.0;
  DateTime? _lastFallTime;
  final double thresholdG = 5.0;
  final double thresholdGyro = 2.0;
  final Duration cooldown = const Duration(minutes: 1);

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _accSub = accelerometerEvents.listen((event) {
      _lastAccMag = sqrt(event.x * event.x + event.y * event.y + event.z * event.z) / 9.81;
      _tryDetect();
    });
    _gyrSub = gyroscopeEvents.listen((event) {
      _lastGyroMag = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      _tryDetect();
    });
  }

  /// ฟังก์ชันตรวจจับการล้มจากค่าเซ็นเซอร์
  Future<void> _tryDetect() async {
    final enabled = await SettingsService.isFallDetectionEnabled();
    if (!enabled) return;
    final now = DateTime.now();
    if (_lastAccMag >= thresholdG &&
        _lastGyroMag >= thresholdGyro &&
        (_lastFallTime == null || now.difference(_lastFallTime!) >= cooldown)) {
      _lastFallTime = now;
      await NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Fall Detected',
        body: 'ตรวจพบการล้ม!',
      );
      NotificationService.startSosCountdown(seconds: 10);
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
