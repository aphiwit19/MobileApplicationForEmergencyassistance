import 'package:flutter/material.dart';

class FirstAidScreen extends StatelessWidget {
  const FirstAidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ปฐมพยาบาลเบื้องต้น'),
        backgroundColor: const Color.fromRGBO(230, 70, 70, 1),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.health_and_safety),
            title: Text('การปฐมพยาบาลเมื่อมีบาดแผล'),
          ),
          ListTile(
            leading: Icon(Icons.health_and_safety),
            title: Text('การปฐมพยาบาลเมื่อหมดสติ'),
          ),
          ListTile(
            leading: Icon(Icons.health_and_safety),
            title: Text('การปฐมพยาบาลเมื่อกระดูกหัก'),
          ),
        ],
      ),
    );
  }
}