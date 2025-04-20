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
  StreamSubscription<AccelerometerEvent>? _accSubscription;
  StreamSubscription<GyroscopeEvent>? _gyrSubscription;
  double _lastAccMag = 0.0;
  double _lastGyroMag = 0.0;
  DateTime? _lastFallTime;

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
      onFallDetected();
    }
  }

  /// Stop listening and reset detection state.
  void stopListening() {
    _accSubscription?.cancel();
    _gyrSubscription?.cancel();
    _accSubscription = null;
    _gyrSubscription = null;
    _lastAccMag = 0.0;
    _lastGyroMag = 0.0;
    _lastFallTime = null;
  }
}
