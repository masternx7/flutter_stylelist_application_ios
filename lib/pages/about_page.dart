
import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class UpdateInfo {
  final String version;
  final String description;
  final String time;

  UpdateInfo({required this.version, required this.description,required this.time});
}

class _AboutScreenState extends State<AboutScreen> {
  final List<UpdateInfo> updateInfoList = [
    UpdateInfo(
        version: "1.0.3",
        description: "- ปรับปรุงส่วนของการสุ่มเสื้อผ้า...", time: "ศุกร์ 15 ธันวาคม 2566, 11:42"),
        UpdateInfo(
        version: "1.0.2",
        description: "- ปรับปรุง UI บางส่วน...", time: "พฤหัส 14 ธันวาคม 2566, 18:10"),
        UpdateInfo(
        version: "1.0.1",
        description: "- อัปเดตเสื้อผ้าวันนี้ในหน้าแรก...", time: "พุธ 13 ธันวาคม 2566, 10:26"),
    UpdateInfo(version: "1.0.0", description: "- แก้ไขแอปพลิเคชันให้มีประสิทธิภาพมากขึ้น...", time: "อังคาร 12 ธันวาคม 2566, 13:09"),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "เกี่ยวกับแอป",
          style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: updateInfoList.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  updateInfoList[index].version,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  updateInfoList[index].description,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  updateInfoList[index].time,
                  style: const TextStyle(fontSize: 14,color: Colors.grey),
                ),
                const Divider(),
              ],
            );
          },
        ),
      ),
    );
  }
}
