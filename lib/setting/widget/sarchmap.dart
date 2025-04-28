import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class MapAddressSearch extends StatefulWidget {
  final String callType;
  final NLatLng? nLatLng;
  const MapAddressSearch({super.key, required this.callType, this.nLatLng});

  @override
  State<MapAddressSearch> createState() => _MapAddressSearchState();
}

class _MapAddressSearchState extends State<MapAddressSearch> {
  Position? currentPosition;
  late NaverMapController _controller;
  bool _isCameraMove = false;
  Future _position() async {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    if (mapProvider.currentLivePosition != null) {
      NCameraUpdate cameraUpdate = NCameraUpdate.scrollAndZoomTo(
        target: NLatLng(widget.nLatLng!.latitude, widget.nLatLng!.longitude),
        zoom: 15,
      );

      cameraUpdate.setAnimation(
        animation: NCameraAnimation.fly,
        duration: const Duration(seconds: 3),
      );

      _controller.updateCamera(cameraUpdate);
    }
  }

  NLatLng? currentCameraPosition;
  Future<void> _updateCameraCenter() async {
    if (_controller != null) {
      try {
        NCameraPosition cameraPosition = await _controller.getCameraPosition();
        setState(() {
          currentCameraPosition = cameraPosition.target;
        });
       
        await _address(); // 카메라 위치 업데이트 후 바로 주소 조회
      } catch (e) {
        print('카메라 위치 업데이트 에러: $e');
      }
    }
  }

  Future<void> _address() async {
    final addProvider = Provider.of<AddProvider>(context, listen: false);

    if (currentCameraPosition != null) {
      try {
        final value = await addProvider.latlngAddress(NLatLng(
            currentCameraPosition!.latitude, currentCameraPosition!.longitude));

        if (mounted) {
          setState(() {
            ads = value;
            adsR = value[1] == 'no' ? '도로명 주소 확인 안됨' : value[1];
            adsS = value[0];
          });
        }
        print(ads);
      } catch (e) {
        print('주소 변환 에러: $e');
      }
    }
  }

  final _mapKey = UniqueKey();
  @override
  Widget build(BuildContext context) {
    // final addProvider = Provider.of<AddProvider>(context);
    // 부천역
    return Scaffold(
      body: Stack(
        children: [
          NaverMap(
            key: _mapKey,
            options: NaverMapViewOptions(
              indoorEnable: false,
              locationButtonEnable: false,
              consumeSymbolTapEvents: false,
              mapType: NMapType.navi,
              locale: const Locale('ko'),
              nightModeEnable: true,
              buildingHeight: 0,
            ),
            onMapReady: (controller) {
              _controller = controller;
              _updateCameraCenter();
              _address();
              _position();
            },
            onCameraChange: (reason, animated) {
              if (_isCameraMove == false) {
                _isCameraMove = true;
              }
            },
            onCameraIdle: () {
              if (_isCameraMove == true) {
                _isCameraMove = false;
              }
              _updateCameraCenter();
              // _address();
            },
            onMapTapped: (point, latLng) {
              FocusScope.of(context).unfocus();
            },
          ),
          // _btn(),
          Positioned(
              top: MediaQuery.of(context).size.height / 2 -
                  45, // 높이의 중간 - 박스 높이의 반
              left: MediaQuery.of(context).size.width / 2 -
                  25, // 너비의 중간 - 박스 너비의 반
              child: Image.asset(
                'asset/img/place.png',
                width: 50,
              )),
          Positioned(
            top: Platform.isAndroid ? 5 : 0,
            child: _top(),
          ),
          Positioned(
            bottom: Platform.isAndroid ? 5 : 0,
            child: _btn(),
          ),
        ],
      ),
    );
  }

  Widget _btn() {
    final hashProvider = Provider.of<HashProvider>(context);
    final addProvider = Provider.of<AddProvider>(context);
    final dw = MediaQuery.of(context).size.width;
    Color _isColor = widget.callType == '차고지'
        ? kGreenFontColor
        : widget.callType.contains('상차')
            ? kBlueBssetColor
            : kRedColor;
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            HapticFeedback.lightImpact();
            if (widget.callType.contains('하차')) {
              addProvider.setLocationDownAddressState(
                  adsS.toString(), adsR.toString());
              addProvider.setLocationDownNLatLngState(NLatLng(
                  currentCameraPosition!.latitude,
                  currentCameraPosition!.longitude));
              addProvider.setLocationDownTypeState('map');

              Navigator.pop(context);
              Navigator.pop(context);
            } else {
              addProvider.setLocationUpAddressState(
                  adsS.toString(), adsR.toString());
              addProvider.setLocationUpNLatLngState(NLatLng(
                  currentCameraPosition!.latitude,
                  currentCameraPosition!.longitude));
              addProvider.setLocationTypeState('map');

              Navigator.pop(context);
              Navigator.pop(context);
            }
          },
          child: Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              width: dw - 20,
              height: 52,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), color: _isColor),
              child: const Center(
                child: KTextWidget(
                    text: '주소지 등록',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              )),
        ),
        const SizedBox(height: 12),
        GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const UnderLineWidget(
                text: '이전페이지로 돌아가기', color: Colors.white)),
        SizedBox(height: Platform.isIOS ? 30 : 10)
      ],
    );
  }

  String? adsS;
  String? adsR;
  List? ads;
  NLatLng? _point;

  List<SearchResult>? results;

  TextEditingController _searchText = TextEditingController();
  bool _searchLoading = false;
  Widget _top() {
    final mapProvider = Provider.of<MapProvider>(context);
    // final authProvider = Provider.of<AuthProvider>(context);
    final addProvider = Provider.of<AddProvider>(context, listen: false);
    final hashProvider = Provider.of<HashProvider>(context);
    final dw = MediaQuery.of(context).size.width;

    Color _isColor = widget.callType == '차고지'
        ? kGreenFontColor
        : widget.callType.contains('상차')
            ? kBlueBssetColor
            : kRedColor;

    return SafeArea(
      child: SizedBox(
        width: dw,
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Column(
            children: [
              Container(
                width: dw,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: msgBackColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                              left: 4, right: 4, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: _isColor
                              //border: Border.all(color: kBlueBssetColor),
                              ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_location_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(width: 3),
                              KTextWidget(
                                  text: '현위치',
                                  size: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              SizedBox(width: 8),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            SizedBox(
                              width: dw - 110,
                              child: KTextWidget(
                                  text: adsS == null ? '...' : adsS.toString(),
                                  size: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            SizedBox(
                              width: dw - 110,
                              child: KTextWidget(
                                  text: adsR == null ? '...' : adsR.toString(),
                                  size: 14,
                                  fontWeight: null,
                                  color: Colors.grey),
                            )
                          ],
                        ),
                      ],
                    ),

                    /* const SizedBox(height: 16),
                    Row(
                      children: [
                        SizedBox(
                          width: dw - 62,
                          child: KTextWidget(
                              text: adsS.toString(),
                              size: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )
                      ],
                    ),
                    const SizedBox(height: 16), */
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (adsR == 'no' || adsR == '도로명 주소 확인 안됨')
                Container(
                  width: dw,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: msgBackColor),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: kRedColor,
                      ),
                      SizedBox(width: 10),
                      KTextWidget(
                          text: '주소를 정확히 확인하세요.\n도로를 선택했을 경우 주소가 다를 수 있습니다.',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: kRedColor)
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// 부천역

class SearchResult {
  final String title;
  final String category;
  final String address;
  final String roadAddress;
  final double mapx;
  final double mapy;

  SearchResult({
    required this.title,
    required this.category,
    required this.address,
    required this.roadAddress,
    required this.mapx,
    required this.mapy,
  });
}
