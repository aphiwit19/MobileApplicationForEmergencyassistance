import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

/// Callback invoked when a fall is detected.
typedef FallDetectedCallback = void Function();

/// Service to listen for accelerometer and gyroscope events and detect falls.
class FallDetectionService {
  final double thresholdG;
  final double thresholdGyro;
  final Duration cooldown;
  StreamSubscription<AccelerometerEvent>? _accSubscription;
  StreamSubscription<GyroscopeEvent>? _gyrSubscription;
  double _lastAccMag = 0.0;
  double _lastGyroMag = 0.0;
  DateTime? _lastFallTime;

  /// [thresholdG] is the minimum G-force to consider as a fall (default: 2.5g).
  /// [thresholdGyro] is the minimum gyroscope magnitude to consider as a fall (default: 2.0).
  /// [cooldown] is the duration to wait before detecting another fall (default: 1 minute).
  FallDetectionService({
    this.thresholdG = 5,
    this.thresholdGyro = 2.0,
    this.cooldown = const Duration(minutes: 1),
  });

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
