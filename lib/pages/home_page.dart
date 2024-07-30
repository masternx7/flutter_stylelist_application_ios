import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stylelist/pages/calendar_page.dart';
import 'package:stylelist/pages/home.dart';
import 'package:stylelist/pages/profile.dart';
import 'package:stylelist/pages/wardrobe.dart';

class HomePage extends StatefulWidget {
  static const String id = 'HomePage';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      const HomeScreen(),
      const WardrobeScreen(),
      const CalendarPage(), 
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _tabs[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        items: [
          CurvedNavigationBarItem(
            child: Icon(Icons.home,
                size: 20,
                color: _selectedIndex == 0 ? Colors.white : Colors.black),
            label: 'หน้าแรก',
          ),
          CurvedNavigationBarItem(
            child: Icon(MdiIcons.wardrobe,
                size: 20,
                color: _selectedIndex == 1 ? Colors.white : Colors.black),
            label: 'ตู้เสื้อผ้า',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.calendar_month,
                size: 20,
                color: _selectedIndex == 2 ? Colors.white : Colors.black),
            label: 'ปฏิทิน',
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.account_box,
                size: 20,
                color: _selectedIndex == 3 ? Colors.white : Colors.black),
            label: 'โปรไฟล์',
          ),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.deepPurpleAccent,
        backgroundColor: Colors.grey.shade50,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}


