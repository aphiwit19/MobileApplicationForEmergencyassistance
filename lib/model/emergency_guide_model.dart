class EmergencyGuideModel {
  final String title;
  final String description;

  EmergencyGuideModel({
    required this.title,
    required this.description,
  });

  factory EmergencyGuideModel.fromMap(Map<String, dynamic> map) {
    return EmergencyGuideModel(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
    };
  }
}
