import 'dart:math';

import 'package:permission_handler/permission_handler.dart';

class NaverMapUtils {
  /// 두 지점 간의 실제 직선 거리를 계산 (km)
  static double calculateDistance({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    const R = 6371.0; // 지구의 반지름 (km)

    // 위도, 경도를 라디안으로 변환
    final lat1 = _degreesToRadians(startLat);
    final lon1 = _degreesToRadians(startLng);
    final lat2 = _degreesToRadians(endLat);
    final lon2 = _degreesToRadians(endLng);

    // 위도, 경도의 차이
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    // Haversine 공식
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // 최종 거리 계산 (km)
    return R * c;
  }

  /// 도(degree)를 라디안(radian)으로 변환
  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}

//// 위치권환 확인
///

Future<Map<String, bool>> checkAllPermissions() async {
  Map<String, bool> permissionResults = {
    'location': false,
    'camera': false,
    'notification': false,
  };

  // 위치 권한 체크 및 요청
  PermissionStatus locationStatus = await Permission.locationWhenInUse.status;
  print('초기 위치 권한 상태: $locationStatus');

  if (locationStatus.isDenied) {
    locationStatus = await Permission.locationWhenInUse.request();
    print('위치 권한 요청 후 상태: $locationStatus');
  }

  // 카메라 권한 체크 및 요청
  PermissionStatus cameraStatus = await Permission.camera.status;
  print('초기 카메라 권한 상태: $cameraStatus');

  if (cameraStatus.isDenied) {
    cameraStatus = await Permission.camera.request();
    print('카메라 권한 요청 후 상태: $cameraStatus');
  }

  // 알람 권한 체크 및 요청
  PermissionStatus notificationStatus = await Permission.notification.status;
  print('초기 알람 권한 상태: $notificationStatus');

  if (notificationStatus.isDenied) {
    notificationStatus = await Permission.notification.request();
    print('알람 권한 요청 후 상태: $notificationStatus');
  }

  // 최종 권한 상태 확인
  final currentLocationStatus = await Permission.locationWhenInUse.status;
  final currentCameraStatus = await Permission.camera.status;
  final currentNotificationStatus = await Permission.notification.status;

  print('최종 위치 권한 상태: $currentLocationStatus');
  print('최종 카메라 권한 상태: $currentCameraStatus');
  print('최종 알람 권한 상태: $currentNotificationStatus');

  permissionResults['location'] = currentLocationStatus.isGranted;
  permissionResults['camera'] = currentCameraStatus.isGranted;
  permissionResults['notification'] = currentNotificationStatus.isGranted;

  return permissionResults;
}


