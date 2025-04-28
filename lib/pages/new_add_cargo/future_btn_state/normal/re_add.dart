import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/btn_state/history.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/add_future_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';

Future<void> reAddNormal(
  AddProvider addProvider,
  String cargoId,
  BuildContext context,
) async {
  final User? user = FirebaseAuth.instance.currentUser;
  final dataProvider = Provider.of<DataProvider>(context, listen: false);
  final hashProvider = Provider.of<HashProvider>(context, listen: false);

  if (user?.uid == null) {
    ScaffoldMessenger.of(context).showSnackBar(
        errorSnackBar('회원 정보를 찾을 수 없습니다.\n잠시 후 다시 시도하세요.', context));
    return;
  }

  String? businessP;
  num cargoTon = 0;

  if (addProvider.addCargoTon != null) {
    cargoTon = (addProvider.addCargoTonString == 'Kg'
        ? addProvider.addCargoTon! / 1000
        : addProvider.addCargoTon)!;
  }

  try {
    addProvider.addLoadingState(true);

    final upEnc = await hashProvider
        .encryptNLatLng(addProvider.setLocationUpNLatLng as NLatLng);
    final downEnc = await hashProvider
        .encryptNLatLng(addProvider.setLocationDownNLatLng as NLatLng);

    if (addProvider.cargoImage != null || addProvider.resetImgUrl != null) {
      if (addProvider.cargoImage != null && addProvider.resetImgUrl == null) {
        final bytes = await (addProvider.cargoImage as File).readAsBytes();
        businessP = await uploadImage2(bytes, 'cargo', cargoId, 'set');
      } else {
        businessP = addProvider.resetImgUrl;
      }
    }

    final String normalUid = addProvider.senderType == '일반'
        ? user!.uid
        : dataProvider.userData!.company[0];

    // CargoInfo update
    final cargoDocRef = FirebaseFirestore.instance
        .collection('cargoInfo')
        .doc(normalUid)
        .collection(extractFour(cargoId))
        .doc(cargoId);

    Map<String, dynamic> cargoData = {
      'downTimeEtc': addProvider.setDownTimeEtc,
      'upTimeEtc': addProvider.setUpTimeEtc,
      'normalUid': user!.uid,
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
      'upStart': addProvider.setUpDateDoubleStart,
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
      'downStart': addProvider.setDownDateDoubleStart,
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
      'id': cargoId,
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
      'liveId': cargoId,
      'normalEtax': addProvider.isNormalEtax,
      'updateAt': DateTime.now(),
      'cashRec': addProvider.isCashRec,
      'doneRec': addProvider.isDoneRec,
      'carEtc': addProvider.carEtc,
    };

    if (addProvider.senderType != '일반') {
      cargoData['normalUserUid'] = dataProvider.userData!.uid;
    }

    await cargoDocRef.update(cargoData);

    // CargoLive update
    final liveRef =
        FirebaseFirestore.instance.collection('cargoLive').doc(cargoId);

    Map<String, dynamic> liveData = {
      'bidingCom' : [],
      'isBlind': addProvider.setIsBlind,
      'downTimeEtc': addProvider.setDownTimeEtc,
      'upTimeEtc': addProvider.setUpTimeEtc,
      'normalUid': user.uid,
      'uid': normalUid,
      'cargoId': cargoId,
      'cargoType': addProvider.addCargoInfo,
      'cargoWe': cargoTon,
      'cargoWeType': addProvider.addCargoTonString,
      'id': cargoId,
      'upLocation': {'geohash': null, 'geopoint': upEnc},
      'downLocation': {'geohash': null, 'geopoint': downEnc},
      'upAddress': addProvider.setLocationUpAddress1,
      'downAddress': addProvider.setLocationDownAddress1,
      'upTimeType': addProvider.setUpTimeType,
      'upStart': addProvider.setUpDateDoubleStart,
      'upEnd': addProvider.setUpDateDoubleEnd,
      'upEtc': addProvider.setUpEtc,
      'upDate': addProvider.setUpDate,
      'isShow': true,
      'carType': addProvider.setCarType,
      'carTon': addProvider.setCarTon.toList(),
      'carOption': addProvider.carOption.toList(),
      'downDate': addProvider.setDownDate,
      'downTimeType': addProvider.setDownTimeType,
      'downStart': addProvider.setDownDateDoubleStart,
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
      liveData['normalUserUid'] = dataProvider.userData!.uid;
    }
    await histroyNormalAdd(dataProvider, addProvider, hashProvider, businessP);

    await liveRef.set(liveData);

    Navigator.pop(context);
    addProvider.addLoadingState(false);
  } catch (e) {
    addProvider.addLoadingState(false);
    rethrow;
  }
}
