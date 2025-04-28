import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class FCMManager {
  // 싱글톤 패턴 구현
  static final FCMManager _instance = FCMManager._internal();
  factory FCMManager() => _instance;
  FCMManager._internal();

  final _firestore = FirebaseFirestore.instance;
  static const int maxRetries = 3;

  // 외부에서 호출할 유일한 public 메서드
  Future<bool> sendPushMessage(
      String userType, String uid, String title, String description) async {
    try {
      print('1. Checking user type and uid: $userType, $uid');

      // 1. 사용자의 FCM 토큰 확인
      final userToken = await _getUserToken(userType, uid);
      print(
          '2. User token fetch result: ${userToken != null ? "Found" : "Not found"}');
      if (userToken == null) {
        print('User token not found for user: $uid of type: $userType');
        return false;
      }

      // 2. FCM 서버 토큰 확인 및 갱신
      final serverToken = await _getValidServerToken();
      print(
          '3. Server token fetch result: ${serverToken != null ? "Found" : "Not found"}');
      if (serverToken == null) {
        print('Failed to get valid server token');
        return false;
      }

      // 3. 메시지 발송
      print('4. Attempting to send message...');
      final success =
          await _sendMessage(userToken, serverToken, title, description);
      print('5. Message send result: $success');

      return success;
    } catch (e, stackTrace) {
      print('Detailed error in sendPushMessage:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<String?> _getUserToken(String userType, String userUid) async {
    try {
      final docSnapshot = userType == 'com'
          ? await FirebaseFirestore.instance
              .collection('cargoComInfo')
              .doc(userUid)
              .get()
          : await FirebaseFirestore.instance
              .collection('user_${userType}')
              .doc(userUid)
              .get();

      if (!docSnapshot.exists) {
        print('User document not found');
        return null;
      }

      final data = docSnapshot.data();
      if (data == null || !data.containsKey('token')) {
        print('Token field not found in user document');
        return null;
      }

      final token = data['token'] as String?;
      if (token == null || token.isEmpty) {
        print('Token is null or empty');
        return null;
      }

      return token;
    } catch (e) {
      print('Error fetching user token: $e');
      return null;
    }
  }

  // FCM 서버 토큰 가져오기 (필요시 갱신)
  Future<String?> _getValidServerToken() async {
    try {
      // 토큰 문서 확인
      final dateDoc =
          await _firestore.collection('pushToken').doc('date').get();
      final tokenDoc =
          await _firestore.collection('pushToken').doc('token').get();

      if (!dateDoc.exists || !tokenDoc.exists) {
        print('Token or date document does not exist');
        return await _refreshServerToken();
      }

      // 토큰 만료 여부 확인
      final tokenData = tokenDoc.data();
      final dateData = dateDoc.data();

      print('Current token data: $tokenData'); // 현재 토큰 데이터 확인

      if (dateData == null ||
          tokenData == null ||
          !dateData.containsKey('finalDate') ||
          !tokenData.containsKey('token')) {
        print('Missing required fields in documents');
        return await _refreshServerToken();
      }

      final lastRefreshDate = dateData['finalDate'].toDate();
      if (DateTime.now().difference(lastRefreshDate).inHours >= 1) {
        print('Token expired, refreshing...');
        return await _refreshServerToken();
      }

      final currentToken = tokenData['token'];
      print(
          'Using existing token from Firestore: ${currentToken.toString().substring(0, math.min(20, currentToken.toString().length))}...');

      return currentToken;
    } catch (e) {
      print('Error in getValidServerToken: $e');
      return null;
    }
  }

  Future<String?> _refreshServerToken() async {
    try {
      print('Starting token refresh...');
      final response = await http.get(
        Uri.parse(
            'https://refresh-and-store-fcm-token-y3iac4yzjq-uc.a.run.app'),
        headers: {'Accept': 'text/plain'},
      );

      print('Token refresh response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('Token refresh failed with status: ${response.statusCode}');
        return null;
      }

      final newToken = response.body.trim();
      if (newToken.isEmpty) {
        print('Received empty token from refresh endpoint');
        return null;
      }

      print(
          'New token received: ${newToken.substring(0, math.min(20, newToken.length))}...');

      // Verify token format before saving
      if (!newToken.startsWith('ya29.') && !newToken.startsWith('Bearer ')) {
        print('Invalid token format received');
        return null;
      }

      // Firestore에 토큰 저장
      await Future.wait([
        _firestore.collection('pushToken').doc('token').set({
          'token': newToken,
          'updatedAt': DateTime.now(),
        }),
        _firestore.collection('pushToken').doc('date').set({
          'finalDate': DateTime.now(),
        }),
      ]);

      return newToken;
    } catch (e) {
      print('Error in refreshServerToken: $e');
      return null;
    }
  }

  Future<bool> _sendMessage(String userToken, String serverToken, String title,
      String description) async {
    try {
      print('Server token: $serverToken'); // 토큰 확인용 로그

      // Authorization 헤더에 'Bearer ' 접두사가 없는 경우를 처리
      final authToken = serverToken.startsWith('Bearer ')
          ? serverToken
          : 'Bearer $serverToken';

      print('Using Authorization header: $authToken'); // 최종 인증 헤더 확인

      final response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/mixcall/messages:send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authToken,
        },
        body: json.encode({
          "message": {
            "token": userToken,
            "notification": {
              "title": title,
              "body": description,
            },
            "android": {
              "notification": {
                "click_action": "Android Click Action",
              }
            },
            "apns": {
              "payload": {
                "aps": {"category": "Message Category", "content-available": 1}
              }
            }
          }
        }),
      );

      print('FCM Response status code: ${response.statusCode}');
      print('FCM Response body: ${response.body}');

      if (response.statusCode != 200) {
        print(
            'Error sending message. Status: ${response.statusCode}, Body: ${response.body}');
        return false;
      }

      return true;
    } catch (e, stackTrace) {
      print('Error in _sendMessage: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /* // 필요한 경우 로컬 알림도 표시
  Future<void> showLocalNotification(String title, String description) async {
    final NotificationDetails details = const NotificationDetails(
      android: AndroidNotificationDetails('alarm 1', '1번 푸시'),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await FlutterLocalNotificationsPlugin().show(
      0, title, description, details, 
      payload: 'deepLink'
    );
  } */
}
