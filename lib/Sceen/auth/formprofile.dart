import 'package:flutter/material.dart';
import 'package:ballauto/model/user_profile.dart';
import 'package:ballauto/services/user_service.dart';
import '../home/home.dart';

class FormProfileScreen extends StatefulWidget {
  const FormProfileScreen({super.key});

  @override
  State<FormProfileScreen> createState() => _FormProfileScreenState();
}

class _FormProfileScreenState extends State<FormProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _diseaseController = TextEditingController();
  final TextEditingController _allergyController = TextEditingController();
  String? _selectedGender;
  String? _selectedBloodType;

  final List<String> _genders = ['ชาย', 'หญิง', 'อื่นๆ'];
  final List<String> _bloodTypes = ['A', 'B', 'O', 'AB'];
  final UserService _userService = UserService();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _diseaseController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  // ฟังก์ชันบันทึกโปรไฟล์
  // คอมเมนต์: การจัดการ async และ error handling สำคัญมาก
  // เพราะต้องแจ้งผู้ใช้เมื่อบันทึกสำเร็จหรือเกิดข้อผิดพลาด
  // และต้องป้องกัน memory leak ด้วยการเช็ค mounted
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userProfile = UserProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          gender: _selectedGender,
          bloodType: _selectedBloodType,
          disease: _diseaseController.text.trim(),
          allergy: _allergyController.text.trim(),
        );

        await _userService.saveUserProfile(userProfile);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('บันทึกข้อมูลสำเร็จ!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // นำทางไปหน้า Home และลบ stack เดิม
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ฟังก์ชันสร้างช่องกรอกข้อมูล
  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color.fromRGBO(230, 70, 70, 1),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[50], // ช่องกรอกข้อมูลเป็นสีเทาอ่อน
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        errorStyle: const TextStyle(fontSize: 12),
      ),
      validator: validator,
    );
  }

  // ฟังก์ชันสร้าง Dropdown
  // คอมเมนต์: DropdownButtonFormField ต้องระวังเรื่อง state
  // ค่า value ต้องอยู่ใน items เสมอ มิฉะนั้นจะเกิด error
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white, // ช่อง dropdown เป็นสีขาว
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items:
          items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 16)),
                ),
              )
              .toList(),
      onChanged: onChanged,
      validator: validator,
      dropdownColor: Colors.white,
      icon: const Icon(Icons.arrow_drop_down, color: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'กรอกข้อมูลส่วนตัว',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(230, 70, 70, 1),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[200], // พื้นหลังเป็นสีเทา
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  'ข้อมูลส่วนตัว',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInput(
                  label: 'ชื่อ-นามสกุล',
                  controller: _nameController,
                  hintText: 'กรอกชื่อ-นามสกุล',
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'กรุณากรอกชื่อ-นามสกุล'
                              : null,
                ),
                const SizedBox(height: 16),
                _buildInput(
                  label: 'เบอร์โทรศัพท์',
                  controller: _phoneController,

                  inputType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกเบอร์โทรศัพท์';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'กรุณากรอกเบอร์โทรศัพท์ให้ถูกต้อง (10 หลัก)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'เพศ',
                  value: _selectedGender,
                  items: _genders,
                  onChanged: (value) => setState(() => _selectedGender = value),
                  validator: (value) => value == null ? 'กรุณาเลือกเพศ' : null,
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'หมู่เลือด',
                  value: _selectedBloodType,
                  items: _bloodTypes,
                  onChanged:
                      (value) => setState(() => _selectedBloodType = value),
                  validator:
                      (value) => value == null ? 'กรุณาเลือกหมู่เลือด' : null,
                ),
                const SizedBox(height: 16),
                _buildInput(
                  label: 'โรคประจำตัว',
                  controller: _diseaseController,
                ),
                const SizedBox(height: 16),
                _buildInput(label: 'การแพ้ยา', controller: _allergyController),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(230, 70, 70, 1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'บันทึกข้อมูล',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
