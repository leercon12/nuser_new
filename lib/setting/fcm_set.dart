import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:http/http.dart' as http;

class FCMTokenManager {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initializeAndUpdateToken() async {
    try {
      // FCM 권한 요청
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 새 토큰 가져오기
        String? newToken = await _firebaseMessaging.getToken();

        if (newToken != null) {
          // 서버에 토큰 업데이트
          await updateTokenOnServer(newToken);

          print('새로운 FCM 토큰이 발급되어 서버에 업데이트되었습니다: $newToken');
        }
      }
    } catch (e) {
      print('토큰 초기화 및 업데이트 실패: $e');
    }
  }

  User? _user = FirebaseAuth.instance.currentUser;
  // 서버에 토큰 업데이트하는 함수
  Future<void> updateTokenOnServer(String newToken) async {
    try {
      // TODO: 실제 서버 엔드포인트로 변경해야 함
      await FirebaseFirestore.instance
          .collection('user_normal')
          .doc(_user!.uid)
          .update({'token': newToken});
    } catch (e) {
      print('서버 토큰 업데이트 실패: $e');
      throw e;
    }
  }

  // 토큰 갱신 리스너 설정
  void setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((String token) async {
      try {
        await updateTokenOnServer(token);

        print('토큰이 갱신되어 서버에 업데이트되었습니다: $token');
      } catch (e) {
        print('토큰 갱신 업데이트 실패: $e');
      }
    });
  }
}
