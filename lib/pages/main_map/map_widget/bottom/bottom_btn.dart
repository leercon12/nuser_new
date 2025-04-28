import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/bottom_history/bottom_driver_info.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/inuse_list/inuse_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/futurue_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/bottom.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/future_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/bottomSheet.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BottomBtnState extends StatefulWidget {
  final double dw;
  final Map<String, dynamic> cargo;
  final String callType;

  const BottomBtnState(
      {super.key,
      required this.dw,
      required this.callType,
      required this.cargo});

  @override
  State<BottomBtnState> createState() => _BottomBtnStateState();
}

class _BottomBtnStateState extends State<BottomBtnState> {
  StreamSubscription? _driverSubscription;
  Timer? _timeUpdateTimer;
  DateTime? _lastReqDate;
  String? _currentPhotoUrl;
  NLatLng? _currentLocation;
  List<Map<String, dynamic>> allDrivers = [];
  List<String>? carInfoParts;
  NMarker? currentMarker;

  @override
  void initState() {
    super.initState();
    _initializeDriverStream();
    _startTimeUpdateTimer();
  }

  void _startTimeUpdateTimer() {
    _timeUpdateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_lastReqDate != null &&
          _currentPhotoUrl != null &&
          _currentLocation != null &&
          mounted) {
        setState(() {
          // setState 추가
          print('1분이 지나 마커 시간을 업데이트합니다.');
          updateMarker(
              context, _currentPhotoUrl!, _lastReqDate!, _currentLocation!);
        });
      }
    });
  }

  @override
  void dispose() {
    _driverSubscription?.cancel();
    _timeUpdateTimer?.cancel();
    super.dispose();
  }

  void _initializeDriverStream() {
    if (widget.cargo['pickUserUid'] != null &&
        widget.cargo['cargoStat'] != '하차완료' &&
        widget.cargo['cargoStat'] != '운송완료') {
      if (widget.cargo['aloneType'] == '다구간') {
        if (!isPassedDate(widget.cargo['locations'][0]['date'].toDate()) &&
            !isPassedDate(widget.cargo['locations'].last['date'].toDate())) {
          _startListeningToDriver();
        }
      } else if (widget.cargo['aloneType'] == '왕복') {
        if (!isPassedDate(widget.cargo['locations'][0]['date'].toDate()) &&
            !isPassedDate(widget.cargo['locations'][2]['date'].toDate())) {
          _startListeningToDriver();
        }
      } else {
        if (!isPassedDate(widget.cargo['upTime'].toDate()) &&
            !isPassedDate(widget.cargo['downTime'].toDate())) {
          _startListeningToDriver();
        }
      }
    }
  }

  NLatLng? decryptedLocation;
  void _startListeningToDriver() {
    final hashProvider = Provider.of<HashProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    bool isNotificationShown = false;

    _driverSubscription?.cancel();

    _driverSubscription = FirebaseFirestore.instance
        .collection('user_driver')
        .doc(widget.cargo['pickUserUid'])
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        print('Driver data received: ${data.toString()}');

        if (data['lastReqDate'] != null &&
            isWithinFiveMinutes(data['lastReqDate'].toDate()) &&
            data['isFind'] == false) {
          final driverPosition =
              data['driverPosition'] as Map<String, dynamic>?;
          if (driverPosition != null && driverPosition['geopoint'] != null) {
            try {
              decryptedLocation =
                  hashProvider.decLatLng(driverPosition['geopoint'].toString());
              print('Decrypted location: $decryptedLocation');

              _lastReqDate = data['lastReqDate'].toDate();
              _currentPhotoUrl = widget.cargo['comUid'] == null
                  ? data['userProfileIMG']
                  : widget.cargo['comPhotoUrl'];
              _currentLocation = decryptedLocation;

              await _locationsHistory();
              await updateMarker(
                  context, _currentPhotoUrl!, _lastReqDate!, _currentLocation!);
            } catch (e) {
              print('위치 복호화 또는 마커 업데이트 실패: $e');
            }
          } else {
            print('드라이버 위치 정보가 없습니다');
          }
        } else {
          if (data['isFind'] == false) {
            await _handleDriverNotFound(isNotificationShown);
            isNotificationShown = true;
          }
        }
      }
    });
  }

  Future<void> _handleDriverNotFound(bool isNotificationShown) async {
    try {
      await FirebaseFirestore.instance
          .collection('user_driver')
          .doc(widget.cargo['pickUserUid'])
          .update({'isFind': true});

      if (!isNotificationShown) {
        await Future.delayed(const Duration(seconds: 5));
        if (!mounted) return;

        final doc = await FirebaseFirestore.instance
            .collection('user_driver')
            .doc(widget.cargo['pickUserUid'])
            .get();

        if (doc.exists && doc.data()?['isFind'] == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              errorSnackBar('기사님이 현재 위치 확인 요청을 받지 못했습니다.', context));
        }
      }
    } catch (e) {
      print('Driver not found handling failed: $e');
    }
  }

  Future<void> updateMarker(BuildContext context, String photoUrl,
      DateTime lastReqDate, NLatLng location) async {
    if (!mounted) return;

    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    if (mapProvider.controller == null) {
      print('Map controller is null');
      return;
    }

    // 현재 시간과의 차이를 매번 새로 계산
    final currentTime = DateTime.now();
    final difference = currentTime.difference(lastReqDate);
    String timeAgo = difference.inMinutes < 60
        ? '${difference.inMinutes}분 전'
        : '${difference.inHours}시간 전';

    print(
        '시간 업데이트 - lastReqDate: $lastReqDate, currentTime: $currentTime, timeAgo: $timeAgo');

    try {
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
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
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

      if (currentMarker != null) {
        await mapProvider.controller?.deleteOverlay(
            const NOverlayInfo(type: NOverlayType.marker, id: 'marker_driver'));
        currentMarker = null;
      }

      currentMarker = NMarker(
        id: 'marker_driver',
        position: location,
      );

      currentMarker!.setIcon(markerIcon);

      currentMarker!.setOnTapListener((NMarker marker) {
        dataProvider.driverLocatonsUpState(true);
      });

      await mapProvider.controller!.addOverlay(currentMarker!);

      print('마커가 성공적으로 업데이트되었습니다.');
    } catch (e) {
      print('마커 업데이트 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.callType);
    if (widget.cargo.isEmpty ||
            widget.callType == '다구간' ||
            widget.callType == '왕복'
        ? widget.cargo['locations'] == null
        : widget.cargo['upTime'] == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.cargo['driverCarInfo'] != null) {
      carInfoParts = widget.cargo['driverCarInfo'].split('/');
    }

    final mapProvider = Provider.of<MapProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);

    return DelayedWidget(
      delayDuration: const Duration(milliseconds: 300),
      animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
      animationDuration: const Duration(milliseconds: 700),
      child: Row(
        children: [
          Row(
            children: [
              GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return StatefulBuilder(builder: (context, setState) {
                          return BottomDriverInfoPage(
                            pickUserUid: widget.cargo['pickUserUid'],
                            isReview: true,
                            cargo: widget.cargo,
                          );
                        });
                      },
                    );
                  },
                  child: cirDriver(widget.dw * 0.12, widget.cargo)),
              const SizedBox(width: 5),
            ],
          ),
          const SizedBox(width: 5),
          if (widget.cargo['pickUserUid'] == null)
            isPassedDate(widget.callType == '다구간' || widget.callType == '왕복'
                        ? widget.cargo['locations'][0]['date'].toDate()
                        : widget.cargo['upTime'].toDate()) ==
                    true
                ? const Row(
                    children: [
                      KTextWidget(
                          text: '만료됨',
                          size: 14,
                          fontWeight: null,
                          color: Colors.grey),
                    ],
                  )
                : const Row(
                    children: [
                      KTextWidget(
                          text: '대기중',
                          size: 14,
                          fontWeight: null,
                          color: Colors.grey),
                      SizedBox(width: 3),
                      SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                          strokeWidth: 1,
                        ),
                      )
                    ],
                  )
          else
            Column(
              children: [],
            ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              makePhoneCall(widget.cargo['driverPhone'].toString());
            },
            child: Container(
              width: widget.dw * 0.11,
              height: widget.dw * 0.11,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: noState.withOpacity(0.5)),
              child: const Center(
                child: Icon(
                  Icons.phone,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              if (widget.cargo['cargoStat'] == '하차완료' ||
                  widget.cargo['cargoStat'] == '운송완료') {
                ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(
                    '종료된 운송의 위치는 확인할 수 없습니다.\n운송중인 화물일때만 클릭하세요.', context));
              } else {
                driverLocation();
              }
            },
            child: Container(
              width: widget.dw * 0.11,
              height: widget.dw * 0.11,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: noState.withOpacity(0.5)),
              child: const Center(
                child: Icon(
                  Icons.location_history,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const InUseCargoList(
                          callType: '지도',
                        )),
              );
            },
            child: Container(
              width: widget.dw * 0.11,
              height: widget.dw * 0.11,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: noState.withOpacity(0.5)),
              child: const Center(
                child: Icon(
                  Icons.menu,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _resetDriverPostion(MapProvider mapProvider) async {
    mapProvider.isLoadingState(true);
    try {
      await FirebaseFirestore.instance
          .collection('user_driver')
          .doc(widget.cargo['pickUserUid'])
          .update({'isFind': true});
    } catch (e) {
      print('Driver position reset failed: $e');
    } finally {
      mapProvider.isLoadingState(false);
    }
  }

  Future<void> _locationsHistory() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final now = DateTime.now();
    final formattedDate = DateFormat('yyMMddHHmmss').format(now);
    final uniqueId = '$formattedDate${widget.cargo['pickUserUid']}';

    try {
      await FirebaseFirestore.instanceFor(
              app: FirebaseFirestore.instance.app, databaseId: 'ourcom')
          .collection('locationsHistory')
          .doc(uniqueId)
          .set({
        'reqUid': dataProvider.userData!.uid,
        'reqDate': now,
        'req': '운송 기사님 위치 확인',
        'target': widget.cargo['pickUserUid'],
        'reqType': '일반인',
        'cargoId': widget.cargo['id']
      });
    } catch (e) {
      print('Location history update failed: $e');
    }
  }

  void driverLocation() {
    final dw = MediaQuery.of(context).size.width;
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    DateTime upDate;
    DateTime downDate;

    if (widget.cargo['aloneType'] == '다구간') {
      upDate = widget.cargo['locations'][0]['date'].toDate();
      downDate = widget.cargo['locations'].last['date'].toDate();
    } else if (widget.cargo['aloneType'] == '왕복') {
      upDate = widget.cargo['locations'][0]['date'].toDate();
      downDate = widget.cargo['locations'][2]['date'].toDate();
    } else {
      upDate = widget.cargo['upTime'].toDate();
      downDate = widget.cargo['downTime'].toDate();
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return BottomSheetWidget(
            contents: SafeArea(
              child: widget.cargo['pickUserUid'] == null
                  ? const Column(
                      children: [
                        SizedBox(height: 24),
                        Icon(Icons.info, size: 70, color: Colors.grey),
                        SizedBox(height: 32),
                        KTextWidget(
                            text: '배차된 기사가 없습니다.',
                            size: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        KTextWidget(
                            text: '아직 기사가 배차되지 않아 현위치를 확인할 수 없습니다.',
                            size: 14,
                            fontWeight: null,
                            color: Colors.grey),
                        KTextWidget(
                            text: '배차 후, 다시 시도하세요.',
                            size: 14,
                            fontWeight: null,
                            color: Colors.grey),
                        SizedBox(height: 32),
                      ],
                    )
                  : isPassedDate(upDate) && isPassedDate(downDate)
                      ? const Column(
                          children: [
                            SizedBox(height: 24),
                            Icon(Icons.info, size: 70, color: kRedColor),
                            SizedBox(height: 32),
                            KTextWidget(
                                text: '운송 기간이 만료되었습니다.',
                                size: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            KTextWidget(
                                text: '설청된 상, 하차일자가 초과되어 위치를 확인할 수 없습니다.',
                                size: 14,
                                fontWeight: null,
                                color: Colors.grey),
                            KTextWidget(
                                text: '기사 위치는 운송중에만 확인 가능합니다.',
                                size: 14,
                                fontWeight: null,
                                color: Colors.grey),
                            SizedBox(height: 32),
                          ],
                        )
                      : const Column(
                          children: [
                            SizedBox(height: 24),
                            Icon(Icons.info, size: 70, color: kGreenFontColor),
                            SizedBox(height: 32),
                            KTextWidget(
                                text: '기사 위치 확인을 요청하였습니다.',
                                size: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            KTextWidget(
                                text: '운송중인 기사님의 위치를 확인합니다.',
                                size: 14,
                                fontWeight: null,
                                color: Colors.grey),
                            KTextWidget(
                                text:
                                    '만약 위치를 확인하기 어려운 상태\n(통화, 앱 미사용 등)라면 위치 인이 불가합니다.',
                                size: 14,
                                textAlign: TextAlign.center,
                                fontWeight: null,
                                color: Colors.grey),
                            SizedBox(height: 32),
                          ],
                        ),
            ),
          );
        });
      },
    ).then((value) async {
      if (widget.cargo['pickUserUid'] != null &&
          (isPassedDate(upDate) == false && isPassedDate(downDate) == false)) {
        await _resetDriverPostion(mapProvider);
        updateCameraCenter(mapProvider.controller,
            NLatLng(decryptedLocation!.latitude, decryptedLocation!.longitude));
      }
    });
  }
}

/*   GestureDetector(
                  onTap: () {
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
                        color: kRedColor),
                    child: const Row(
                      children: [
                        // Icon(Icons.cancel, color: kRedColor, size: 16),
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
                        Navigator.pop(context);
                      },
                      child: const UnderLineWidget(
                        text: '돌아가기',
                        color: Colors.grey,
                        size: 14,
                      ),
                    ),
                  ],
                ) */
