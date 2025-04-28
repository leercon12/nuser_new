import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/model/multi_cargo_add_model.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/btn_state/history.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/add_future_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

Future<bool> returnReSet(
    List<CargoLocation> locations,
    AddProvider addProvider,
    HashProvider hashProvider,
    DataProvider dataProvider,
    MapProvider mapProvider,
    Map<String, dynamic> cargo,
    context) async {
  String uniqId = cargo['id'];
  try {
    print('===== 데이터 처리 시작 =====');
    print('시작: Incoming locations length: ${locations.length}');

    if (locations.isEmpty) {
      print('에러: Locations list is empty');
      return false;
    }

    List<Map<String, dynamic>> processedLocations = [];

    // 각 위치 정보를 순차적으로 처리
    for (var i = 0; i < locations.length; i++) {
      var cargo = locations[i];
      try {
        print('처리 시작 - 타입: ${cargo.type}');
        print('현재 처리중인 위치: ${i + 1}/${locations.length}');

        // 1. 위치 정보 암호화
        if (cargo.location == null) {
          print('에러: 위치 정보가 없음 - ${cargo.type}');
          continue;
        }

        final encryptedLocation =
            await hashProvider.encryptNLatLng(cargo.location as NLatLng);
        print('위치 암호화 완료');

        // 2. 화물 처리 (상하차/회차 구분)
        List<Map<String, dynamic>> processedUpCargos = []; // null 대신 빈 리스트로 초기화
        List<Map<String, dynamic>> processedDownCargos =
            []; // null 대신 빈 리스트로 초기화

        if (cargo.upCargos != null && cargo.upCargos.isNotEmpty) {
          print('상차 화물 처리 중: ${cargo.upCargos.length}개');

          for (var cargoInfo in cargo.upCargos) {
            var processedInfo = cargoInfo.toJson();
            if (cargoInfo.imgFile != null) {
              final bytes = await cargoInfo.imgFile!.readAsBytes();
              processedInfo['imgUrl'] = await uploadImage2(bytes, 'cargo',
                  uniqId, 'set_${DateTime.now().millisecondsSinceEpoch}');
            }
            processedUpCargos.add(processedInfo);
          }
        }

// 모든 위치에서 downCargos 처리
        if (cargo.downCargos != null && cargo.downCargos.isNotEmpty) {
          print('하차 화물 처리 중: ${cargo.downCargos.length}개');

          for (var cargoInfo in cargo.downCargos) {
            var processedInfo = cargoInfo.toJson();
            if (cargoInfo.imgFile != null) {
              final bytes = await cargoInfo.imgFile!.readAsBytes();
              processedInfo['imgUrl'] = await uploadImage2(bytes, 'cargo',
                  uniqId, 'set_${DateTime.now().millisecondsSinceEpoch}');
            }
            processedDownCargos.add(processedInfo);
          }
        }

        print('위치 정보 상세: ${cargo.type}, ${cargo.address1}');

        // 3. location 데이터 생성
        final locationData = {
          'type': cargo.type,
          'address1': cargo.address1,
          'address2': cargo.address2,
          'addressDis': cargo.addressDis,
          'location': encryptedLocation,
          'howTo': cargo.howTo,
          'senderType': cargo.senderType,
          'senderName': cargo.senderName,
          'senderPhone': cargo.senderPhone,
          'dateType': cargo.dateType,
          'dateAloneString': cargo.dateAloneString,
          'dateStart': cargo.dateStart,
          'dateEnd': cargo.dateEnd,
          'date': cargo.date,
          'etc': cargo.etc,
          'becareful': cargo.becareful,
          'upCargos': processedUpCargos,
          'downCargos': processedDownCargos,
        };

        processedLocations.add(locationData);
        print(
            '위치 정보 처리 완료: ${cargo.type}, 현재 processedLocations 길이: ${processedLocations.length}');
      } catch (e) {
        print('개별 위치 처리 중 에러 발생:');
        print('위치 인덱스: $i');
        print('위치 타입: ${cargo.type}');
        print('에러 내용: $e');
        continue;
      }
    }

    print('전체 위치 처리 완료. processedLocations 최종 확인:');
    print(processedLocations
        .map((loc) => '타입: ${loc['type']}, 주소: ${loc['address1']}')
        .toList());

    // 4. 모든 위치가 정상적으로 처리되었는지 확인
    if (processedLocations.length != locations.length) {
      print('에러: 처리된 위치 개수 불일치');
      print('원본 위치: ${locations.length}, 처리된 위치: ${processedLocations.length}');
      return false;
    }

    // 5. coordinates 확인
    if (addProvider.coordinates == null || addProvider.coordinates!.isEmpty) {
      print('에러: 좌표 정보 없음');
      return false;
    }
    print('cargoData 생성 직전 상태 확인:');

    print('addProvider.carOption type: ${addProvider.carOption.runtimeType}');
    print('addProvider.carOption: ${addProvider.carOption}');
    print(
        'addProvider.setCarTypeSub type: ${addProvider.setCarTypeSub.runtimeType}');
    print('addProvider.setCarTypeSub: ${addProvider.setCarTypeSub}');
    print(
        'addProvider.coordinates type: ${addProvider.coordinates.runtimeType}');
    print('addProvider.coordinates: ${addProvider.coordinates}');
    print('위치 처리 완료, Firebase 데이터 생성 시작');

    final totalLocations = processedLocations.length;
    print('총 위치 수: $totalLocations');
    final upLocations =
        processedLocations.where((loc) => loc['type'] == '상차').length;
    print('상차 위치 수: $upLocations');
    final downLocations =
        processedLocations.where((loc) => loc['type'] == '하차').length;
    print('하차 위치 수: $downLocations');

    print('------------------------------------!!');
    print(dataProvider.userData!.company[0]);
    final result = analyzeCargoData(addProvider.locations);
    var upPoints = result['상차화물수'];
    var downPoints = result['하차화물수'];
    var maxLoad = result['최대적재정보'];
    final cargoDocRef = FirebaseFirestore.instance
        .collection('cargoInfo')
        .doc(cargo['normalUid'])
        .collection(DateTime.now().year.toString())
        .doc(uniqId);

    final liveRef =
        FirebaseFirestore.instance.collection('cargoLive').doc(uniqId);

    print('cargoData 생성 시작');
    final cargoData = {
      'downTime': processedLocations.last['date'],
      'upTime': processedLocations.first['date'],
      'totalUpcargos': upPoints,
      'totalDowncargos': downPoints,
      'totalCargoInfos': maxLoad,
      'normalUid': dataProvider.userData!.uid,
      'uid': addProvider.senderType == '일반'
          ? dataProvider.userData!.uid
          : dataProvider.userData!.company[0],
      if (addProvider.senderType != '일반')
        'normalUserUid': dataProvider.userData!.uid,
      'locations': processedLocations,
      'carTon': addProvider.setCarTon,
      'carOption': addProvider.carOption,
      'carType': addProvider.setCarType,
      'comUid': null,
      'isBlind': addProvider.setIsBlind,
      'isBiding': true,
      'bidingUsers': [],
      'bidingCom': [],
      'cargoStat': '대기',
      'senderType': addProvider.senderType,
      'isNormal': true,
      'payMoney': null,
      'payType': null,
      'payCommission': null,
      'createdDate': DateTime.now(),
      'sanjea': null,
      'sanjeahalf': null,
      'vat': null,
      'downAloneType': addProvider.setDownTimeAloneType,
      'upAloneType': addProvider.setUpTimeAloneType,
      'pickUserUid': null,
      'pricePerKm': null,
      'allDis': addProvider.totalDistance,
      'allDur': addProvider.totalDuration,
      'allRoute': hashProvider.fastEncryptPath(addProvider.coordinates),
      'upType': addProvider.setLocationCargoUpType,
      'downType': addProvider.setLocationCargoDownType,
      'upComType': addProvider.addUpSenderType,
      'downComType': addProvider.addDownSenderType,
      'isDownTmm': addProvider.isTmm,
      'isWith': addProvider.isWith,
      'id': uniqId,
      'clientType':
          addProvider.senderUpType == true && addProvider.senderDownType == true
              ? '상, 하차지 동일'
              : addProvider.senderUpType == true
                  ? '상차지 동일'
                  : addProvider.senderDownType == true
                      ? '하차지와 동일'
                      : null,
      'clientInfo': '${dataProvider.name} / ${dataProvider.phone}',
      'comUser': null,
      'comUserName': null,
      'cargoCategory': addProvider.cargoCategory,
      'isShow': true,
      'eTax': null,
      'eTaxPrice': null,
      'eTaxDate': null,
      'sendDoc': null,
      'comClass': null,
      'comType': null,
      'transitType': addProvider.addSubType,
      'aloneType': addProvider.addMainType,
      'carOptions': addProvider.carOption,
      'ownerType': addProvider.senderType,
      'normalComUid': addProvider.senderType == '일반'
          ? null
          : dataProvider.userData!.company[0],
      'norPayType': addProvider.isPriceType,
      'norPayHowto': addProvider.payHowto,
      'liveId': uniqId,
      'updateAt': DateTime.now(),
      'normalEtax': addProvider.isNormalEtax,
      'multiNum': totalLocations,
      'multiUp': upLocations,
      'multiDown': downLocations,
      'cashRec': addProvider.isCashRec,
      'doneRec': addProvider.isDoneRec,
      'upTime': processedLocations.isNotEmpty
          ? processedLocations.first['date']
          : null,
      'downTime': processedLocations.length > 1
          ? processedLocations.last['date']
          : null,
      'carEtc': addProvider.carEtc,
    };
    print('cargoData 생성 완료');

    print('liveData 생성 시작2');
    print(addProvider.addMainType);
    final liveData = {
      'bidingCom' : [],
      'locations': processedLocations,
      'downTime': processedLocations.last['date'],
      'upTime': processedLocations.first['date'],
      'isBlind': addProvider.setIsBlind,
      'downTimeEtc': processedLocations.last['etc'],
      'upTimeEtc': processedLocations.first['etc'],
      'totalLocations': addProvider.locations.length,
      'totalUpcargos': upPoints,
      'totalDowncargos': downPoints,
      'totalCargoInfos': maxLoad,
      'normalUid': dataProvider.userData!.uid,
      'uid': addProvider.senderType == '일반'
          ? dataProvider.userData!.uid
          : dataProvider.userData!.company[0],
      if (addProvider.senderType != '일반')
        'normalUserUid': dataProvider.userData!.uid,
      'cargoId': uniqId,
      'id': uniqId,
      'upLocation': {
        'geohash': null,
        'geopoint': processedLocations.isNotEmpty
            ? processedLocations.first['location']
            : null
      },
      'downLocation': {
        'geohash': null,
        'geopoint': addProvider.addMainType == '다구간'
            ? processedLocations.last['location']
            : processedLocations.length > 1
                ? processedLocations[1]['location']
                : null
      },
      'upAddress': processedLocations.isNotEmpty
          ? processedLocations.first['address1']
          : null,
      'downAddress': addProvider.addMainType == '다구간'
          ? processedLocations.last['address1']
          : processedLocations.length > 1
              ? processedLocations[1]['address1']
              : null,
      'upTimeType': processedLocations.isNotEmpty
          ? processedLocations.first['dateType']
          : null,
      'upStart': processedLocations.isNotEmpty &&
              processedLocations.first['dateType'] == '시간 선택'
          ? processedLocations.first['dateStart']
          : null,
      'upEnd': processedLocations.isNotEmpty
          ? processedLocations.first['dateEnd']
          : null,
      'upDate': processedLocations.isNotEmpty
          ? processedLocations.first['date']
          : null,
      "isShow": true,
      'carType': addProvider.setCarType,
      'carTon': addProvider.setCarTon,
      'carOption': addProvider.carOption,
      'downDate': processedLocations.last['date'],
      'downTimeType': processedLocations.last['dateType'],
      'downStart': processedLocations.last['dateType'] == '시간 선택'
          ? processedLocations.last['dateStart']
          : null,
      'downEnd': processedLocations.last['dateEnd'],
      'upAloneType': processedLocations.first['dateAloneString'],
      'downAloneType': processedLocations.last['dateAloneString'],

      ///
      'returnDate': processedLocations[1]['date'],
      'returnTimeType': processedLocations[1]['dateType'],
      'returnStart': processedLocations[1]['dateType'] == '시간 선택'
          ? processedLocations[1]['dateStart']
          : null,
      'returnEnd': processedLocations[1]['dateEnd'],
      'returnAloneType': processedLocations[1]['dateAloneString'],
      'returnnDate': processedLocations[1]['date'],

      'upType': processedLocations[0]['howTo'],
      'downType': processedLocations[2]['howTo'],
      'returnType': processedLocations[1]['howTo'],

      ///

      'kmPer': null,
      'price': null,
      'blockList': [],
      "isBiding": true,
      "cUser": null,
      'cTime': null,
      'comUid': null,
      'senderType': '일반',
      'isNormal': true,
      'createdDate': DateTime.now(),
      'normalComUid': addProvider.senderType == '일반'
          ? null
          : dataProvider.userData!.company[0],
      'norPayType': addProvider.isPriceType,
      'norPayHowto': addProvider.payHowto,
      'allDis': addProvider.totalDistance,
      'allDur': addProvider.totalDuration,
      'payCommission': null,

      'upComType': addProvider.addUpSenderType,
      'downComType': addProvider.addDownSenderType,
      'transitType': addProvider.addSubType,
      'aloneType': addProvider.addMainType,
      'normalEtax': addProvider.isNormalEtax,
      'multiNum': totalLocations,
      'multiUp': upLocations,
      'multiDown': downLocations,
      'cashRec': addProvider.isCashRec,
      'doneRec': addProvider.isDoneRec,
      'carEtc': addProvider.carEtc,
    };

    print('liveData 생성 완료');

    print('Firebase 업데이트 시작');
    try {
      print('cargoDoc 업데이트 시작');
      await cargoDocRef.update(cargoData);
      print('cargoDoc 업데이트 완료');

      print('liveRef 업데이트 시작');
      await liveRef.set(liveData);
      print('liveRef 업데이트 완료');

      print('히스토리 추가 시작');
      await histroyAdd(dataProvider, addProvider, hashProvider);
      print('히스토리 추가 완료');
      Navigator.pop(context);
      if (addProvider.addMainType == '다구간') {
        ScaffoldMessenger.of(context)
            .showSnackBar(currentSnackBar('다구간 운송건이 정상 등록되었습니다.', context));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(currentSnackBar('왕복 운송건이 정상 등록되었습니다.', context));
      }

      print('===== 데이터 처리 완료 =====');
      return true;
    } catch (e) {
      print('Firebase 업데이트 중 에러:');
      print('에러 내용: $e');
      print('에러 위치: ${StackTrace.current}');
      mapProvider.isLoadingState(false);
      return false;
    }
  } catch (e) {
    mapProvider.isLoadingState(false);

    print('전체 처리 중 에러:');
    print('에러 내용: $e');
    print('에러 위치: ${StackTrace.current}');
    return false;
  }
}
