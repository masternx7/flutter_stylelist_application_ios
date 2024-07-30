import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:stylelist/pages/db/wardrobe_firedb.dart';
import 'package:stylelist/pages/repository/api_removebg.dart';

class AddClothesScreen extends StatefulWidget {
  final String wardrobeName;

  const AddClothesScreen(
      {super.key,
      required this.wardrobeName,
      required String userId,
      required String wardrobeId});

  @override
  _AddClothesScreenState createState() => _AddClothesScreenState();
}

class _AddClothesScreenState extends State<AddClothesScreen> {
  Uint8List? imageFile;
  String? imagePath;
  ScreenshotController controller = ScreenshotController();
  String filter = '';
  bool isLoading = false;
  bool isLoading2 = false;

  String? colorClothes;
  final Map<String, Color> colorMap = {
    'ส้ม': Colors.orange,
    'แดง': Colors.red,
    'เขียว': Colors.green,
    'ฟ้า': Colors.lightBlue,
    'เหลือง': Colors.yellow,
    'ขาว': Colors.white,
    'ดำ': Colors.black,
    'น้ำตาล': Colors.brown,
    'น้ำเงิน': Colors.blue.shade900,
    'ชมพู': Colors.pink.shade300,
    'ม่วง': Colors.deepPurpleAccent,
  };

  String? typeClothes;
  String? selectedImagePath;

  final Map<String, String> typeImages = {
    'หมวก': 'lib/images/cap2.png',
    'เสื้อ': 'lib/images/shirt2.png',
    'กางเกง': 'lib/images/pants2.png',
    'รองเท้า': 'lib/images/shoes2.png',
    'เดรส': 'lib/images/dress2.png',
    'กระโปรง': 'lib/images/skirt2.png',
    'กระเป๋า': 'lib/images/bag2.png',
    'ถุงเท้า': 'lib/images/socks2.png',
  };

  String detailsClothes = "";

  final typeClothesController = TextEditingController();
  final colorClothesController = TextEditingController();
  final detailsClothesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 32.0),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () async {
                if (imageFile == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('กรุณาเลือกรูปภาพก่อนบันทึก'),
                      backgroundColor: Colors.black,
                    ),
                  );
                } else if (colorClothes == null || typeClothes == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('กรุณาเลือกสีและประเภทของเสื้อผ้าก่อนบันทึก'),
                      backgroundColor: Colors.black,
                    ),
                  );
                } else {
                  setState(() {
                    isLoading2 = true;
                  });

                  var wardrobeService = WardrobeFirestore();
                  String? wardrobeId = await getWardrobeId(widget.wardrobeName);

                  await wardrobeService.addClothesImage(
                    wardrobeId!,
                    imageFile!,
                    typeClothes!,
                    colorClothes!,
                    detailsClothes,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('บันทึกรูปภาพเสร็จสิ้น'),
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                  );

                  Navigator.pop(context);

                  setState(() {
                    isLoading2 = false;
                  });
                }
              },
              child: const Text(
                'บันทึกข้อมูล',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'เพิ่มเสื้อผ้า',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
      ),
      backgroundColor: Colors.white,
      body: isLoading2
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 15),
                    if (imageFile != null)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.memory(
                                imageFile!,
                                width: 400,
                                height: 300,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.deepPurpleAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    imageFile = await ApiClient()
                                        .removeBgApi(imagePath!);
                                    setState(() {
                                      isLoading = false;
                                    });
                                  } catch (e) {}
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(CommunityMaterialIcons.auto_fix,
                                        color: Colors.white),
                                    SizedBox(width: 4),
                                    Text('ลบพื้นหลังเสื้อผ้า',
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                builder: (context) {
                                  return SizedBox(
                                    height: 150,
                                    child: Wrap(
                                      children: <Widget>[
                                        ListTile(
                                          leading: const Icon(Icons.image),
                                          title:
                                              const Text('เลือกรูปจากแกลอรี่'),
                                          onTap: () {
                                            getImage(ImageSource.gallery);
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.camera_alt),
                                          title: const Text('ถ่ายภาพ'),
                                          onTap: () {
                                            getImage(ImageSource.camera);
                                            Navigator.pop(context);
                                          },
                                        ),
                                        //
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              width: 400,
                              height: 300,
                              color: Colors.grey[100],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 100,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 10),
                                  const Text('แตะเพื่อเพิ่มรูปภาพ'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ประเภทของเสื้อผ้า',
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () => _showClothesTypeSheet(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    selectedImagePath ?? 'lib/images/shirt.png',
                                    width: 24,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    typeClothes ?? 'เลือกประเภท',
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black54),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_drop_down,
                                  color: Colors.black54),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'สีของเสื้อผ้า',
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () => _showColorPicker(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: colorClothes != null
                                    ? colorMap[colorClothes]
                                    : Colors.grey[300],
                                radius: 10,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  colorClothes ?? 'เลือกสี',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black54),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down,
                                  color: Colors.black54),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'รายละเอียดของเสื้อผ้า',
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: detailsClothesController,
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(fontSize: 16),
                          hintText: 'กรุณาป้อนรายละเอียดของเสื้อผ้า',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 12),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.deepPurpleAccent, width: 2.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                        onChanged: (value) {
                          detailsClothes = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: colorMap.keys.length,
            itemBuilder: (BuildContext context, int index) {
              String colorName = colorMap.keys.elementAt(index);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorMap[colorName],
                  radius: 10,
                ),
                title: Text(colorName),
                onTap: () {
                  setState(() {
                    colorClothes = colorName;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        imagePath = pickedImage.path;
        imageFile = await pickedImage.readAsBytes();
        setState(() {});
      }
    } catch (e) {
      imageFile = null;
      setState(() {});
    }
  }

  Future<String?> getWardrobeId(String wardrobeName) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      QuerySnapshot wardrobes = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wardrobes')
          .where('wardrobeName', isEqualTo: wardrobeName) //

          .get();
      if (wardrobes.docs.isNotEmpty) {
        return wardrobes.docs.first.id;
      }
    }
    return null;
  }

  void _showClothesTypeSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: typeImages.keys.length,
            itemBuilder: (BuildContext context, int index) {
              String typeName = typeImages.keys.elementAt(index);
              return ListTile(
                leading: Image.asset(
                  typeImages[typeName]!,
                  width: 24,
                  height: 24,
                ),
                title: Text(typeName),
                onTap: () {
                  setState(() {
                    typeClothes = typeName;
                    selectedImagePath = typeImages[typeName];
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }
}
