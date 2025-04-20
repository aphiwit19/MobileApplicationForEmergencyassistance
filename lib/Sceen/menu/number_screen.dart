import 'package:flutter/material.dart';

class NumberScreen extends StatelessWidget {
  const NumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เบอร์โทรฉุกเฉิน'),
        backgroundColor: const Color.fromRGBO(230, 70, 70, 1),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('ตำรวจ: 191'),
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('ดับเพลิง: 199'),
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('โรงพยาบาล: 1669'),
          ),
        ],
      ),
    );
  }
}