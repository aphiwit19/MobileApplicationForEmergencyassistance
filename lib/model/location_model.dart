class LocationModel {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String placeId;
  final String? phoneNumber;

  LocationModel({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.placeId, // ID สถานบริการ
    this.phoneNumber,
  });

  // แปลงข้อมูลจาก JSON (Google Maps API) เป็น Object
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] ?? '',
      address: json['vicinity'] ?? '',
      latitude: json['geometry']['location']['lat'] ?? 0.0,
      longitude: json['geometry']['location']['lng'] ?? 0.0,
      placeId: json['place_id'] ?? '',
      phoneNumber: json['international_phone_number'] ?? null,
    );
  }
}