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
  final List<Map<String, String>> _serviceTypes = [
    {'label': 'โรงพยาบาล', 'value': 'hospital'},
    {'label': 'สถานีตำรวจ', 'value': 'police'},
    {'label': 'ร้านยา', 'value': 'pharmacy'},
    {'label': 'คลินิก', 'value': 'doctor'},
  ];

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
      final list = await _locationService.fetchNearbyWithDistance(
        type,
        _radiusKm,
      );
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
        title: const Text(
          'สถานบริการฉุกเฉินใกล้ฉัน',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(230, 70, 70, 1),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          // แถบตัวเลือกประเภทบริการ
          Container(
            color: Color.fromRGBO(
              230,
              70,
              70,
              1,
            ), // พื้นหลังสีขาวสำหรับแถบตัวเลือก
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  _serviceTypes.map((type) {
                    return GestureDetector(
                      onTap: () => _fetchLocations(type['value']!),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            type['label']!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color:
                                  _selectedType == type['value']
                                      ? Colors
                                          .white // สีแดงเมื่อเลือก
                                      : Colors.white70, // สีดำเมื่อไม่ได้เลือก
                            ),
                          ),
                          if (_selectedType == type['value'])
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              height: 2,
                              width: 40,
                              color: Colors.white, // เส้นใต้สีแดงเมื่อเลือก
                            ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // รัศมีค้นหา
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('รัศมีค้นหา: $_radiusKm กม.'),
                Slider(
                  value: _radiusKm.toDouble(),
                  min: 5,
                  max: 50,
                  divisions: 9,
                  label: '$_radiusKm กม.',
                  activeColor: Color.fromRGBO(230, 70, 70, 1), // สีแดงสำหรับแถบที่เลือก
                  inactiveColor:
                      Colors.red[100], // สีแดงอ่อนสำหรับแถบที่ไม่ได้เลือก
                  onChanged: (value) {
                    setState(() => _radiusKm = value.round());
                  },
                  onChangeEnd: (value) {
                    _fetchLocations(_selectedType);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _locationsWithDistance.isEmpty
                    ? const Center(child: Text('ไม่พบข้อมูลสถานที่'))
                    : RefreshIndicator(
                      onRefresh: () => _fetchLocations(_selectedType),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _locationsWithDistance.length,
                        itemBuilder: (context, index) {
                          final item = _locationsWithDistance[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.place.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.place,
                                                  size: 16,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    item.place.address,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.phone,
                                                  size: 16,
                                                  color: Colors.green,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  item.place.phoneNumber ??
                                                      'ไม่ระบุ',
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.directions_walk,
                                                    size: 16,
                                                    color: Colors.orange,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'ระยะทาง ${item.distanceKm.toStringAsFixed(2)} กม.',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (item.place.phoneNumber != null)
                                        ElevatedButton.icon(
                                          onPressed:
                                              () => launchUrl(
                                                Uri.parse(
                                                  'tel:${item.place.phoneNumber}',
                                                ),
                                              ),
                                          icon: const Icon(
                                            Icons.phone,
                                            size: 18,
                                          ),
                                          label: const Text('โทร'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          final lat = item.place.latitude;
                                          final lng = item.place.longitude;
                                          final uri = Uri.parse(
                                            'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
                                          );
                                          launchUrl(
                                            uri,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.location_on,
                                          size: 18,
                                        ),
                                        label: const Text('ตำแหน่ง'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
