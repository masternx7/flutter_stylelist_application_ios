
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stylelist/pages/db/wardrobe_firedb.dart';
import 'package:stylelist/pages/inside_wardrobe.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  final WardrobeFirestore wardrobeFirestore = WardrobeFirestore();
  TextEditingController customController = TextEditingController();

  String searchQuery = "";

  final List<String> suggestions = [
    'ตู้เสื้อผ้าของฉัน',
    'ตู้แฟชันของฉัน',
    'ตู้เสื้อผ้ากีฬา',
    'ตู้เสื้อสไตล์ใหม่',
    'ตู้ชุดทำงาน',
    'ตู้ชุดไปเที่ยว',
    'ตู้ชุดนอน',
    'ตู้ชุดสบายๆ',
    'ตู้ชุดออกเดท',
    'ตู้ชุดงานปาร์ตี้',
    'ตู้ชุดทางการ',
    'ตู้ชุดสีแสบตา',
    'ตู้ชุดสังสรรค์',
    'ตู้ชุดไปหาเพื่อน',
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedImageFromFirestore();
  }

  String? _currentImagePath = 'lib/images/bg0.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.photo_filter, color: Colors.black),
            onPressed: _showImagePickerDialog,
          ),
          title: const Center(
            child: Text(
              'ตู้เสื้อผ้า',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.normal),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  color: Colors.deepPurpleAccent),
              onPressed: openWardrobeBox,
            ),
          ],
          elevation: 1,
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CupertinoTextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              placeholder: 'ค้นหาตู้เสื้อผ้า...',
              decoration: BoxDecoration(
                border: Border.all(
                    color: CupertinoColors.lightBackgroundGray, width: 0.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              prefix: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.0),
                child: Icon(CupertinoIcons.search),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            ),
          ),
          Expanded(
            child: SlidableAutoCloseBehavior(
              closeWhenOpened: true,
              child: StreamBuilder<QuerySnapshot>(
                stream: wardrobeFirestore.getWardrobesStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List wardrobeList = snapshot.data!.docs;

                    if (wardrobeList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Image.asset(
                              "lib/images/logo.png",
                              width: 400,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'ไม่มีตู้เสื้อผ้า',
                              style: TextStyle(
                                fontSize: 32,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    wardrobeList = wardrobeList.where((document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String wardrobeName = data['wardrobeName'].toLowerCase();
                      return wardrobeName.contains(searchQuery);
                    }).toList();

                    if (wardrobeList.isEmpty) {
                      return const Center(
                          child: Text("ไม่มีตู้เสื้อผ้าดังกล่าว"));
                    }

                    return ListView.builder(
                      itemCount: wardrobeList.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = wardrobeList[index];
                        String docID = document.id;

                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String wardrobeText = data['wardrobeName'];

                        return Slidable(
                          startActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                backgroundColor: Colors.green,
                                icon: Icons.edit,
                                label: 'แก้ไขข้อมูล',
                                onPressed: (context) =>
                                    openEditWardrobeBoxWithOldName(docID),
                              ),
                            ],
                          ),
                          endActionPane: ActionPane(
                              motion: const BehindMotion(),
                              children: [
                                SlidableAction(
                                  backgroundColor: Colors.red,
                                  icon: Icons.delete,
                                  label: 'ลบตู้เสื้อผ้า',
                                  onPressed: (context) {
                                    showCupertinoDialog(
                                      context: context,
                                      builder: (context) {
                                        return CupertinoAlertDialog(
                                          title: const Text('ยืนยันการลบ'),
                                          content: const Text(
                                              'คุณต้องการลบตู้เสื้อผ้านี้หรือไม่? \nหากลบข้อมูลของคุณจะโดนลบทั้งหมด'),
                                          actions: <Widget>[
                                            CupertinoDialogAction(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('ยกเลิก'),
                                            ),
                                            CupertinoDialogAction(
                                              onPressed: () async {
                                                wardrobeFirestore
                                                    .deleteWardrobe(docID);
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'ลบตู้เสื้อผ้านี้แล้ว'),
                                                    backgroundColor:
                                                        Colors.deepPurpleAccent,
                                                  ),
                                                );
                                              },
                                              child: const Text('ยืนยัน'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                )
                              ]),
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) =>
                                            WardrobeDetailScreen(
                                                wardrobeName: wardrobeText),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(_currentImagePath!),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        wardrobeText,
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.black),
                                      ),
                                    ),
                                  )),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Text("");
                  }
                },
              ),
            ),
          )
        ]));
  }

  void openWardrobeBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text(
            'สร้างตู้เสื้อผ้า',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          ),
          contentPadding: const EdgeInsets.all(20.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: customController,
                      decoration: InputDecoration(
                        hintText: 'ใส่ชื่อตู้เสื้อผ้าของคุณ...',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10.0),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.0),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CommunityMaterialIcons.comment_question_outline),
                    onPressed: () => _showSuggestionList(context),
                  ),
                ],
              ),
            ],
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                customController.clear();
                Navigator.pop(context);
              },
              child: const Text(
                'ยกเลิก',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 17,
                    fontWeight: FontWeight.normal),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (customController.text.isNotEmpty) {
                  wardrobeFirestore.addWardrobe(customController.text);
                  customController.clear();
                  Navigator.pop(context);
                  const snackBar = SnackBar(
                    content: Text('สร้างตู้เสื้อผ้าสำเร็จแล้ว'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text('ยืนยัน',
                  style:
                      TextStyle(fontSize: 17, fontWeight: FontWeight.normal)),
            ),
          ],
        );
      },
    );
  }

  void _showSuggestionList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        double screenHeight = MediaQuery.of(context).size.height;
        return SizedBox(
          height: screenHeight *0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "แนะนำชื่อตู้เสื้อผ้า",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
              ),
              const Divider(), 
              Flexible(
                child: ListView.builder(
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(suggestions[index]),
                      onTap: () {
                        customController.text = suggestions[index];
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('เลือกพื้นหลังของตู้เสื้อผ้า'),
          children: <String>[
            'lib/images/bg0.png',
            'lib/images/bg1.png',
            'lib/images/bg2.png',
            'lib/images/bg3.png',
            'lib/images/bg4.png',
            'lib/images/bg5.png',
          ].map((String imagePath) {
            bool isSelected = _currentImagePath == imagePath;

            return SimpleDialogOption(
              onPressed: () async {
                setState(() {
                  _currentImagePath = imagePath;
                });
                await _saveImageToFirestore(imagePath);
                Navigator.of(context).pop();
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Positioned(
                        top: 30,
                        left: 140,
                        child:
                            Icon(Icons.check, color: Colors.deepPurpleAccent))
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _saveImageToFirestore(String imagePath) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef =
        FirebaseFirestore.instance.collection('selectedImages').doc(user.uid);

    await docRef.set({'imagePath': imagePath});
  }

  Future<void> _loadSelectedImageFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final docRef =
          FirebaseFirestore.instance.collection('selectedImages').doc(user.uid);

      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final imagePath = data['imagePath'] as String?;
        if (imagePath != null) {
          setState(() {
            _currentImagePath = imagePath;
          });
        }
      }
    } catch (error) {
      print('Error loading selected image from Firestore: $error');
    }
  }

  Future<void> openEditWardrobeBoxWithOldName(String docID) async {
    String? oldName;
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('wardrobes')
          .doc(docID)
          .get();

      oldName = doc['wardrobeName'];
    } catch (e) {
      print('Error fetching wardrobe name: $e');
    }

    if (oldName != null) {
      TextEditingController customController =
          TextEditingController(text: oldName);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: const Text(
              'แก้ไขชื่อตู้เสื้อผ้า',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
            contentPadding: const EdgeInsets.all(20.0),
            content: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: customController,
                    decoration: InputDecoration(
                      hintText: 'แก้ไขชื่อตู้เสื้อผ้าของคุณ...',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10.0),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text('ยกเลิก', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (customController.text.isNotEmpty) {
                    wardrobeFirestore.updateWardrobe(
                        docID, customController.text);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text('ยืนยัน'),
              ),
            ],
          );
        },
      );
    }
  }
}
