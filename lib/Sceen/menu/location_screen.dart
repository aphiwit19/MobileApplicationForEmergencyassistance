import 'package:flutter/material.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('บริการฉุกเฉิน'),
        backgroundColor: const Color.fromRGBO(230, 70, 70, 1),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('โรงพยาบาลใกล้ฉัน'),
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('สถานีตำรวจใกล้ฉัน'),
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('สถานีดับเพลิงใกล้ฉัน'),
          ),
        ],
      ),
    );
  }
}