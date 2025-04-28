import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_mixcall_normaluser_new/env.dart';
import 'package:flutter_mixcall_normaluser_new/model/multi_cargo_add_model.dart';
import 'package:flutter_mixcall_normaluser_new/service/map_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/sarchmap.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart' as xml;

String ju = Env.KAKAO_KEY;
String ju2 = Env.NAVER_MAP_KEY;
String ju3 = Env.NEVER_SCRET_KEY;

String ju4 = Env.NEVER_OPEN_KEY;
String ju5 = Env.NEVER_OPEN_SCRET;

class AddProvider extends ChangeNotifier {
  String? _addMainType;
  String? get addMainType => _addMainType;

  void addMainTypeState(String? value) {
    _addMainType = value;
    notifyListeners();
  }

  String? _addSubType;
  String? get addSubType => _addSubType;

  void addSubTypeState(String? value) {
    _addSubType = value;
    notifyListeners();
  }

  String? _cargoState;
  String? get cargoState => _cargoState;

  void cargoStateState(String? value) {
    _cargoState = value;
    notifyListeners();
  }

  bool? _setIsBlind = false;
  bool? get setIsBlind => _setIsBlind;

  void setIsBlindState(bool? value) {
    _setIsBlind = value;
    notifyListeners();
  }

  bool? _addLoading = false;
  bool? get addLoading => _addLoading;

  void addLoadingState(bool? value) {
    _addLoading = value;
    notifyListeners();
  }

  int? _locationsIndex;
  int? get locationsIndex => _locationsIndex;

  void locationsIndexState(int type) {
    _locationsIndex = type;

    notifyListeners();
  }

  int? _cargosIndex;
  int? get cargosIndex => _cargosIndex;

  void cargosIndexState(int type) {
    _cargosIndex = type;

    notifyListeners();
  }

  ///
  ///
  ///
  ///
  ///// 정보 리셋 //////////////////////////////////////
  void allReset() {
    addReset();
    resetUpLocationData();
    resetDownLocationData();
    notifyListeners();
    resetEtc();
  }

  void mulitiAddReset() {
    resetUpLocationData();
    resetDownLocationData();
    notifyListeners();
  }

  void addReset() {
    _addMainType = null;
    _addSubType = null;
    _setIsBlind = false;
    _setLocationType = null;
    _isCashRec = false;
    _isDoneRec = false;
    _carEtc = null;
    _cargosIndex = null;
    _locationsIndex = null;
  }

  void resetUpLocationData() {
    _setLocationUpName = null;
    _setLocationUpPhone = null;
    _setLocationUpDis = null;
    _setLocationUpAddress1 = null;
    _setLocationUpAddress2 = null;
    _setLocationType = null;
    _setLocationUpNLatLng = null;
    _addUpSenderType = null;
    _addUpSenderFact = null;

    _setUpTimeType = null;
    _setUpDateAlone = null;
    _setUpDateDoubleStart = null;
    _setUpDateDoubleEnd = null;
    _setUpTimeAloneType = null;
    _setUpDate = null;
    _setUpTimeisDone = false;
    _dayNameUp = null;
    _setLocationCargoUpType = null;
    _setUpTimeEtc = null;
    _setUpEtc = null;
    notifyListeners();
  }

// 하차지(Down) 관련 모든 데이터 리셋
  void resetDownLocationData() {
    _setLocationDownName = null;
    _setLocationDownPhone = null;
    _setLocationDownDis = null;
    _setLocationCargoDownType = null;
    _dayNameDown = null;
    _setLocationDownType = null;
    _setLocationDownAddress1 = null;
    _setLocationDownAddress2 = null;
    _addDownSenderType = null;
    _addDownSenderFact = null;
    _setLocationDownNLatLng = null;
    _setDownTimeEtc = null;
    _setDownTimeisDone = false;
    _setDownDateAlone = null;
    _setDownDateDoubleStart = null;
    _setDownDateDoubleEnd = null;
    _setDownTimeAloneType = null;
    _setDownDate = null;
    _setDownTimeType = null;
    _isTmm = false;
    _setDownEtc = null;
    notifyListeners();
  }

  void resetEtc() {
    _locations.clear();
    _addMultiEtc = null;
    _cargoImage = null;
    _setCarType = null;
    _carOption.clear();

    _setCarTon.clear();
    _addCargoInfo = null;
    _addCargoTon = null;
    _addCargoSizeGaro = null;
    _addCargoSizeSero = null;
    _addCargoSizeHi = null;
    _addCargoCbm = null;
    _addCargoEtc = null;
    _clientType = null;
    _senderUpType = null;
    _senderDownType = null;
    _useHistory = null;
    _isPriceType = null;
    _payHowto = [];
    _addCargoTonString = '톤';
    _senderType = null;
    _resetImgUrl = null;
    _cargoImage = null;
    _isNormalEtax = false;
  }

  ///// 상차지 정보 //////////////////////////////////////
  /////////////////////////////////////////
  /////////////////////////////////////////
  /////////////////////////////////////////
  /////////////////////////////////////////

  /* String? _clientInfo;
  String? get clientInfo => _clientInfo;

  String? _clientPhone;
  String? get clientPhone => _clientPhone;
 */
  String? _clientType;
  String? get clientType => _clientType;

  void setClientState(String? type) {
    _clientType = type;
    notifyListeners();
  }

  bool? _senderUpType;
  bool? get senderUpType => _senderUpType;

  void setSenderUpTypeState(bool? type) {
    _senderUpType = type;
    notifyListeners();
  }

  bool? _senderDownType;
  bool? get senderDownType => _senderDownType;

  void setSenderDownTypeState(bool? type) {
    _senderDownType = type;
    notifyListeners();
  }

  bool? _isLocationSave = false;
  bool? get isLocationSave => _isLocationSave;

  void isLocationSaveState(bool? value) {
    _isLocationSave = value;
    notifyListeners();
  }

  String? _useHistory;
  String? get useHistory => _useHistory;

  void useHistoryState(String? name) {
    _useHistory = name;

    notifyListeners();
  }

  String? _setLocationUpName;
  String? get setLocationUpName => _setLocationUpName;

  String? _setLocationUpPhone;
  String? get setLocationUpPhone => _setLocationUpPhone;

  void setLocationUpNamePhoneState(String? name, String? phone) {
    _setLocationUpName = name;
    _setLocationUpPhone = phone;
    notifyListeners();
  }

  String? _setLocationUpDis;
  String? get setLocationUpDis => _setLocationUpDis;

  void setLocationUpDisState(String? value) {
    _setLocationUpDis = value;
    notifyListeners();
  }

  String? _setLocationUpAddress1;
  String? get setLocationUpAddress1 => _setLocationUpAddress1;

  String? _setLocationUpAddress2;
  String? get setLocationUpAddress2 => _setLocationUpAddress2;

  void setLocationUpAddressState(String? address1, String? address2) {
    _setLocationUpAddress1 = address1;
    _setLocationUpAddress2 = address2;
    notifyListeners();
  }

  String? _setLocationType;
  String? get setLocationType => _setLocationType;

  void setLocationTypeState(String? value) {
    _setLocationType = value;
    notifyListeners();
  }

  NLatLng? _setLocationUpNLatLng;
  NLatLng? get setLocationUpNLatLng => _setLocationUpNLatLng;

  void setLocationUpNLatLngState(NLatLng? value) {
    _setLocationUpNLatLng = value;
    notifyListeners();
  }

  List<String>? _addUpSenderType;
  List<String>? get addUpSenderType => _addUpSenderType;

  void addUpSenderTypeState(List? type) {
    print("----addUpSenderTypeState 시작----");
    print("받은 type: $type");
    print("현재 _addUpSenderType: $_addUpSenderType");

    if (type == null) {
      print("type이 null이라서 null로 설정");
      _addUpSenderType = null;
      notifyListeners();
      return;
    }

    // 리스트가 하나의 항목만 포함하고 있다면 토글 모드로 동작
    if (type.length == 1) {
      _addUpSenderType ??= [];
      print("초기화 후 _addUpSenderType: $_addUpSenderType");

      var item = type[0];
      print("처리 중인 item: $item");

      // '정보 없음'이 들어온 경우
      if (item == '정보 없음') {
        if (_addUpSenderType!.contains(item)) {
          print("'정보 없음'이 이미 존재해서 제거");
          _addUpSenderType!.remove(item);
        } else {
          print("'정보 없음'이 선택되어 모든 항목 제거 후 '정보 없음'만 추가");
          _addUpSenderType!.clear(); // 기존 항목 모두 제거
          _addUpSenderType!.add(item); // '정보 없음'만 추가
        }
      }
      // 다른 항목이 들어온 경우
      else {
        // '정보 없음'이 이미 선택되어 있으면 제거
        if (_addUpSenderType!.contains('정보 없음')) {
          print("다른 항목 선택으로 '정보 없음' 제거");
          _addUpSenderType!.remove('정보 없음');
        }

        // 일반 토글 로직
        if (_addUpSenderType!.contains(item)) {
          print("$item이 이미 존재해서 제거");
          _addUpSenderType!.remove(item);
        } else if (_addUpSenderType!.length < 3) {
          print("$item 추가됨");
          _addUpSenderType!.add(item);
        }
      }
    }
    // 여러 항목이 포함된 리스트라면 전체 대체, 단 '정보 없음'이 포함되어 있으면 그것만 유지
    else {
      // '정보 없음'이 포함되어 있는지 확인
      if (type.contains('정보 없음')) {
        print("여러 항목 중 '정보 없음'이 포함되어 있어 '정보 없음'만 설정");
        _addUpSenderType = ['정보 없음'];
      } else {
        print("여러 항목으로 전체 대체");
        _addUpSenderType = List<String>.from(type);
      }
    }

    print("최종 _addUpSenderType: $_addUpSenderType");
    print("----addUpSenderTypeState 끝----");
    notifyListeners();
  }

  List<String>? _addDownSenderType;
  List<String>? get addDownSenderType => _addDownSenderType;

  void addDownSenderTypeState(List? type) {
    print("----addDownSenderTypeState 시작----");
    print("받은 type: $type");
    print("현재 _addDownSenderType: $_addDownSenderType");

    if (type == null) {
      print("type이 null이라서 null로 설정");
      _addDownSenderType = null;
      notifyListeners();
      return;
    }

    // 리스트가 하나의 항목만 포함하고 있다면 토글 모드로 동작
    if (type.length == 1) {
      _addDownSenderType ??= [];
      print("초기화 후 _addDownSenderType: $_addDownSenderType");

      var item = type[0];
      print("처리 중인 item: $item");

      // '정보 없음'이 들어온 경우
      if (item == '정보 없음') {
        if (_addDownSenderType!.contains(item)) {
          print("'정보 없음'이 이미 존재해서 제거");
          _addDownSenderType!.remove(item);
        } else {
          print("'정보 없음'이 선택되어 모든 항목 제거 후 '정보 없음'만 추가");
          _addDownSenderType!.clear(); // 기존 항목 모두 제거
          _addDownSenderType!.add(item); // '정보 없음'만 추가
        }
      }
      // 다른 항목이 들어온 경우
      else {
        // '정보 없음'이 이미 선택되어 있으면 제거
        if (_addDownSenderType!.contains('정보 없음')) {
          print("다른 항목 선택으로 '정보 없음' 제거");
          _addDownSenderType!.remove('정보 없음');
        }

        // 일반 토글 로직
        if (_addDownSenderType!.contains(item)) {
          print("$item이 이미 존재해서 제거");
          _addDownSenderType!.remove(item);
        } else if (_addDownSenderType!.length < 3) {
          print("$item 추가됨");
          _addDownSenderType!.add(item);
        }
      }
    }
    // 여러 항목이 포함된 리스트라면 전체 대체, 단 '정보 없음'이 포함되어 있으면 그것만 유지
    else {
      // '정보 없음'이 포함되어 있는지 확인
      if (type.contains('정보 없음')) {
        print("여러 항목 중 '정보 없음'이 포함되어 있어 '정보 없음'만 설정");
        _addDownSenderType = ['정보 없음'];
      } else {
        print("여러 항목으로 전체 대체");
        _addDownSenderType = List<String>.from(type);
      }
    }

    print("최종 _addDownSenderType: $_addDownSenderType");
    print("----addDownSenderTypeState 끝----");
    notifyListeners();
  }

  String? _addUpSenderFact;
  String? get addUpSenderFact => _addUpSenderFact;

  void addUpSenderFactState(String? type) {
    _addUpSenderFact = type;

    notifyListeners();
  }

  bool _isTmm = false;
  bool get isTmm => _isTmm;

  void isTmmState(bool type) {
    _isTmm = type;

    notifyListeners();
  }

  String? _setUpTimeType;
  String? get setUpTimeType => _setUpTimeType;

  void setLocationUpTimeTypeState(String? type) {
    _setUpTimeType = type;

    notifyListeners();
  }

  DateTime? _setUpDateAlone;
  DateTime? get setUpDateAlone => _setUpDateAlone;

  void setUpTimeAloneDateState(DateTime? date) {
    _setUpDateAlone = date;

    notifyListeners();
  }

  DateTime? _setUpDateDoubleStart;
  DateTime? get setUpDateDoubleStart => _setUpDateDoubleStart;

  void setUpTimeDoubleStartState(DateTime? start) {
    _setUpDateDoubleStart = start;

    notifyListeners();
  }

  DateTime? _setUpDateDoubleEnd;
  DateTime? get setUpDateDoubleEnd => _setUpDateDoubleEnd;

  void setUpTimeDoubleEndState(DateTime? end) {
    _setUpDateDoubleEnd = end;

    notifyListeners();
  }

  String? _setUpTimeAloneType;
  String? get setUpTimeAloneType => _setUpTimeAloneType;

  void setUpTimeAloneTypeState(String? text) {
    _setUpTimeAloneType = text;
    notifyListeners();
  }

  DateTime? _setUpDate;
  DateTime? get setUpDate => _setUpDate;

  void setUpDateState(DateTime? end) {
    _setUpDate = end;

    notifyListeners();
  }

  bool? _setUpTimeisDone = false;
  bool? get setUpTimeisDone => _setUpTimeisDone;

  void setLocationUpTimeisDoneState(bool? type) {
    _setUpTimeisDone = type;

    notifyListeners();
  }

  String? _dayNameUp;
  String? get dayNameUp => _dayNameUp;

  void dayNameUpState(String? type) {
    _dayNameUp = type;

    notifyListeners();
  }

  String? _setLocationCargoUpType;
  String? get setLocationCargoUpType => _setLocationCargoUpType;

  void setLocationCargoUpTypeState(String? value) {
    _setLocationCargoUpType = value;
    notifyListeners();
  }

  //////////////
  ///

  String? _setLocationDownName;
  String? get setLocationDownName => _setLocationDownName;

  String? _setLocationDownPhone;
  String? get setLocationDownPhone => _setLocationDownPhone;

  void setLocationDownNamePhoneState(String? name, String? phone) {
    _setLocationDownName = name;
    _setLocationDownPhone = phone;
    notifyListeners();
  }

  String? _setLocationDownDis;
  String? get setLocationDownDis => _setLocationDownDis;

  void setLocationDownDisState(String? value) {
    _setLocationDownDis = value;
    notifyListeners();
  }

  String? _setLocationCargoDownType;
  String? get setLocationCargoDownType => _setLocationCargoDownType;

  void setLocationCargoDownTypeState(String? value) {
    _setLocationCargoDownType = value;
    notifyListeners();
  }

  String? _dayNameDown;
  String? get dayNameDown => _dayNameDown;

  void dayNameDownState(String? type) {
    _dayNameDown = type;

    notifyListeners();
  }

  String? _setLocationDownType;
  String? get setLocationDownType => _setLocationDownType;

  void setLocationDownTypeState(String? value) {
    _setLocationDownType = value;
    notifyListeners();
  }

  String? _setLocationDownAddress1;
  String? get setLocationDownAddress1 => _setLocationDownAddress1;

  String? _setLocationDownAddress2;
  String? get setLocationDownAddress2 => _setLocationDownAddress2;

  void setLocationDownAddressState(String? address1, String? address2) {
    _setLocationDownAddress1 = address1;
    _setLocationDownAddress2 = address2;
    notifyListeners();
  }

  String? _addDownSenderFact;
  String? get addDownSenderFact => _addDownSenderFact;

  void addDownSenderFactState(String? type) {
    _addDownSenderFact = type;

    notifyListeners();
  }

  NLatLng? _setLocationDownNLatLng;
  NLatLng? get setLocationDownNLatLng => _setLocationDownNLatLng;

  void setLocationDownNLatLngState(NLatLng? value) {
    _setLocationDownNLatLng = value;
    notifyListeners();
  }

  String? _setDownTimeEtc;
  String? get setDownTimeEtc => _setDownTimeEtc;

  void setDownTimeEtcState(String? text) {
    _setDownTimeEtc = text;
    notifyListeners();
  }

  String? _setUpTimeEtc;
  String? get setUpTimeEtc => _setUpTimeEtc;

  void setUpTimeEtcState(String? text) {
    _setUpTimeEtc = text;
    notifyListeners();
  }

  bool? _setDownTimeisDone = false;
  bool? get setDownTimeisDone => _setDownTimeisDone;

  void setLocationDownTimeisDoneState(bool? type) {
    _setDownTimeisDone = type;

    notifyListeners();
  }

  DateTime? _setDownDateAlone;
  DateTime? get setDownDateAlone => _setDownDateAlone;

  void setDownTimeAloneDateState(DateTime? date) {
    _setDownDateAlone = date;

    notifyListeners();
  }

  DateTime? _setDownDateDoubleStart;
  DateTime? get setDownDateDoubleStart => _setDownDateDoubleStart;

  void setDownTimeDoubleStartState(DateTime? start) {
    _setDownDateDoubleStart = start;

    notifyListeners();
  }

  DateTime? _setDownDateDoubleEnd;
  DateTime? get setDownDateDoubleEnd => _setDownDateDoubleEnd;

  void setDownTimeDoubleEndState(DateTime? end) {
    _setDownDateDoubleEnd = end;

    notifyListeners();
  }

  String? _setDownTimeAloneType;
  String? get setDownTimeAloneType => _setDownTimeAloneType;

  void setDownTimeAloneTypeState(String? text) {
    _setDownTimeAloneType = text;
    notifyListeners();
  }

  DateTime? _setDownDate;
  DateTime? get setDownDate => _setDownDate;

  void setDownDateState(DateTime? end) {
    _setDownDate = end;

    notifyListeners();
  }

  String? _setDownTimeType;
  String? get setDownTimeType => _setDownTimeType;

  void setLocationDownTimeTypeState(String? type) {
    _setDownTimeType = type;

    notifyListeners();
  }

  String? _setDownEtc;
  String? get setDownEtc => _setDownEtc;

  void setDownEtcState(String? type) {
    _setDownEtc = type;

    notifyListeners();
  }

  String? _setUpEtc;
  String? get setUpEtc => _setUpEtc;

  void setUpEtcState(String? type) {
    _setUpEtc = type;

    notifyListeners();
  }

  /////////////////////////////////

  String? _setCarType;
  String? get setCarType => _setCarType;

  void setCarTypeState(String? type) {
    _setCarType = type;

    notifyListeners();
  }

  String? _setCarEtc;
  String? get setCarEtc => _setCarEtc;

  void setCarEtcState(String? type) {
    _setCarEtc = type;

    notifyListeners();
  }

  List<num> _setCarTon = [];
  List<num> get setCarTon => _setCarTon;

  void setCarTonState(num type) {
    // 999가 선택되었을 때
    if (type == 999) {
      _setCarTon = [999]; // 999만 남기고 모두 제거
      notifyListeners();
      return;
    }

    // 현재 999가 있는 상태에서 다른 값이 선택되면
    if (_setCarTon.contains(999)) {
      _setCarTon.clear(); // 999 제거
    }

    if (_setCarTon.contains(type)) {
      // 이미 존재하는 값이면 제거
      _setCarTon.remove(type);
    } else {
      // 3개 제한 체크
      if (_setCarTon.length >= 3) {
        return; // 이미 3개가 선택된 상태면 추가하지 않음
      }
      // 존재하지 않는 값이면 추가
      _setCarTon.add(type);
    }

    notifyListeners();
  }

  String? _setCarTypeSub;
  String? get setCarTypeSub => _setCarTypeSub;

  void setCarTypeSubState(String? type) {
    _setCarTypeSub = type;

    notifyListeners();
  }

  String? _cargoCategory = '일반화물';
  String? get cargoCategory => _cargoCategory;

  void cargoCategoryState(String? value) {
    _cargoCategory = value;
    notifyListeners();
  }

  bool? _isWith = false;
  bool? get isWith => _isWith;

  void isWithState(bool type) {
    _isWith = type;

    notifyListeners();
  }

  List<String> _carOption = []; // null 대신 빈 리스트로 초기화
  List<String> get carOption => _carOption;

  void carOptionState(String type) {
    // 단일 String을 받도록 변경
    if (_carOption.contains(type)) {
      _carOption.remove(type); // 이미 선택된 항목이면 제거
    } else {
      _carOption.add(type); // 선택되지 않은 항목이면 추가
    }
    notifyListeners();
  }

  void clearCarOption() {
    _carOption.clear(); // 리스트 비우기
    notifyListeners();
  }

/*   List<double> _carTon = []; // null 대신 빈 리스트로 초기화
  List<double> get carTon => _carTon;

  void carTonState(double type) {
    // 단일 String을 받도록 변경
    if (_carTon.contains(type)) {
      _carTon.remove(type); // 이미 선택된 항목이면 제거
    } else {
      _carTon.add(type); // 선택되지 않은 항목이면 추가
    }
    notifyListeners();
  }

  void clearCarTon() {
    _carTon.clear(); // 리스트 비우기
    notifyListeners();
  } */

  File? _cargoImage;
  File? get cargoImage => _cargoImage;

  void cargoImageState(File? value) {
    _cargoImage = value;

    notifyListeners();
  }

  File? _companyBusinessPhoto;
  File? get companyBusinessPhoto => _companyBusinessPhoto;

  void companyBusinessPhotoState(File? value) {
    _companyBusinessPhoto = value;

    notifyListeners();
  }

  File? _companyAccountPhoto;
  File? get companyAccountPhoto => _companyAccountPhoto;

  void companyAccountPhotoState(File? value) {
    _companyAccountPhoto = value;

    notifyListeners();
  }

  File? _companyLogoPhoto;
  File? get companyLogoPhoto => _companyLogoPhoto;

  void companyLogoPhotoState(File? value) {
    _companyLogoPhoto = value;

    notifyListeners();
  }

  String? _addMultiEtc;
  String? get addMultiEtc => _addMultiEtc;

  void addMultiEtcState(String? type) {
    _addMultiEtc = type;

    notifyListeners();
  }

  String? _carEtc;
  String? get carEtc => _carEtc;

  void carEtcState(String? type) {
    _carEtc = type;

    notifyListeners();
  }

  String? _addCargoInfo;
  String? get addCargoInfo => _addCargoInfo;

  void addCargoInfoState(String? type) {
    _addCargoInfo = type;

    notifyListeners();
  }

  void clearCarTon() {
    _setCarTon.clear();

    notifyListeners();
  }

  String? _addCargoTonString = '톤';
  String? get addCargoTonString => _addCargoTonString;

  void addCargotonStringState(String? type) {
    _addCargoTonString = type;

    notifyListeners();
  }

  String? _multiImgUrl;
  String? get multiImgUrl => _multiImgUrl;

  void multiImgUrlState(String? type) {
    _multiImgUrl = type;

    notifyListeners();
  }

  double? _addCargoTon;
  double? get addCargoTon => _addCargoTon;

  void addCargoTonState(double? type) {
    _addCargoTon = type;

    notifyListeners();
  }

  double? _addCargoCbm;
  double? get addCargoCbm => _addCargoCbm;

  void addCargoCbmState(double? type) {
    _addCargoCbm = type;

    notifyListeners();
  }

  double? _addCargoSizeGaro;
  double? get addCargoSizeGaro => _addCargoSizeGaro;

  double? _addCargoSizeSero;
  double? get addCargoSizeSero => _addCargoSizeSero;

  double? _addCargoSizeHi;
  double? get addCargoSizeHi => _addCargoSizeHi;

  void addCargoSizedState(double? garo, double? sero, double? hi) {
    _addCargoSizeGaro = garo;
    _addCargoSizeSero = sero;
    _addCargoSizeHi = hi;

    notifyListeners();
  }

  String? _addCargoImgUrl;
  String? get addCargoImgUrl => _addCargoImgUrl;

  void addCargoImgUrlState(String? type) {
    _addCargoImgUrl = type;

    notifyListeners();
  }

  String? _addCargoEtc;
  String? get addCargoEtc => _addCargoEtc;

  void addCargoEtcState(String? type) {
    _addCargoEtc = type;

    notifyListeners();
  }

  String? _resetImgUrl;
  String? get resetImgUrl => _resetImgUrl;

  void resetImgUrlState(String? type) {
    _resetImgUrl = type;

    notifyListeners();
  }

  String? _isPriceType;
  String? get isPriceType => _isPriceType;

  void isPriceTypeState(String type) {
    _isPriceType = type;

    notifyListeners();
  }

  bool? _isNormalEtax = false;
  bool? get isNormalEtax => _isNormalEtax;

  void isNormalEtaxState(bool type) {
    _isNormalEtax = type;

    notifyListeners();
  }

  bool? _isCashRec = false;
  bool? get isCashRec => _isCashRec;

  void isCashRecState(bool type) {
    _isCashRec = type;

    notifyListeners();
  }

  bool? _isDoneRec = false;
  bool? get isDoneRec => _isDoneRec;

  void isDoneRecState(bool type) {
    _isDoneRec = type;

    notifyListeners();
  }

  String? _senderType;
  String? get senderType => _senderType;

  void senderTypeState(String type) {
    _senderType = type;

    notifyListeners();
  }

  List<String> _payHowto = [];
  List<String> get payHowto => _payHowto;

  final Map<String, List<String>> _groups = {
    'paymentTiming': [
      '상차지에서 현금 결제',
      '하차지에서 현금 결제',
      '배차 후, 계좌 이체',
      '상차 완료 후, 계좌 이체',
      '하차 완료 후, 계좌 이체',
      '최초 장소에서 현금 결제',
      '마지막 장소에서 현금 결제',
      '운송 완료 후, 계좌 이체',
      '경유지에서 현금 결제'
    ],
    'paymentMethod': ['현금 결제', '계좌 이체']
  };

  void payHowtoState(String type) {
    print('입력된 값: "$type"');
    print('현재 리스트: $_payHowto');

    // 타이밍인지 확인
    if (_groups['paymentTiming']!.contains(type)) {
      // 기존 타이밍 제거하고 새로운 타이밍 추가
      _payHowto.removeWhere((item) => _groups['paymentTiming']!.contains(item));
      _payHowto.add(type);
    }
    // 결제방법인지 확인
    else if (_groups['paymentMethod']!.contains(type)) {
      // 기존 결제방법 제거하고 새로운 방법 추가
      _payHowto.removeWhere((item) => _groups['paymentMethod']!.contains(item));
      _payHowto.add(type);
    }

    print('변경된 리스트: $_payHowto');
    notifyListeners();
  }
  /////////////////////////////
  ////////////////////////////
  ///////////////////////////

  Map<String, String> headerss = {
    "X-NCP-APIGW-API-KEY-ID": ju2, // 개인 클라이언트 아이디
    "X-NCP-APIGW-API-KEY": ju3 // 개인 시크릿 키
  };
  Future<List<String>> latlngAddress(NLatLng position) async {
    String lat = position.latitude.toString();
    String lon = position.longitude.toString();

    print(ju2);
    print(ju3);

    try {
      http.Response response = await http.get(
        Uri.parse(
            "https://maps.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=$lon,$lat&output=json&orders=legalcode,admcode,addr,roadaddr"),
        headers: headerss,
      );

      // 인코딩 문제 해결: UTF-8로 명시적 디코딩
      final utf8Response = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonDataMap = jsonDecode(utf8Response);
        if (jsonDataMap.containsKey('results') &&
            jsonDataMap['results'] is List &&
            jsonDataMap['results'].isNotEmpty) {
          List<dynamic> results = jsonDataMap['results'];

          // 인덱스 찾기
          int addrIndex = -1;
          int roadAddrIndex = -1;

          for (int i = 0; i < results.length; i++) {
            if (results[i]['name'] == 'addr') {
              addrIndex = i;
            } else if (results[i]['name'] == 'roadaddr') {
              roadAddrIndex = i;
            }
          }

          // 지번 주소 처리
          String adsSS = '';
          if (addrIndex >= 0 && addrIndex < results.length) {
            var addrData = results[addrIndex];

            String adsS1 = '';
            if (addrData.containsKey('region')) {
              var region = addrData['region'];
              adsS1 = safeGet(region, 'area1.name', '') +
                  ' ' +
                  safeGet(region, 'area2.name', '') +
                  ' ' +
                  safeGet(region, 'area3.name', '') +
                  ' ' +
                  safeGet(region, 'area4.name', '');
            }

            String adsS2 = '';
            String adsS3 = '';
            if (addrData.containsKey('land')) {
              var land = addrData['land'];
              adsS2 = safeGet(land, 'type', '') == '2' ? '산 ' : '';

              var number1 = safeGet(land, 'number1', '');
              var number2 = safeGet(land, 'number2', '');

              adsS3 = (number2 == null || number2 == '')
                  ? number1
                  : number1 + '-' + number2;
            }

            adsSS = (adsS1 + ' ' + adsS2 + adsS3).trim();
          }

          // 도로명 주소 처리
          String adsR2 = 'no';
          if (roadAddrIndex >= 0 && roadAddrIndex < results.length) {
            var roadAddrData = results[roadAddrIndex];

            if (roadAddrData.containsKey('region') &&
                roadAddrData.containsKey('land')) {
              var region = roadAddrData['region'];
              var land = roadAddrData['land'];

              adsR2 = safeGet(region, 'area1.name', '') +
                  ' ' +
                  safeGet(region, 'area2.name', '') +
                  ' ' +
                  safeGet(region, 'area3.name', '') +
                  ' ' +
                  safeGet(land, 'name', '') +
                  ' ' +
                  safeGet(land, 'number1', '') +
                  (safeGet(land, 'number2', '').isNotEmpty
                      ? '-' + safeGet(land, 'number2', '')
                      : '') +
                  (safeGet(land, 'addition0.value', '').isNotEmpty
                      ? ' ' + safeGet(land, 'addition0.value', '')
                      : '');
            }
          }

          return [adsSS, adsR2];
        }
        print('검색 결과가 없습니다.');
        return [];
      } else {
        print('서버 응답 코드: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print("에러 발생: $e");
      return [];
    }
  }

// 안전하게 값을 가져오는 도우미 함수
  String safeGet(Map<dynamic, dynamic> map, String path, String defaultValue) {
    if (map == null) return defaultValue;

    List<String> keys = path.split('.');
    dynamic current = map;

    for (String key in keys) {
      if (current is Map && current.containsKey(key)) {
        current = current[key];
      } else {
        return defaultValue;
      }
    }

    return current == null ? defaultValue : current.toString();
  }
  //원미로 13번길 43

  static const String URL =
      "https://dapi.kakao.com/v2/local/search/address.json";

  static const String KURL =
      "https://dapi.kakao.com/v2/local/search/keyword.json";

  static Map<String, String> HEADERS = {"Authorization": "KakaoAK " + ju};

  Map<String, dynamic>? _data;
  Map<String, dynamic>? get data => _data;
  Map<String, dynamic>? _dataA; // Map 형식 유지
  Map<String, dynamic>? get dataA => _dataA;

  set data(newData) {
    this._data = newData;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> search(
      {required String searchData}) async {
    try {
      final String _data =
          "?query=$searchData&page=1&size=10&analyze_type=similar";
      final http.Response _res = await http.get(
          Uri.parse(AddProvider.URL + _data),
          headers: AddProvider.HEADERS);
      final Map<String, dynamic> _result = json.decode(_res.body);

      if (_result != null && _result.containsKey('documents')) {
        // _dataA를 Map 형태로 저장
        _dataA = {'documents': _result['documents']};

        this.data = _result;
        notifyListeners();

        // 리스트 형태로 반환
        return List<Map<String, dynamic>>.from(_result['documents']);
      } else {
        print('No results found or invalid response format');
        _dataA = {'documents': []}; // 빈 결과일 때도 Map 형태 유지
        notifyListeners();
        return [];
      }
    } catch (e) {
      print('Search error: $e');
      _dataA = {'documents': []}; // 에러 발생시에도 Map 형태 유지
      notifyListeners();
      return [];
    }
  }

  Future<List<SearchResult>> keywordSearch(String keyword) async {
    String url =
        'https://openapi.naver.com/v1/search/local.xml?query=${Uri.encodeComponent(keyword)}&display=10&start=1&sort=random';

    Map<String, String> headers = {
      'X-Naver-Client-Id': ju4,
      'X-Naver-Client-Secret': ju5,
    };

    var response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(response.body);

      final items = document.findAllElements('item');
      List<SearchResult> results = [];

      for (var item in items) {
        final title = item.findElements('title').first.text;
        final category = item.findElements('category').first.text;
        final address = item.findElements('address').first.text;
        final roadAddress = item.findElements('roadAddress').first.text;
        final mapx = int.parse(item.findElements('mapx').first.text) / 1e7;
        final mapy = int.parse(item.findElements('mapy').first.text) / 1e7;

        final formattedTitle = title.replaceAll(RegExp(r'<.*?>'), '');
        print(title);

        SearchResult result = SearchResult(
          title: formattedTitle,
          category: category,
          address: address,
          roadAddress: roadAddress,
          mapx: mapx,
          mapy: mapy,
        );
        final mapxValue = item.findElements('mapx').first;
        print('mapx value: $mapxValue');

        results.add(result);
      }

      notifyListeners();

      return results;
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return [];
    }
  }

  //////////////////////////////////////////
  /////////////////////////////////////////////
  /////////////////////////////////////////////
  /////////////////////////////////////////////

  List<CargoLocation> _locations = [];

  // 전체 리스트 getter
  List<CargoLocation> get locations => _locations;

  // 현재 등록된 개수
  int get locationCount => _locations.length;

  // 추가 가능 여부 (15개 제한)
  bool get canAddMore => _locations.length <= 17;

  // 새로운 위치 추가
  void addLocation(CargoLocation location) {
    print('addLocation 호출: ${location.type}, canAddMore: $canAddMore');
    if (canAddMore) {
      _locations.add(location);
      print('위치 추가됨, 현재 길이: ${_locations.length}');
      notifyListeners();
    } else {
      print('canAddMore가 false여서 위치 추가 실패');
    }
  }

  void updateLocation(
    int index, {
    required String type,
    required String address1,
    required String address2,
    required String addressDis,
    required NLatLng location,
    required String howTo,
    required List senderType,
    required String senderName,
    required String snederPhone,
    required String dateType,
    required String dateAloneString,
    DateTime? dateStart,
    DateTime? dateEnd,
    required DateTime date,
    required String etc,
    required String becareful,
    bool? isDone,
    DateTime? isDoneTime,
    List<CargoInfo>? downCargos,
    List<CargoInfo>? upCargos,
  }) {
    if (index >= 0 && index < _locations.length) {
      CargoLocation cargo = _locations[index];

      cargo.type = type;
      cargo.address1 = address1;
      cargo.address2 = address2;
      cargo.addressDis = addressDis;
      cargo.location = location;
      cargo.howTo = howTo;
      cargo.senderType = senderType;
      cargo.senderName = senderName;
      cargo.senderPhone = snederPhone;
      cargo.dateType = dateType;
      cargo.dateAloneString = dateAloneString;
      cargo.dateStart = dateStart;
      cargo.dateEnd = dateEnd;
      cargo.date = date;
      cargo.etc = etc;
      cargo.becareful = becareful;
      cargo.isDone = isDone;
      cargo.isDoneTime = isDoneTime;

      if (downCargos != null) {
        cargo.downCargos = downCargos;
      }

      if (upCargos != null) {
        cargo.upCargos = upCargos;
      }

      notifyListeners();
    }
  }

  // 상차 화물 관련 메서드들 추가

  void setUpCargoList(int locationIndex, List<CargoInfo> cargoList) {
    if (locationIndex >= 0 && locationIndex < _locations.length) {
      _locations[locationIndex].upCargos = List.from(cargoList);
      notifyListeners();
    }
  }

  void setdownCargoList(int locationIndex, List<CargoInfo> cargoList) {
    if (locationIndex >= 0 && locationIndex < _locations.length) {
      _locations[locationIndex].downCargos = List.from(cargoList);
      notifyListeners();
    }
  }

  void addUpCargo(int locationIndex, CargoInfo cargo) {
    if (locationIndex >= 0 && locationIndex < _locations.length) {
      _locations[locationIndex].upCargos.add(cargo);
      notifyListeners();
    }
  }

  void updateSUpCargo(int cargoIndex, CargoInfo cargo) {
    if (cargoIndex >= 0 && cargoIndex < _upCargos.length) {
      _upCargos[cargoIndex] = cargo;
      notifyListeners();
    }
  }

// 하차 화물용
  void updateSDownCargo(int cargoIndex, CargoInfo cargo) {
    if (cargoIndex >= 0 && cargoIndex < _downCargos.length) {
      _downCargos[cargoIndex] = cargo;
      notifyListeners();
    }
  }

  void updateUpCargo(int locationIndex, int cargoIndex, CargoInfo cargo) {
    if (locationIndex >= 0 &&
        locationIndex < _locations.length &&
        cargoIndex >= 0 &&
        cargoIndex < _locations[locationIndex].upCargos.length) {
      _locations[locationIndex].upCargos[cargoIndex] = cargo;
      notifyListeners();
    }
  }

  void removeUpCargo(int locationIndex, int cargoIndex) {
    if (locationIndex >= 0 &&
        locationIndex < _locations.length &&
        cargoIndex >= 0 &&
        cargoIndex < _locations[locationIndex].upCargos.length) {
      _locations[locationIndex].upCargos.removeAt(cargoIndex);
      notifyListeners();
    }
  }

  // 하차 화물 관련 메서드들은 그대로 유지
  void addDownCargo(int locationIndex, CargoInfo cargo) {
    if (locationIndex >= 0 && locationIndex < _locations.length) {
      _locations[locationIndex].downCargos.add(cargo);
      notifyListeners();
    }
  }

  void updateDownCargo(int locationIndex, int cargoIndex, CargoInfo cargo) {
    if (locationIndex >= 0 &&
        locationIndex < _locations.length &&
        cargoIndex >= 0 &&
        cargoIndex < _locations[locationIndex].downCargos.length) {
      _locations[locationIndex].downCargos[cargoIndex] = cargo;
      notifyListeners();
    }
  }

  void removeDownCargo(int locationIndex, int cargoIndex) {
    if (locationIndex >= 0 &&
        locationIndex < _locations.length &&
        cargoIndex >= 0 &&
        cargoIndex < _locations[locationIndex].downCargos.length) {
      _locations[locationIndex].downCargos.removeAt(cargoIndex);
      notifyListeners();
    }
  }

  // 하차 화물 정보를 담는 클래스

  // 특정 위치 삭제
  void removeLocation(int index) {
    if (index >= 0 && index < _locations.length) {
      // 삭제될 위치의 모든 상차 화물 ID를 수집
      List<String?> cargoIdsToRemove = [];
      if (_locations[index].upCargos.isNotEmpty) {
        for (var cargo in _locations[index].upCargos) {
          if (cargo.id != null) {
            cargoIdsToRemove.add(cargo.id);
          }
        }
      }

      // 해당 인덱스의 위치 삭제
      _locations.removeAt(index);

      // 수집된 ID를 가진 화물을 모든 위치의 하차 목록에서 제거
      for (var location in _locations) {
        if (location.downCargos.isNotEmpty) {
          location.downCargos.removeWhere((cargo) =>
              cargo.id != null && cargoIdsToRemove.contains(cargo.id));
        }
      }

      // 남은 위치들의 인덱스 업데이트
      for (int i = 0; i < _locations.length; i++) {
        // 상차 화물 인덱스 업데이트
        for (var cargo in _locations[i].upCargos) {
          if (cargo.locationIndex != null && cargo.locationIndex! > index) {
            cargo.locationIndex = cargo.locationIndex! - 1;
          }
        }

        // 하차 화물 인덱스 업데이트
        for (var cargo in _locations[i].downCargos) {
          if (cargo.locationIndex != null && cargo.locationIndex! > index) {
            cargo.locationIndex = cargo.locationIndex! - 1;
          }

          if (cargo.downIndex != null && cargo.downIndex! > index) {
            cargo.downIndex = cargo.downIndex! - 1;
          }
        }
      }

      notifyListeners();
    }
  }

  void insertLocation(int index, CargoLocation newLocation) {
    if (index >= 0 && index <= _locations.length) {
      // 새 위치 삽입
      _locations.insert(index, newLocation);

      // 삽입 지점 이후의 모든 위치와 화물의 인덱스 업데이트
      for (int i = 0; i < _locations.length; i++) {
        // 상차 화물 인덱스 업데이트
        for (var cargo in _locations[i].upCargos) {
          // 새 위치가 삽입된 지점 이후에 있는 화물들의 인덱스 증가
          if (cargo.locationIndex != null &&
              cargo.locationIndex! >= index &&
              i != index) {
            cargo.locationIndex = cargo.locationIndex! + 1;
          }
        }

        // 하차 화물 인덱스 업데이트
        for (var cargo in _locations[i].downCargos) {
          // 새 위치가 삽입된 지점 이후에 있는 화물들의 인덱스 증가
          if (cargo.locationIndex != null &&
              cargo.locationIndex! >= index &&
              i != index) {
            cargo.locationIndex = cargo.locationIndex! + 1;
          }

          if (cargo.downIndex != null && cargo.downIndex! >= index) {
            cargo.downIndex = cargo.downIndex! + 1;
          }
        }
      }

      // 새로 삽입된 위치의 화물들에게 올바른 locationIndex 설정
      for (var cargo in _locations[index].upCargos) {
        cargo.locationIndex = index;
      }

      for (var cargo in _locations[index].downCargos) {
        cargo.locationIndex = index;
      }

      notifyListeners();
    }
  }

  // 전체 위치 초기화
  void clearLocations() {
    _locations.clear();
    notifyListeners();
  }

  // 특정 인덱스의 위치 정보 가져오기
  CargoLocation? getLocation(int index) {
    if (index >= 0 && index < _locations.length) {
      return _locations[index];
    }
    return null;
  }

  int getPickupCount() {
    return _locations.where((location) => location.type == '상차').length;
  }

  // 하차 개수만 반환
  int getDropoffCount() {
    return _locations.where((location) => location.type == '하차').length;
  }

  // 전체 타입별 카운트를 한번에 반환 (기존 메소드)
  Map<String, int> getTypeCount() {
    return {
      '상차': getPickupCount(),
      '하차': getDropoffCount(),
    };
  }

// 날짜별 개수를 반환하는 메소드
  // 오늘 날짜의 카운트만 반환
  int getTodayCount() {
    final now = DateTime.now();
    return _locations.where((location) {
      final locationDate = DateTime(
        location.date!.year,
        location.date!.month,
        location.date!.day,
      );
      return locationDate.year == now.year &&
          locationDate.month == now.month &&
          locationDate.day == now.day;
    }).length;
  }

  // 내일 날짜의 카운트만 반환
  int getTomorrowCount() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return _locations.where((location) {
      final locationDate = DateTime(
        location.date!.year,
        location.date!.month,
        location.date!.day,
      );
      return locationDate.year == tomorrow.year &&
          locationDate.month == tomorrow.month &&
          locationDate.day == tomorrow.day;
    }).length;
  }

  // 예약(내일 이후) 날짜의 카운트만 반환
  int getFutureCount() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return _locations.where((location) {
      final locationDate = DateTime(
        location.date!.year,
        location.date!.month,
        location.date!.day,
      );
      return locationDate.isAfter(tomorrow);
    }).length;
  }

  // 전체 날짜별 카운트를 한번에 반환 (기존 메소드)
  Map<String, int> getDateTypeCount() {
    return {
      '오늘': getTodayCount(),
      '내일': getTomorrowCount(),
      '예약': getFutureCount(),
    };
  }

// 총 이동 거리를 계산하는 메소드 (km 단위)
  Future<Map<String, dynamic>> calculateTotalDistance() async {
    if (_locations.length < 2) {
      return {
        'totalDistance': 0.0,
        'segments': <Map<String, dynamic>>[],
      };
    }

    double totalDistance = 0.0;
    List<Map<String, dynamic>> segments = [];

    for (int i = 0; i < _locations.length - 1; i++) {
      final start = _locations[i];
      final end = _locations[i + 1];

      // null check 추가
      if (start.location == null || end.location == null) {
        continue;
      }

      // 두 지점 간의 거리 계산
      final distance = NaverMapUtils.calculateDistance(
        startLat: start.location!.latitude,
        startLng: start.location!.longitude,
        endLat: end.location!.latitude,
        endLng: end.location!.longitude,
      );

      // 구간 정보 저장
      segments.add({
        'fromAddress': start.address1,
        'toAddress': end.address1,
        'fromLocation': {
          'lat': start.location!.latitude,
          'lng': start.location!.longitude,
        },
        'toLocation': {
          'lat': end.location!.latitude,
          'lng': end.location!.longitude,
        },
        'distance': double.parse(distance.toStringAsFixed(1)),
      });

      totalDistance += distance;
    }

    return {
      'totalDistance': double.parse(totalDistance.toStringAsFixed(1)),
      'segments': segments,
    };
  }

  Future<String> getFormattedTotalDistance() async {
    try {
      final result = await calculateTotalDistance();
      if (result == null || !result.containsKey('totalDistance')) {
        return '0.0 km';
      }

      final distance = result['totalDistance'] as double;
      return '${distance.toStringAsFixed(1)} km';
    } catch (e) {
      return '0.0 km'; // 어떤 에러가 발생하더라도 0 반환
    }
  }

// 분석 결과를 한번에 가져오는 메소드
  Future<Map<String, dynamic>> getAnalytics() async {
    final typeCount = getTypeCount();
    final dateCount = getDateTypeCount();
    final totalDistance = await calculateTotalDistance();

    return {
      'typeCount': typeCount,
      'dateCount': dateCount,
      'totalDistance': totalDistance,
    };
  }

  // 리스트에서 좌표만 뽑음
  List<NLatLng> getLocationCoordinates() {
    List<NLatLng> coordinates = [];

    // locations 리스트를 순회하면서 각 CargoLocation의 좌표를 추출
    for (CargoLocation cargo in _locations) {
      // location이 null이 아닌 경우만 추가
      if (cargo.location != null) {
        coordinates.add(cargo.location!);
      }
    }

    return coordinates;
  }

  List<CargoPoint> getDetailedLocationCoordinates() {
    List<CargoPoint> detailedCoords = [];
    int order = 0;

    // locations 리스트를 순회하면서 정보 추출
    for (CargoLocation cargo in _locations) {
      if (cargo.location != null) {
        detailedCoords.add(
          CargoPoint(
            coordinate: cargo.location!,
            type: cargo.type.toString(), // '상차' 또는 '하차'
            order: order++, // 순서
            address: cargo.address1.toString(), // 주소
            upNum: cargo.upCargos.length,
            downNum: cargo.downCargos.length,
          ),
        );
      }
    }

    return detailedCoords;
  }

  //////////////////////////////////////////
  /////////////////////////////////////////////
  /////////////////////////////////////////////
  /////////////////////////////////////////////
  //

  /// 설정에서 필요한 up,down 화물 정보
  ///
  ///
  ///
  ///

  List<CargoInfo> _upCargos = [];

  // Getter
  List<CargoInfo> get upCargos => _upCargos;

  List<CargoInfo> _downCargos = [];

  // Getter
  List<CargoInfo> get downCargos => _downCargos;

// upCargos setter
  void setUpCargos(List<CargoInfo> cargos) {
    _upCargos = List.from(cargos);
    notifyListeners();
  }

// downCargos setter
  void setDownCargos(List<CargoInfo> cargos) {
    _downCargos = List.from(cargos);
    notifyListeners();
  }

  void subUpAddCargo(CargoInfo cargo) {
    _upCargos.add(cargo);
    notifyListeners();
  }

  void subUpUpdateCargo(int index, CargoInfo cargo) {
    if (index >= 0 && index < _upCargos.length) {
      _upCargos[index] = cargo;
      notifyListeners();
    }
  }

  void removeCargoFromAllLocations(String targetId, AddProvider addProvider) {
    // 모든 locations를 순회하며
    for (var location in addProvider.locations) {
      // upCargos에서 해당 ID를 가진 CargoInfo 삭제
      if (location.upCargos != null) {
        int upIndexToRemove =
            location.upCargos.indexWhere((cargo) => cargo.id == targetId);
        if (upIndexToRemove != -1) {
          location.upCargos.removeAt(upIndexToRemove);
        }
      }

      // downCargos에서 해당 ID를 가진 CargoInfo 삭제
      if (location.downCargos != null) {
        int downIndexToRemove =
            location.downCargos.indexWhere((cargo) => cargo.id == targetId);
        if (downIndexToRemove != -1) {
          location.downCargos.removeAt(downIndexToRemove);
        }
      }
    }
    notifyListeners();
  }

  void subUpRemoveCargo(int index) {
    if (index >= 0 && index < _upCargos.length) {
      _upCargos.removeAt(index);
      notifyListeners();
    }
  }

  void subDownAddCargo(CargoInfo cargo) {
    _downCargos.add(cargo);
    notifyListeners();
  }

  void subDownUpdateCargo(int index, CargoInfo cargo) {
    if (index >= 0 && index < _downCargos.length) {
      _downCargos[index] = cargo;
      notifyListeners();
    }
  }

  void subDownRemoveCargo(int index) {
    if (index >= 0 && index < _downCargos.length) {
      _downCargos.removeAt(index);
      notifyListeners();
    }
  }

  void setCargos(List<CargoInfo> cargos) {
    _upCargos = List.from(cargos);
    _downCargos = List.from(cargos);
    notifyListeners();
  }

  void clearCargos() {
    _upCargos.clear();
    _downCargos.clear();
    notifyListeners();
  }

  //////////////////////////////////////////
  /////////////////////////////////////////////
  /////////////////////////////////////////////
  /////////////////////////////////////////////
  // 네이버 경로 호출

  /// 경로 요청 및 좌표 반환
  /// [coordinates]: 시작점, 경유지들, 도착점을 포함한 좌표 리스트
  ///
  ///
  ///

  List<NLatLng> _coordinates = [];
  List<NLatLng> _routeWaypoints = []; // 이전 경로 요청시의 좌표들
  String _totalDistance = "...";
  String _totalDuration = "...";
  bool _isRouteLoading = false;
  String? _error;

  // Getters
  List<NLatLng> get coordinates => _coordinates;
  String get totalDistance => _totalDistance;
  String get totalDuration => _totalDuration;
  bool get isRouteLoading => _isRouteLoading;
  String? get error => _error;

  void totalDistancedState(String value) {
    _totalDistance = value;
    notifyListeners();
  }

  void totalDurationState(String value) {
    _totalDuration = value;
    notifyListeners();
  }

  void coordSet(List<NLatLng> value) {
    _coordinates = value;
    notifyListeners();
  }

  bool _isRoad = false;
  bool get isRoad => _isRoad;

  void isRoadState(bool value) {
    _isRoad = value;
    notifyListeners();
  }

  void disDur(String dis, String dur) {
    _totalDistance = dis;
    _totalDuration = dur;

    notifyListeners();
  }

  // 변수 추가
  String _halfDistance = "...";
  String _halfDuration = "...";

// getter 추가
  String get halfDistance => _halfDistance;
  String get halfDuration => _halfDuration;

// 기존 disDur 함수는 그대로 두고, 하프값을 위한 새로운 함수 추가
  void halfDisDur(String dis, String dur) {
    _halfDistance = dis;
    _halfDuration = dur;
    notifyListeners();
  }

  // 경로 체크 및 업데이트
  Future<void> checkAndUpdateRoute() async {
    List<NLatLng> locationCoords = getLocationCoordinates();

    // 경로가 2개 미만이면 초기화
    if (locationCoords.length < 2) {
      _routeWaypoints = [];
      _coordinates = [];
      _totalDistance = "...";
      _totalDuration = "...";
      notifyListeners();
      return;
    }

    // 이전 경로 요청 좌표와 현재 좌표 비교
    bool needsUpdate = true;

    if (_routeWaypoints.isNotEmpty) {
      // 개수가 같은지 먼저 확인
      if (locationCoords.length == _routeWaypoints.length) {
        needsUpdate = false;
        // 순서대로 좌표 비교
        for (int i = 0; i < locationCoords.length; i++) {
          if (!_coordsMatch(locationCoords[i], _routeWaypoints[i])) {
            needsUpdate = true;
            break;
          }
        }
      }
    }

    print(locationCoords);

    // 업데이트가 필요한 경우만 API 호출
    if (needsUpdate) {
      print('호출');
      await getRoute(points: locationCoords, carType: '3', fuelType: 'diesel');
    }
  }

  // 좌표 비교
  bool _coordsMatch(NLatLng coord1, NLatLng coord2) {
    const double tolerance = 0.0001;
    return (coord1.latitude - coord2.latitude).abs() < tolerance &&
        (coord1.longitude - coord2.longitude).abs() < tolerance;
  }

  // 경로 요청
  Future<void> getRoute({
    required List<NLatLng> points,
    required String carType,
    required String fuelType,
    num? mileage,
  }) async {
    _isRouteLoading = true;
    _error = null;
    notifyListeners();
    print('경로 추적 시작');

    try {
      // 현재 요청하는 좌표들 저장
      _routeWaypoints = List.from(points);

      String start = '${points.first.longitude},${points.first.latitude}';
      String goal = '${points.last.longitude},${points.last.latitude}';

      List<String> waypoints = [];
      if (points.length >= 2) {
        waypoints = points.sublist(1, points.length - 1).map((coord) {
          return '${coord.longitude},${coord.latitude}';
        }).toList();
      }

      final response = await (points.length > 7
          ? _getDynamic15Response(
              start, goal, waypoints, carType, fuelType, mileage)
          : _getDynamic5Response(
              start, goal, waypoints, carType, fuelType, mileage));

      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        Map<String, dynamic> data = json.decode(responseBody);
        _processRouteData(data);
      } else {
        _error = 'API 호출 실패: ${response.statusCode}';
        _routeWaypoints = []; // 실패 시 초기화
        print(_error);
      }
    } catch (e) {
      _error = '에러 발생: $e';
      _routeWaypoints = []; // 에러 시 초기화
    } finally {
      _isRouteLoading = false;
      notifyListeners();
    }
  }

  Future<http.Response> _getDynamic5Response(
    String start,
    String goal,
    List<String> waypoints,
    String carType,
    String fuelType,
    num? mileage,
  ) async {
    if (waypoints.length > 5) {
      waypoints = waypoints.sublist(0, 5);
    }

    String baseUrl = 'https://maps.apigw.ntruss.com/map-direction/v1/driving';
    String waypointParam =
        waypoints.isEmpty ? '' : '&waypoints=${waypoints.join('|')}';
    String url =
        '$baseUrl?start=$start&goal=$goal$waypointParam&option=tracomfort&cartype=4&fueltype=diesel&mileage=${mileage ?? 13}';

    return await http.get(
      Uri.parse(url),
      headers: {
        'X-NCP-APIGW-API-KEY-ID': ju2,
        'X-NCP-APIGW-API-KEY': ju3,
      },
    );
  }

  Future<http.Response> _getDynamic15Response(
    String start,
    String goal,
    List<String> waypoints,
    String carType,
    String fuelType,
    num? mileage,
  ) async {
    if (waypoints.length > 13) {
      waypoints = waypoints.sublist(0, 13);
    }

    String baseUrl =
        'https://maps.apigw.ntruss.com/map-direction-15/v1/driving';
    String waypointParam =
        waypoints.isEmpty ? '' : '&waypoints=${waypoints.join('|')}';
    String url =
        '$baseUrl?start=$start&goal=$goal$waypointParam&option=tracomfort&cartype=4&fueltype=diesel&mileage=${mileage ?? 13}';

    return await http.get(
      Uri.parse(url),
      headers: {
        'X-NCP-APIGW-API-KEY-ID': ju2,
        'X-NCP-APIGW-API-KEY': ju3,
      },
    );
  }

  void _processRouteData(Map<String, dynamic> data) {
    try {
      if (!data.containsKey('route') ||
          !data['route'].containsKey('tracomfort') ||
          data['route']['tracomfort'].isEmpty) {
        _error = '유효하지 않은 응답 데이터';
        return;
      }

      var route = data['route']['tracomfort'][0];

      // 경로 좌표 추출
      List<dynamic> path = route['path'];
      _coordinates = path.map<NLatLng>((coordinate) {
        return NLatLng(
          coordinate[1].toDouble(),
          coordinate[0].toDouble(),
        );
      }).toList();

      // 거리 변환 (미터 -> km)
      int distanceInMeters = route['summary']['distance'];
      // 전체 거리
      _totalDistance = distanceInMeters >= 1000
          ? '${(distanceInMeters / 1000).toStringAsFixed(1)}km'
          : '${distanceInMeters}m';
      // 반값 거리
      int halfDistanceMeters = (distanceInMeters / 2).round();
      _halfDistance = halfDistanceMeters >= 1000
          ? '${(halfDistanceMeters / 1000).toStringAsFixed(1)}km'
          : '${halfDistanceMeters}m';

      // 시간 변환
      int durationInSeconds = (route['summary']['duration'] / 1000).floor();
      // 전체 시간
      int hours = (durationInSeconds / 3600).floor();
      int minutes = ((durationInSeconds % 3600) / 60).floor();
      if (hours > 0) {
        _totalDuration = '${hours}시간 ${minutes}분';
      } else {
        _totalDuration = '${minutes}분';
      }

      // 반값 시간
      int halfDurationSeconds = (durationInSeconds / 2).round();
      int halfHours = (halfDurationSeconds / 3600).floor();
      int halfMinutes = ((halfDurationSeconds % 3600) / 60).floor();
      if (halfHours > 0) {
        _halfDuration = '${halfHours}시간 ${halfMinutes}분';
      } else {
        _halfDuration = '${halfMinutes}분';
      }
    } catch (e) {
      _error = '데이터 처리 중 에러: $e';
      print('에러: $e');
    }
  }

  Future<void> checkAndUpdateSimpleRoute() async {
    // 1. 상하차 좌표가 모두 있는지 확인
    if (_setLocationUpNLatLng == null || _setLocationDownNLatLng == null) {
      _routeWaypoints = [];
      _coordinates = [];
      _totalDistance = "...";
      _totalDuration = "...";
      notifyListeners();
      return;
    }

    // 2. 현재 좌표 리스트 생성
    List<NLatLng> currentCoords = [
      _setLocationUpNLatLng!,
      _setLocationDownNLatLng!
    ];

    // 3. 이전 경로 요청 좌표와 비교 (경로가 없거나 다른 경우에만 업데이트)
    bool needsUpdate = true;

    if (_routeWaypoints.isNotEmpty) {
      // 상하차 좌표 2개가 모두 있고 같은지 확인
      if (_routeWaypoints.length == 2) {
        needsUpdate = !_coordsMatch(_routeWaypoints[0], currentCoords[0]) ||
            !_coordsMatch(_routeWaypoints[1], currentCoords[1]);
      }
    }

    // 4. 업데이트가 필요한 경우만 API 호출
    if (needsUpdate) {
      await getRoute(points: currentCoords, carType: '3', fuelType: 'diesel');
    }
  }

  void clear() {
    _coordinates = [];
    _routeWaypoints = [];
    _totalDistance = "...";
    _totalDuration = "...";
    _halfDistance = '...';
    _halfDuration = '...';
    _error = null;
    notifyListeners();
  }

  //////////////////////////////////////////
  /////////////////////////////////////////////
  /////////////////////////////////////////////
  /////////////////////////////////////////////
  // 이미지 정리

  void setLoading(bool value) {
    _addLoading = value;
    notifyListeners();
  }

  Future<bool> captureAndCompressImage({
    required ImageSource source,
    required String callType,
  }) async {
    try {
      setLoading(true);

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final compressedImage = await _compressImage(imageFile);

        if (compressedImage != null) {
          _cargoImage = compressedImage;
          notifyListeners();
        }
      }
      return true;
    } catch (e) {
      print('이미지 처리 중 에러 발생: $e');
      // 에러 처리 로직
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> comAddImage({
    required ImageSource source,
    required String callType,
  }) async {
    try {
      setLoading(true);

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final compressedImage = await _compressImage(imageFile);

        if (compressedImage != null) {
          if (callType.contains('사업자등록증')) {
            _companyBusinessPhoto = compressedImage;
          } else if (callType.contains('로고')) {
            _companyLogoPhoto = compressedImage;
          } else {
            _companyAccountPhoto = compressedImage;
          }

          notifyListeners();
        }
      }
      return true;
    } catch (e) {
      print('이미지 처리 중 에러 발생: $e');
      // 에러 처리 로직
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<File?> _compressImage(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final formattedDate = DateFormat('MM-dd-HH-mm-ss').format(now);
      final imagePath = '${directory.path}/mixCall_$formattedDate.jpg';

      if (!imageFile.existsSync()) {
        print('원본 이미지 파일이 없습니다');
        return null;
      }

      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        imageFile.path,
        imagePath,
        quality: 10,
      );

      return compressedImage != null ? File(compressedImage.path) : null;
    } catch (e) {
      print('압축 중 에러 발생: $e');
      return null;
    }
  }

  void clearImage() {
    _cargoImage = null;
    notifyListeners();
  }

  void updateCargoInAllLocations(CargoInfo updatedCargo) {
    String targetId = updatedCargo.id.toString();
    print('업데이트 시도 - ID: $targetId');

    // 1. _upCargos 업데이트
    if (_upCargos != null) {
      for (int i = 0; i < _upCargos.length; i++) {
        if (_upCargos[i].id == targetId) {
          print('_upCargos[$i] 업데이트됨');
          _upCargos[i] = updatedCargo;
        }
      }
    }

    // 2. _downCargos 업데이트
    if (_downCargos != null) {
      for (int i = 0; i < _downCargos.length; i++) {
        if (_downCargos[i].id == targetId) {
          print('_downCargos[$i] 업데이트됨');
          _downCargos[i] = updatedCargo;
        }
      }
    }

    // 3. 모든 _locations의 upCargos 업데이트
    if (_locations != null) {
      for (int locIndex = 0; locIndex < _locations.length; locIndex++) {
        // upCargos 업데이트
        if (_locations[locIndex].upCargos != null) {
          for (int i = 0; i < _locations[locIndex].upCargos.length; i++) {
            if (_locations[locIndex].upCargos[i].id == targetId) {
              print('_locations[$locIndex].upCargos[$i] 업데이트됨');
              _locations[locIndex].upCargos[i] = updatedCargo;
            }
          }
        }

        // 4. 모든 _locations의 downCargos 업데이트
        if (_locations[locIndex].downCargos != null) {
          for (int i = 0; i < _locations[locIndex].downCargos.length; i++) {
            if (_locations[locIndex].downCargos[i].id == targetId) {
              print('_locations[$locIndex].downCargos[$i] 업데이트됨');
              _locations[locIndex].downCargos[i] = updatedCargo;
            }
          }
        }
      }
    }

    print('업데이트 완료');
    notifyListeners();
  }

  /// 주소 요청(우편번호)
  ///
  ///
  ///
  ///

/*   static const String URLDaum =
      "https://dapi.kakao.com/v2/local/search/address.json";



  Future<void> searchAA({required String searchData}) async {
    final String _data =
        "?query=$searchData&page=1&size=10&analyze_type=similar";
    final http.Response _res =
        await http.get(Uri.parse(URLDaum + _data), headers: AddProvider.HEADERS);
    final Map<String, dynamic> _result = json.decode(_res.body);

    if (_result != null) {
      print('Result: $_result');
      print(_result['meta']['total_count']);
    } else {
      print('No result found');
      return null; // 예를 들어, 결과가 없을 때 null을 반환하도록 설정
    }
    _dataA = _result;
    this.data = _result;
    notifyListeners();
    return;
  } */
}
