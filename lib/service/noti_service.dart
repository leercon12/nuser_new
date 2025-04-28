/* import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

Future<void> sendNoti(
    String ownerType, String uid, String title, String dis, context) async {
  String _uid;
  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
      .collection('user_$ownerType')
      .doc(uid)
      .get();

  if (userSnapshot.exists) {
    // 사용자 문서가 존재하는 경우
    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

    _uid = userData['uid'];
    await state(title, dis, userData['token'].toString(), context);
  } else {
    // 사용자 문서가 존재하지 않는 경우
    // 예외 처리 또는 해당 사실을 처리하는 코드를 작성할 수 있습니다.
  }
}

Future state(String title, String dis, String userToken, context) async {
  DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance
          .collection('pushToken')
          .doc('token')
          .get();

  if (documentSnapshot.exists) {
    Map<String, dynamic>? data = documentSnapshot.data();
    // 여기서 data를 통해 문서의 정보에 접근할 수 있습니다.
    if (data != null) {
      String key = data['token']; // 예시: 문서의 'token' 필드에 저장된 값
      await postMessage(userToken, key, title, dis, context);
    }
  }
}

bool isServerTimeEarlierThanOneHour(DateTime serverTime) {
  DateTime currentTime = DateTime.now();
  Duration difference = currentTime.difference(serverTime);
  return difference.inHours > 1;
}

Future fetchData(context) async {
  var url =
      Uri.parse('https://refresh-and-store-fcm-token-y3iac4yzjq-uc.a.run.app');
  await http.get(url);

  await FirebaseFirestore.instance
      .collection('pushToken')
      .doc('date')
      .update({'finalDate': DateTime.now()});

  await Future.delayed(const Duration(seconds: 2));
}

Future<String?> postMessage(String fcmToken, String accessToken, String title,
    String dis, context) async {
  try {
    print('시작');

    http.Response _response = await http.post(
        Uri.parse(
          "https://fcm.googleapis.com/v1/projects/mixcall/messages:send",
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          "message": {
            "token": fcmToken.toString(),
            // "topic": "user_uid",

            "notification": {
              "title": title.toString(),
              "body": dis.toString(),
            },
            "data": {
              "click_action": "FCM Test Click Action",
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
        }));

    if (_response.statusCode == 200) {
      print('성공');
      return _response.statusCode.toString();
    } else {
      // await fetchData();
      return "실패";
    }
  } on HttpException catch (error) {
    return error.message;
  }
}
 */