import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/service/ar_service/aos_ar.dart';
import 'package:flutter_mixcall_normaluser_new/service/ar_service/ios_ar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';

import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class ARServiceMainPage extends StatefulWidget {
  const ARServiceMainPage({Key? key}) : super(key: key);

  @override
  _ARServiceMainPageState createState() => _ARServiceMainPageState();
}

class _ARServiceMainPageState extends State<ARServiceMainPage> {
  bool _hasCameraPermission = false;
  bool _isCheckingPermission = true;

  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  @override
  void initState() {
    super.initState();
    // initCamera();
    _initCameraAndCheckPermission();
  }

  void initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final controller =
            CameraController(cameras[0], ResolutionPreset.medium);
        await controller.initialize();
        print('카메라 초기화 성공');
      }
    } catch (e) {
      print('카메라 초기화 오류: $e');
    }
  }

  /* Future<void> _checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      print('현재 카메라 권한 상태: ${status.toString()}');

      if (mounted) {
        setState(() {
          _hasCameraPermission = status.isGranted;
          _isCheckingPermission = false;
        });
      }
    } catch (e) {
      print('권한 확인 중 오류: $e');
      if (mounted) {
        setState(() {
          _isCheckingPermission = false;
        });
      }
    }
  }

  Future<void> _requestCameraPermission() async {
    try {
      print('카메라 권한 요청 시작');
      setState(() {
        _isCheckingPermission = true;
      });

      var status = await Permission.camera.status;
      print('현재 권한 상태: $status');

      if (status.isPermanentlyDenied) {
        // 영구 거부된 경우 즉시 설정으로 이동
        setState(() {
          _isCheckingPermission = false;
        });
        _showSettingsDialog();
        return;
      }

      if (status.isDenied || status.isRestricted || status.isLimited) {
        status = await Permission.camera.request();
        print('권한 요청 후 상태: $status');
      }

      if (mounted) {
        setState(() {
          _hasCameraPermission = status.isGranted;
          _isCheckingPermission = false;
        });
      }

      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'AR 기능을 사용하려면 카메라 권한이 필요합니다\n이미 두번 이상 카메라 권한을 거절하였습니다.\n이용하시려면 설정에서 직접 카메라 권한을 설정하세요.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('권한 요청 중 오류: $e');
      if (mounted) {
        setState(() {
          _isCheckingPermission = false;
        });
      }
    }
  } */

  Future<void> _initCameraAndCheckPermission() async {
    try {
      print('카메라 초기화 및 권한 확인 시작');
      setState(() {
        _isCheckingPermission = true;
      });

      // 카메라 초기화 시도 - 이 시점에서 iOS가 권한 요청 다이얼로그를 표시할 수 있음
      _cameras = await availableCameras();

      // 권한 상태 확인
      final status = await Permission.camera.status;
      print('카메라 초기화 후 권한 상태: ${status.toString()}');

      if (status.isGranted && _cameras.isNotEmpty) {
        // 권한이 있으면 카메라 컨트롤러 초기화
        _cameraController = CameraController(
          _cameras[0],
          ResolutionPreset.medium,
        );
        await _cameraController?.initialize();
        print('카메라 컨트롤러 초기화 완료');
      } else if (status.isDenied || status.isRestricted || status.isLimited) {
        // 권한이 없지만 요청 가능한 상태면 요청
        print('카메라 권한 요청 시도');
        await Permission.camera.request();
        // 요청 후 상태 다시 확인
        final newStatus = await Permission.camera.status;
        print('권한 요청 후 상태: ${newStatus.toString()}');

        if (newStatus.isGranted && _cameras.isNotEmpty) {
          _cameraController = CameraController(
            _cameras[0],
            ResolutionPreset.medium,
          );
          await _cameraController?.initialize();
        }
      } else if (status.isPermanentlyDenied) {
        print('카메라 권한이 영구적으로 거부됨 - 설정으로 이동 다이얼로그 표시');
        _showSettingsDialog();
      }

      if (mounted) {
        setState(() {
          _hasCameraPermission = status.isGranted;
          _isCheckingPermission = false;
        });
      }
    } catch (e) {
      print('카메라 초기화 중 오류 발생: $e');
      if (mounted) {
        setState(() {
          _isCheckingPermission = false;
        });
      }
    }
  }

  // 기존 _requestCameraPermission 메서드는 유지하되 카메라 초기화 로직 추가
  Future<void> _requestCameraPermission() async {
    try {
      print('카메라 권한 요청 및 초기화 시작');
      setState(() {
        _isCheckingPermission = true;
      });

      // 카메라 리스트 가져오기 시도 - 이 단계에서 권한 요청이 발생할 수 있음
      try {
        _cameras = await availableCameras();
        print('사용 가능한 카메라: ${_cameras.length}개');
      } catch (e) {
        print('카메라 목록 가져오기 실패: $e');
      }

      var status = await Permission.camera.status;
      print('현재 권한 상태: $status');

      if (status.isDenied || status.isRestricted || status.isLimited) {
        print('권한 거부됨 - 권한 요청 시도');
        status = await Permission.camera.request();
        print('권한 요청 후 상태: $status');
      }

      if (status.isGranted && _cameras.isNotEmpty) {
        print('권한 승인됨 - 카메라 초기화 시도');
        _cameraController = CameraController(
          _cameras[0],
          ResolutionPreset.medium,
        );
        await _cameraController?.initialize();
        print('카메라 초기화 완료');
      }

      if (mounted) {
        setState(() {
          _hasCameraPermission = status.isGranted;
          _isCheckingPermission = false;
        });
      }

      if (status.isPermanentlyDenied) {
        print('권한 영구 거부됨 - 설정 다이얼로그 표시');
        _showSettingsDialog();
      } else if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AR 기능을 사용하려면 카메라 권한이 필요합니다'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('권한 요청 및 카메라 초기화 중 오류: $e');
      if (mounted) {
        setState(() {
          _isCheckingPermission = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카메라 권한 필요'),
        content: const Text('AR 서비스를 사용하려면 카메라 권한이 필요합니다. 설정에서 권한을 허용해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 권한 확인 중일 때 로딩 표시
    if (_isCheckingPermission) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'AR 화물 사이즈 측정',
            style: TextStyle(fontSize: 20),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 권한이 없는 경우 권한 요청 화면
    if (!_hasCameraPermission) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'AR 화물 사이즈 측정',
            style: TextStyle(fontSize: 20),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'asset/img/ar1.png',
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: KTextWidget(
                  text: 'AR서비스 이용을 위해 카메라 권한이 필요합니다.',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _requestCameraPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreenFontColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  '카메라 권한 설정하기',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 카메라 권한이 있는 경우 AR 페이지로 이동
    return Platform.isIOS ? ARIOSPage() : Container(); // ARAndroidPage();
  }
}
