import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/bottomSheet.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class OutTmeBottomSheet extends StatelessWidget {
  const OutTmeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
            color: dialogColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BottomTobMarker(),
              ],
            ),
            const SizedBox(height: 23),
            const Icon(
              Icons.info,
              color: kRedColor,
              size: 80,
            ),
            const SizedBox(height: 23),
            KTextWidget(
                text: '회원탈퇴전 안내 사항을 확인하세요.',
                size: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
            const SizedBox(height: 12),
            _contents(),
            const SizedBox(height: 23),
            GestureDetector(
              onTap: () async {
                HapticFeedback.lightImpact();

                Navigator.pop(context, 'exit');
              },
              child: Container(
                height: 56,
                margin: EdgeInsets.only(left: 16, right: 16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12), color: kRedColor),
                child: const Center(
                    child: KTextWidget(
                  text: '회원 탈퇴',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: UnderLineWidget(
                        text: '이전페이지로 돌아가기', color: Colors.grey)),
              ],
            ),
            Platform.isIOS
                ? const SizedBox(height: 20)
                : const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _contents() {
    return const SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KTextWidget(
                text: '탈퇴 후, 개인정보 및 사업자정보 관리',
                size: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
            KTextWidget(
                text:
                    '탈퇴 즉시 계정은 삭제되나, 계정 정보는 운송 관련 정보 보관 방침에 따라 1년간 저장되며 이후 1년이 되는 시점에 삭제됩니다.',
                size: 14,
                fontWeight: null,
                color: Colors.grey),
            SizedBox(height: 15),
            KTextWidget(
                text: '사업자 정보, 배차 정보',
                size: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
            KTextWidget(
                text:
                    '운송건에 기록되어 화주 또는 주선사에게 정보는 약관 및 운송 정보 기록 기준에 따라 2년간 보유한뒤 자동으로 삭제됩니다.',
                size: 14,
                fontWeight: null,
                color: Colors.grey),
            SizedBox(height: 15),
            KTextWidget(
                text: '관련 정보 연동 불가',
                size: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
            KTextWidget(
                text:
                    '회원 탈퇴 후, 재가입을 진행하셔도 이전 정보를 연동할 수 없습니다. 또, 탈퇴후 회원 관련 안내 및 정보 제공이 불가함으로, 반드시 모든 업무를 처리하신 후 탈퇴과정을 진행하세요.',
                size: 14,
                fontWeight: null,
                color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
