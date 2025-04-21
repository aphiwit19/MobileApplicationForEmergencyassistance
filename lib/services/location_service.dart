import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import '../model/location_model.dart';

/// ประกอบข้อมูลสถานที่กับระยะทาง
class LocationWithDistance {
  final LocationModel place;
  final double distanceKm;
  LocationWithDistance({required this.place, required this.distanceKm});
}

class LocationService {
  final String apiKey = 'AIzaSyAjQbfLaPaYhWF0p_zcnNLGG_Wg5vVpdPQ'; // ใส่ API Key ของคุณที่นี่

  Future<List<LocationModel>> fetchLocations(String type, double lat, double lng) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=5000&type=$type&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    debugPrint('Google Places API URL: $url');
    debugPrint('HTTP status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] != 'OK') {
        throw Exception('Google Places API error: ${data['status']} - ${data['error_message'] ?? ''}');
      }
      final results = data['results'] as List;

      return results.map((json) => LocationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load locations: HTTP ${response.statusCode}');
    }
  }

  /// ขอสิทธิ์และดึงตำแหน่งผู้ใช้ปัจจุบัน
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw Exception('Location permissions are denied.');
    }
    if (permission == LocationPermission.deniedForever) throw Exception('Location permissions are permanently denied.');
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  /// ดึงสถานบริการพร้อมคำนวณระยะทางจากตำแหน่งปัจจุบัน
  Future<List<LocationWithDistance>> fetchNearbyWithDistance(String type) async {
    final pos = await getCurrentLocation();
    final places = await fetchLocations(type, pos.latitude, pos.longitude);
    return places.map((place) {
      final d = calculateDistanceInKm(pos.latitude, pos.longitude, place.latitude, place.longitude);
      return LocationWithDistance(place: place, distanceKm: d);
    }).toList();
  }

  /// คำนวณระยะทางระหว่างพิกัดสองจุด (หน่วย: กม.)
  double calculateDistanceInKm(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final meters = Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
    return meters / 1000;
  }
}