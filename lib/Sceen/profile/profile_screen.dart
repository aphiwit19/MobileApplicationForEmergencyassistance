import 'package:ballauto/Sceen/BottomNavigationBar/bottom_navigation_bar.dart';
import 'package:ballauto/Sceen/profile/edit_profile_screen.dart';
import 'package:ballauto/model/user_profile.dart';
import 'package:ballauto/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ballauto/services/settings_service.dart';
import 'package:ballauto/services/fall_detection_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:ballauto/services/fall_detection_task.dart';
import 'package:ballauto/services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<UserProfile?> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userService = UserService();
        return await userService.getUserProfile(user.uid);
      }
    } catch (e) {
      debugPrint('ข้อผิดพลาดในการดึงข้อมูล: $e');
    }
    return null;
  }

  bool _isFallEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSetting();
  }

  Future<void> _loadSetting() async {
    final enabled = await SettingsService.isFallDetectionEnabled();
    setState(() {
      _isFallEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ข้อมูลผู้ใช้งาน',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(230, 70, 70, 1),
      ),
      backgroundColor: Colors.grey[200],
      body: FutureBuilder<UserProfile?>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('ไม่พบข้อมูลผู้ใช้'));
          }

          final userData = snapshot.data!;
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'ข้อมูลผู้ใช้งาน',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProfileScreen(
                                          userProfile: userData,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.person,
                                color: Colors.redAccent,
                              ),
                              title: Text(
                                'ชื่อ-นามสกุล',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                userData.name,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.phone,
                                color: Colors.redAccent,
                              ),
                              title: Text(
                                'เบอร์โทรศัพท์',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                userData.phone,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.male,
                                color: Colors.redAccent,
                              ),
                              title: Text(
                                'เพศ',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                userData.gender ?? 'ไม่ระบุ',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.opacity,
                                color: Colors.redAccent,
                              ),
                              title: Text(
                                'กรุ๊ปเลือด',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                userData.bloodType ?? 'ไม่ระบุ',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.healing,
                                color: Colors.redAccent,
                              ),
                              title: Text(
                                'โรคประจำตัว',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                userData.disease,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.medication,
                                color: Colors.redAccent,
                              ),
                              title: Text(
                                'แพ้ยา',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                userData.allergy,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: SwitchListTile(
                        activeColor: Colors.redAccent,
                        activeTrackColor: Colors.redAccent.withOpacity(0.4),
                        title: const Text('ตรวจจับการล้ม',style: TextStyle(fontWeight: FontWeight.w600)),
                        value: _isFallEnabled,
                        onChanged: (value) async {
                          await SettingsService.setFallDetectionEnabled(value);
                          setState(() {
                            _isFallEnabled = value;
                          });
                          if (value) {
                            FlutterForegroundTask.startService(
                              notificationTitle: 'Fall Detection Running',
                              notificationText: 'กำลังตรวจจับการล้มตลอดเวลา',
                              callback: startCallback,
                            );
                            FallDetectionService().startListening(onFallDetected: () {
                              NotificationService.startSosCountdown(seconds: 10);
                            });
                          } else {
                            FallDetectionService().stopListening();
                            FlutterForegroundTask.stopService();
                          }
                        },
                        secondary: const Icon(Icons.settings, color: Colors.redAccent),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ListTile(
                        leading: const Icon(Icons.history, color: Colors.redAccent),
                        title: const Text(
                          'ประวัติการแจ้งเหตุ',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        
                        onTap: () => Navigator.pushNamed(context, '/history_sos'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'เกิดข้อผิดพลาดในการออกจากระบบ: $e',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'ออกจากระบบ',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {},
      ),
    );
  }
}