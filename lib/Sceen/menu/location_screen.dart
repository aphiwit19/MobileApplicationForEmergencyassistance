import 'package:ballauto/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final LocationService _locationService = LocationService();
  List<LocationWithDistance> _locationsWithDistance = [];
  bool _isLoading = false;
  int _radiusKm = 5;
  String _selectedType = 'hospital';

  @override
  void initState() {
    super.initState();
    _fetchLocations('hospital'); // เริ่มต้นด้วยการดึงข้อมูลโรงพยาบาล
  }

  Future<void> _fetchLocations(String type) async {
    setState(() {
      _isLoading = true;
      _selectedType = type;
    });
    try {
      final list = await _locationService.fetchNearbyWithDistance(type, _radiusKm);
      setState(() => _locationsWithDistance = list);
    } catch (e) {
      print('Error fetching locations: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('บริการฉุกเฉิน'),
        backgroundColor: const Color.fromRGBO(230, 70, 70, 1),
      ),
      body: Column(
        children: [
          // ปุ่มเลือกประเภทสถานบริการ
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _fetchLocations('hospital'),
                  child: const Text('โรงพยาบาล'),
                ),
                ElevatedButton(
                  onPressed: () => _fetchLocations('police'),
                  child: const Text('สถานีตำรวจ'),
                ),
                ElevatedButton(
                  onPressed: () => _fetchLocations('pharmacy'),
                  child: const Text('ร้านยา'),
                ),
                ElevatedButton(
                  onPressed: () => _fetchLocations('doctor'),
                  child: const Text('คลินิก'),
                ),
              ],
            ),
          ),
          // ปุ่มปรับรัศมีค้นหา ทีละ 5 กม.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _radiusKm > 5
                      ? () {
                          setState(() => _radiusKm -= 5);
                          _fetchLocations(_selectedType);
                        }
                      : null,
                ),
                Text('รัศมี: $_radiusKm กม.'),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _radiusKm < 50
                      ? () {
                          setState(() => _radiusKm += 5);
                          _fetchLocations(_selectedType);
                        }
                      : null,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _locationsWithDistance.isEmpty
                    ? const Center(child: Text('ไม่พบข้อมูลสถานที่'))
                    : ListView.builder(
                        itemCount: _locationsWithDistance.length,
                        itemBuilder: (context, index) {
                          final item = _locationsWithDistance[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text(item.place.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.place.address),
                                Text('ระยะทาง ${item.distanceKm.toStringAsFixed(2)} กม.'),
                                if (item.place.phoneNumber != null) Text('โทร: ${item.place.phoneNumber}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.map),
                              onPressed: () {
                                final lat = item.place.latitude;
                                final lng = item.place.longitude;
                                final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                                launchUrl(uri, mode: LaunchMode.externalApplication);
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}