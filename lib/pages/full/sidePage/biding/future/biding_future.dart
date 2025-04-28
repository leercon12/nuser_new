import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/fcm_noti/fcm.dart';
import 'package:flutter_mixcall_normaluser_new/service/noti_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';

Future selDriverProposal(
  DataProvider dataProvider,
  Map<String, dynamic> data,
  context,
) async {
  if (dataProvider.selectedCargo != null) {
    await FirebaseFirestore.instance
        .collection('user_driver')
        .doc(data['uid'])
        .collection('biding')
        .doc(dataProvider.selectedCargo!['id'])
        .update({
      'choiceTime': DateTime.now(),
      'isChoice': true,
    });

    await FirebaseFirestore.instance
        .collection('cargoInfo')
        .doc(dataProvider.selectedCargo!['uid'])
        .collection(extractFour(dataProvider.selectedCargo!['id']))
        .doc(dataProvider.selectedCargo!['id'])
        .update({
      'confirmUser': data['uid'],
      'conDate': DateTime.now(),
      'conMoney': data['price'],
      'conComUid': data['comUid'],
    });

    await FirebaseFirestore.instance
        .collection('cargoLive')
        .doc(data['cargoId'])
        .update({
      'confirmUser': data['uid'],
      'conDate': DateTime.now(),
      'conMoney': data['price'],
      'conComUid': data['comUid'],
    });
  }

  await FirebaseFirestore.instance
      .collection('msg')
      .doc('user')
      .collection(data['uid'])
      .doc()
      .set({
    'sender': data['uid'],
    'comUid': null,
    'comUser': null,
    'normalUid': data['normalUid'],
    'callType': '가격제안_승락',
    'cargoId': data['cargoId'],
    'date': DateTime.now(),
  });
  final fcmManager = FCMManager();
  try {
    print('Starting push message sending process...'); // 시작 로그
    final result = await fcmManager.sendPushMessage('driver', data['uid'],
        '🎊운송료 제안이 승락되었습니다.', '✅제안하신 운송료가 승락되었습니다. 3분이내에 운송 여부를 선택하세요.');

    print('Push message result: $result'); // 결과 로그

    if (!result) {
      print('Push message failed to send but did not throw an error');
    }
  } catch (e, stackTrace) {
    print('Error sending push message: $e');
    print('Stack trace: $stackTrace');
  }

  /*  await sendNoti('normal', data['uid'], '가격제안이 승락되었습니다.',
      '제안하신 가격이 승락되었습니다. 배차를 받으려면, 배차 받기를 클릭하세요.', context); */
}

Future selComProposal(
  DataProvider dataProvider,
  Map<String, dynamic> data,
  context,
) async {
  if (dataProvider.selectedCargo != null) {
    await FirebaseFirestore.instance
        .collection('cargoInfo')
        .doc(dataProvider.selectedCargo!['uid'])
        .collection(extractFour(dataProvider.selectedCargo!['id']))
        .doc(dataProvider.selectedCargo!['id'])
        .update({
      'confirmUser': data['comUid'],
      'conDate': DateTime.now(),
      'conMoney': data['price'],
      'conComUid': data['comUid'],
    });

    await FirebaseFirestore.instance
        .collection('cargoLive')
        .doc(data['cargoId'])
        .update({
      'confirmUser': data['comUid'],
      'conDate': DateTime.now(),
      'conMoney': data['price'],
      'conComUid': data['comUid'],
    });
  }

  // 첫 번째 Firestore 업데이트

  //

  await FirebaseFirestore.instanceFor(
          app: FirebaseFirestore.instance.app, databaseId: 'mixcallcompany')
      .collection(data['comUid'])
      .doc('msg')
      .set({
    'sender': data['uid'],
    'comUid': null,
    'comUser': null,
    'normalUser': data['normalUid'],
    'callType': '가격제안_승락',
    'cargoId': data['cargoId'],
    'date': DateTime.now(),
  });

  final fcmManager = FCMManager();

  // 여기서 회사 uid가 들어가야되.
  try {
    print('Starting push message sending process...'); // 시작 로그
    final result = await fcmManager.sendPushMessage('com', data['comUid'],
        '🎊운송료 제안이 승락되었습니다.', '✅제안하신 운송료가 승락되었습니다. 3분이내에 운송 여부를 선택하세요.');

    print('Push message result: $result'); // 결과 로그

    if (!result) {
      print('Push message failed to send but did not throw an error');
    }
  } catch (e, stackTrace) {
    print('Error sending push message: $e');
    print('Stack trace: $stackTrace');
  }

/*   await sendNoti('com', data['uid'], '가격제안이 승락되었습니다.',
      '제안하신 가격이 승락되었습니다. 배차를 받으려면, 배차 받기를 클릭하세요.', context); */
}

Future bidingCancel(
  DataProvider dataProvider,
  Map<String, dynamic> data,
  context,
) async {
  await FirebaseFirestore.instance
      .collection('cargoLive')
      .doc(data['cargoId'])
      .update({
    'confirmUser': null,
    'conDate': null,
    'conMoney': null,
    'conComUid': null,
  });

  await FirebaseFirestore.instance
      .collection('user_driver')
      .doc(data['uid'])
      .collection('biding')
      .doc(dataProvider.selectedCargo!['id'])
      .update({
    'choiceTime': null,
    'isChoice': false,
  });

  if (data['comUid'] == null) {
    await FirebaseFirestore.instance
        .collection('cargoInfo')
        .doc(dataProvider.selectedCargo!['uid'])
        .collection(extractFour(dataProvider.selectedCargo!['id']))
        .doc(dataProvider.selectedCargo!['id'])
        .update({
      'confirmUser': null,
      'conDate': null,
      'conMoney': null,
      'conComUid': null,
    });

    await FirebaseFirestore.instance
        .collection('msg')
        .doc('user')
        .collection(data['uid'])
        .doc()
        .set({
      'sender': data['uid'],
      'comUid': null,
      'comUser': null,
      'normalUser': data['normalUid'],
      'callType': '가격제안_취소',
      'cargoId': data['cargoId'],
      'date': DateTime.now(),
    });

    /*  await sendNoti('normal', data['uid'], '제안 수락이 취소되었습니다.',
        '사용자가 제안하신 가격 수락을 취소하였습니다.', context); */
  } else {
    await FirebaseFirestore.instanceFor(
            app: FirebaseFirestore.instance.app, databaseId: 'mixcallcompany')
        .collection(data['comUid'])
        .doc('biding')
        .collection(extractFour(data['cargoId']))
        .doc(data['cargoId'])
        .update({
      'confirmUser': null,
      'conDate': null,
      'conMoney': null,
      'conComUid': null,
    });

    await FirebaseFirestore.instance
        .collection('msg')
        .doc('user')
        .collection(data['ownerUid'])
        .doc()
        .set({
      'sender': data['uid'],
      'comUid': data['comUid'],
      'comUser': data['uid'],
      'normalUid': data['normalUid'],
      'callType': '가격제안_취소',
      'cargoId': data['cargoId'],
      'date': DateTime.now(),
    });

    /*  await sendNoti('com', data['uid'], '제안 수락이 취소되었습니다.',
        '사용자가 제안하신 가격 수락을 취소하였습니다.', context); */
  }
}

Future bidingComCancel(
  DataProvider dataProvider,
  Map<String, dynamic> data,
  context,
) async {
  await FirebaseFirestore.instance
      .collection('cargoLive')
      .doc(data['cargoId'])
      .update({
    'confirmUser': null,
    'conDate': null,
    'conMoney': null,
    'conComUid': null,
  });

  await FirebaseFirestore.instance
      .collection('cargoInfo')
      .doc(dataProvider.selectedCargo!['uid'])
      .collection(extractFour(dataProvider.selectedCargo!['id']))
      .doc(dataProvider.selectedCargo!['id'])
      .update({
    'confirmUser': null,
    'conDate': null,
    'conMoney': null,
    'conComUid': null,
  });

  await FirebaseFirestore.instance
      .collection('msg')
      .doc('user')
      .collection(data['uid'])
      .doc()
      .set({
    'sender': data['uid'],
    'comUid': null,
    'comUser': null,
    'normalUser': data['normalUid'],
    'callType': '가격제안_취소',
    'cargoId': data['cargoId'],
    'date': DateTime.now(),
  });

  /*  await sendNoti('normal', data['uid'], '제안 수락이 취소되었습니다.',
        '사용자가 제안하신 가격 수락을 취소하였습니다.', context); */
}
