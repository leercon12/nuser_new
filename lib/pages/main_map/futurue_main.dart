import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/model/multi_cargo_add_model.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import 'dart:math' show pi;

import '../../providers/addProvider.dart';

void startTracking(BuildContext context) async {
  final mapProvider = Provider.of<MapProvider>(context, listen: false);
  try {
    await mapProvider.startLocationUpdates();
  } catch (e) {
    // 에러 처리
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('위치 서비스 오류'),
        content: Text('위치 서비스를 사용할 수 없습니다.\n설정에서 위치 권한을 확인해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }
}

void updateCameraCenter(NaverMapController? _controller, NLatLng target) async {
  NCameraUpdate cameraUpdate = NCameraUpdate.scrollAndZoomTo(target: target);

  cameraUpdate.setAnimation(
      animation: NCameraAnimation.fly, duration: const Duration(seconds: 3));

  _controller!.updateCamera(cameraUpdate);
}

Future<void> addMarkersToMapUpDown({
  AddProvider? addProvider,
  required NaverMapController controller,
  required BuildContext context,
  NLatLng? up,
  NLatLng? down,
}) async {
  if (addProvider != null) {}
  // 상차 마커 추가

  NMarker upMarker = NMarker(
    id: 'marker_up',
    position: addProvider == null ? up! : addProvider.setLocationUpNLatLng!,
  )
    ..setIcon(const NOverlayImage.fromAssetImage('asset/img/up_navi.png'))
    ..setCaption(
      const NOverlayCaption(
        text: '상차지',
        textSize: 10,
        color: Colors.black,
        haloColor: Colors.white,
      ),
    );

  controller.addOverlay(upMarker);

  NMarker downMarker = NMarker(
    id: 'marker_down',
    position: addProvider == null ? down! : addProvider.setLocationDownNLatLng!,
  )
    ..setIcon(const NOverlayImage.fromAssetImage('asset/img/down_navi.png'))
    ..setCaption(
      const NOverlayCaption(
        text: '하차지',
        textSize: 10,
        color: Colors.black,
        haloColor: Colors.white,
      ),
    );

  controller.addOverlay(downMarker);
}

Future<void> addMarkersToMapMulti(AddProvider addProvider,
    NaverMapController controller, BuildContext context) async {
  List<CargoPoint> points = addProvider.getDetailedLocationCoordinates();

  for (CargoPoint point in points) {
    // 마커 색상 설정
    Color markerColor = point.type == '상차' ? Colors.blue : Colors.red;

    // 마커 아이콘 생성
    NOverlayImage markerIcon = await NOverlayImage.fromWidget(
      context: context,
      widget: Container(
        //padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: markerColor,
          // border: Border.all(color: markerColor, width: 5),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: RotatedBox(
            quarterTurns: Platform.isAndroid ? 2 : 0,
            child: Text(
              '${point.order + 1}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ),
      ),
      size: const Size(35, 35),
    );

    // 마커 생성
    NMarker marker = NMarker(
      id: 'marker_${point.order}',
      position: point.coordinate,
    )
      ..setIcon(markerIcon)
      ..setCaption(
        NOverlayCaption(
          text: '상차 ${point.upNum}건, 하차 ${point.downNum}건',
          textSize: 14,
          color: Colors.black,
          //haloColor: Colors.white,
        ),
      );

    // 마커를 지도에 추가
    controller.addOverlay(marker);
  }
}

Future<void> addMarkersToMapReturn(AddProvider addProvider,
    NaverMapController controller, BuildContext context) async {
  List<CargoPoint> points = addProvider.getDetailedLocationCoordinates();

  for (CargoPoint point in points) {
    NOverlayImage markerIcon;

    if (point.order == 1) {
      // 중간 지점
      markerIcon = await NOverlayImage.fromWidget(
        context: context,
        widget: Container(
          decoration: const BoxDecoration(
            color: kGreenFontColor,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.refresh,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        size: const Size(35, 35),
      );
    } else {
      // 0번과 2번 - 두 이미지 중첩
      markerIcon = await NOverlayImage.fromWidget(
        context: context,
        widget: Stack(
          children: [
            Positioned(
              left: 0, // 왼쪽에 위치
              child: Image.asset(
                'asset/img/up_navi.png',
                width: 35,
                height: 35,
              ),
            ),
            Positioned(
              left: 45, // 첫 번째 이미지 너비(35) + 간격(10)
              child: Image.asset(
                'asset/img/down_navi.png',
                width: 35,
                height: 35,
              ),
            ),
          ],
        ),
        size: const Size(80, 35), // 전체 너비를 두 이미지 + 간격만큼 조정
      );
    }

    // 마커 생성
    NMarker marker = NMarker(
      id: 'marker_${point.order}',
      position: point.coordinate,
    )
      ..setIcon(markerIcon)
      ..setCaption(
        NOverlayCaption(
          text: point.order == 1 ? '경유지(회차지)' : '시작, 최종하차지',
          textSize: 14,
          color: Colors.black,
        ),
      );

    // 마커를 지도에 추가
    controller.addOverlay(marker);
  }
}

Future<void> addMarkersToMapMulti2(DataProvider dataProvider,
    NaverMapController controller, BuildContext context) async {
  List<CargoPoint> points = dataProvider.getCurrentCargoPoints(context);

  for (CargoPoint point in points) {
    // 마커 색상 설정
    Color markerColor = point.type == '상차' ? Colors.blue : Colors.red;

    // 마커 아이콘 생성
    NOverlayImage markerIcon = await NOverlayImage.fromWidget(
      context: context,
      widget: Container(
        //padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: markerColor,
          // border: Border.all(color: markerColor, width: 5),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${point.order + 1}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
      size: const Size(35, 35),
    );

    // 마커 생성
    NMarker marker = NMarker(
      id: 'marker_${point.order}',
      position: point.coordinate,
    )
      ..setIcon(markerIcon)
      ..setCaption(
        NOverlayCaption(
          text: '상차 ${point.upNum}건, 하차 ${point.downNum}건',
          textSize: 14,
          color: Colors.black,
          //haloColor: Colors.white,
        ),
      );

    // 마커를 지도에 추가
    controller.addOverlay(marker);
  }
}

Future<void> addMarkersToMapMulti3(DataProvider dataProvider,
    NaverMapController controller, BuildContext context) async {
  List<CargoPoint> points = dataProvider.getCurrentCargoPoints(context);

  for (CargoPoint point in points) {
    NOverlayImage markerIcon;

    // Make sure markerIcon is always initialized
    if (point.order == 1) {
      markerIcon = await NOverlayImage.fromAssetImage(
        'asset/img/return_bb.png',
      );
    } else {
      // For order 0, 2, or any other value
      markerIcon = await NOverlayImage.fromAssetImage(
        'asset/img/return_aa.png',
      );
    }

    // 마커 생성
    NMarker marker = NMarker(
      id: 'marker_${point.order}',
      position: point.coordinate,
    )
      ..setIcon(markerIcon)
      ..setSize(const Size(40, 40)) // 마커 사이즈를 40으로 설정
      ..setCaption(
        NOverlayCaption(
          text: point.order == 1 ? '경유지(회차지)' : '시작 & 종료 ',
          textSize: 14,
          color: Colors.black,
        ),
      );

    // 마커를 지도에 추가
    controller.addOverlay(marker);
  }
}
