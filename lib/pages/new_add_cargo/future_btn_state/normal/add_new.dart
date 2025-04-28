import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/btn_state/history.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/add_future_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';

Future<bool> addCargoNor(
    AddProvider addProvider, String callType, BuildContext context) async {
  final User? user = FirebaseAuth.instance.currentUser;
  final dataProvider = Provider.of<DataProvider>(context, listen: false);
  final hashProvider = Provider.of<HashProvider>(context, listen: false);

  if (user?.uid == null) {
    ScaffoldMessenger.of(context).showSnackBar(
        errorSnackBar('회원 정보를 찾을 수 없습니다.\n잠시 후 다시 시도하세요.', context));
    return false;
  }

  String? businessP;
  final num cargoTon = _calculateCargoTon(addProvider);
  String docId = '';

  try {
    addProvider.addLoadingState(true);

    final upEnc = await hashProvider
        .encryptNLatLng(addProvider.setLocationUpNLatLng as NLatLng);
    final downEnc = await hashProvider
        .encryptNLatLng(addProvider.setLocationDownNLatLng as NLatLng);

    final String normalUid = _getNormalUid(addProvider, dataProvider, user!);

    try {
      docId = await generateUniqueString(normalUid, addProvider.setUpDate!);
      businessP = await _handleCargoImage(addProvider, docId);
    } catch (e) {
      print('ID generation or image handling failed: $e');
      return false;
    }

    // 문서 참조 생성
    final cargoDocRef = FirebaseFirestore.instance
        .collection('cargoInfo')
        .doc(normalUid)
        .collection(DateTime.now().year.toString())
        .doc(docId);

    final liveRef =
        FirebaseFirestore.instance.collection('cargoLive').doc(docId);

    // cargoInfo 데이터 준비
    final Map<String, dynamic> cargoData = {
      'downTimeEtc': addProvider.setDownTimeEtc,
      'upTimeEtc': addProvider.setUpTimeEtc,
      'normalUid': user.uid,
      'uid': normalUid,
      'carTon': addProvider.setCarTon,
      'carOption': addProvider.carOption,
      'carType': addProvider.setCarType,
      'comUid': null,
      'isBlind': addProvider.setIsBlind,
      'isBiding': true,
      'bidingUsers': [],
      'bidingCom': [],
      'upName': addProvider.setLocationUpName,
      'upPhone': addProvider.setLocationUpPhone,
      'upAddress': addProvider.setLocationUpAddress1,
      'upAddressDis': addProvider.setLocationUpDis,
      'upRoadAddress': addProvider.setLocationUpAddress2,
      'upTime': addProvider.setUpDate,
      'upTimeType': addProvider.setUpTimeType,
      'upStart': _getUpStartTime(addProvider),
      'upEnd': addProvider.setUpDateDoubleEnd,
      'upEtc': addProvider.setUpEtc,
      'upType': addProvider.setLocationCargoUpType,
      'downName': addProvider.setLocationDownName,
      'downPhone': addProvider.setLocationDownPhone,
      'downAddress': addProvider.setLocationDownAddress1,
      'downAddressDis': addProvider.setLocationDownDis,
      'downRoadAddress': addProvider.setLocationDownAddress2,
      'downTime': addProvider.setDownDate,
      'downTimeType': addProvider.setDownTimeType,
      'downStart': _getDownStartTime(addProvider),
      'downEnd': addProvider.setDownDateDoubleEnd,
      'downEtc': addProvider.setDownEtc,
      'downType': addProvider.setLocationCargoDownType,
      'cargoEtc': addProvider.addCargoEtc,
      'cargoStat': '대기',
      'garo': addProvider.addCargoSizeGaro,
      'sero': addProvider.addCargoSizeSero,
      'he': addProvider.addCargoSizeHi,
      'cbm': addProvider.addCargoCbm,
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
      'upComType': addProvider.addUpSenderType,
      'downComType': addProvider.addDownSenderType,
      'isDownTmm': addProvider.isTmm,
      'isWith': addProvider.isWith,
      'id': docId,
      'clientType': _getClientType(addProvider),
      'clientInfo': '${dataProvider.name} / ${dataProvider.phone}',
      'comUser': null,
      'comUserName': null,
      'cargoCategory': addProvider.cargoCategory,
      'isShow': true,
      'upLocation': {'geohash': null, 'geopoint': upEnc},
      'downLocation': {'geohash': null, 'geopoint': downEnc},
      'eTax': null,
      'eTaxPrice': null,
      'eTaxDate': null,
      'cargoType': addProvider.addCargoInfo,
      'cargoWe': cargoTon,
      'cargoWeType': addProvider.addCargoTonString,
      'sendDoc': null,
      'comClass': null,
      'comType': null,
      'transitType': addProvider.addSubType,
      'aloneType': addProvider.addMainType,
      'carOptions': addProvider.setCarTypeSub,
      'ownerType': dataProvider.loginType,
      'cargoPhotoUrl': businessP,
      'norPayType': addProvider.isPriceType,
      'norPayHowto': addProvider.payHowto,
      'liveId': docId,
      'normalEtax': addProvider.isNormalEtax,
      'updateAt': DateTime.now(),
      'cashRec': addProvider.isCashRec,
      'doneRec': addProvider.isDoneRec,
      'carEtc': addProvider.carEtc,
    };

    // cargoLive 데이터 준비
    final Map<String, dynamic> liveData = {
      'bidingCom' : [],
      'isBlind': addProvider.setIsBlind,
      'downTimeEtc': addProvider.setDownTimeEtc,
      'upTimeEtc': addProvider.setUpTimeEtc,
      'normalUid': user.uid,
      'uid': normalUid,
      'cargoId': docId,
      'cargoType': addProvider.addCargoInfo,
      'cargoWe': cargoTon,
      'cargoWeType': addProvider.addCargoTonString,
      'id': docId,
      'upLocation': {'geohash': null, 'geopoint': upEnc},
      'downLocation': {'geohash': null, 'geopoint': downEnc},
      'upAddress': addProvider.setLocationUpAddress1,
      'downAddress': addProvider.setLocationDownAddress1,
      'upTimeType': addProvider.setUpTimeType,
      'upStart': _getUpStartTime(addProvider),
      'upEnd': addProvider.setUpDateDoubleEnd,
      'upEtc': addProvider.setUpEtc,
      'upDate': addProvider.setUpDate,
      'isShow': true,
      'carType': addProvider.setCarType,
      'carTon': addProvider.setCarTon.toList(),
      'carOption': addProvider.carOption.toList(),
      'downDate': addProvider.setDownDate,
      'downTimeType': addProvider.setDownTimeType,
      'downStart': _getDownStartTime(addProvider),
      'downEnd': addProvider.setDownDateDoubleEnd,
      'downEtc': addProvider.setDownEtc,
      'upAloneType': addProvider.setUpTimeAloneType,
      'downAloneType': addProvider.setDownTimeAloneType,
      'kmPer': null,
      'price': null,
      'blockList': [],
      'isBiding': true,
      'cUser': null,
      'cTime': null,
      'comUid': null,
      'senderType': addProvider.senderType,
      'isNormal': true,
      'createdDate': DateTime.now(),
      'norPayType': addProvider.isPriceType,
      'norPayHowto': addProvider.payHowto,
      'allDis': addProvider.totalDistance,
      'allDur': addProvider.totalDuration,
      'payCommission': null,
      'upType': addProvider.setLocationCargoUpType,
      'downType': addProvider.setLocationCargoDownType,
      'upComType': addProvider.addUpSenderType,
      'downComType': addProvider.addDownSenderType,
      'transitType': addProvider.addSubType,
      'aloneType': addProvider.addMainType,
      'normalEtax': addProvider.isNormalEtax,
      'cashRec': addProvider.isCashRec,
      'doneRec': addProvider.isDoneRec,
      'carEtc': addProvider.carEtc,
    };

    if (addProvider.senderType != '일반') {
      cargoData['normalUserUid'] = dataProvider.userData!.uid;
      liveData['normalUserUid'] = dataProvider.userData!.uid;
    }

    // 일반 write 작업으로 문서 생성
    await cargoDocRef.set(cargoData);
    await liveRef.set(liveData);

    await histroyNormalAdd(dataProvider, addProvider, hashProvider, businessP);

    Navigator.pop(context);
    addProvider.addLoadingState(false);
    return true;
  } catch (e, stackTrace) {
    print('Cargo addition failed: $e\n$stackTrace');
    final String normalUid = _getNormalUid(addProvider, dataProvider, user!);

    if (docId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('cargoInfo')
            .doc(normalUid)
            .collection(DateTime.now().year.toString())
            .doc(docId)
            .delete();

        await FirebaseFirestore.instance
            .collection('cargoLive')
            .doc(docId)
            .delete();
      } catch (rollbackError) {
        print('Rollback failed: $rollbackError');
      }
    }

    addProvider.addLoadingState(false);
    return false;
  }
}

// 헬퍼 함수들은 그대로 유지

Future<String?> _handleCargoImage(AddProvider addProvider, String value) async {
  if (addProvider.cargoImage == null && addProvider.resetImgUrl == null) {
    return null;
  }
  if (addProvider.cargoImage != null && addProvider.resetImgUrl == null) {
    final bytes = await (addProvider.cargoImage as File).readAsBytes();
    return await uploadImage2(bytes, 'cargo', value, 'set');
  }
  return addProvider.resetImgUrl;
}

num _calculateCargoTon(AddProvider addProvider) {
  if (addProvider.addCargoTon == null) return 0;
  final num addTon = addProvider.addCargoTon as num;
  return addProvider.addCargoTonString == 'Kg' ? addTon / 1000 : addTon;
}

String _getNormalUid(
    AddProvider addProvider, DataProvider dataProvider, User user) {
  return addProvider.senderType == '일반'
      ? user.uid
      : dataProvider.userData!.company[0];
}

String _getClientType(AddProvider addProvider) {
  if (addProvider.senderUpType == true && addProvider.senderDownType == true) {
    return '상, 하차지 동일';
  }
  if (addProvider.senderUpType == true) {
    return '상차지 동일';
  }
  if (addProvider.senderDownType == true) {
    return '하차지와 동일';
  }
  return '';
}

dynamic _getUpStartTime(AddProvider addProvider) {
  return addProvider.setUpTimeType == '시간 선택'
      ? addProvider.setUpDateDoubleStart
      : addProvider.setUpDateDoubleStart;
}

dynamic _getDownStartTime(AddProvider addProvider) {
  return addProvider.setDownTimeType == '시간 선택'
      ? addProvider.setDownDateDoubleStart
      : addProvider.setDownDateDoubleStart;
}
