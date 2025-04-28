import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );

  if (await canLaunchUrl(launchUri)) {
    await launchUrl(launchUri);
  } else {
    throw '전화를 걸 수 없습니다: $phoneNumber';
  }
}

/// 전화번호검색
Future<bool> isEmailAlreadyRegistered(String email) async {
  try {
    // 이메일에 대한 로그인 방법을 가져옵니다.
    List<String> methods =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

    // 로그인 방법이 존재한다면 (리스트가 비어있지 않다면) 이미 등록된 이메일입니다.
    return methods.isNotEmpty;
  } catch (e) {
    print('Error checking email registration: $e');
    // 에러 발생 시 false를 반환하거나, 에러를 다시 던질 수 있습니다.
    // throw e; // 에러를 다시 던지려면 이 줄의 주석을 해제하세요.
    return false; // 또는 에러 발생 시 false를 반환합니다.
  }
}

double getDistance(NLatLng point1, NLatLng point2) {
  return point1.distanceTo(point2);
}

String formatDistance(double distanceInMeters) {
  if (distanceInMeters >= 1000) {
    return '${(distanceInMeters / 1000).toStringAsFixed(2)}km';
  } else {
    return '${distanceInMeters.toStringAsFixed(0)}m';
  }
}
