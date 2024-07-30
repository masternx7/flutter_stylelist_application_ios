import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stylelist/pages/about_page.dart';
import 'package:stylelist/pages/repository/auth.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _profileImageUrl = FirebaseAuth.instance.currentUser?.photoURL;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'โปรไฟล์',
          style: TextStyle(
              fontSize: 20, color: Colors.black, fontWeight: FontWeight.normal),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 55,
                      backgroundImage: NetworkImage(
                        _profileImageUrl ?? 'path/to/default/image.jpg',
                      ),
                      backgroundColor: Colors.grey[300],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                FirebaseAuth.instance.currentUser?.displayName ?? 'ไม่ระบุชื่อ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ProfileMenuWidget(
                        title: "ข้อมูลส่วนตัว",
                        icon: MdiIcons.account,
                        onPress: () => _openEditNameModal(context)),
                    ProfileMenuWidget(
                      title: "เกี่ยวกับแอป",
                      icon: Icons.update,
                      onPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AboutScreen()),
                        );
                      },
                    ),
                    ProfileMenuWidget(
                      title: "ติดต่อเรา",
                      icon: Icons.contact_mail,
                      onPress: () async {
                        const url = 'https://www.facebook.com/nontapatxnon';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ไม่สามารถเปิด Facebook ได้'),
                            ),
                          );
                        }
                      },
                    ),
                    ProfileMenuWidget(
                      title: "ออกจากระบบ",
                      icon: Icons.exit_to_app,
                      onPress: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              title: const Text('ยืนยันการออกจากระบบ'),
                              content:
                                  const Text('คุณต้องการออกจากระบบหรือไม่?'),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('ยกเลิก',
                                      style: TextStyle(color: Colors.black)),
                                ),
                                CupertinoDialogAction(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    await Future.delayed(
                                        const Duration(seconds: 2));
                                    AuthMethods().signOut();
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  },
                                  isDefaultAction: true,
                                  child: const Text('ยืนยัน',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      endIcon: false,
                      textColor: Colors.red,
                    ),
                    if (_isLoading)
                      const Center(child: CupertinoActivityIndicator()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateUserData(String name, String email) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      await user.updateEmail(email);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'username': name,
        'email': email,
      });

      setState(() {});
    }
  }

  void _openEditNameModal(BuildContext context) {
    final TextEditingController nameController = TextEditingController(
      text: FirebaseAuth.instance.currentUser?.displayName,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'แก้ไขข้อมูลส่วนตัว',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'ชื่อผู้ใช้งาน',
                        labelStyle: const TextStyle(
                            color: Colors.deepPurple, fontSize: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.grey[400]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: TextEditingController(
                        text: FirebaseAuth.instance.currentUser!.email,
                      ),
                      style: const TextStyle(color: Colors.grey),
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'อีเมล',
                        labelStyle: const TextStyle(
                            color: Colors.deepPurple, fontSize: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.grey[400]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      updateUserData(nameController.text,
                          FirebaseAuth.instance.currentUser!.email!);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('แก้ไขข้อมูลเรียบร้อยแล้ว'),
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'บันทึกข้อมูล',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      try {
        String userId =
            FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        String fileName = '${userId}_$timestamp';

        Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child('user_images/$fileName');
        UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
        TaskSnapshot taskSnapshot = await uploadTask;

        final url = await taskSnapshot.ref.getDownloadURL();

        User? user = FirebaseAuth.instance.currentUser;
        await user?.updatePhotoURL(url);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .update({
          'profilePhoto': url,
        });

        setState(() {
          _profileImageUrl = url;
        });
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _fetchUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        _profileImageUrl =
            userDoc['profilePhoto'] as String? ?? _profileImageUrl;
      });
    }
  }
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.black.withOpacity(0.1),
        ),
        child: Icon(
          icon,
          color: Colors.grey,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle().apply(color: textColor),
      ),
      trailing: endIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.black.withOpacity(0.1),
              ),
              child: const Icon(Icons.keyboard_arrow_right))
          : null,
    );
  }
}
