import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_naver_map/flutter_naver_map.dart';

class CargoLocation {
  String? type;
  String? address1;
  String? address2;
  String? addressDis;
  NLatLng? location;
  String? howTo;
  List? senderType;
  String? senderName;
  String? senderPhone;
  String? dateType;
  String? dateAloneString;
  DateTime? dateStart;
  DateTime? dateEnd;
  DateTime? date;
  String? etc;
  String? becareful;
  bool? isDone;
  DateTime? isDoneTime;

  // 하차 화물 리스트 추가
  List<CargoInfo> downCargos;
  List<CargoInfo> upCargos;

  CargoLocation({
    required this.type,
    required this.address1,
    required this.address2,
    required this.addressDis,
    required this.location,
    required this.howTo,
    required this.senderType,
    required this.senderName,
    required this.senderPhone,
    required this.dateType,
    required this.dateAloneString,
    this.dateStart,
    this.dateEnd,
    this.isDone,
    this.isDoneTime,
    required this.date,
    required this.etc,
    required this.becareful,
    List<CargoInfo>? downCargos,
    List<CargoInfo>? upCargos,
  })  : downCargos = downCargos ?? [],
        upCargos = upCargos ?? [];
}

class CargoPoint {
  final NLatLng coordinate;
  final String type; // '상차' or '하차'
  final int order; // 순서
  final String address; // 주소 정보
  final int upNum;
  final int downNum;
  CargoPoint({
    required this.coordinate,
    required this.type,
    required this.order,
    required this.address,
    required this.upNum,
    required this.downNum,
  });
}

class CargoInfo {
  String? cargoType;
  String? cargoWeType;
  num? cargoWe;
  String? imgUrl;
  File? imgFile;
  num? cbm;
  num? garo;
  num? sero;
  num? hi;
  String? code;
  bool? isDown;
  int? downIndex;
  String? type;
  String? cargo;
  int? locationIndex;
  int? cargoIndex;
  String? id;
  Uint8List? webImage;

  CargoInfo(
      {this.cargoType,
      this.cargoWeType,
      this.cargoWe,
      this.imgUrl,
      this.imgFile,
      this.cbm,
      this.garo,
      this.sero,
      this.hi,
      this.code,
      this.isDown,
      this.type,
      this.cargo,
      this.cargoIndex,
      this.locationIndex,
      this.downIndex,
      this.id,
      this.webImage});

  Map<String, dynamic> toJson() {
    return {
      'cargoType': cargoType,
      'cargoWeType': cargoWeType,
      'cargoWe': cargoWe,
      'imgUrl': imgUrl,
      'cbm': cbm,
      'garo': garo,
      'sero': sero,
      'hi': hi,
      'code': code,
      'isDown': isDown,
      'type': type,
      'cargo': cargo,
      'cargoIndex': cargoIndex,
      'locationIndex': locationIndex,
      'id': id,
      'downIndex': downIndex,
      'webImage': webImage,
    };
  }

  // fromMap 메소드 추가
  factory CargoInfo.fromMap(Map<String, dynamic> map) {
    return CargoInfo(
        cargoType: map['cargoType'],
        cargoWeType: map['cargoWeType'],
        cargoWe: map['cargoWe'],
        imgUrl: map['imgUrl'],
        imgFile: map['imgFile'],
        cbm: map['cbm'],
        garo: map['garo'],
        sero: map['sero'],
        hi: map['hi'],
        code: map['code'],
        isDown: map['isDown'],
        type: map['type'],
        cargo: map['cargo'],
        locationIndex: map['locationIndex'],
        cargoIndex: map['cargoIndex'],
        downIndex: map['downIndex']?.toInt(),
        webImage: map['webImage'],
        id: map['id']);
  }
  CargoInfo copyWith({
    String? cargoType,
    String? cargoWeType,
    num? cargoWe,
    String? imgUrl,
    File? imgFile,
    num? cbm,
    num? garo,
    num? sero,
    num? hi,
    String? code,
    bool? isDown,
    int? downIndex,
    String? type,
    String? cargo,
    int? locationIndex,
    int? cargoIndex,
    String? id,
    Uint8List? webImage,
  }) {
    return CargoInfo(
      cargoType: cargoType ?? this.cargoType,
      cargoWeType: cargoWeType ?? this.cargoWeType,
      cargoWe: cargoWe ?? this.cargoWe,
      imgUrl: imgUrl ?? this.imgUrl,
      imgFile: imgFile ?? this.imgFile,
      cbm: cbm ?? this.cbm,
      garo: garo ?? this.garo,
      sero: sero ?? this.sero,
      hi: hi ?? this.hi,
      code: code ?? this.code,
      isDown: isDown ?? this.isDown,
      downIndex: downIndex ?? this.downIndex,
      type: type ?? this.type,
      cargo: cargo ?? this.cargo,
      locationIndex: locationIndex ?? this.locationIndex,
      cargoIndex: cargoIndex ?? this.cargoIndex,
      id: id ?? this.id,
      webImage: webImage ?? this.webImage,
    );
  }
}
