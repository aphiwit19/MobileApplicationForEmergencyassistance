import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

/// Callback invoked when a fall is detected.
typedef FallDetectedCallback = void Function();

/// Service to listen for accelerometer and gyroscope events and detect falls.
class FallDetectionService {
  // Singleton pattern
  FallDetectionService._internal();
  static final FallDetectionService _instance = FallDetectionService._internal();
  factory FallDetectionService() => _instance;

  // Default thresholds
  final double thresholdG = 5;
  final double thresholdGyro = 2.0;
  final Duration cooldown = const Duration(minutes: 1);
  final double staticThreshold = 0.1; // ค่าความเร่งที่ถือว่าหยุดนิ่ง
  final Duration staticCheckDuration = const Duration(seconds: 5); // เวลาเช็คการหยุดนิ่ง

  StreamSubscription<AccelerometerEvent>? _accSubscription;
  StreamSubscription<GyroscopeEvent>? _gyrSubscription;
  double _lastAccMag = 0.0;
  double _lastGyroMag = 0.0;
  DateTime? _lastFallTime;
  Timer? _staticCheckTimer;

  /// Start listening to accelerometer and gyroscope and trigger [onFallDetected] when a fall occurs.
  void startListening({required FallDetectedCallback onFallDetected}) {
    _accSubscription = accelerometerEvents.listen((event) {
      _lastAccMag = sqrt(event.x * event.x + event.y * event.y + event.z * event.z) / 9.81;
      _tryDetect(onFallDetected);
    });
    _gyrSubscription = gyroscopeEvents.listen((event) {
      _lastGyroMag = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      _tryDetect(onFallDetected);
    });
  }

  void _tryDetect(FallDetectedCallback onFallDetected) {
    final now = DateTime.now();
    if (_lastAccMag >= thresholdG &&
        _lastGyroMag >= thresholdGyro &&
        (_lastFallTime == null || now.difference(_lastFallTime!) >= cooldown)) {
      _lastFallTime = now;
      // เริ่มเช็คการหยุดนิ่ง
      _startStaticCheck(onFallDetected);
    }
  }

  void _startStaticCheck(FallDetectedCallback onFallDetected) {
    // ยกเลิก timer เก่าถ้ามี
    _staticCheckTimer?.cancel();
    
    // เริ่ม timer ใหม่
    _staticCheckTimer = Timer(staticCheckDuration, () {
      // เช็คว่าหยุดนิ่งหรือไม่
      if ((_lastAccMag - 1.0).abs() < staticThreshold) {
        onFallDetected();
      }
    });
  }

  /// Stop listening and reset detection state.
  void stopListening() {
    _accSubscription?.cancel();
    _gyrSubscription?.cancel();
    _staticCheckTimer?.cancel();
    _accSubscription = null;
    _gyrSubscription = null;
    _staticCheckTimer = null;
    _lastAccMag = 0.0;
    _lastGyroMag = 0.0;
    _lastFallTime = null;
  }
}
