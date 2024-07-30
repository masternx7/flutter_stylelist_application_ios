import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stylelist/pages/calendarAddClothes_page.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  final String title;
  final List<String> imageUrls;

  Event({required this.title, required this.imageUrls});
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime todayDate = DateTime.now();
  Map<DateTime, List<Event>> _events = {};
  List<Event> _selectedEvents = [];

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      todayDate = day;
      _selectedEvents = _events[day] ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    _reloadEvents();
  }

  Future<void> _reloadEvents() async {
    await _fetchEventsFromFirestore().then((fetchedEvents) {
      setState(() {
        _events = fetchedEvents;
        _selectedEvents = _events[todayDate] ?? [];
      });
    });
  }

  Widget _horizontalListView(List<String> imageUrls) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildImage(imageUrls[index]),
          );
        },
      ),
    );
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _deleteEvent(todayDate),
        backgroundColor: Colors.deepPurpleAccent,
        child: const Icon(Icons.delete),
      ),
      appBar: AppBar(
        elevation: 1,
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        title: const Text('ปฏิทิน',
            style: TextStyle(fontWeight: FontWeight.normal)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: Colors.deepPurpleAccent,
            onPressed: () {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (context) => WardrobeSelectionPage(
                    selectedDate: todayDate,
                  ),
                ),
              )
                  .then((_) {
                _fetchEventsFromFirestore().then((fetchedEvents) {
                  setState(() {
                    _events = fetchedEvents;
                    _selectedEvents = _events[todayDate] ?? [];
                  });
                });
              });
            },
          )
        ],
      ),
      body: SafeArea(
        child: SmartRefresher(
          enablePullDown: true,
          controller: _refreshController,
          onRefresh: _handleRefresh,
          header: const ClassicHeader(
            refreshingText: "กำลังรีเฟรช...",
            idleText: "ดึงลงเพื่อรีเฟรช",
            completeText: "รีเฟรชเสร็จสมบูรณ์",
            failedText: "รีเฟรชไม่สำเร็จ",
            releaseText: "ปล่อยเพื่อรีเฟรช",
          ),
          child: ListView(
            children: [CalendarSelect(events: _events)],
          ),
        ),
      ),
    );
  }

  Widget CalendarSelect({required Map<DateTime, List<Event>> events}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                  blurRadius: 2,
                ),
              ],
            ),
            margin: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: GestureDetector(
              onTap: () {},
              child: TableCalendar(
                locale: "th_TH",
                eventLoader: (day) => _events[day] ?? [],
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  titleTextFormatter: (date, locale) => toBuddhistYear(date),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekendStyle: TextStyle(color: Colors.red),
                ),
                calendarStyle: const CalendarStyle(
                  weekendTextStyle: TextStyle(color: Colors.red),
                  todayDecoration: BoxDecoration(
                    color: Colors.purpleAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(color: Colors.white),
                  todayTextStyle: TextStyle(color: Colors.white),
                ),
                availableGestures: AvailableGestures.all,
                selectedDayPredicate: (day) => isSameDay(day, todayDate),
                focusedDay: todayDate,
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime(2030, 3, 14),
                onDaySelected: _onDaySelected,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 395,
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: FutureBuilder<Map<DateTime, List<Event>>>(
                future: _fetchEventsFromFirestore(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
            
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
                  }
            
                  if (snapshot.hasData) {
                    Map<DateTime, List<Event>> allEvents = snapshot.data!;
            
                    if (_selectedEvents.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Center(
                              child: SizedBox(
                                width: 60,
                                height: 60,
                                child: _buildImage(
                                    _selectedEvents[0].imageUrls.isNotEmpty
                                        ? _selectedEvents[0].imageUrls[0]
                                        : null),
                              ),
                            ),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: _buildImage(
                                          _selectedEvents[0].imageUrls.length > 4
                                              ? _selectedEvents[0].imageUrls[4]
                                              : null),
                                    ),
                                    SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: _buildImage(
                                          _selectedEvents[0].imageUrls.length > 1
                                              ? _selectedEvents[0].imageUrls[1]
                                              : null),
                                    ),
                                    SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: _buildImage(
                                          _selectedEvents[0].imageUrls.length > 6
                                              ? _selectedEvents[0].imageUrls[6]
                                              : null),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: _buildImage(
                                          _selectedEvents[0].imageUrls.length > 5
                                              ? _selectedEvents[0].imageUrls[5]
                                              : null),
                                    ),
                                    SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: _buildImage(
                                          _selectedEvents[0].imageUrls.length > 2
                                              ? _selectedEvents[0].imageUrls[2]
                                              : null),
                                    ),
                                    SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: _buildImage(
                                          _selectedEvents[0].imageUrls.length > 7
                                              ? _selectedEvents[0].imageUrls[7]
                                              : null),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Column(children: [
                                  Center(
                                      child: SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: _buildImage(
                                        _selectedEvents[0].imageUrls.length > 3
                                            ? _selectedEvents[0].imageUrls[3]
                                            : null),
                                  ))
                                ])
                              ],
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Center(
                        child: Container(
                          width: 395,
                          height: 280,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'lib/images/logo.png',
                                width: 180,
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'ไม่มีกิจกรรม',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'แตะที่วันที่เพื่อดูเสื้อผ้าหรือเลือกวันที่เพิ่มเสื้อผ้าลงปฏิทิน',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  } else {
                    return const Center(
                      child: Text('ไม่มีข้อมูล'),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await _fetchEventsFromFirestore().then((fetchedEvents) {
      setState(() {
        _events = fetchedEvents;
        _selectedEvents = _events[todayDate] ?? [];
      });
      _refreshController.refreshCompleted();
    });
  }

  Future<Map<DateTime, List<Event>>> _fetchEventsFromFirestore() async {
    Map<DateTime, List<Event>> fetchedEvents = {};

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('selectedWardrobes')
          .get();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        DateTime eventDate = DateTime.parse(doc.id);
        final data = doc.data() as Map<String, dynamic>;
        List<String> imageUrls = [];
        if (data['capImageUrl'] != null) imageUrls.add(data['capImageUrl']);
        if (data['shirtImageUrl'] != null) imageUrls.add(data['shirtImageUrl']);
        if (data['pantsImageUrl'] != null) imageUrls.add(data['pantsImageUrl']);
        if (data['shoesImageUrl'] != null) imageUrls.add(data['shoesImageUrl']);
        if (data['dressImageUrl'] != null) imageUrls.add(data['dressImageUrl']);
        if (data['skirtImageUrl'] != null) imageUrls.add(data['skirtImageUrl']);
        if (data['bagImageUrl'] != null) imageUrls.add(data['bagImageUrl']);
        if (data['socksImageUrl'] != null) imageUrls.add(data['socksImageUrl']);

        final event = Event(title: 'Selected Wardrobe', imageUrls: imageUrls);

        if (fetchedEvents[eventDate] != null) {
          fetchedEvents[eventDate]!.add(event);
        } else {
          fetchedEvents[eventDate] = [event];
        }
      }
    }

    return fetchedEvents;
  }

  Future<void> _deleteEvent(DateTime date) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;

      DocumentReference docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('selectedWardrobes')
          .doc(date.toIso8601String());

      DocumentSnapshot docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('ไม่มีกิจกรรมของวันนี้'),
            backgroundColor: Colors.black,
            action: SnackBarAction(
              label: 'เพิ่มเลย',
              textColor: Colors.purpleAccent,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WardrobeSelectionPage(
                      selectedDate: todayDate,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      } else {
        await docRef.delete();

        setState(() {
          _events[date]
              ?.removeWhere((event) => event.title == 'Selected Wardrobe');
        });
      }
    }
  }

  String toBuddhistYear(DateTime date) {
    int year = date.year + 543;
    String monthInThai = "ไม่ระบุเดือน";

    switch (date.month) {
      case 1:
        monthInThai = "มกราคม";
        break;
      case 2:
        monthInThai = "กุมภาพันธ์";
        break;
      case 3:
        monthInThai = "มีนาคม";
        break;
      case 4:
        monthInThai = "เมษายน";
        break;
      case 5:
        monthInThai = "พฤษภาคม";
        break;
      case 6:
        monthInThai = "มิถุนายน";
        break;
      case 7:
        monthInThai = "กรกฎาคม";
        break;
      case 8:
        monthInThai = "สิงหาคม";
        break;
      case 9:
        monthInThai = "กันยายน";
        break;
      case 10:
        monthInThai = "ตุลาคม";
        break;
      case 11:
        monthInThai = "พฤศจิกายน";
        break;
      case 12:
        monthInThai = "ธันวาคม";
        break;
    }

    return '${date.day} $monthInThai $year';
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(imageUrl);
    } else {
      return const SizedBox.shrink();
    }
  }
}
