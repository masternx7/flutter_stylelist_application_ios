import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:stylelist/pages/db/wardrobe_firedb.dart';

class ClothesDetailScreen extends StatefulWidget {
  final DocumentSnapshot document;

  const ClothesDetailScreen({super.key, required this.document});

  @override
  _ClothesDetailScreenState createState() => _ClothesDetailScreenState();
}

class _ClothesDetailScreenState extends State<ClothesDetailScreen> {
  bool isFavourite = false;
  final WardrobeFirestore wardrobeFirestore = WardrobeFirestore();

  late TextEditingController _typeController;
  late TextEditingController _colorController;
  late TextEditingController _detailsController;

  String? selectedType;
  String? selectedColor;
  final Map<String, IconData> typeIcons = {
    'หมวก': CommunityMaterialIcons.hat_fedora,
    'เสื้อ': CommunityMaterialIcons.tshirt_crew,
    'กางเกง': CommunityMaterialIcons.bulma,
    'รองเท้า': CommunityMaterialIcons.shoe_formal,
    'เดรส': CommunityMaterialIcons.tshirt_crew,
    'กระโปรง': CommunityMaterialIcons.bulma,
    'กระเป๋า': CommunityMaterialIcons.bag_carry_on,
    'ถุงเท้า': Icons.local_offer,
  };

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

  final List<String> typeClothesList = [
    'หมวก',
    'เสื้อ',
    'กางเกง',
    'รองเท้า',
    'เดรส',
    'กระโปรง',
    'กระเป๋า',
    'ถุงเท้า'
  ];
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

  final List<String> colorClothesList = [
    'ส้ม',
    'แดง',
    'เขียว',
    'ฟ้า',
    'เหลือง',
    'ขาว',
    'ดำ',
    'น้ำตาล',
    'น้ำเงิน',
    'ชมพู',
    'ม่วง'
  ];

  @override
  void initState() {
    super.initState();
    isFavourite = widget.document['favourite'] ?? false;

    _typeController =
        TextEditingController(text: widget.document['typeClothes']);
    _colorController =
        TextEditingController(text: widget.document['colorClothes']);
    _detailsController =
        TextEditingController(text: widget.document['detailsClothes']);

    selectedType = widget.document['typeClothes'];
    selectedColor = widget.document['colorClothes'];
  }

  @override
  void dispose() {
    _typeController.dispose();
    _colorController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> updateClothesDetails() async {
    String clothesId = widget.document.id;
    String userId = widget.document['userId'];
    String wardrobeId = widget.document['wardrobeId'];

    try {
      await wardrobeFirestore
          .updateClothesDetails(userId, wardrobeId, clothesId, {
        'typeClothes': _typeController.text,
        'colorClothes': _colorController.text,
        'detailsClothes': _detailsController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('อัปเดตข้อมูลสำเร็จ'),
          backgroundColor: Colors.deepPurpleAccent,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error updating clothes details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการอัปเดตข้อมูล')),
      );
    }
  }

  Future<void> toggleFavouriteStatus() async {
    var data = widget.document.data() as Map<String, dynamic>;

    if (!data.containsKey('userId') || !data.containsKey('wardrobeId')) {
      print("Document does not contain userId or wardrobeId fields!");
      return;
    }

    String userId = data['userId'];
    String wardrobeId = data['wardrobeId'];
    String clothesId = widget.document.id;

    try {
      await wardrobeFirestore.updateFavouriteStatus(
          userId, wardrobeId, clothesId, !isFavourite);
      setState(() {
        isFavourite = !isFavourite;
      });
    } catch (e) {
      print('Error updating favourite status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการอัปเดตสถานะ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var imageUrl = widget.document['imageUrl'];

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
                onPressed: updateClothesDetails,
                child: const Text(
                  'อัปเดตข้อมูล',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'รายละเอียดเสื้อผ้า',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_forever_sharp),
              onPressed: () async {
                bool? shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text(
                      'ต้องการลบใช่หรือไม่?',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    actions: [
                      TextButton(
                        child: const Text('ยกเลิก'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      TextButton(
                        child: const Text('ลบ'),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                );

                if (mounted && (shouldDelete ?? false)) {
                  await widget.document.reference.delete();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ลบแฟชันนี้เรียบร้อยแล้ว')),
                    );

                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 300.0,
                  margin: const EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(imageUrl),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.favorite,
                            color:
                                isFavourite ? Colors.red : Colors.grey.shade300,
                            size: 22.0,
                          ),
                        ],
                      ),
                      onPressed: toggleFavouriteStatus,
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                const Text(
                  'ประเภทของเสื้อผ้า',
                  style: TextStyle(fontSize: 17),
                ),
                const SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () => _showTypePicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 13.0, horizontal: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        if (selectedType != null)
                          Image.asset(
                            typeImages[selectedType] ??
                                'lib/images/shirt.png',
                            width: 24.0, 
                          ),
                        const SizedBox(width: 8.0),
                        Text(
                          selectedType ?? 'เลือกประเภท',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'สีของเสื้อผ้า',
                  style: TextStyle(fontSize: 17),
                ),
                const SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () => _showColorPicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 13.0, horizontal: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        if (selectedColor != null)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorMap[selectedColor],
                            ),
                          ),
                        const SizedBox(width: 5.0),
                        Text(
                          selectedColor ?? 'เลือกสี',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5.0),
                const Text(
                  'รายละเอียดของเสื้อผ้า',
                  style: TextStyle(fontSize: 17),
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: TextFormField(
                    controller: _detailsController,
                    decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.deepPurpleAccent, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _showColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height *0.55,
          child: ListView.builder(
            itemCount: colorClothesList.length,
            itemBuilder: (BuildContext context, int index) {
              String colorName = colorClothesList[index];
              Color color = colorMap[colorName] ?? Colors.transparent;
              return ListTile(
                leading: Icon(Icons.circle, color: color),
                title: Text(colorName),
                onTap: () {
                  setState(() {
                    selectedColor = colorName;
                    _colorController.text = colorName;
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

  void _showTypePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height *0.55,
          child: ListView.builder(
            itemCount: typeClothesList.length,
            itemBuilder: (BuildContext context, int index) {
              String type = typeClothesList[index];
              return ListTile(
                leading: Image.asset(
                  typeImages[type] ?? 'lib/images/shirt.png',
                  width: 24,
                ),
                title: Text(type),
                onTap: () {
                  setState(() {
                    selectedType = type;
                    _typeController.text = type;
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
