import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ballauto/services/notification_service.dart';
import 'package:ballauto/services/fall_detection_task.dart';
import 'package:ballauto/services/fall_detection_service.dart';
import 'package:geolocator/geolocator.dart';

// Removed AlertService. Use NotificationService.showFallAlert instead.

/// Initialize Firebase, notifications, foreground service, and fall detection listener
Future<void> initializeServices() async {
  // Initialize Firebase and local notifications
  await Firebase.initializeApp();
  await NotificationService.init();

  // Start/stop fall detection based on user login status
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      // Start background service
      FlutterForegroundTask.startService(
        notificationTitle: 'Fall Detection Running',
        notificationText: 'กำลังตรวจจับการล้มตลอดเวลา',
        callback: startCallback,
      );
      // UI-level detection
      FallDetectionService().startListening(onFallDetected: () {
        NotificationService.startSosCountdown(seconds: 10);
      });
    } else {
      // Stop services when logged out
      FallDetectionService().stopListening();
      FlutterForegroundTask.stopService();
    }
  });

  // Request location permission upfront
  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied.');
    }
  } catch (e) {
    debugPrint('Error requesting location permission: $e');
  }

  // Prepare foreground service for continuous fall detection
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'fall_service_channel',
      channelName: 'Fall Detection Service',
      channelDescription: 'รัน service ดักจับการล้มตลอดเวลา',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      iconData: const NotificationIconData(
        resType: ResourceType.mipmap,
        resPrefix: ResourcePrefix.ic,
        name: 'launcher',
      ),
    ),
    iosNotificationOptions: const IOSNotificationOptions(),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 1000,
      isOnceEvent: false,
      autoRunOnBoot: true,
    ),
  );
}
