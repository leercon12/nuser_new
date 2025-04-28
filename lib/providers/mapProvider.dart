import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

class MapProvider extends ChangeNotifier {
  bool _normalStop = false;
  String _normalAnd = '1.0.0';
  String _normalIos = '1.0.0';

  bool get normalStop => _normalStop;
  String get normalAnd => _normalAnd;
  String get normalIos => _normalIos;

  void updateRemoteConfig({
    required bool normalStop,
    required String normalAnd,
    required String normalIos,
  }) {
    _normalStop = normalStop;
    _normalAnd = normalAnd;
    _normalIos = normalIos;
    notifyListeners();
  }

  bool? _isUpdateDown = false;
  bool? get isUpdateDown => _isUpdateDown;

  void isUpdateDownState(bool value) {
    _isUpdateDown = value;
    notifyListeners();
  }

  bool? _isLogin = false;
  bool? get isLogin => _isLogin;

  void isLoginState(bool value) {
    _isLogin = value;
    notifyListeners();
  }

  String? _joinType;
  String? get joinType => _joinType;

  void joinTypeState(String? value) {
    _joinType = value;
    notifyListeners();
  }

  String? _resetPhone;
  String? get resetPhone => _resetPhone;

  void resetPhoneState(String? value) {
    _resetPhone = value;
    notifyListeners();
  }

  String? _bidingSelId;
  String? get bidingSelId => _bidingSelId;

  void bidingSelIdState(String? value) {
    _bidingSelId = value;
    notifyListeners();
  }

  bool? _isResetVerif = false;
  bool? get isResetVerif => _isResetVerif;

  void isResetVerifState(bool value) {
    _isResetVerif = value;
    notifyListeners();
  }

  /////////////////////////////////
  /// 로딩프로바이더.
  ///

  bool? _isLoading = false;
  bool? get isLoading => _isLoading;

  void isLoadingState(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  /////////////////////////////////
  /// 일반가입 정보
  ///

  String? _joinUserName;
  String? get joinUserName => _joinUserName;

  void joinUserNameState(String? value) {
    _joinUserName = value;
    notifyListeners();
  }

  String? _joinEmail;
  String? get joinEmail => _joinEmail;

  void joinEmailState(String? value) {
    _joinEmail = value;
    notifyListeners();
  }

  String? _joinPhone;
  String? get joinPhone => _joinPhone;

  void joinPhoneState(String? value) {
    _joinPhone = value;
    notifyListeners();
  }

  String? _joinPw;
  String? get joinPw => _joinPw;

  void joinPwState(String? value) {
    _joinPw = value;
    notifyListeners();
  }

  ///////////////////////////
  ///
  /// 지도 관련
  ///

  NaverMapController? _controller;

  NaverMapController? get controller => _controller;
  // 컨트롤러 상태관리
  void setController(NaverMapController? controller) {
    _controller = controller;
    notifyListeners();
  }

  NLatLng? _currentLivePosition;
  NLatLng? get currentLivePosition => _currentLivePosition;

  final StreamController<NLatLng> _locationStreamController =
      StreamController<NLatLng>.broadcast();
  Stream<NLatLng> get locationStream => _locationStreamController.stream;

  StreamSubscription<Position>? _positionStreamSubscription;

// 위치 권한 체크 및 요청
  Future<bool> checkAndRequestLocationPermission() async {
    // 1. 위치 서비스 활성화 체크
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('위치 서비스가 비활성화되어 있습니다.');
      return false;
    }

    // 2. 위치 권한 상태 체크
    LocationPermission permission = await Geolocator.checkPermission();

    // 3. 권한이 거부된 경우 요청
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('위치 권한이 거부되었습니다.');
        return false;
      }
    }

    // 4. 영구적으로 거부된 경우
    if (permission == LocationPermission.deniedForever) {
      print('위치 권한이 영구적으로 거부되었습니다.');
      return false;
    }

    return true;
  }

// 실시간 위치 업데이트 시작
  Future<void> startLocationUpdates() async {
    try {
      // 권한 체크 및 요청
      bool hasPermission = await checkAndRequestLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission not granted');
      }

      // 위치 업데이트 시작
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen(
        // 위치 업데이트 수신
        (Position position) {
          _currentLivePosition = NLatLng(
            position.latitude,
            position.longitude,
          );
          _locationStreamController.add(_currentLivePosition!);
          notifyListeners();
        },
        // 에러 처리
        onError: (error) {
          print('위치 스트림 에러: $error');
          if (_positionStreamSubscription != null) {
            _positionStreamSubscription!.cancel();
            _positionStreamSubscription = null;
          }
        },
      );
    } catch (e) {
      print('위치 업데이트 시작 오류: $e');
      rethrow;
    }
  }

// 위치 업데이트 중지
  void stopLocationUpdates() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

// Provider dispose 시 정리
  @override
  void dispose() {
    stopLocationUpdates();
    _locationStreamController.close();
    super.dispose();
  }
}
