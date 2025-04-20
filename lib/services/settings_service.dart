import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyEnableFall = 'enable_fall_detection';

  /// อ่านค่าการตรวจจับการล้ม (default: เปิด)
  static Future<bool> isFallDetectionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEnableFall) ?? true;
  }

  /// บันทึกค่าการตรวจจับการล้ม
  static Future<void> setFallDetectionEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnableFall, enabled);
  }
}
