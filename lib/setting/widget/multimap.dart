import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/model/multi_cargo_add_model.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/futurue_main.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';

class CargoMapPage extends StatefulWidget {
  final String? callType;
  final Map<String, dynamic>? cargo;
  const CargoMapPage({super.key, this.callType, required this.cargo});

  @override
  State<CargoMapPage> createState() => _CargoMapPageState();
}

class _CargoMapPageState extends State<CargoMapPage> {
  @override
  void initState() {
    super.initState();
    // 경로 오버레이 생성

    if (widget.cargo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final addProvider = Provider.of<AddProvider>(context, listen: false);
        if (addProvider.addMainType == '다구간' ||
            addProvider.addMainType == '왕복') {
          _init();
        } else {
          _initNormal();
        }
      });
    }
  }

  Future _initNormal() async {
    final addProvider = Provider.of<AddProvider>(context, listen: false);
    final hashProvider = Provider.of<HashProvider>(context, listen: false);

    addProvider.setLocationUpNLatLngState(
        hashProvider.decLatLng(widget.cargo!['upLocation']['geopoint']));

    addProvider.setLocationDownNLatLngState(
        hashProvider.decLatLng(widget.cargo!['downLocation']['geopoint']));

    addProvider.coordSet(
        await hashProvider.fastDecryptPath(widget.cargo!['allRoute']));
  }

  Future _init() async {
    final addProvider = Provider.of<AddProvider>(context, listen: false);
    final hashProvider = Provider.of<HashProvider>(context, listen: false);

    addProvider.clearLocations();
    List<dynamic> rawLocations = widget.cargo!['locations'] as List;
    rawLocations.forEach((locationData) {
      print('위치 처리 중: ${locationData['type']}');
      // location 필드만 복호화
      NLatLng decryptedLocation =
          hashProvider.decLatLng(locationData['location'].toString());

      // downCargos와 upCargos를 CargoInfo 리스트로 변환
      List<CargoInfo> downCargosList = (locationData['downCargos'] as List?)
              ?.map((cargo) => CargoInfo.fromMap(cargo as Map<String, dynamic>))
              ?.toList() ??
          [];

      List<CargoInfo> upCargosList = (locationData['upCargos'] as List?)
              ?.map((cargo) => CargoInfo.fromMap(cargo as Map<String, dynamic>))
              ?.toList() ??
          [];

      CargoLocation cargoLocation = CargoLocation(
        type: locationData['type'],
        address1: locationData['address1'],
        address2: locationData['address2'],
        addressDis: locationData['addressDis'],
        location: decryptedLocation,
        howTo: locationData['howTo'],
        senderType: locationData['senderType'],
        senderName: locationData['senderName'],
        senderPhone: locationData['senderPhone'],
        dateType: locationData['dateType'],
        dateAloneString: locationData['dateAloneString'],
        dateStart: locationData['dateStart']?.toDate(),
        dateEnd: locationData['dateEnd']?.toDate(),
        date: locationData['date']?.toDate(),
        etc: locationData['etc'],
        becareful: locationData['becareful'],
        isDone: locationData['isDone'],
        isDoneTime: locationData['isDoneTime']?.toDate(),
        downCargos: downCargosList,
        upCargos: upCargosList,
      );

      addProvider.addLocation(cargoLocation);
      print('위치 추가 후 locations 길이: ${addProvider.locations.length}');
    });

    addProvider.coordSet(
        await hashProvider.fastDecryptPath(widget.cargo!['allRoute']));
  }

  bool _isTrafic = false;

  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    final hashProvider = Provider.of<HashProvider>(context);
    late NaverMapController _controller;

    return Scaffold(
      body: Stack(
        children: [
          addProvider.coordinates.isEmpty
              ? Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: Colors.grey,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              : NaverMap(
                  options: NaverMapViewOptions(
                      indoorEnable: false,
                      locationButtonEnable: false,
                      consumeSymbolTapEvents: false,
                      mapType: NMapType.navi,
                      activeLayerGroups:
                          !_isTrafic ? [] : [NLayerGroup.traffic],
                      locale: const Locale('ko'),
                      nightModeEnable: true,
                      buildingHeight: 0,
                      initialCameraPosition: NCameraPosition(
                          target: addProvider.coordinates[0], zoom: 13)),
                  onMapReady: (controller) async {
                    _controller = controller;

                    _controller.addOverlay(NPathOverlay(
                      id: 'route',
                      coords: addProvider.coordinates,
                      color: Colors.cyanAccent,
                      width: !_isTrafic ? 5 : 3,
                      outlineColor: Colors.cyan.withOpacity(0.3),
                      patternInterval: 80,
                    ));
                    if (widget.cargo == null) {
                      if (addProvider.addMainType == '다구간') {
                        addMarkersToMapMulti(addProvider, controller, context);
                      } else if (addProvider.addMainType == '왕복') {
                        addMarkersToMapReturn(addProvider, controller, context);
                      } else {
                        addMarkersToMapUpDown(
                            controller: controller,
                            context: context,
                            addProvider: addProvider);
                      }
                    } else {
                      if (widget.cargo!['aloneType'] == '다구간') {
                        addMarkersToMapMulti(addProvider, controller, context);
                      } else if (widget.cargo!['aloneType'] == '왕복') {
                        addMarkersToMapReturn(addProvider, controller, context);
                      } else {
                        addMarkersToMapUpDown(
                            controller: controller,
                            context: context,
                            addProvider: addProvider);
                      }
                    }
                  },
                  onCameraChange: (reason, animated) {},
                  onCameraIdle: () {},
                  onMapTapped: (point, latLng) {
                    FocusScope.of(context).unfocus();
                  },
                ),

          // 커스텀 AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  height: 120,
                  color: msgBackColor.withOpacity(0.8),
                  child: Column(
                    children: [
                      const Spacer(),
                      Row(
                        children: [
                          // 뒤로가기 버튼
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          // 중앙 정렬된 제목
                          const Expanded(
                            child: Center(
                              child: Text(
                                '전체 경로 보기',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          // 우측 여백을 위한 빈 공간
                          const SizedBox(width: 48), // 뒤로가기 버튼과 동일한 너비
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        /*  if (_isTrafic) {
                          _isTrafic = false;
                          _controller.deleteOverlay(NOverlayInfo(
                              type: NOverlayType.pathOverlay, id: 'route'));
                          _controller.addOverlay(NPathOverlay(
                            id: 'route',
                            coords: addProvider.coordinates,
                            color: Colors.cyanAccent,
                            width: !_isTrafic ? 5 : 3,
                            outlineColor: Colors.cyan.withOpacity(0.3),
                            patternInterval: 80,
                          ));
                        } else {
                          _isTrafic = true;
                          _controller.deleteOverlay(NOverlayInfo(
                              type: NOverlayType.pathOverlay, id: 'route'));
                          _controller.addOverlay(NPathOverlay(
                            id: 'route',
                            coords: addProvider.coordinates,
                            color: Colors.cyanAccent,
                            width: !_isTrafic ? 5 : 3,
                            outlineColor: Colors.cyan.withOpacity(0.3),
                            patternInterval: 80,
                          ));
                        }
 */
                        setState(() {
                          _isTrafic = !_isTrafic;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: msgBackColor),
                        child: Center(
                          child: Icon(
                            Icons.traffic,
                            color: !_isTrafic
                                ? Colors.grey.withOpacity(0.5)
                                : kGreenFontColor,
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
