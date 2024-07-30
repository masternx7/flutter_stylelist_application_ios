import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stylelist/pages/editClothes.dart';

class FavouriteClothesScreen extends StatefulWidget {
  final String? userId;
  final String? wardrobeId;

  const FavouriteClothesScreen({super.key, this.userId, this.wardrobeId});

  @override
  _FavouriteClothesScreenState createState() => _FavouriteClothesScreenState();
}

class _FavouriteClothesScreenState extends State<FavouriteClothesScreen> {
  Future<List<DocumentSnapshot>> _fetchFavouriteClothes() async {
    String? userId = widget.userId;
    List<DocumentSnapshot> favouriteClothes = [];

    if (userId != null) {
      final wardrobeDocs = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wardrobes')
          .get();

      for (var doc in wardrobeDocs.docs) {
        final clothesDocs = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('wardrobes')
            .doc(doc.id)
            .collection('clothesDetails')
            .where('favourite', isEqualTo: true)
            .get();

        favouriteClothes.addAll(clothesDocs.docs);
      }
    }
    return favouriteClothes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "เสื้อผ้าที่ชื่นชอบ",
          style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
        ),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchFavouriteClothes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/images/logo.png', 
                    width: 300, 
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'ไม่มีรายการโปรด',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }

          List<DocumentSnapshot> favouriteClothes = snapshot.data!;

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: favouriteClothes.length,
            itemBuilder: (context, index) {
              final imageUrl = favouriteClothes[index]['imageUrl'];

              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ClothesDetailScreen(
                          document: favouriteClothes[index]),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 50,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
