import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_mixcall_normaluser_new/pages/full/normal/cargo_info.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/new_add_main.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/bottomSheet.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

Future<bool?> cargoDelete(context, String cargoId, String ownerUid) async {
  final dw = MediaQuery.of(context).size.width;
  final mapProvider = Provider.of<MapProvider>(context, listen: false);

  // showModalBottomSheet의 결과를 반환값으로 받습니다
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return BottomSheetWidget(
            contents: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min, // 내용에 맞게 크기 조정
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.info, size: 70, color: kRedColor),
              const SizedBox(height: 32),
              const KTextWidget(
                  text: '화물 운송 요청을 취소합니다.',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              const KTextWidget(
                  text: '화물 운송 요청건을 취소하고, 관련 데이터를 모두 삭제합니다.',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey),
              const KTextWidget(
                  text: '취소를 계속하시려면 아래 버튼을 클릭하세요.',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context, true); // true 반환
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
                      Spacer(),
                      KTextWidget(
                          text: '화물 운송 취소',
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
                      Navigator.pop(context, false); // false 반환
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
  );

  return result; // 반환된 값을 그대로 반환
}

Future<void> deleteCargoWithSubcollections(
    String ownerUid, String cargoId) async {
  final String mainPath =
      'cargoInfo/$ownerUid/${extractFour(cargoId)}/$cargoId';
  final DocumentReference docRef = FirebaseFirestore.instance.doc(mainPath);

  // 문서의 모든 하위 컬렉션 가져오기
  final collections = await docRef.get().then((snapshot) async {
    if (!snapshot.exists) return;

    // 하위 컬렉션 목록 가져오기 (알고 있는 하위 컬렉션 이름들)
    final knownSubCollections = [
      'bidng',
    ]; // 실제 하위 컬렉션 이름으로 수정

    // 각 하위 컬렉션 삭제
    for (String collectionName in knownSubCollections) {
      final collectionPath = '$mainPath/$collectionName';
      await deleteCollectionBatch(collectionPath);
    }

    // 최종적으로 문서 자체를 삭제
    await docRef.delete();
  });
}

Future<void> deleteCollectionBatch(String collectionPath) async {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final int batchSize = 100;

  var query = db.collection(collectionPath).limit(batchSize);
  int deleted = 0;

  while (true) {
    final QuerySnapshot snapshot = await query.get();

    if (snapshot.docs.isEmpty) {
      break;
    }

    final WriteBatch batch = db.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
      deleted++;
    }

    await batch.commit();

    if (snapshot.docs.length < batchSize) {
      break;
    }

    query = db.collection(collectionPath).limit(batchSize);
  }

  print('Deleted $deleted documents');
}

void cargoReset(
    context, String cargoId, String ownerUid, Map<String, dynamic> cargo) {
  final dw = MediaQuery.of(context).size.width;
  final mapProvider = Provider.of<MapProvider>(context, listen: false);
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
              const Icon(Icons.info, size: 70, color: kOrangeAssetColor),
              const SizedBox(height: 32),
              const KTextWidget(
                  text: '수정 동안 기사에 노출되지 않습니다.',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              const KTextWidget(
                  text: '운송 정보 수정기간에는 기사에게 노출되지 않습니다.',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey),
              const KTextWidget(
                  text: '수정 완료 후, 반드시 완료를 선택하세요.',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey),
              const KTextWidget(
                  text: '수정시, 기존 제안은 모두 삭제됩니다.',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context, true);
                },
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  width: dw,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: kOrangeAssetColor),
                  child: const Row(
                    children: [
                      // Icon(Icons.cancel, color: kRedColor, size: 16),
                      Spacer(),
                      KTextWidget(
                          text: '화물 운송 수정',
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
    if (value == true) {
      await resetState(cargo, context).then((value) async {
        print(value);

        print('@@@@@@@@@@@@@@@@');
        await FirebaseFirestore.instance
            .collection('cargoLive')
            .doc(cargoId)
            .update({'isShow': false});
        await FirebaseFirestore.instance
            .collection('cargoInfo')
            .doc(ownerUid)
            .collection(extractFour(cargoId))
            .doc(cargoId)
            .update({'isShow': false});
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => NewAddMainPage(
                    callType: '수정',
                    cargo: cargo,
                  )),
        );
      });
    }
  });
}

void cargoDriverSet(
    context, String cargoId, String ownerUid, Map<String, dynamic> cargo) {
  final dw = MediaQuery.of(context).size.width;
  final mapProvider = Provider.of<MapProvider>(context, listen: false);
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
              const Icon(Icons.info, size: 70, color: kOrangeAssetColor),
              const SizedBox(height: 32),
              const KTextWidget(
                  text: '현재 기사가 운송중입니다.',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              const SizedBox(height: 8),
              const KTextWidget(
                  text:
                      '운송중인 기사와 협의되지 않은 정보 수정은 문제가 될 수 있습니다. 반드시 기사 또는 담당 주선사와 통화를 통해 정보 수정 문제를 협의하세요.',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey),
              const SizedBox(height: 8),
              const KTextWidget(
                  text:
                      '반드시, 기사 또는 주선사와 협의가 된 상태에서 정보를 수정해야 합니다. 수정 기록은 시스템에 저장되며, 협의 되지 않은 수정으로 인해 발생되는 문제의 책임은 본인에게 있습니다.',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context, true);
                },
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  width: dw,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: kOrangeAssetColor),
                  child: const Row(
                    children: [
                      // Icon(Icons.cancel, color: kRedColor, size: 16),
                      Spacer(),
                      KTextWidget(
                          text: '화물 운송 수정',
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
    if (value == true) {
      await resetState(cargo, context).then((value) async {
        if (value == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewAddMainPage(
                      callType: '수정_기사업데이트',
                      cargo: cargo,
                    )),
          );
        }
      });
    }
  });
}

void cargoReCon(context, String cargoId, String ownerUid,
    Map<String, dynamic> cargo, String callType) {
  final dw = MediaQuery.of(context).size.width;
  final mapProvider = Provider.of<MapProvider>(context, listen: false);
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
              const Icon(Icons.info, size: 70, color: kGreenFontColor),
              const SizedBox(height: 32),
              const KTextWidget(
                  text: '운송 정보를 수정하고, 재등록합니다.',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              const KTextWidget(
                  text: '이전 운송정보를 활용하여 새로운 운송요청을 등록합니다.',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey),
              const KTextWidget(
                  text: '상차일, 하차일 정보를 꼭 수정하세요.',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context, true);
                },
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  width: dw,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: kGreenFontColor),
                  child: const Row(
                    children: [
                      // Icon(Icons.cancel, color: kRedColor, size: 16),
                      Spacer(),
                      KTextWidget(
                          text: '화물 운송 재등록',
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
    if (value == true) {
      await resetState(cargo, context).then((value) async {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => NewAddMainPage(
                    callType: callType + '_완료다시등록',
                    cargo: cargo,
                  )),
        );
      });
    }
  });
}



/* if (cargo['comUid'] != null) {
        await FirebaseFirestore.instanceFor(
                app: FirebaseFirestore.instance.app,
                databaseId: 'mixcallcompany')
            .collection(cargo['comUid'])
            .doc('cargoInfo')
            .collection(extractFour(cargo['id']))
            .doc(cargo['id'])
            .update({
          'cargoStat': '취소',
          'pickUserUid': null,
          'cancelUserUid': cargo['pickUserUid'],
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
      } */