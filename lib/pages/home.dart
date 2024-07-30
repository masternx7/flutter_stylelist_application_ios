import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stylelist/pages/db/wardrobe_firedb.dart';
import 'package:stylelist/pages/favouriteAll_page.dart';
import 'package:stylelist/pages/repository/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _weatherServer = WeatherService("9fc6656d8a7fd7c9c7691b719edd0fda");
  final WardrobeFirestore wardrobeFirestore = WardrobeFirestore();
  Weather? _weather;

  String? userId;
  String? wardrobeId;
  String? username;
  String? profilePhoto;
  String? selectedWardrobeId;
  List<String> wardrobeIds = [];

  DocumentSnapshot? selectedWardrobe;
  List<DocumentSnapshot> wardrobes = [];

  @override
  void initState() {
    super.initState();
    _initializeData2();
    _initializeData();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Image.asset(
          'lib/images/logo.png',
          width: 200,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          color: Colors.blue,
                        ),
                        children: [
                          TextSpan(
                            text: 'ยินดีต้อนรับ!',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.grey[700],
                                fontSize: 16),
                          ),
                          const TextSpan(text: '  '),
                          if (username != null)
                            TextSpan(
                              text: username!.length > 20
                                  ? '${username!.substring(0, 20)}...'
                                  : username,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey[700],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (profilePhoto != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(profilePhoto!),
                        radius: 20,
                        backgroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('lib/images/bgwea.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Lottie.asset(
                              getWeatherAnimation(_weather?.mainCondition),
                              width: 50,
                              height: 30,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              children: [
                                const Text(
                                  "สภาพอากาศ",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                                Text(
                                  _weather?.mainCondition ?? "",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 30,
                              child: Center(
                                child: Text(
                                  'อุณหภูมิ ${_weather?.temperature.round()} °C',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.checkroom,
                          color: Colors.deepPurpleAccent,
                          size: 24.0,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'เสื้อผ้าวันนี้',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _fetchWardrobeForToday(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox(
                              height: 150,
                              child:
                                  Center(child: CircularProgressIndicator()));
                        }

                        List<Map<String, dynamic>> todayWardrobe =
                            snapshot.data!;
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              height: 150,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'lib/images/logo.png',
                                      width: 200,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'ไม่มีข้อมูลเสื้อผ้าสำหรับวันนี้',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        return Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            height: 150,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: todayWardrobe.length,
                              itemBuilder: (context, index) {
                                var wardrobeItem = todayWardrobe[index];
                                return Row(
                                  children: wardrobeItem.entries
                                      .where((entry) =>
                                          entry.key != 'timestamp' &&
                                          entry.value != null)
                                      .map((entry) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Card(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                                child: Image.network(
                                                  entry.value,
                                                  width: 150,
                                                  height: 150,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
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
                                          ))
                                      .toList(),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Colors.deepPurpleAccent,
                      size: 24.0,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "เสื้อผ้าที่ชื่นชอบ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => FavouriteClothesScreen(
                            userId: userId,
                            wardrobeId: wardrobeId,
                          ),
                        ));
                      },
                      icon: const Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _initializeData(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox(
                            height: 150,
                            child: Center(child: CircularProgressIndicator()));
                      }

                      List<Map<String, dynamic>> favouriteClothes =
                          snapshot.data!;
                      if (favouriteClothes.isEmpty) {
                        return SizedBox(
                          height: 150,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'lib/images/logo.png',
                                  width: 200,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'ไม่มีรายการโปรด',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: min(5, favouriteClothes.length),
                          itemBuilder: (context, index) {
                            final imageUrl =
                                favouriteClothes[index]['imageUrl'];
                            return GestureDetector(
                              onTap: () {},
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: Image.network(
                                      imageUrl,
                                      width: 150,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
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
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initializeData2() async {
    userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      username = userDoc.data()?['username'];
      profilePhoto = userDoc.data()?['profilePhoto'];
      setState(() {});
    }
  }

  Future<List<Map<String, dynamic>>> _initializeData() async {
    userId = FirebaseAuth.instance.currentUser?.uid;
    List<Map<String, dynamic>> favouriteClothes = [];

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
        for (var clothesDoc in clothesDocs.docs) {
          favouriteClothes.add(clothesDoc.data());
        }
      }
    }
    return favouriteClothes;
  }

  Future<List<Map<String, dynamic>>> _fetchWardrobeForToday() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DateTime today = DateTime.now();
      String todayIsoString =
          "${DateTime(today.year, today.month, today.day).toIso8601String()}Z";

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('selectedWardrobes')
          .doc(todayIsoString)
          .get();

      if (snapshot.exists) {
        return [snapshot.data() as Map<String, dynamic>];
      } else {}
    }
    return [];
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'lib/images/sunny.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
        return 'lib/images/cloud.json';
      case 'rain':
        return 'lib/images/rain.json';
      case 'thunderstorm':
        return 'lib/images/storm.json';
      case 'clear':
        return 'lib/images/sunny.json';
      default:
        return 'lib/images/sunny.json';
    }
  }

  _fetchWeather() async {
    String cityName = await _weatherServer.getCurrentCity();

    try {
      final weather = await _weatherServer.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }
}
