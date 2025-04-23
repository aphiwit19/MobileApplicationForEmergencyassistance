import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ballauto/services/sos_service.dart';
import 'package:ballauto/main.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Service using Flutter Local Notifications for system alerts
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  /// Initialize local notifications for Android and iOS
  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _handleNotificationResponse,
    );
    // Create notification channel on Android and request permission
    if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      // Explicitly create channel for fall detection alerts
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'fall_channel', 
          'Fall Detection',
          description: 'Channel for fall detection alerts',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
      // Request runtime permission on Android 13+
      await androidPlugin?.requestNotificationsPermission();
    }
    // Handle notification action if app was launched via notification
    final details = await _notifications.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      final response = details!.notificationResponse;
      if (response != null) {
        await _handleNotificationResponse(response);
      }
    }
  }

  /// Handle action button taps: show SnackBar and send SOS
  @pragma('vm:entry-point')
  static Future<void> _handleNotificationResponse(NotificationResponse response) async {
    debugPrint('NotificationResponse: actionId=${response.actionId}');
    // Cancel any running countdown timer for this notification
    _countdownTimers[response.id]?.cancel();
    _countdownTimers.remove(response.id);
    if (response.actionId == 'confirm') {
      // Show in-app feedback
      //rootScaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('กำลังส่ง SOS...')));
      // Also show system notification status
      await showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'กำลังส่ง SOS...',
        body: 'กำลังส่งข้อความแจ้งเหตุ...',
        includeActions: false,
      );
      try {
        await SosService().sendSos();
        // Success feedback
        rootScaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('ส่ง SOS สำเร็จ'), backgroundColor: Colors.green));
        await showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: 'ส่ง SOS สำเร็จ',
          body: 'ข้อความแจ้งเหตุถูกส่งเรียบร้อย',
          includeActions: false,
        );
      } catch (e) {
        debugPrint('Error sending SOS: $e');
        rootScaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('ส่ง SOS ล้มเหลว'), backgroundColor: Colors.red));
        await showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: 'ส่ง SOS ล้มเหลว',
          body: 'ไม่สามารถส่งข้อความแจ้งเหตุ',
          includeActions: false,
        );
      }
    } else if (response.actionId == 'cancel') {
      // User canceled; timer canceled above
      rootScaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text('ยกเลิกสำเร็จ'), backgroundColor: Colors.orange));
      await showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'ยกเลิกสำเร็จ',
        body: 'คุณได้ยกเลิกการแจ้งเหตุ',
        includeActions: false,
      );
    }
  }

  /// Start SOS countdown with vibration. Auto-send if not canceled.
  static void startSosCountdown({int seconds = 10}) {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int remaining = seconds;
    // แสดง notification เริ่มนับถอยหลัง
    showNotification(
      id: id,
      title: 'Fall Detected',
      body: 'ระบบจะแจ้งเหตุเมื่อหมดเวลานับถอยหลัง $remaining วินาที',
    );
    HapticFeedback.vibrate();
    // นับถอยหลังทุกวินาที
    final timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      remaining--;
      if (remaining > 0) {
        await showNotification(
          id: id,
          title: 'Fall Detected',
          body: 'ระบบจะแจ้งเหตุเมื่อหมดเวลานับถอยหลัง $remaining วินาที',
        );
        HapticFeedback.vibrate();
      } else {
        timer.cancel();
        _countdownTimers.remove(id);
        // ยกเลิก notification เก่าเพื่อรีเฟรชเนื้อหา
        await _notifications.cancel(id);
        // แสดง notification สรุปการส่ง
        await showNotification(
          id: id,
          title: 'ส่ง SOS อัตโนมัติ',
          body: 'ไม่มีการยกเลิก จึงส่ง SOS อัตโนมัติ',
          includeActions: false,
        );
        // สั่งส่ง SOS ใน background โดยไม่รอผล
        unawaited(SosService().sendSos());
      }
    });
    _countdownTimers[id] = timer;
  }

  /// Show a notification with given [id], [title], and [body]
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    bool includeActions = true,
  }) async {
    final androidDetails = includeActions
        ? AndroidNotificationDetails(
            'fall_channel',
            'Fall Detection',
            channelDescription: 'Channel for fall detection alerts',
            importance: Importance.max,
            priority: Priority.high,
            actions: <AndroidNotificationAction>[
              AndroidNotificationAction('confirm', 'ยืนยัน', showsUserInterface: true, cancelNotification: true),
              AndroidNotificationAction('cancel', 'ยกเลิก', showsUserInterface: true, cancelNotification: true),
            ],
          )
        : AndroidNotificationDetails(
            'fall_channel',
            'Fall Detection',
            channelDescription: 'Channel for fall detection alerts',
            importance: Importance.max,
            priority: Priority.high,
          );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _notifications.show(id, title, body, details);
  }

  // Active countdown timers keyed by notification id
  static final Map<int, Timer> _countdownTimers = {};
}
