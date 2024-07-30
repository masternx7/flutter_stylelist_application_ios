import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stylelist/pages/addClothes.dart';
import 'package:stylelist/pages/db/wardrobe_firedb.dart';
import 'package:stylelist/pages/editClothes.dart';

class WardrobeDetailScreen extends StatefulWidget {
  final String wardrobeName;

  const WardrobeDetailScreen({super.key, required this.wardrobeName});

  @override
  _WardrobeDetailScreenState createState() => _WardrobeDetailScreenState();
}

class _WardrobeDetailScreenState extends State<WardrobeDetailScreen> {
  final WardrobeFirestore wardrobeFirestore = WardrobeFirestore();
  String? wardrobeId;
  User? user;

  @override
  void initState() {
    super.initState();
    _fetchWardrobeId();
    user = FirebaseAuth.instance.currentUser;
  }

  void _fetchWardrobeId() async {
    String? id =
        await wardrobeFirestore.getWardrobeIdByName(widget.wardrobeName);
    if (id != null) {
      setState(() {
        wardrobeId = id;
      });
    }
  }

  void _addClothes() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddClothesScreen(
        wardrobeName: widget.wardrobeName,
        userId: user?.uid ?? '',
        wardrobeId: wardrobeId ?? '',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('ไม่พบผู้ใช้ที่ลงชื่อเข้าใช้'),
        ),
      );
    }

    return DefaultTabController(
      length: 8,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.wardrobeName,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.normal),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.black,
            labelStyle: TextStyle(fontWeight: FontWeight.normal),
            indicatorColor: Colors.deepPurpleAccent,
            tabs: [
              Tab(
                icon: Image(
                  image: AssetImage('lib/images/cap2.png'),
                  height: 24,
                ),
                text: 'หมวก',
              ),
              Tab(
                icon: Image(
                  image: AssetImage('lib/images/shirt2.png'),
                  height: 24,
                ),
                text: 'เสื้อ',
              ),
              Tab(
                icon: Image(
                  image: AssetImage('lib/images/pants2.png'),
                  height: 24,
                ),
                text: 'กางเกง',
              ),
              Tab(
                icon: Image(
                  image: AssetImage('lib/images/shoes2.png'),
                  height: 24,
                ),
                text: 'รองเท้า',
              ),
              Tab(
                icon: Image(
                  image: AssetImage('lib/images/dress2.png'),
                  height: 24,
                ),
                text: 'เดรส',
              ),
              Tab(
                icon: Image(
                  image: AssetImage('lib/images/skirt2.png'),
                  height: 24,
                ),
                text: 'กระโปรง',
              ),
              Tab(
                icon: Image(
                  image: AssetImage('lib/images/bag2.png'),
                  height: 24,
                ),
                text: 'กระเป๋า',
              ),
              Tab(
                icon: Image(
                  image: AssetImage('lib/images/socks2.png'),
                  height: 24,
                ),
                text: 'ถุงเท้า',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ClothesList(wardrobeName: widget.wardrobeName, typeClothes: 'หมวก'),
            ClothesList(
                wardrobeName: widget.wardrobeName, typeClothes: 'เสื้อ'),
            ClothesList(
                wardrobeName: widget.wardrobeName, typeClothes: 'กางเกง'),
            ClothesList(
                wardrobeName: widget.wardrobeName, typeClothes: 'รองเท้า'),
            ClothesList(wardrobeName: widget.wardrobeName, typeClothes: 'เดรส'),
            ClothesList(
                wardrobeName: widget.wardrobeName, typeClothes: 'กระโปรง'),
            ClothesList(
                wardrobeName: widget.wardrobeName, typeClothes: 'กระเป๋า'),
            ClothesList(
                wardrobeName: widget.wardrobeName, typeClothes: 'ถุงเท้า'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addClothes,
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class ClothesList extends StatelessWidget {
  final String wardrobeName;
  final String? typeClothes;
  final WardrobeFirestore wardrobeFirestore = WardrobeFirestore();

  ClothesList(
      {super.key, required this.wardrobeName, required this.typeClothes});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot?>(
      stream: typeClothes != null
          ? wardrobeFirestore.getClothesImagesByType(
              wardrobeName, typeClothes ?? 'default_value')
          : const Stream.empty(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  'lib/images/logo.png',
                  width: 300,
                ),
                const SizedBox(height: 5),
                Text(
                  'ไม่มีข้อมูลเสื้อผ้า',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        var clothesList = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: clothesList.length,
            itemBuilder: (context, index) {
              var document = clothesList[index];
              var imageUrl = document['imageUrl'];

              return GestureDetector(
                onTap: () async {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ClothesDetailScreen(
                      document: document,
                    ),
                  ));
                },
                onLongPress: () async {
                  bool? shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('ต้องการลบรูปนี้หรือไม่?'),
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

                  if (shouldDelete ?? false) {
                    await document.reference.delete();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          Center(child: Text(error.toString())),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
