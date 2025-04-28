import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/history_list/history.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StopDialog extends StatelessWidget {
  const StopDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: msgBackColor,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                const Icon(
                  Icons.info,
                  size: 60,
                  color: Colors.red,
                ),
                const SizedBox(height: 32),
                const Text(
                  '현재 서비스를 이용하실 수 없습니다.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '서비스 이용에 불편을 드려 죄송합니다.\n현재 서비스에서 발생된 문제 해결을 위해 잠시 서비스 이용이 중지되었습니다. 기존 기록 확인은 가능하나, 신규 운송 등록 등의 업무가 불가합니다. 이용에 불편을 드려 죄송합니다.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    //addProvider.addReset();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HistoryListMain()),
                    );
                  },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[900],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.settings, color: Colors.grey, size: 16),
                        SizedBox(width: 10),
                        Text(
                          '나의 운송 내역 바로가기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                /* const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // normalStop 상태를 false로 변경
                  },
                  child: const Text(
                    '위치정보없이 혼적콜 이용',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ), */
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class upDateDialog extends StatelessWidget {
  const upDateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final maprovider = Provider.of<MapProvider>(context);
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: msgBackColor,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                const Icon(
                  Icons.downloading_sharp,
                  size: 60,
                  color: kBlueBssetColor,
                ),
                const SizedBox(height: 32),
                const Text(
                  '앱의 신규 버전이 있습니다.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '현재 이용중이신 앱의 버전이 너무 낮습니다.\n버전이 낮아 서비스 이용이 어렵습니다.\n지금 신규 버전으로 업데이트 하세요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    //addProvider.addReset();
                    launchStore();
                  },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[900],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.settings, color: Colors.grey, size: 16),
                        SizedBox(width: 10),
                        Text(
                          '신규 버전 업데이트',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    maprovider.isUpdateDownState(true);
                  },
                  child: const Text(
                    '업데이트 없이 혼적콜 이용',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> launchStore() async {
    try {
      if (Platform.isAndroid) {
        // Android인 경우 Play Store로 이동
        final url = 'market://details?id=your.package.name';
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
        } else {
          // Play Store 앱이 없는 경우 웹 Play Store로 이동
          final webUrl =
              'https://play.google.com/store/apps/details?id=your.package.name';
          await launchUrl(
            Uri.parse(webUrl),
            mode: LaunchMode.externalApplication,
          );
        }
      } else if (Platform.isIOS) {
        // iOS인 경우 App Store로 이동
        final url = 'itms-apps://itunes.apple.com/app/id[YOUR_APP_ID]';
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
        } else {
          // App Store 앱이 없는 경우 웹 App Store로 이동
          final webUrl = 'https://apps.apple.com/app/id[YOUR_APP_ID]';
          await launchUrl(
            Uri.parse(webUrl),
            mode: LaunchMode.externalApplication,
          );
        }
      }
    } catch (e) {
      print('스토어 열기 실패: $e');
    }
  }
}
