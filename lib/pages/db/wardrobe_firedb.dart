import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class WardrobeFirestore {
  final CollectionReference wardrobes =
      FirebaseFirestore.instance.collection('wardrobes');

  //สร้างตู้เสื้อผ้า
  Future<void> addWardrobe(String wardrobeName) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userId = user.uid;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('wardrobes')
            .add({
          'wardrobeName': wardrobeName,
          'timestamp': Timestamp.now(),
        });
      } else {
        print('ไม่พบผู้ใช้ที่ลงชื่อเข้าใช้');
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการบันทึกข้อมูล: $e');
    }
  }

  //Read

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

  Future<void> updateWardrobe(String wardrobeId, String updatedWardrobeName) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userId = user.uid;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('wardrobes')
            .doc(wardrobeId)
            .update({
          'wardrobeName': updatedWardrobeName,
        });
      } else {
        print('ไม่พบผู้ใช้ที่ลงชื่อเข้าใช้');
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการอัปเดตข้อมูล: $e');
    }
  }

  //Delete
  Future<void> deleteWardrobe(String wardrobeId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userId = user.uid;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('wardrobes')
            .doc(wardrobeId)
            .delete();
      } else {
        print('ไม่พบผู้ใช้ที่ลงชื่อเข้าใช้');
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการลบข้อมูล: $e');
    }
  }

  Future<DocumentReference?> addClothesImage(
    String wardrobeId,
    Uint8List imageFile,
    String typeClothes,
    String colorClothes,
    String detailsClothes,
  ) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('ไม่พบผู้ใช้ที่ลงชื่อเข้าใช้');
      return null;
    }

    final imageUrl = await _uploadImageToStorage(imageFile);
    if (imageUrl == null) {
      return null;
    }

    return _addDetailsToFirestore(
      user.uid,
      wardrobeId,
      imageUrl,
      typeClothes,
      colorClothes,
      detailsClothes,
    );
  }

  Future<String?> _uploadImageToStorage(Uint8List imageFile) async {
    try {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('clothes')
          .child('${DateTime.now().toIso8601String()}.jpg');

      await ref.putData(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ: $e');
      return null;
    }
  }

  Future<DocumentReference?> _addDetailsToFirestore(
    String userId,
    String wardrobeId,
    String imageUrl,
    String typeClothes,
    String colorClothes,
    String detailsClothes,
  ) async {
    try {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wardrobes')
          .doc(wardrobeId)
          .collection('clothesDetails')
          .add({
        'userId': userId,
        'wardrobeId': wardrobeId,
        'imageUrl': imageUrl,
        'typeClothes': typeClothes,
        'colorClothes': colorClothes,
        'detailsClothes': detailsClothes,
        'timestamp': Timestamp.now(),
        'favourite': false,
      });
    } catch (e) {
      print('เกิดข้อผิดพลาดในการบันทึกข้อมูล: $e');
      return null;
    }
  }

  Stream<QuerySnapshot> getClothesImages(String wardrobeId) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wardrobes')
          .doc(wardrobeId)
          .collection('clothesDetails')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } else {
      print('ไม่พบผู้ใช้ที่ลงชื่อเข้าใช้');
      throw Exception('ไม่พบผู้ใช้ที่ลงชื่อเข้าใช้');
    }
  }

  Future<void> updateFavouriteStatus(
    String userId,
    String wardrobeId,
    String clothesId,
    bool newStatus,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wardrobes')
          .doc(wardrobeId)
          .collection('clothesDetails')
          .doc(clothesId)
          .update({'favourite': newStatus});
    } catch (e) {
      print('เกิดข้อผิดพลาดในการอัพเดตสถานะ: $e');
    }
  }

  Future<void> updateClothesImage(String wardrobeId, String imageId,
      Map<String, dynamic> updatedData) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wardrobes')
          .doc(wardrobeId)
          .collection('clothesDetails')
          .doc(imageId)
          .update(updatedData);
    } else {
      print('ไม่พบผู้ใช้ที่ลงชื่อเข้าใช้');
      throw Exception('ไม่พบผู้ใช้ที่ลงชื่อเข้าใช้');
    }
  }

  Future<void> deleteClothesImage(String wardrobeId, String imageId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wardrobes')
          .doc(wardrobeId)
          .collection('clothesDetails')
          .doc(imageId)
          .delete();
    } else {
      print('ไม่พบผู้ใช้ที่ลงชื่อเข้าใช้');
      throw Exception('ไม่พบผู้ใช้ที่ลงชื่อเข้าใช้');
    }
  }

  Future<String?> getWardrobeIdByName(String wardrobeName) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wardrobes')
          .where('wardrobeName', isEqualTo: wardrobeName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
    }
    return null;
  }

  Stream<QuerySnapshot?> getClothesImagesByType(String wardrobeName,
      [String? typeClothes]) async* {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      String? wardrobeId = await getWardrobeIdByName(wardrobeName);
      if (wardrobeId != null) {
        Query query = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('wardrobes')
            .doc(wardrobeId)
            .collection('clothesDetails');

        if (typeClothes != null && typeClothes.isNotEmpty) {
          query = query.where('typeClothes', isEqualTo: typeClothes);
        }

        yield* query.snapshots();
      } else {
        yield null;
      }
    } else {
      yield null;
    }
  }

  Stream<QuerySnapshot> getLatestClothesStream(String wardrobeId) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('wardrobes')
        .doc(wardrobeId)
        .collection('clothesDetails')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> updateClothesDetails(String userId, String wardrobeId,
      String clothesId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('wardrobes')
        .doc(wardrobeId)
        .collection('clothesDetails')
        .doc(clothesId)
        .update(data);
  }
}
