import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<String> generateUniqueString(String uid, DateTime update) async {
  String uniqueString = ''; // Initialize with an empty string

  // 현재 날짜를 YYYYMMDD 형식으로 포맷팅
  DateTime now = update;
  String formattedDate =
      '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

  // uid의 앞 5자
  //String uidPrefix = uid.substring(0, 5);
  String uidPrefix = uid;
  String year = DateTime.now().year.toString();
  // Firestore 인스턴스
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 고유한 ID를 생성하고 Firestore에서 확인
  bool isUnique = false;

  while (!isUnique) {
    // 10자리 랜덤 숫자 생성

    String randomNumbers = generateRandomString(8);

    // 최종 문자열 생성
    uniqueString = '$formattedDate$uidPrefix$randomNumbers';

    // Firestore 트랜잭션 사용
    await firestore.runTransaction((transaction) async {
      DocumentReference docRef = firestore
          .collection('cargoInfo')
          .doc(uid)
          .collection(DateTime.now().year.toString())
          .doc(uniqueString);

      DocumentSnapshot docSnapshot = await transaction.get(docRef);

      if (!docSnapshot.exists) {
        // 문서가 존재하지 않으면 새 문서 생성
        transaction.set(docRef, {'existsCheck': true});
        isUnique = true;
      }
    }).catchError((error) {
      print('Transaction failed: $error');
    });
  }

  return uniqueString;
}

String generateRandomString(int length) {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'; // Characters to use for random string
  Random random = Random();
  return List.generate(length, (index) {
    int randIndex = random.nextInt(chars.length);
    return chars[randIndex];
  }).join();
}

Future<String?> uploadImage2(
    Uint8List imageBytes, String coll, String coll2, String filename2) async {
  try {
    // Firebase 초기화
    await Firebase.initializeApp();

    DateTime now = DateTime.now();

    // Storage에 대한 참조 생성
    String uniqueId = '${filename2}_cargo.png';
    Reference ref =
        FirebaseStorage.instance.ref().child("images/$coll/$coll2/$uniqueId");

    // 이미지 업로드
    UploadTask uploadTask = ref.putData(imageBytes);
    TaskSnapshot snapshot = await uploadTask;

    // 업로드된 이미지의 URL 가져오기
    String downloadURL = await snapshot.ref.getDownloadURL();

    return downloadURL;
  } catch (e) {
    print("Error uploading image: $e");
    return null;
  }
}
