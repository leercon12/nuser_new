import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  // 1. 모든 권한 상태 확인
  Future<Map<Permission, bool>> checkAllPermissions() async {
    Map<Permission, bool> permissionStatus = {
      Permission.camera: false,
      Permission.location: false,
      Permission.photos: false,
    };

    // 각 권한 상태 확인
    for (var permission in permissionStatus.keys) {
      final status = await permission.status;
      permissionStatus[permission] =
          !(status.isDenied || status.isPermanentlyDenied);
    }

    return permissionStatus;
  }

  // 2. 개별 권한 요청 함수
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return !(status.isDenied || status.isPermanentlyDenied);
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return !(status.isDenied || status.isPermanentlyDenied);
  }

  Future<bool> requestPhotosPermission() async {
    final status = await Permission.photos.request();
    return !(status.isDenied || status.isPermanentlyDenied);
  }

  // 3. 개별 권한 상태 확인
  Future<bool> getCameraPermissionStatus() async {
    final status = await Permission.camera.status;
    return !(status.isDenied || status.isPermanentlyDenied);
  }

  Future<bool> getLocationPermissionStatus() async {
    final status = await Permission.location.status;
    return !(status.isDenied || status.isPermanentlyDenied);
  }

  Future<bool> getPhotosPermissionStatus() async {
    final status = await Permission.photos.status;
    return !(status.isDenied || status.isPermanentlyDenied);
  }

  // 권한 상태 메시지 반환 (필요한 경우에만 사용)
  String getPermissionMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return '권한이 허용됨';
      case PermissionStatus.denied:
        return '권한이 거부됨';
      case PermissionStatus.restricted:
        return '권한이 제한됨';
      case PermissionStatus.limited:
        return '권한이 제한적으로 허용됨';
      case PermissionStatus.permanentlyDenied:
        return '권한이 영구적으로 거부됨';
      default:
        return '알 수 없는 상태';
    }
  }
}
