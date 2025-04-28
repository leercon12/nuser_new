import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/normal/cargo_info.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/new_add_main.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/bottomSheet.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

void driverOut(context, String cargoId, String ownerUid,
    Map<String, dynamic> cargo, String callType) {
  final dw = MediaQuery.of(context).size.width;
  final mapProvider = Provider.of<MapProvider>(context, listen: false);
  final dataProvider = Provider.of<DataProvider>(context, listen: false);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return BottomSheetWidget(
            contents: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.info, size: 70, color: kRedColor),
              const SizedBox(height: 32),
              const KTextWidget(
                  text: '현재 기사 또는 주선사가 지정된 상태입니다.',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              const SizedBox(height: 8),
              const KTextWidget(
                  text:
                      '현재 기사 또는 주선사가 해당 운송건을 진행중입니다. 기사 또는 주선사로부터 취소를 요청받은것이 아니라면, 취소전에 해당 기사 및 주선사에 취소 의사를 알려주세요.',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey),
              const SizedBox(height: 8),
              const KTextWidget(
                  text:
                      '지정된 기사 또는 주선사와 협의 없는 일방적인 취소는 시스템에 저장되어 대상자가 이의를 제기할 수 있으며, 운송 상태에 따라 추가요금 또는 법적 책임이 따를 수 있습니다.',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey),
              const SizedBox(height: 32),
              if (isPassedDate(cargo['upTime'] == null
                      ? cargo['locations'][0]['date'].toDate()
                      : cargo['upTime'].toDate()) ==
                  false)
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context, '재등록');
                  },
                  child: Container(
                    height: 52,
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    width: dw,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: kRedColor),
                    child: const Row(
                      children: [
                        // Icon(Icons.cancel, color: kRedColor, size: 16),
                        Spacer(),
                        KTextWidget(
                            text: '기사 배차 취소 후, 재등록',
                            size: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context, '취소');
                },
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  width: dw,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: kRedColor),
                  child: const Row(
                    children: [
                      // Icon(Icons.cancel, color: kRedColor, size: 16),
                      Spacer(),
                      KTextWidget(
                          text: '기사 배차 취소 후, 운송 취소',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      Spacer(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: const UnderLineWidget(
                      text: '돌아가기',
                      color: Colors.grey,
                      size: 14,
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
      });
    },
  ).then((value) async {
    mapProvider.isLoadingState(true);

    Map<String, dynamic> cancelUser = {
      'user': dataProvider.uid,
      'date': DateTime.now()
    };
    Map<String, dynamic> cancelDriver = {
      'user': cargo['pickUserUid'],
      'date': DateTime.now()
    };

    if (value == '취소') {
      await FirebaseFirestore.instance
          .collection('cargoInfo')
          .doc(cargo['uid'])
          .collection(extractFour(cargo['id']))
          .doc(cargo['id'])
          .update({
        'cargoStat': '취소',
        'pickUserUid': null,
        'cancelUserUid': FieldValue.arrayUnion([cancelUser]),
        'cancelDriver': FieldValue.arrayUnion([cancelDriver]),
        'cancelDate': DateTime.now(),
        'driverBusiness': null,
        'driverBank': null,
        'driverCarInfo': null,
        'driverClass': null,
        'driverName': null,
        'driverPhone': null,
        'driverPhoto': null,
        'driverType': null,
        'fixDate': null,
      });

      await FirebaseFirestore.instance
          .collection('user_driver_cargo')
          .doc(cargo['pickUserUid'])
          .collection('history')
          .doc(cargo['id'])
          .update({'state': '취소'});

      await deleteDocumentsByField(cargo['id'], cargo['pickUserUid']);
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(currentSnackBar('운송건 취소가 완료되었습니다.', context));
    }

    if (value == '재등록') {
      await resetState(cargo, context).then((value) async {
        if (value == true) {
          bool driverDel =
              await deleteDocumentsByField(cargo['id'], cargo['pickUserUid']);

          if (driverDel == true) {
            await FirebaseFirestore.instance
                .collection('cargoInfo')
                .doc(cargo['uid'])
                .collection(extractFour(cargo['id']))
                .doc(cargo['id'])
                .update({
              'cargoStat': '대기',
              'pickUserUid': null,
              'cancelUserUid': FieldValue.arrayUnion([cancelUser]),
              'cancelDriver': FieldValue.arrayUnion([cancelDriver]),
              'cancelDate': DateTime.now(),
              'driverBusiness': null,
              'driverBank': null,
              'driverCarInfo': null,
              'driverClass': null,
              'driverName': null,
              'driverPhone': null,
              'driverPhoto': null,
              'driverType': null,
              'fixDate': null,
            });

            await FirebaseFirestore.instance
                .collection('user_driver_cargo')
                .doc(cargo['pickUserUid'])
                .collection('history')
                .doc(cargo['id'])
                .update({'state': '취소'});

            await deleteBidingCollection(cargo['uid'], cargo['id']);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewAddMainPage(
                        callType: '${callType}_재등록',
                        cargo: cargo,
                      )),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                errorSnackBar('문제가 발생했습니다.\n잠시 후 다시 시도하세요.', context));
          }
        }
      });
    }

    await FirebaseFirestore.instance
        .collection('cargoInfo')
        .doc(cargo['uid'])
        .collection(extractFour(cargo['id']))
        .doc(cargo['id'])
        .collection('cancel')
        .doc()
        .set({'data': DateTime.now(), 'type': value, 'user': dataProvider.uid});

    mapProvider.isLoadingState(false);
  });
}

Future<bool> deleteDocumentsByField(String cargoId, String pickUserUid) async {
  try {
    // cargoId로 문서들 조회
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('user_driver_cargo')
        .doc(pickUserUid)
        .collection('cargo_info')
        .where('cargoId', isEqualTo: cargoId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      print('No matching documents found to delete');
      return true; // 삭제할 문서가 없는 것도 성공으로 간주
    }

    // 문서 삭제 진행
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.delete();
      print('Document deleted: ${doc.id}');
    }

    // 삭제 후 해당 cargoId를 가진 문서가 완전히 삭제되었는지 확인
    final verifySnapshot = await FirebaseFirestore.instance
        .collection('user_driver_cargo')
        .doc(pickUserUid)
        .collection('cargo_info')
        .where('cargoId', isEqualTo: cargoId)
        .get();

    final success = verifySnapshot.docs.isEmpty;
    if (success) {
      print('Successfully deleted all documents with cargoId: $cargoId');
    } else {
      print('Failed to delete some documents with cargoId: $cargoId');
    }
    return success;
  } catch (e) {
    print('Error in deleteDocumentsByField: $e');
    return false;
  }
}

Future<void> deleteBidingCollection(String userUid, String cargoId) async {
  try {
    // 먼저 'biding' 컬렉션의 모든 문서를 가져옵니다
    final bidingRef = FirebaseFirestore.instance
        .collection('cargoInfo')
        .doc(userUid)
        .collection(extractFour(cargoId))
        .doc(cargoId)
        .collection('biding');

    final QuerySnapshot snapshot = await bidingRef.get();

    // 문서가 있는 경우에만 배치 삭제 실행
    if (snapshot.docs.isNotEmpty) {
      // 배치 작업 시작
      WriteBatch batch = FirebaseFirestore.instance.batch();
      int count = 0;

      for (DocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
        count++;

        // Firebase는 배치당 최대 500개로 제한되어 있으므로
        // 500개가 되면 커밋하고 새로운 배치 시작
        if (count == 500) {
          await batch.commit();
          batch = FirebaseFirestore.instance.batch();
          count = 0;
        }
      }

      // 남은 문서들 삭제
      if (count > 0) {
        await batch.commit();
      }

      print('Successfully deleted all documents in biding collection');
    } else {
      print('No documents found in biding collection');
    }
  } catch (e) {
    print('Error deleting biding collection: $e');
    throw e;
  }
}
