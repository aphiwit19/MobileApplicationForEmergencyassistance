import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/emergency_number_model.dart';
import '../services/emergency_number_service.dart';

Future<void> seedEmergencyNumbers() async {
  final EmergencyNumberService service = EmergencyNumberService();
  final collection = FirebaseFirestore.instance.collection('emergency_numbers');

  // ลบข้อมูลโครงสร้างเดิมทั้งหมด
  final existing = await collection.get();
  for (var doc in existing.docs) {
    await doc.reference.delete();
  }

  // ข้อมูลเบอร์โทรฉุกเฉินที่ต้องการ seed
  final numbers = [
    // เบอร์โทรฉุกเฉิน การแพทย์และโรงพยาบาล
    EmergencyNumberModel(
      name: 'หน่วยแพทย์กู้ชีวิต วชิรพยาบาล',
      number: '1554',
      category: 'การแพทย์และโรงพยาบาล',
    ),
    EmergencyNumberModel(
      name: 'สถาบันการแพทย์ฉุกเฉินแห่งชาติ (ทั่วประเทศ)',
      number: '1669',
      category: 'การแพทย์และโรงพยาบาล',
    ),
    EmergencyNumberModel(
      name: 'หน่วยแพทย์ฉุกเฉิน (กทม.)',
      number: '1646',
      category: 'การแพทย์และโรงพยาบาล',
    ),
    EmergencyNumberModel(
      name: 'โรงพยาบาลตำรวจ',
      number: '1691',
      category: 'การแพทย์และโรงพยาบาล',
    ),
    EmergencyNumberModel(
      name: 'กรมป้องกันและบรรเทาสาธารณภัย',
      number: '1784',
      category: 'การแพทย์และโรงพยาบาล',
    ),
    EmergencyNumberModel(
      name: 'สายด่วนกรมสุขภาพจิต',
      number: '1667',
      category: 'การแพทย์และโรงพยาบาล',
    ),

    // เบอร์โทรฉุกเฉิน แจ้งเหตุด่วนเหตุร้าย
    EmergencyNumberModel(
      name: 'แจ้งคนหาย',
      number: '1300',
      category: 'แจ้งเหตุด่วนเหตุร้าย',
    ),
    EmergencyNumberModel(
      name: 'แจ้งเหตุไฟไหม้ดับเพลิง',
      number: '199',
      category: 'แจ้งเหตุด่วนเหตุร้าย',
    ),
    EmergencyNumberModel(
      name: 'แจ้งเหตุด่วนเหตุร้ายกับเจ้าหน้าที่ตำรวจ',
      number: '191',
      category: 'แจ้งเหตุด่วนเหตุร้าย',
    ),
    EmergencyNumberModel(
      name: 'ศูนย์เตือนภัยพิบัติแห่งชาติ',
      number: '192',
      category: 'แจ้งเหตุด่วนเหตุร้าย',
    ),
    EmergencyNumberModel(
      name: 'กองปราบ (สายด่วนแจ้งเหตุอาชญากรรม คดีร้ายแรง)',
      number: '1195',
      category: 'แจ้งเหตุด่วนเหตุร้าย',
    ),
    EmergencyNumberModel(
      name: 'ศูนย์ปราบปรามการโจรกรรมรถ (แจ้งรถหาย)',
      number: '1192',
      category: 'แจ้งเหตุด่วนเหตุร้าย',
    ),
    EmergencyNumberModel(
      name: 'แจ้งอุบัติเหตุทางน้ำ',
      number: '1196',
      category: 'แจ้งเหตุด่วนเหตุร้าย',
    ),
    EmergencyNumberModel(
      name: 'ร่วมด้วยช่วยกัน',
      number: '1677',
      category: 'แจ้งเหตุด่วนเหตุร้าย',
    ),

    // เบอร์โทรฉุกเฉิน หน่วยงานและองค์กรทั่วไป
    EmergencyNumberModel(
      name: 'การไฟฟ้าส่วนภูมิภาค',
      number: '1129',
      category: 'หน่วยงานและองค์กรทั่วไป',
    ),
    EmergencyNumberModel(
      name: 'การไฟฟ้านครหลวง',
      number: '1130',
      category: 'หน่วยงานและองค์กรทั่วไป',
    ),
    EmergencyNumberModel(
      name: 'การประปานครหลวง',
      number: '1125',
      category: 'หน่วยงานและองค์กรทั่วไป',
    ),
    EmergencyNumberModel(
      name: 'การประปาส่วนภูมิภาค',
      number: '1162',
      category: 'หน่วยงานและองค์กรทั่วไป',
    ),
    EmergencyNumberModel(
      name: 'สำนักงานประกันสังคม',
      number: '1506',
      category: 'หน่วยงานและองค์กรทั่วไป',
    ),
    EmergencyNumberModel(
      name: 'สายด่วนประกันภัย',
      number: '1186',
      category: 'หน่วยงานและองค์กรทั่วไป',
    ),
    EmergencyNumberModel(
      name: 'จส.100แจ้งเหตุด่วนเพื่อประสานงานต่อ',
      number: '1137',
      category: 'หน่วยงานและองค์กรทั่วไป',
    ),
    EmergencyNumberModel(
      name: 'ศูนย์รับแจ้งเบาะแสและให้ความช่วยเหลือเด็ก มูลนิธิปวีณา หงสกุล',
      number: '1134',
      category: 'หน่วยงานและองค์กรทั่วไป',
    ),
    EmergencyNumberModel(
      name: 'ศูนย์รับแจ้งข่าวปราบปรามยาเสพติด',
      number: '1138',
      category: 'หน่วยงานและองค์กรทั่วไป',
    ),
    EmergencyNumberModel(
      name: 'สายด่วนยาเสพติด สถาบันธัญญารักษ์',
      number: '1165',
      category: 'หน่วยงานและองค์กรทั่วไป',
    ),

    // เบอร์โทรฉุกเฉิน การท่องเที่ยว
    EmergencyNumberModel(
      name: 'กรมทางพิเศษแห่งประเทศไทย',
      number: '1543',
      category: 'การท่องเที่ยว',
    ),
    EmergencyNumberModel(
      name: 'ตำรวจทางหลวง',
      number: '1193',
      category: 'การท่องเที่ยว',
    ),
    EmergencyNumberModel(
      name:
          'ตำรวจท่องเที่ยว (แจ้งเหตุด่วนเหตุร้ายที่เกี่ยวข้องกับนักท่องเที่ยว)',
      number: '1155',
      category: 'การท่องเที่ยว',
    ),
    EmergencyNumberModel(
      name: 'สวพ. FM91 สถานีวิทยุเพื่อความปลอดภัยและจราจร',
      number: '1644',
      category: 'การท่องเที่ยว',
    ),
    EmergencyNumberModel(
      name: 'การรถไฟแห่งประเทศไทย',
      number: '1690',
      category: 'การท่องเที่ยว',
    ),
    EmergencyNumberModel(
      name: 'กรมทางหลวงชนบท',
      number: '1146',
      category: 'การท่องเที่ยว',
    ),
    EmergencyNumberModel(
      name: 'ศูนย์ช่วยเหลือนักท่องเที่ยว (TAC)',
      number: '02-134-4077',
      category: 'การท่องเที่ยว',
    ),
  ];

  // อัปโหลดข้อมูลไปยัง Firebase
  for (var number in numbers) {
    await collection.doc(number.name).set(number.toMap());
  }

  print('Seed ข้อมูลเบอร์โทรฉุกเฉินเรียบร้อยแล้ว!');
}
