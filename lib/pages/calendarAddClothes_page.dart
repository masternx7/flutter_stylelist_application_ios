import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stylelist/pages/db/wardrobe_firedb.dart';

class WardrobeSelectionPage extends StatefulWidget {
  final DateTime selectedDate;

  const WardrobeSelectionPage({super.key, required this.selectedDate});

  @override
  _WardrobeSelectionPageState createState() => _WardrobeSelectionPageState();
}

class _WardrobeSelectionPageState extends State<WardrobeSelectionPage> {
  DocumentSnapshot? selectedWardrobe;
  final WardrobeFirestore wardrobeFirestore = WardrobeFirestore();
  List<String> selectedTypes = [];
  List<String> clothingTypes = [
    "หมวก",
    "เดรส",
    "เสื้อ",
    "กระเป๋า",
    "กระโปรง",
    "กางเกง",
    "ถุงเท้า",
    "รองเท้า"
  ];

  String? selectedCapImageUrl;
  String? selectedDressImageUrl;
  String? selectedShirtImageUrl;
  String? selectedBagImageUrl;
  String? selectedSkirtImageUrl;
  String? selectedPantsImageUrl;
  String? selectedSocksImageUrl;
  String? selectedShoesImageUrl;

  final Map<DateTime, List> _events = {};

  DateTime todayDate = DateTime.now();

  Map<int, String> thaiMonths = {
    1: 'มกราคม',
    2: 'กุมภาพันธ์',
    3: 'มีนาคม',
    4: 'เมษายน',
    5: 'พฤษภาคม',
    6: 'มิถุนายน',
    7: 'กรกฎาคม',
    8: 'สิงหาคม',
    9: 'กันยายน',
    10: 'ตุลาคม',
    11: 'พฤศจิกายน',
    12: 'ธันวาคม'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          '${widget.selectedDate.day} ${thaiMonths[widget.selectedDate.month]} ${widget.selectedDate.year + 543}',
          style: const TextStyle(
              fontWeight: FontWeight.normal, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              await _saveSelectedWardrobe();
              Navigator.pop(context, true);
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: getWardrobesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text('No wardrobes found');
                    }

                    List<DocumentSnapshot> wardrobes = snapshot.data!.docs;

                    return InkWell(
                      onTap: () =>
                          _showWardrobeSelectionBottomSheet(context, wardrobes),
                      child: Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selectedWardrobe != null
                                  ? (selectedWardrobe!.data()
                                      as Map<String, dynamic>)['wardrobeName']
                                  : 'เลือกตู้เสื้อผ้า',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                TextButton(
                  onPressed: () => _onRandomClothingPressed(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(MdiIcons.shuffleVariant,
                          size: 26, color: Colors.deepPurpleAccent),
                      const SizedBox(width: 8),
                      const Text(
                        'สุ่มเสื้อผ้า',
                        style: TextStyle(
                            fontSize: 16, color: Colors.deepPurpleAccent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 2),
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: Column(
              children: [
                Center(
                  child: InkWell(
                      onTap: () {
                        showClothesDetails("หมวก");
                      },
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Image(
                          image: selectedCapImageUrl != null
                              ? NetworkImage(selectedCapImageUrl!)
                              : const AssetImage('lib/images/cap.png')
                                  as ImageProvider<Object>,
                        ),
                      )),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                            onTap: () {
                              showClothesDetails("เดรส");
                            },
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Image(
                                image: selectedDressImageUrl != null
                                    ? NetworkImage(selectedDressImageUrl!)
                                    : const AssetImage('lib/images/dress.png')
                                        as ImageProvider<Object>,
                                width: 50,
                                height: 50,
                              ),
                            )),
                        InkWell(
                            onTap: () {
                              showClothesDetails("เสื้อ");
                            },
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Image(
                                image: selectedShirtImageUrl != null
                                    ? NetworkImage(selectedShirtImageUrl!)
                                    : const AssetImage('lib/images/shirt.png')
                                        as ImageProvider<Object>,
                                width: 50,
                                height: 50,
                              ),
                            )),
                        InkWell(
                            onTap: () {
                              showClothesDetails("กระเป๋า");
                            },
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Image(
                                image: selectedBagImageUrl != null
                                    ? NetworkImage(selectedBagImageUrl!)
                                    : const AssetImage('lib/images/bag.png')
                                        as ImageProvider<Object>,
                                width: 50,
                                height: 50,
                              ),
                            )),
                      ],
                    ),
                    //
                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                            onTap: () {
                              showClothesDetails("กระโปรง");
                            },
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Image(
                                image: selectedSkirtImageUrl != null
                                    ? NetworkImage(selectedSkirtImageUrl!)
                                    : const AssetImage('lib/images/skirt.png')
                                        as ImageProvider<Object>,
                                width: 50,
                                height: 50,
                              ),
                            )),
                        InkWell(
                            onTap: () {
                              showClothesDetails("กางเกง");
                            },
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Image(
                                image: selectedPantsImageUrl != null
                                    ? NetworkImage(selectedPantsImageUrl!)
                                    : const AssetImage('lib/images/black.png')
                                        as ImageProvider<Object>,
                                width: 50,
                                height: 50,
                              ),
                            )),
                        InkWell(
                            onTap: () {
                              showClothesDetails("ถุงเท้า");
                            },
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Image(
                                image: selectedSocksImageUrl != null
                                    ? NetworkImage(selectedSocksImageUrl!)
                                    : const AssetImage('lib/images/socks.png')
                                        as ImageProvider<Object>,
                                width: 50,
                                height: 50,
                              ),
                            )),
                      ],
                    ),
                    //
                  ],
                ),
                Column(
                  children: [
                    Center(
                      child: InkWell(
                          onTap: () {
                            showClothesDetails("รองเท้า");
                          },
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: Image(
                              image: selectedShoesImageUrl != null
                                  ? NetworkImage(selectedShoesImageUrl!)
                                  : const AssetImage('lib/images/shoes.png')
                                      as ImageProvider<Object>,
                              width: 50,
                              height: 50,
                            ),
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onRandomClothingPressed(BuildContext context) {
    if (selectedWardrobe == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('คุณยังไม่ได้เลือกตู้เสื้อผ้า'),
        ),
      );
      return;
    }

    showClothingTypeSelection(context);
  }

  Future<void> showClothingTypeSelection(BuildContext context) async {
    List<String> selectedTypes = [];
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        double screenHeight = MediaQuery.of(context).size.height;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: screenHeight * 0.65,
            child: Theme(
              data: ThemeData(
                checkboxTheme: CheckboxThemeData(
                  checkColor: MaterialStateProperty.all(Colors.white),
                  fillColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.deepPurpleAccent;
                    }
                    return Colors.white;
                  }),
                ),
              ),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Text(
                          'เลือกประเภทเสื้อผ้าที่ต้องการสุ่ม',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.normal),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: clothingTypes.length,
                          itemBuilder: (BuildContext context, int index) {
                            String type = clothingTypes[index];
                            return CheckboxListTile(
                              title: Text(type),
                              value: selectedTypes.contains(type),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedTypes.add(type);
                                  } else {
                                    selectedTypes.remove(type);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.deepPurpleAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                              if (selectedTypes.isNotEmpty) {
                                randomizeClothes(selectedTypes);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('กรุณาเลือกประเภทเสื้อผ้าก่อน'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'ยืนยันการสุ่ม',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal, fontSize: 16),
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showWardrobeSelectionBottomSheet(
      BuildContext context, List<DocumentSnapshot> wardrobes) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'เลือกตู้เสื้อผ้า',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: wardrobes.map((DocumentSnapshot wardrobe) {
                    return ListTile(
                      title: Text(
                        (wardrobe.data()
                                as Map<String, dynamic>)['wardrobeName'] ??
                            'Unknown',
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          selectedWardrobe = wardrobe;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Stream<QuerySnapshot> getWardrobesStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wardrobes')
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
    return const Stream<QuerySnapshot>.empty();
  }

  Future<bool> isImageSelectedBefore(String imageUrl) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('selectedWardrobes')
          .where('imageUrl', isEqualTo: imageUrl)
          .get();

      return snapshot.docs.isNotEmpty;
    }
    return false;
  }

  Future<void> _saveSelectedWardrobe() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final selectedDateIsoString = widget.selectedDate.toIso8601String();

      Map<String, dynamic> wardrobeData = {
        if (selectedCapImageUrl != null) 'capImageUrl': selectedCapImageUrl,
        if (selectedDressImageUrl != null)
          'dressImageUrl': selectedDressImageUrl,
        if (selectedShirtImageUrl != null)
          'shirtImageUrl': selectedShirtImageUrl,
        if (selectedBagImageUrl != null) 'bagImageUrl': selectedBagImageUrl,
        if (selectedSkirtImageUrl != null)
          'skirtImageUrl': selectedSkirtImageUrl,
        if (selectedPantsImageUrl != null)
          'pantsImageUrl': selectedPantsImageUrl,
        if (selectedSocksImageUrl != null)
          'socksImageUrl': selectedSocksImageUrl,
        if (selectedShoesImageUrl != null)
          'shoesImageUrl': selectedShoesImageUrl,
        'timestamp': Timestamp.fromDate(DateTime.now())
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('selectedWardrobes')
          .doc(selectedDateIsoString)
          .set(wardrobeData);
    }
  }

  Future<void> showClothesDetails(String typeClothes) async {
    if (selectedWardrobe == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกตู้เสื้อผ้าก่อน'),
          backgroundColor: Colors.deepPurpleAccent,
        ),
      );
      return;
    }

    Stream<QuerySnapshot?> stream = wardrobeFirestore.getClothesImagesByType(
        (selectedWardrobe?.data() as Map<String, dynamic>)['wardrobeName'],
        typeClothes);

    stream.listen((snapshot) {
      if (snapshot != null && snapshot.docs.isNotEmpty) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          builder: (BuildContext context) {
            return ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              child: Container(
                height: 200,
                color: Colors.white,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.docs.length,
                  itemBuilder: (context, index) {
                    final clothes = snapshot.docs[index];
                    final clothesImageUrl = clothes['imageUrl'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          switch (typeClothes) {
                            case "หมวก":
                              selectedCapImageUrl = clothesImageUrl;
                              break;
                            case "เดรส":
                              selectedDressImageUrl = clothesImageUrl;
                              break;
                            case "เสื้อ":
                              selectedShirtImageUrl = clothesImageUrl;
                              break;
                            case "กระเป๋า":
                              selectedBagImageUrl = clothesImageUrl;
                              break;
                            case "กระโปรง":
                              selectedSkirtImageUrl = clothesImageUrl;
                              break;
                            case "กางเกง":
                              selectedPantsImageUrl = clothesImageUrl;
                              break;
                            case "ถุงเท้า":
                              selectedSocksImageUrl = clothesImageUrl;
                              break;
                            case "รองเท้า":
                              selectedShoesImageUrl = clothesImageUrl;
                              break;
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 30, left: 30, bottom: 30),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[200],
                          ),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(clothesImageUrl),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่มีเสื้อผ้าในประเภทนี้'),
            backgroundColor: Colors.deepPurpleAccent,
          ),
        );
      }
    });
  }

  Future<void> randomizeClothes(List<String> selectedTypes) async {
    if (selectedWardrobe == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกตู้เสื้อผ้าก่อน'),
          backgroundColor: Colors.deepPurpleAccent,
        ),
      );
      return;
    }

    String wardrobeName =
        (selectedWardrobe!.data() as Map<String, dynamic>)['wardrobeName'];

    List<String> foundTypes = [];
    List<String> notFoundTypes = [];

    for (String type in selectedTypes) {
      var snapshot = await wardrobeFirestore
          .getClothesImagesByType(wardrobeName, type)
          .first;
      var documents = snapshot?.docs;

      if (documents != null && documents.isNotEmpty) {
        var randomClothes = (documents..shuffle()).first;
        String imageUrl = randomClothes['imageUrl'] ?? '';

        foundTypes.add(type);

        setState(() {
          switch (type) {
            case "หมวก":
              selectedCapImageUrl = imageUrl;
              break;
            case "เดรส":
              selectedDressImageUrl = imageUrl;
              break;
            case "เสื้อ":
              selectedShirtImageUrl = imageUrl;
              break;
            case "กระเป๋า":
              selectedBagImageUrl = imageUrl;
              break;
            case "กระโปรง":
              selectedSkirtImageUrl = imageUrl;
              break;
            case "กางเกง":
              selectedPantsImageUrl = imageUrl;
              break;
            case "ถุงเท้า":
              selectedSocksImageUrl = imageUrl;
              break;
            case "รองเท้า":
              selectedShoesImageUrl = imageUrl;
              break;
          }
        });
      } else {
        notFoundTypes.add(type);
      }
    }
    if (notFoundTypes.isNotEmpty) {
      String notFoundMessage =
          'ไม่มีเสื้อผ้าประเภท: ${notFoundTypes.join(', ')}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(notFoundMessage),
          backgroundColor: Colors.deepPurpleAccent,
        ),
      );
    }
  }
}
