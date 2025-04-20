class EmergencyNumberModel {
  final String name;
  final String number;
  final String category;

  EmergencyNumberModel({
    required this.name,
    required this.number,
    required this.category, // เพิ่ม required
  });

  // แปลงข้อมูลจาก Map (Firebase) เป็น Object
  factory EmergencyNumberModel.fromMap(Map<String, dynamic> map) {
    return EmergencyNumberModel(
      number: map['number'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
    );
  }

  // แปลง Object เป็น Map เพื่ออัปโหลดไป Firebase
  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'name': name,
      'category': category,
    };
  }
}