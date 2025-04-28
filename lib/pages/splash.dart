import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/pages/homePage.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/main_page.dart';
import 'package:flutter_mixcall_normaluser_new/service/firebase/remoteconfig.dart';
import 'package:flutter_mixcall_normaluser_new/setting/fcm_set.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
    RemoteConfigService.getInstance(context);
    getCurrentVersion().then((version) => ver2 = version);
  }

  String? ver2;
  Future<void> _initializeApp() async {
    // FCM 토큰 생성 및 업데이트
    await _createFCMToken();
  }

  Future<void> _createFCMToken() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.deleteToken();
      String? token = await messaging.getToken();

      if (token != null) {
        await FirebaseFirestore.instance
            .collection('user_normal')
            .doc(user.uid)
            .update({'token': token});
        print('FCM 토큰 업데이트 완료: $token');
      } else {
        print('FCM 토큰을 가져올 수 없습니다.');
      }
    } catch (e) {
      print('FCM 토큰 생성 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 초기 로딩 상태 처리
              return Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Center(
                  child: Image.asset(
                    'asset/img/logo.png',
                    width: 300,
                  ),
                ),
              );
            }

            return AnimatedSplashScreen(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              splash: Container(
                  child: Image.asset(
                'asset/img/logo.png',
                width: 300,
              )),
              duration: 1300,
              animationDuration: const Duration(milliseconds: 500),
              nextScreen: snapshot.data == null
                  ? const HomePage()
                  : MainMapPage(
                      version: ver2.toString(),
                    ),
            );
          }),
    );
  }
}
