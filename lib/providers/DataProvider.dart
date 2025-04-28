import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/model/multi_cargo_add_model.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';

class DataProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  String? _loginType;
  String? get loginType => _loginType;

  void loginTypeState(String? value) {
    _loginType = value;
    notifyListeners();
  }

  int? _selNum;
  int? get selNum => _selNum;

  void selNumState(int? value) {
    _selNum = value;
    notifyListeners();
  }

  String? _driverUid;
  String? get driverUid => _driverUid;

  String? _driverNetworkPhoto;
  String? get driverNetworkPhoto => _driverNetworkPhoto;

  NLatLng? _driverLocation;
  NLatLng? get driverLocation => _driverLocation;

  void driverLocations(String? uid, String? networkImgUrl, NLatLng? location,
      DateTime? lastReqDate, context) {
    _driverUid = uid;
    _driverLocation = location;
    _driverNetworkPhoto = networkImgUrl;
    //driverLocationMarker(context, lastReqDate);
    notifyListeners();
  }

  bool? _driverLocationUp = false;
  bool? get driverLocationUp => _driverLocationUp;

  void driverLocatonsUpState(bool value) {
    _driverLocationUp = value;
    notifyListeners();
  }

  DateTime? _lastReqDate;
  bool _isMarkerVisible = false;

  /*  // 초기 마커 설정과 타이머 시작
  Future<void> driverLocationMarker(
      BuildContext context, DateTime? lastReqDate) async {
    _lastReqDate = lastReqDate;
    await updateMarker(context);
    startMarkerUpdateTimer(context);
  }

  Future<void> updateMarker(BuildContext context) async {
    if (_lastReqDate == null) return;

    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    // 시간 차이 계산
    final difference = DateTime.now().difference(_lastReqDate!);
    String timeAgo = difference.inMinutes < 60
        ? '${difference.inMinutes}분 전'
        : '${difference.inHours}시간 전';

    // 마커 아이콘 생성
    NOverlayImage markerIcon = await NOverlayImage.fromWidget(
      context: context,
      widget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 2,
                )
              ],
            ),
            child: ClipOval(
              child: _driverNetworkPhoto != null
                  ? Image.network(
                      _driverNetworkPhoto!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  spreadRadius: 1,
                )
              ],
            ),
            child: Text(
              timeAgo,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
      size: const Size(80, 90),
    );

    try {
      try {
        // 기존 마커 삭제 시도
        await mapProvider.controller?.deleteOverlay(
            NOverlayInfo(type: NOverlayType.marker, id: 'marker_driver'));
      } catch (e) {
        // 마커가 없는 경우의 에러는 무시
        print('기존 마커 없음');
      }

      // 삭제/생성 간 짧은 딜레이
      await Future.delayed(const Duration(milliseconds: 100));

      if (_driverLocation != null) {
        // 새 마커 생성
        final marker = NMarker(
          id: 'marker_driver',
          position: NLatLng(
            _driverLocation!.latitude,
            _driverLocation!.longitude,
          ),
        )..setIcon(markerIcon);

        // 마커 클릭 리스너 설정
        marker.setOnTapListener((NMarker marker) {
          driverLocatonsUpState(true);
        });

        // 마커 추가
        await mapProvider.controller!.addOverlay(marker);
      }
    } catch (e) {
      print('마커 업데이트 실패: $e');
    }
  }
 */
  // 타이머 설정

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void isLoadingState(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _isUp = false;
  bool get isUp => _isUp;

  void isUpState(bool value) {
    _isUp = value;
    notifyListeners();
  }

  // 단일 사용자 데이터를 저장할 변수
  UserData? _userData;
  UserData? get userData => _userData;

  // 개별 필드에 대한 getter
  String get email => _userData?.email ?? '';
  String get name => _userData?.name ?? '';
  String get phone => _userData?.phone ?? '';
  List get company => _userData?.company ?? [];
  String get comName => _userData?.comName ?? '';
  Timestamp? get joinDate => _userData?.joinDate;
  List get likeDriver => _userData?.likeDriver ?? [];
  String get uid => _userData?.uid ?? '';
  String get wait => _userData?.wait ?? '';
  String get waitName => _userData?.waitName ?? '';
  List get masterCompany => _userData?.masterCompany ?? [];
  void userProvider() async {
    User? user = FirebaseAuth.instance.currentUser; // 현재 사용자 즉시 확인
    if (user != null) {
      await _fetchUserDriverData(user.uid); // 데이터 fetch 완료 대기
    }
    notifyListeners();
  }

  Future<void> _fetchUserDriverData(
    String userId,
  ) async {
    try {
      //final collection = loginType == '일반' ? 'user_normal' : 'user_normalCom';

      final snapshot = await FirebaseFirestore.instance
          .collection('user_normal')
          .doc(userId) // 특정 사용자의 문서
          .get();

      if (snapshot.exists) {
        _userData = UserData.fromMap(snapshot.data()!);
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void disposeUserData() {
    _userData = null;
    _user = null; // FirebaseAuth user도 null로
    notifyListeners();
  }
  ///////////
  ///
  ///   downDoneTime 해당 문서중에downDoneTime == null 인문서의
  ///  현제 진행중인 운송 건 가져오기
  ///

  // 화물 리스트 관련 변수
  List<Map<String, dynamic>> _cargoList = [];
  List<Map<String, dynamic>> _companyCargoList = [];
  List<Map<String, dynamic>> _totalCargoList = [];
  Map<String, dynamic>? _currentCargo;

  // 스트림 구독
  StreamSubscription? _personalStream;
  StreamSubscription? _companyStream;
  StreamSubscription? _currentCargoStream;

  // 타이머 관리
  final Map<String, Timer> _cargoTimers = {};
  final Map<String, bool> _processedCargos = {};
  Timer? _currentCargoTimer;
  int _remainingSeconds = 180;
  Timestamp? _targetTimestamp;

  // Getters
  List<Map<String, dynamic>> get cargoList => _cargoList;
  List<Map<String, dynamic>> get companyCargoList => _companyCargoList;
  List<Map<String, dynamic>> get totalCargoList => _totalCargoList;
  Map<String, dynamic>? get currentCargo => _currentCargo;

  int get remainingSeconds => _remainingSeconds;
  bool get isActive => _remainingSeconds > 0;
  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // Current Cargo 관련 메서드
  void setCurrentCargo(Map<String, dynamic>? cargo) {
    _currentCargo = cargo;
    notifyListeners();
  }

  // 타이머 관련 메서드
  void setTargetTime(Timestamp timestamp) {
    _targetTimestamp = timestamp;
    _startBiddingTimer();
  }

  void _startBiddingTimer() {
    _currentCargoTimer?.cancel();

    if (_targetTimestamp == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final targetMs = _targetTimestamp!.toDate().millisecondsSinceEpoch;
    final elapsedSeconds = (now - targetMs) ~/ 1000;

    if (elapsedSeconds >= 180) {
      _remainingSeconds = 0;
      notifyListeners();
      return;
    }

    _remainingSeconds = 180 - elapsedSeconds;
    _remainingSeconds = _remainingSeconds.clamp(0, 180);
    notifyListeners();

    _currentCargoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _remainingSeconds = 0;
        notifyListeners();
        return;
      }

      _remainingSeconds--;
      notifyListeners();
    });
  }

  // 초기화 메서드
  void initStreams() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _clearAll();
    _initPersonalStream(user.uid);

    // 회사 정보가 없을 경우 먼저 로드하고 스트림 초기화
    if (_userData == null || _userData!.company.isEmpty) {
      _fetchUserDriverData(user.uid).then((_) {
        if (_userData != null && _userData!.company.isNotEmpty) {
          print('회사 정보 로드 완료 후 스트림 초기화: ${_userData!.company}');
          _initCompanyStream(_userData!.company[0].toString());
        }
      });
    } else {
      print('기존 회사 정보로 스트림 초기화: ${_userData!.company}');
      _initCompanyStream(_userData!.company[0].toString());
    }
  }

  void _initPersonalStream(String userId) {
    // 오늘 자정 기준 시간 계산
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayTimestamp = Timestamp.fromDate(today);

    _personalStream = FirebaseFirestore.instance
        .collection('cargoInfo')
        .doc(userId)
        .collection(DateTime.now().year.toString())
        .where('cargoStat', whereNotIn: ['운송완료', '하차완료', '취소']) // 상태 필터링 유지
        .where('downTime',
            isGreaterThanOrEqualTo: todayTimestamp) // 오늘 이후 데이터만 가져오기
        .orderBy('downTime') // downTime으로 정렬 추가 (where 조건과 같은 필드로 정렬해야 함)
        .orderBy('createdDate', descending: true)
        .snapshots()
        .listen(
          (snapshot) => _handleSnapshot(snapshot, true),
          onError: (error) => print('Personal stream error: $error'),
        );
  }

  void _initCompanyStream(String companyId) {
    print(companyId);

    // 오늘 자정 기준 시간 계산
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayTimestamp = Timestamp.fromDate(today);

    _companyStream = FirebaseFirestore.instance
        .collection('cargoInfo')
        .doc(companyId)
        .collection(DateTime.now().year.toString())
        .where('cargoStat', whereNotIn: ['운송완료', '하차완료', '취소']) // 상태 필터링은 유지
        .where('downTime',
            isGreaterThanOrEqualTo: todayTimestamp) // 오늘 이후 데이터만 가져오기
        .orderBy('downTime') // downTime으로 정렬 추가 (where 조건과 같은 필드로 정렬해야 함)
        .orderBy('createdDate', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            print('회사 스냅샷 수신: 문서 ${snapshot.docs.length}개');
            print('변경 사항: ${snapshot.docChanges.length}개');
            for (var change in snapshot.docChanges) {
              print('  변경 유형: ${change.type}, 문서 ID: ${change.doc.id}');
            }
            _handleSnapshot(snapshot, false);
          },
          onError: (error) => print('회사 스트림 에러: $error'),
        );
  }

// 2. 데이터 처리 및 UI 업데이트 개선
  void _handleSnapshot(QuerySnapshot snapshot, bool isPersonal) {
    print(
        '스냅샷 이벤트 발생: ${isPersonal ? "개인" : "회사"} 데이터, 문서 수: ${snapshot.docs.length}');

    final newList = snapshot.docs.map((doc) {
      return {
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
        'type': isPersonal ? '일반' : '기업',
      };
    }).toList();

    // 데이터 변경 감지 로그 추가
    if (isPersonal) {
      bool hasChanges = _cargoList.length != newList.length;
      _cargoList = newList;
      print('개인 데이터 ${hasChanges ? "변경됨" : "변경 없음"}: ${_cargoList.length}개');
    } else {
      bool hasChanges = _companyCargoList.length != newList.length;
      _companyCargoList = newList;
      print(
          '회사 데이터 ${hasChanges ? "변경됨" : "변경 없음"}: ${_companyCargoList.length}개');
    }

    // UI 업데이트 강제 수행
    _updateTotalList();

    // 상태 변경 알림을 메인 스레드에서 실행
    Future.microtask(() {
      notifyListeners();
      print('UI 업데이트 요청 완료');
    });
  }

  // 동일한 날짜인지 확인하는 헬퍼 함수
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /*  void _updateTotalList() {
    _totalCargoList = [..._cargoList, ..._companyCargoList];

    if (_totalCargoList.isNotEmpty) {
      _totalCargoList.sort((a, b) => (b['createdDate'] as Timestamp)
          .compareTo(a['createdDate'] as Timestamp));
    }

    // 현재 화물 업데이트 로직
    if (_totalCargoList.isEmpty) {
      setCurrentCargo(null);
    }
    /* else if (_currentCargo != null) {
      final updatedCargo = _totalCargoList.firstWhere(
          (cargo) => cargo['id'] == _currentCargo!['id'],
          orElse: () => _totalCargoList[0]);
      setCurrentCargo(updatedCargo);
    } else */
    {
      setCurrentCargo(_totalCargoList[0]);
    }

    print('Total cargo list updated: ${_totalCargoList.length} items');
    notifyListeners();
  }
 */

  void _updateTotalList() {
    _totalCargoList = [..._cargoList, ..._companyCargoList];

    print('전체 화물 리스트 업데이트: ${_totalCargoList.length}개');
    print(' - 개인: ${_cargoList.length}개');
    print(' - 회사: ${_companyCargoList.length}개');

    if (_totalCargoList.isEmpty) {
      _currentCargo = null;
    } else {
      // 정렬 전 데이터 확인
      print(
          '정렬 전 첫 번째 화물 ID: ${_totalCargoList.isNotEmpty ? _totalCargoList[0]['id'] : "없음"}');

      // 날짜 기준 정렬
      _totalCargoList.sort((a, b) => (b['createdDate'] as Timestamp)
          .compareTo(a['createdDate'] as Timestamp));

      // 정렬 후 데이터 확인
      print(
          '정렬 후 첫 번째 화물 ID: ${_totalCargoList.isNotEmpty ? _totalCargoList[0]['id'] : "없음"}');

      // 현재 선택된 화물 설정
      _currentCargo = _totalCargoList[0];
      print('현재 화물 설정: ${_currentCargo?['id']}');
    }
  }

  // 3분 타이머 관련 메서드
/*   void _processTimers(List<Map<String, dynamic>> cargoList, bool isPersonal) {
    for (var cargo in cargoList) {
      if (_shouldProcessTimer(cargo)) {
        _setupCargoTimer(cargo, isPersonal);
      }
    }
  } */

  bool _shouldProcessTimer(Map<String, dynamic> cargo) {
    return cargo['confirmUser'] != null &&
        cargo['conDate'] != null &&
        !_processedCargos.containsKey(cargo['id']);
  }

  void _setupCargoTimer(Map<String, dynamic> cargo, bool isPersonal) {
    final conDate = cargo['conDate'] as Timestamp;
    final now = DateTime.now().millisecondsSinceEpoch;
    final conDateMs = conDate.toDate().millisecondsSinceEpoch;
    final timeDiff = now - conDateMs;

    if (timeDiff >= 180000) {
      _resetCargoConfirmation(cargo, isPersonal);
      _processedCargos[cargo['id']] = true;
    } else {
      final remainingMs = 180000 - timeDiff;
      _cargoTimers[cargo['id']]?.cancel();
      _cargoTimers[cargo['id']] =
          Timer(Duration(milliseconds: remainingMs), () {
        _resetCargoConfirmation(cargo, isPersonal);
        _cargoTimers.remove(cargo['id']);
        _processedCargos[cargo['id']] = true;
      });
    }
  }

  Future<void> _resetCargoConfirmation(
      Map<String, dynamic> cargo, bool isPersonal) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final updates = {
        'confirmUser': null,
        'conDate': null,
        'conMoney': null,
        'conComUid': null,
      };

      // CargoLive 업데이트
      final liveRef =
          FirebaseFirestore.instance.collection('cargoLive').doc(cargo['id']);
      batch.update(liveRef, updates);

      // CargoInfo 업데이트
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final infoRef = FirebaseFirestore.instance
            .collection('cargoInfo')
            .doc(isPersonal ? userId : cargo['uid'])
            .collection(DateTime.now().year.toString())
            .doc(cargo['id']);
        batch.update(infoRef, updates);
      }

      await batch.commit();
      await _updateBidingStatus(cargo);
    } catch (e) {
      print('Error resetting cargo confirmation: $e');
    }
  }

  Future<void> _updateBidingStatus(Map<String, dynamic> cargo) async {
    try {
      if (cargo['conComUid'] == null) {
        await FirebaseFirestore.instance
            .collection('user_driver')
            .doc(cargo['confirmUser'])
            .collection('biding')
            .doc(cargo['id'])
            .update({
          'choiceTime': null,
          'isChoice': false,
        });
      } else {
        await FirebaseFirestore.instanceFor(
                app: FirebaseFirestore.instance.app,
                databaseId: 'mixcallcompany')
            .collection(cargo['comUid'])
            .doc('biding')
            .collection(_getCargoIdPrefix(cargo['cargoId']))
            .doc(cargo['cargoId'])
            .update({
          'choiceTime': null,
          'isChoice': false,
        });
      }
    } catch (e) {
      print('Error updating biding status: $e');
    }
  }

  void _clearAll() {
    _personalStream?.cancel();
    _companyStream?.cancel();
    _currentCargoStream?.cancel();
    _currentCargoTimer?.cancel();
    _cargoTimers.forEach((_, timer) => timer.cancel());
    _cargoTimers.clear();
    _processedCargos.clear();
    _cargoList = [];
    _companyCargoList = [];
    _totalCargoList = [];
    _currentCargo = null;
    _remainingSeconds = 180;
    _targetTimestamp = null;
    notifyListeners();
  }

  String _getCargoIdPrefix(String cargoId) {
    return cargoId.length >= 4 ? cargoId.substring(0, 4) : cargoId;
  }

  void setUpState(bool value) {
    _isUp = value;
    notifyListeners();
  }

  // 특정 문서 스트림을 위한 변수 추가
  Map<String, dynamic>? _selectedCargo;
  StreamSubscription? _selectedCargoStream;

  // 특정 문서의 getter
  Map<String, dynamic>? get selectedCargo => _selectedCargo;

  // 특정 문서 스트림 초기화
  void initStream(String normalUid, String id) {
    // 기존 스트림이 있다면 취소
    _selectedCargoStream?.cancel();

    _selectedCargoStream = FirebaseFirestore.instance
        .collection('cargoInfo')
        .doc(normalUid)
        .collection(DateTime.now().year.toString())
        .doc(id)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _selectedCargo = {
          ...snapshot.data() as Map<String, dynamic>,
          'id': snapshot.id
        };
        notifyListeners();
      }
    });
  }

  ////////////////
  ///
  ///
  ///

  ///////////
  ///
  ///
  ///  포인트
  ///

  num? _pxNum = 0;
  num? get pxNum => _pxNum;

  void pxNumState(num value) {
    _pxNum = value;
    notifyListeners();
  }

  late Stream<DocumentSnapshot> _crogoPxStream;
  StreamSubscription? _subscription; // StreamSubscription 추가

  CrogoPxProvider(BuildContext context) {
    final hashProvider = Provider.of<HashProvider>(context, listen: false);
    User? user = FirebaseAuth.instance.currentUser;

    _crogoPxStream = FirebaseFirestore.instance
        .collection('cargo_px')
        .doc('user_driver')
        .collection(user!.uid.toString())
        .doc('main_px')
        .snapshots();

    // StreamSubscription을 변수에 저장
    _subscription = _crogoPxStream.listen((snapshot) async {
      if (snapshot.exists) {
        String pxData = snapshot['px'] ?? '0';
        num? _cp = extractAndParseNumber(hashProvider.decryptData(pxData));
        pxNumState(_cp as num);
        print(_cp);
        notifyListeners();
      }
    });
  }

  /// 멀티 지도 표시를 위한 상태
  ///

  List<CargoPoint> getCurrentCargoPoints(context) {
    final hashProvider = Provider.of<HashProvider>(context, listen: false);
    List<CargoPoint> detailedCoords = [];
    int order = 0;

    // currentCargo가 Map이므로 locations 배열에 접근
    List<dynamic> locations = _currentCargo!['locations'];

    for (var cargo in locations) {
      // cargo도 Map 형태일 것이므로 키로 접근
      if (cargo['location'] != null) {
        detailedCoords.add(
          CargoPoint(
            coordinate: hashProvider.decLatLng(cargo['location']),
            type: cargo['type'].toString(),
            order: order++,
            address: cargo['address1'].toString(),
            upNum: cargo['upCargos']?.length ?? 0,
            downNum: cargo['downCargos']?.length ?? 0,
          ),
        );
      }
    }

    return detailedCoords;
  }

  //// 보톰 라지 박스 사이즈 빌더
  ///
  double useStateWidth = 0;

  void updateWidth(double width) {
    useStateWidth = width;
    notifyListeners();
  }

  //// 검색창 개인 회사 /
  ///

  bool? _isCompany = false;
  bool? get isCompany => _isCompany;

  void isCompanyState(bool? value) {
    _isCompany = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _clearAll();
    _subscription?.cancel(); // 스트림 구독 취소
    _isMarkerVisible = false;
    _processedCargos.clear();
    _selectedCargoStream?.cancel();
    _selectedCargo = null;
    super.dispose();
  }
}

class UserData {
  // 필요한 필드들 정의
  final String email;
  final Timestamp joinDate;
  final String name;
  final String phone;
  final List company;
  final String comName;
  final List likeDriver;
  final String uid;
  final String preOrderId;
  final String preBank;
  final String preAcNum;
  final String preOnewr;
  final int prePrice;
  final String preDday;
  final String wait;
  final String waitName;
  final List masterCompany;

  // ... 기타 필드들

  UserData({
    required this.email,
    required this.joinDate,
    required this.name,
    required this.phone,
    required this.company,
    required this.comName,
    required this.likeDriver,
    required this.uid,
    required this.preAcNum,
    required this.preBank,
    required this.preDday,
    required this.preOnewr,
    required this.preOrderId,
    required this.prePrice,
    required this.wait,
    required this.waitName,
    required this.masterCompany,
    // ... 기타 필드들
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
        email: map['email'] ?? '',
        joinDate: map['joinDate'] ?? '',
        name: map['name'] ?? '',
        phone: map['phone'] ?? '',
        company: map['company'] ?? [],
        comName: map['comName'] ?? '',
        likeDriver: map['likeDriver'] ?? [],
        uid: map['uid'] ?? '',
        preAcNum: map['preAcNum'] ?? '',
        preBank: map['preBank'] ?? '',
        preDday: map['preDday'] ?? '',
        preOnewr: map['preOnewr'] ?? '',
        preOrderId: map['preOrderId'] ?? '',
        prePrice: map['prePrice'] ?? 0,
        wait: map['wait'] ?? '',
        waitName: map['waitName'] ?? '',
        masterCompany: map['masterCompany'] ?? []);
  }
}

num? extractAndParseNumber(String input) {
  RegExp regExp = RegExp(r'(\d+\.?\d*)');
  Match? match = regExp.firstMatch(input);

  if (match != null) {
    String numericString = match.group(0)!;
    num? parsedNumber = num.tryParse(numericString);

    // Check if parsedNumber is not null and round to the nearest integer
    if (parsedNumber != null) {
      return parsedNumber
          .round(); // Use .floor() for rounding down or .ceil() for rounding up
    }
  }

  return null;
}
