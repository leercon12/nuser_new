import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';

Future<void> histroyAdd(DataProvider dataProvider, AddProvider addProvider,
    HashProvider hashProvider) async {
  try {
    final locationHistory = getAllLocationInfo(addProvider, hashProvider);
    final cargoHistory = getAllCargoInfo(addProvider);

    DocumentReference docRef;

    if (addProvider.senderType == '일반') {
      docRef = FirebaseFirestore.instance
          .collection('user_normal')
          .doc(dataProvider.userData!.uid)
          .collection('recList')
          .doc('rec');
    } else {
      docRef = FirebaseFirestore.instance
          .collection('normalCom')
          .doc(dataProvider.userData!.company[0])
          .collection('recList')
          .doc('rec');
    }

    // 문서가 존재하는지 확인
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

      // 기존 위치 목록과 화물 목록 가져오기
      List<dynamic> existingLocations =
          List<dynamic>.from(data['locations'] ?? []);
      List<dynamic> existingCargos = List<dynamic>.from(data['cargos'] ?? []);

      // 위치 처리: address1과 name이 같은 항목은 덮어쓰기
      List<Map<String, dynamic>> updatedLocations =
          List<Map<String, dynamic>>.from(existingLocations);

      for (var newLocation in locationHistory) {
        bool found = false;
        for (int i = 0; i < updatedLocations.length; i++) {
          if (updatedLocations[i]['address1'] == newLocation['address1'] &&
              updatedLocations[i]['name'] == newLocation['name']) {
            // 기존 항목 발견 - 덮어쓰기
            updatedLocations[i] = newLocation;
            found = true;
            break;
          }
        }
        if (!found) {
          // 기존에 없는 항목 - 추가
          updatedLocations.add(newLocation);
        }
      }

      // 화물 처리: 내용이 같으면 추가하지 않음
      List<Map<String, dynamic>> updatedCargos =
          List<Map<String, dynamic>>.from(existingCargos);

      for (var newCargo in cargoHistory) {
        bool isDuplicate = false;
        for (var existingCargo in updatedCargos) {
          if (_areCargosEqual(newCargo, existingCargo)) {
            isDuplicate = true;
            break;
          }
        }
        if (!isDuplicate) {
          updatedCargos.add(newCargo);
        }
      }

      // 데이터 업데이트
      final updates = {
        'locations': updatedLocations,
        'cargos': updatedCargos,
        'updatedAt': DateTime.now(),
      };

      await docRef.set(updates);
    } else {
      // 문서가 존재하지 않으면 새로 생성
      final initialData = {
        'locations': locationHistory,
        'cargos': cargoHistory,
        'updatedAt': DateTime.now(),
      };
      await docRef.set(initialData);
    }
  } catch (e) {
    print('Error in historyAdd: $e');
    rethrow;
  }
}

// 두 화물 정보가 동일한지 확인하는 함수
bool _areCargosEqual(Map<String, dynamic> cargo1, Map<String, dynamic> cargo2) {
  return cargo1['cargoType'] == cargo2['cargoType'] &&
      cargo1['cargoWeType'] == cargo2['cargoWeType'] &&
      cargo1['cargoWe'] == cargo2['cargoWe'] &&
      cargo1['cbm'] == cargo2['cbm'] &&
      cargo1['garo'] == cargo2['garo'] &&
      cargo1['sero'] == cargo2['sero'] &&
      cargo1['hi'] == cargo2['hi'];
}

List<Map<String, dynamic>> getAllLocationInfo(
    AddProvider addProvider, HashProvider hashProvider) {
  List<Map<String, dynamic>> allLocations = [];

  for (var location in addProvider.locations) {
    print("Processing location:");
    print("- address1: ${location.address1}");
    print("- address2: ${location.address2}");
    print("- addressDis: ${location.addressDis}");
    print("- location: ${location.location}");
    print("- senderName: ${location.senderName}");
    print("- snederPhone: ${location.senderPhone}");
    print("- senderType: ${location.senderType}");
    Map<String, dynamic> locationInfo = {
      'address1': location.address1.toString(),
      'address2': location.address2.toString(),
      'addressDis': location.addressDis.toString(),
      'location': hashProvider.encryptNLatLng(location.location as NLatLng),
      'name': location.senderName.toString(),
      'phone': location.senderPhone.toString(),
      'type': location.senderType.toString(),
    };

    allLocations.add(locationInfo);
  }

  return allLocations;
}

// 모든 화물 정보를 수집하는 함수
List<Map<String, dynamic>> getAllCargoInfo(AddProvider addProvider) {
  List<Map<String, dynamic>> allCargos = [];

  for (var location in addProvider.locations) {
    // upCargos 수집
    if (location.upCargos != null) {
      for (var cargo in location.upCargos) {
        Map<String, dynamic> cargoInfo = {
          'cargoType': cargo.cargoType.toString(),
          'cargoWeType': cargo.cargoWeType.toString(),
          'cargoWe': cargo.cargoWe.toString(),
          'cbm': cargo.cbm ?? 0,
          'garo': cargo.garo ?? 0,
          'sero': cargo.sero ?? 0,
          'hi': cargo.hi ?? 0,
          'imgUrl': cargo.imgUrl.toString(),
        };
        allCargos.add(cargoInfo);
      }
    }

    // downCargos 수집 추가
    if (location.downCargos != null) {
      for (var cargo in location.downCargos) {
        Map<String, dynamic> cargoInfo = {
          'cargoType': cargo.cargoType.toString(),
          'cargoWeType': cargo.cargoWeType.toString(),
          'cargoWe': cargo.cargoWe.toString(),
          'cbm': cargo.cbm ?? 0,
          'garo': cargo.garo ?? 0,
          'sero': cargo.sero ?? 0,
          'hi': cargo.hi ?? 0,
          'imgUrl': cargo.imgUrl.toString(),
        };
        allCargos.add(cargoInfo);
      }
    }
  }

  return allCargos;
}

Future<void> histroyNormalAdd(DataProvider dataProvider,
    AddProvider addProvider, HashProvider hashProvider, String? imgUrl) async {
  try {
    final locationHistory = getAllLocationNormalInfo(addProvider, hashProvider);
    final cargoHistory = getAllCargoNormalInfo(addProvider, imgUrl);

    DocumentReference docRef;

    if (addProvider.senderType != '일반') {
      docRef = FirebaseFirestore.instance
          .collection('normalCom')
          .doc(dataProvider.userData!.company[0])
          .collection('recList')
          .doc('rec');
    } else {
      docRef = FirebaseFirestore.instance
          .collection('user_normal')
          .doc(dataProvider.userData!.uid)
          .collection('recList')
          .doc('rec');
    }

    // 문서가 존재하는지 확인
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

      // 기존 위치 목록과 화물 목록 가져오기
      List<dynamic> existingLocations =
          List<dynamic>.from(data['locations'] ?? []);
      List<dynamic> existingCargos = List<dynamic>.from(data['cargos'] ?? []);

      // 위치 처리: address1과 name이 같은 항목은 덮어쓰기
      List<Map<String, dynamic>> updatedLocations =
          List<Map<String, dynamic>>.from(existingLocations);

      for (var newLocation in locationHistory) {
        bool found = false;
        for (int i = 0; i < updatedLocations.length; i++) {
          if (updatedLocations[i]['address1'] == newLocation['address1'] &&
              updatedLocations[i]['name'] == newLocation['name']) {
            // 기존 항목 발견 - 덮어쓰기
            updatedLocations[i] = newLocation;
            found = true;
            break;
          }
        }
        if (!found) {
          // 기존에 없는 항목 - 추가
          updatedLocations.add(newLocation);
        }
      }

      // 화물 처리: 내용이 같으면 추가하지 않음
      List<Map<String, dynamic>> updatedCargos =
          List<Map<String, dynamic>>.from(existingCargos);

      for (var newCargo in cargoHistory) {
        bool isDuplicate = false;
        for (var existingCargo in updatedCargos) {
          if (_areCargosEqual(newCargo, existingCargo)) {
            isDuplicate = true;
            break;
          }
        }
        if (!isDuplicate) {
          updatedCargos.add(newCargo);
        }
      }

      // 데이터 업데이트
      final updates = {
        'locations': updatedLocations,
        'cargos': updatedCargos,
        'updatedAt': DateTime.now(),
      };

      await docRef.set(updates);
    } else {
      // 문서가 존재하지 않으면 새로 생성
      final initialData = {
        'locations': locationHistory,
        'cargos': cargoHistory,
        'updatedAt': DateTime.now(),
      };
      await docRef.set(initialData);
    }
  } catch (e) {
    print('Error in historyNormalAdd: $e');
    rethrow;
  }
}

List<Map<String, dynamic>> getAllLocationNormalInfo(
    AddProvider addProvider, HashProvider hashProvider) {
  List<Map<String, dynamic>> allLocations = [];

  // 상차지 정보
  Map<String, dynamic> locationInfoUp = {
    'address1': addProvider.setLocationUpAddress1.toString(),
    'address2': addProvider.setLocationUpAddress2.toString(),
    'addressDis': addProvider.setLocationUpDis.toString(),
    'location': hashProvider
        .encryptNLatLng(addProvider.setLocationUpNLatLng as NLatLng),
    'name': addProvider.setLocationUpName.toString(),
    'phone': addProvider.setLocationUpPhone.toString(),
    'type': addProvider.addUpSenderType.toString(),
  };

  // 하차지 정보
  Map<String, dynamic> locationInfoDown = {
    'address1': addProvider.setLocationDownAddress1.toString(),
    'address2': addProvider.setLocationDownAddress2.toString(),
    'addressDis': addProvider.setLocationDownDis.toString(),
    'location': hashProvider
        .encryptNLatLng(addProvider.setLocationDownNLatLng as NLatLng),
    'name': addProvider.setLocationDownName.toString(),
    'phone': addProvider.setLocationDownPhone.toString(),
    'type': addProvider.addDownSenderType.toString(),
  };

  allLocations.add(locationInfoUp);
  allLocations.add(locationInfoDown);

  return allLocations;
}

// 모든 화물 정보를 수집하는 함수
List<Map<String, dynamic>> getAllCargoNormalInfo(
    AddProvider addProvider, String? imgUrl) {
  List<Map<String, dynamic>> allCargos = [];

  // Normal 타입일 때는 직접 addProvider에서 정보 가져오기
  Map<String, dynamic> cargoInfo = {
    'cargoType': addProvider.addCargoInfo.toString(),
    'cargoWeType': addProvider.addCargoTonString.toString(),
    'cargoWe': addProvider.addCargoTon.toString(),
    'cbm': addProvider.addCargoCbm ?? 0,
    'garo': addProvider.addCargoSizeGaro ?? 0,
    'sero': addProvider.addCargoSizeSero ?? 0,
    'hi': addProvider.addCargoSizeHi ?? 0,
    'imgUrl': imgUrl,
  };

  allCargos.add(cargoInfo);

  return allCargos;
}
