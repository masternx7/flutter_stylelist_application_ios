import 'package:flutter/material.dart';
import 'package:stylelist/pages/repository/auth.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthMethods _authMethods = AuthMethods();

  final RoundedLoadingButtonController googleController =
      RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('lib/images/bglogin.png'), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Spacer(),
                  //Logo
                  Image.asset(
                    'lib/images/logo.png',
                    width: 500,
                  ),
                  const Spacer(),
                  const SizedBox(
                    height: 30,
                  ),

                  // Text เข้าสู่ระบบ

                  const Text(
                    "ยินดีต้อนรับ!",
                    style: TextStyle(fontSize: 32, color: Colors.white),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "ลงชื่อเข้าใช้เพื่อเข้าถึงบัญชีของคุณ",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),

                  const SizedBox(
                    height: 50,
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RoundedLoadingButton(
                        controller: googleController,
                        onPressed: () async {
                          var result = await _authMethods.signInWithGoogle();
                          if (result != null) {
                            googleController.success();
                          } else {
                            googleController.error();
                            await Future.delayed(const Duration(seconds: 1));
                            googleController.reset();
                          }
                        },
                        color: Colors.white,
                        valueColor: Colors.black,
                        borderRadius: 25,
                        elevation: 0,
                        width: MediaQuery.of(context).size.width * 0.80,
                        height: 50,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image(
                              image: AssetImage('lib/images/googleicon.png'),
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Sign In with Google",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  //Login with google
                  //login with facebook
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
