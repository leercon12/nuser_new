import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/model/multi_cargo_add_model.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/futurue_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/bottom.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/state_widget/state.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/top/top_main.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/firebase/remoteconfig.dart';
import 'package:flutter_mixcall_normaluser_new/service/map_service.dart';
import 'package:flutter_mixcall_normaluser_new/service/weather.dart';
import 'package:flutter_mixcall_normaluser_new/setting/fcm_set.dart';
import 'package:flutter_mixcall_normaluser_new/setting/loading_page.dart';
import 'package:flutter_mixcall_normaluser_new/setting/permisson/per_state.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/bottomSheet.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainMapPage extends StatelessWidget {
  final String version;
  const MainMapPage({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    final maprovider = Provider.of<MapProvider>(context);
    String isSpec =
        Platform.isAndroid ? maprovider.normalAnd : maprovider.normalIos;
    print('@@@@@@@');
    print(version);
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            // 전체 화면을 차지하도록
            child: NaverMapPage(),
          ),
          const Positioned(top: 0, child: TopMainWidget()),
          const Positioned(bottom: 0, child: BottomMainPage()),
          if (maprovider.normalStop == true)
            const Positioned.fill(child: StopDialog()),
          if ((version != 'null') &&
              isSpec != version &&
              maprovider.isUpdateDown == false)
            const Positioned.fill(child: upDateDialog()),
          if (maprovider.isLoading == true) const LoadingPage()
        ],
      ),
    );
  }
}

class NaverMapPage extends StatefulWidget {
  const NaverMapPage({super.key});

  @override
  State<NaverMapPage> createState() => _NaverMapPageState();
}

class _NaverMapPageState extends State<NaverMapPage>
    with WidgetsBindingObserver {
  NaverMapController? _controller;
  final Completer<NaverMapController> mapControllerCompleter = Completer();

  @override
  void initState() {
    super.initState();
    print('InitState started');
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    _checkPermissionAndInit();
    dataProvider.userProvider();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('PostFrameCallback started');
      startTracking(context);
      _fcmTokenSet();
    });
  }

  Key _mapKey = UniqueKey();
  DateTime? _lastBackgroundTime;
  bool _needMapReinit = false;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    print('앱 생명주기 상태 변경: $state');
    if (state == AppLifecycleState.paused) {
      // 앱이 백그라운드로 갈 때 컨트롤러 정리
    }
    // inactive 상태에 들어갈 때 시간 기록
    if (state == AppLifecycleState.inactive) {
      _lastBackgroundTime = DateTime.now();
      print('앱이 inactive 상태로 전환됨: $_lastBackgroundTime');
    }
    // 앱이 다시 활성화될 때
    else if (state == AppLifecycleState.resumed) {
      print('앱이 resumed 상태로 복귀됨');
      print(mapProvider.controller);
      /*   setState(() {
        _mapKey = UniqueKey(); // 새 키 생성
      }); */

      try {
        // 컨트롤러 메서드 호출이 가능한지 테스트
        mapProvider.controller!.getCameraPosition().then((position) {
          print('맵 컨트롤러 동작 중: $position');
        }).catchError((error) {
          print('맵 컨트롤러 오류: $error - 컨트롤러 재초기화 필요');
        });
      } catch (e) {
        print('맵 컨트롤러 접근 오류: $e');
      }
      // inactive 상태에서 바로 resumed로 돌아온 경우도 처리
      if (_lastBackgroundTime != null) {
        final inactiveDuration =
            DateTime.now().difference(_lastBackgroundTime!);
        print('inactive 체류 시간: ${inactiveDuration.inMilliseconds}ms');

        // 지도 컨트롤러 재초기화
        if (mapProvider.controller != null) {
          // 지도 상태 저장
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future _fcmTokenSet() async {
    print('@#@#');
    final tokenManager = FCMTokenManager();

    // 앱 시작할 때마다 토큰 초기화 및 서버 업데이트
    await tokenManager.initializeAndUpdateToken();

    // 토큰 갱신 리스너 설정
    tokenManager.setupTokenRefreshListener();
  }

  Map<String, dynamic>? _previousCargo;
  bool? _perLocation = null;
  bool? _perCamera = null;
  bool? _perNotification = null;
  // 권한 체크 및 초기화 함수
  Future<void> _checkPermissionAndInit() async {
    Map<String, bool> permissions = await checkAllPermissions();

    setState(() {
      _perLocation = permissions['location'] ?? false;
      // 필요하다면 다른 권한 상태도 저장
      _perCamera = permissions['camera'] ?? false;
      _perNotification = permissions['notification'] ?? false;
    });

    print('권한 상태: $permissions');
    print('카메라 권힌 : $_perCamera');

    if (permissions['location'] == true) {
      startTracking(context);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dataProvider = Provider.of<DataProvider>(context);

    if (dataProvider.currentCargo != _previousCargo) {
      if (dataProvider.currentCargo != null) {
        _updateRouteOverlay(dataProvider);
      } else {
        // currentCargo가 null일 경우 오버레이 제거
        // final mapProvider = Provider.of<MapProvider>(context, listen: false);
        _controller?.clearOverlays();
      }
      _previousCargo = dataProvider.currentCargo;
    }
  }

  DateTime? _lastPressedAt;
  bool _isTraffic = false;
  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);

    //  final hashProvider = Provider.of<HashProvider>(context);
    print('sdfsdf');

    return WillPopScope(
      onWillPop: () async {
        if (_lastPressedAt == null ||
            DateTime.now().difference(_lastPressedAt!) > Duration(seconds: 2)) {
          // 2초 이내에 다시 누르지 않았을 경우
          _lastPressedAt = DateTime.now();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: dialogColor,
              content: Text('뒤로가기 버튼을 한번 더 누르시면 종료됩니다.'),
              duration: Duration(seconds: 2),
            ),
          );
          return false; // 앱 종료 방지
        }
        return true; // 앱 종료 허용
      },
      child: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: StatefulBuilder(builder: (context, setState) {
              return NaverMap(
                key: _mapKey,
                
                options: NaverMapViewOptions(
                  indoorEnable: true,
                  pickTolerance: 0,
                  locationButtonEnable: false,
                  consumeSymbolTapEvents: false,
                  rotationGesturesFriction: 3,
                  indoorFocusRadius: 0,
                  zoomGesturesFriction: 5,
                  minZoom: 6,
                  mapType: NMapType.navi,
                  locale: Locale('ko'),
                  nightModeEnable: true,
                  buildingHeight: 0,
                ),
                
                onMapReady: (controller) async {
                  _controller = controller;

                  // mapProvider.setController(_controller);

                  if (!mapControllerCompleter.isCompleted) {
                    mapControllerCompleter.complete(_controller);
                  }

                  if (_controller != null) {
                    context.read<MapProvider>().setController(_controller);
                  }

                  if (_controller == null || mapProvider.controller == null) {
                    print('지도 멈춤!!!!');
                  }

                  _controller!.getLocationOverlay();
                  _controller!
                      .setLocationTrackingMode(NLocationTrackingMode.noFollow);

                  Future.delayed(const Duration(milliseconds: 700), () {
                    dataProvider.initStreams();
                    // totalCargoList가 null이 아니고 비어있지 않은지 확실히 체크
                    if (dataProvider.totalCargoList != null &&
                        dataProvider.totalCargoList.isNotEmpty) {
                      dataProvider
                          .setCurrentCargo(dataProvider.totalCargoList.first);
                      // dataProvider.CrogoPxProvider(context);

                      _updateRouteOverlay(dataProvider);
                      setState(() {
                        _previousCargo = dataProvider.currentCargo;
                      });
                    } else {
                      print('No cargo data available');
                      // 필요한 경우 여기에 빈 데이터 처리 로직 추가
                    }
                  });

                  Future.delayed(const Duration(seconds: 1), () {
                    if (mapProvider.currentLivePosition != null) {
                      updateCameraCenter(
                          _controller,
                          NLatLng(mapProvider.currentLivePosition!.latitude,
                              mapProvider.currentLivePosition!.longitude));
                    }

                    if (dataProvider.currentCargo != null &&
                        dataProvider.currentCargo!.isNotEmpty) {
                      _updateRouteOverlay(dataProvider);
                    }
                  });
                },
                onCameraIdle: () async {},
                onCameraChange:
                    (NCameraUpdateReason reason, bool animated) async {
                  _handleCameraChange(reason, animated);
                  //
                },
                onMapTapped: (point, latLng) async {
                  _handleMapTapped(point, latLng);
                  //updateWeather();

                  //clearCachedData();
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _handleCameraChange(NCameraUpdateReason reason, bool animated) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    if (dataProvider.isUp) {
      // setState 없이 직접 Provider 상태 변경
      dataProvider.isUpState(false);
    }
  }

  void _handleMapTapped(NPoint point, NLatLng latLng) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    if (dataProvider.isUp) {
      dataProvider.isUpState(false);
    }
  }

  void _noPerBottomSheet(MapProvider mapProvider) {
    final dw = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return BottomSheetWidget(
              contents: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                const Icon(Icons.info, size: 70, color: kRedColor),
                const SizedBox(height: 32),
                const KTextWidget(
                    text: '위치권한설정이 필요합니다.',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                const KTextWidget(
                    text: '혼적콜을 이용하기 위해서는 위치정보가 필요합니다.',
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey),
                const KTextWidget(
                    text: '혼적콜은 사용자 위치정보를 저장하지 않습니다.',
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await openAppSettings();

                    if (!mounted) return;

                    await Future.delayed(const Duration(milliseconds: 500));
                    mapProvider.isLoadingState(true);
                    Navigator.pop(context);

                    try {
                      bool hasAnyLocationPermission =
                          await _checkAllLocationPermissions();
                      print('위치 권한 있음: $hasAnyLocationPermission');

                      if (hasAnyLocationPermission) {
                        setState(() {
                          _perLocation = true;
                        });

                        startTracking(context);

                        if (_controller != null) {
                          await _controller!.setLocationTrackingMode(
                              NLocationTrackingMode.noFollow);
                          await _controller!.getLocationOverlay();

                          await Future.delayed(const Duration(seconds: 2));

                          if (mapProvider.currentLivePosition != null) {
                            updateCameraCenter(
                                _controller,
                                NLatLng(
                                    mapProvider.currentLivePosition!.latitude,
                                    mapProvider
                                        .currentLivePosition!.longitude));
                          }
                        }
                      }
                    } catch (e) {
                      print('설정 후 처리 중 에러: $e');
                    } finally {
                      mapProvider.isLoadingState(false);
                    }
                  },
                  child: Container(
                    height: 52,
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    width: dw,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: noState),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.settings, color: Colors.grey, size: 16),
                        SizedBox(width: 10),
                        KTextWidget(
                            text: '위치 권한 설정하기',
                            size: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: UnderLineWidget(
                            text: '위치정보없이 혼적콜 이용', color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ));
        });
      },
    );
  }

  Future<bool> _checkAllLocationPermissions() async {
    // 모든 위치 관련 권한 체크
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationAlways,
      Permission.locationWhenInUse,
    ].request();

    print('위치 권한 상태들:');
    statuses.forEach((permission, status) {
      print('$permission: $status');
    });

    // 하나라도 granted 상태인 경우 true 반환
    return statuses.values.any((status) => status.isGranted);
  }

  Future<void> _updateRouteOverlay(DataProvider dataProvider) async {
    print('Starting route overlay update');
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    final hashProvider = Provider.of<HashProvider>(context, listen: false);

    try {
      final coords = await hashProvider
          .fastDecryptPath(dataProvider.currentCargo!['allRoute']);

      _controller!.clearOverlays();

      _controller!.addOverlay(NPathOverlay(
        id: 'route',
        coords: coords,
        color: Colors.cyanAccent,
        width: 5, // 선 굵기 추가
        outlineColor: kGreenFontColor.withOpacity(0.3),
        // patternImage: NOverlayImage.fromAssetImage('asset/img/pattern_arrow.png'),
        patternInterval: 80,
      ));

      if (dataProvider.currentCargo!['aloneType'] == '다구간') {
        // List<CargoPoint> points = dataProvider.getCurrentCargoPoints();

        await addMarkersToMapMulti2(dataProvider, _controller!, context);
      } else if (dataProvider.currentCargo!['aloneType'] == '왕복') {
        await addMarkersToMapMulti3(dataProvider, _controller!, context);
      } else {
        final up = hashProvider
            .decLatLng(dataProvider.currentCargo!['upLocation']['geopoint']);
        final down = hashProvider
            .decLatLng(dataProvider.currentCargo!['downLocation']['geopoint']);

        await addMarkersToMapUpDown(
            controller: _controller!, context: context, up: up, down: down);
      }

      print('Overlay added successfully');
    } catch (e) {
      print('Error updating route overlay: $e');
      print('Error stack trace: ${StackTrace.current}');
    }
  }
}
