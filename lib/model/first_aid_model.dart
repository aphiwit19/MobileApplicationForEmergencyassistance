class FirstAidModel {
  final String title;
  final String description;

  FirstAidModel({
    required this.title,
    required this.description,
  });

  // แปลงข้อมูลจาก Firebase (Map) เป็น Object
  factory FirstAidModel.fromMap(Map<String, dynamic> map) {
    return FirstAidModel(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
    );
  }

  // แปลง Object เป็น Map เพื่ออัปโหลดไป Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
    };
  }
}