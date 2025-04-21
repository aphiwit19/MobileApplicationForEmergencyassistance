import 'package:ballauto/services/location_service.dart';
import 'package:flutter/material.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final LocationService _locationService = LocationService();
  List<LocationWithDistance> _locationsWithDistance = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLocations('hospital'); // เริ่มต้นด้วยการดึงข้อมูลโรงพยาบาล
  }

  Future<void> _fetchLocations(String type) async {
    setState(() => _isLoading = true);
    try {
      final list = await _locationService.fetchNearbyWithDistance(type);
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
                              ],
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