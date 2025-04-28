import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/bottomSheet.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';

Future<bool?> mainCategoryBottom(context, callType) async {
  final dw = MediaQuery.of(context).size.width;

  return await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return BottomSheetWidget(
            contents: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.info, size: 70, color: kGreenFontColor),
              const SizedBox(height: 32),
              if (callType == '무관')
                _all()
              else if (callType == '혼적')
                _mix(dw)
              else if (callType == '독차')
                _oneWay(dw)
              else if (callType == '왕복')
                _return()
              else if (callType == '다구간')
                _multi(),
              const SizedBox(height: 42),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context, true); // true 값을 반환
                },
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  width: dw,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: kGreenFontColor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      KTextWidget(
                          text: '확인',
                          size: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
      });
    },
  );
}

Widget _return() {
  return const Column(
    children: [
      const KTextWidget(
          text: '화물을 상차지 > 하차지 > 상차지로 운송합니다.',
          size: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white),
      const SizedBox(height: 12),
      const KTextWidget(
          text: '1건 또는 그이상의 화물을 왕복으로 운송합니다.\n편도보다 높은 운송료가 발생됩니다.',
          size: 14,
          textAlign: TextAlign.center,
          fontWeight: null,
          color: Colors.grey),
    ],
  );
}

Widget _multi() {
  return const Column(
    children: [
      const KTextWidget(
          text: '다양한 화물과 여러 상, 하차지를 운송합니다.',
          size: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white),
      const SizedBox(height: 12),
      const KTextWidget(
          text:
              '최소 3개 이상의 상, 하치지로 화물을 운송합니다.\n상, 하차 정보와 화물 정보를 개별 등록함으로, 모든\n상, 하차지 및 화물의 정보를 등록해야 합니다.',
          size: 14,
          textAlign: TextAlign.center,
          fontWeight: null,
          color: Colors.grey),
    ],
  );
}

Widget _all() {
  return const Column(
    children: [
      const KTextWidget(
          text: '1건의 화물을 상차지 > 하차지로',
          size: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white),
      const KTextWidget(
          text: '혼적이든 독차이든 상관없이 운송합니다.',
          size: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white),
      const SizedBox(height: 12),
      const KTextWidget(
          text: '화물은 혼적이든 독차이든 상관없이 운송합니다.\n더다양한 가격을 제안받을 수 있습니다.',
          size: 14,
          textAlign: TextAlign.center,
          fontWeight: null,
          color: Colors.grey),
    ],
  );
}

Widget _mix(double dw) {
  return Column(
    children: [
      const KTextWidget(
          text: '1건의 화물을 상차지 > 하차지로 혼적 운송합니다.',
          size: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white),
      const SizedBox(height: 32),
      Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: SizedBox(
          width: dw,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KTextWidget(
                  text: '혼적이란?',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              KTextWidget(
                  text:
                      '같은 방향으로 향하는 여러 운송을 처리하는 것을 말합니다. 화물 사이즈가 작거나 가벼운 화물에 적합하며, 일반적으로 독차보다 낮은 가격을 제안받을 수 있습니다.',
                  size: 14,
                  textAlign: TextAlign.start,
                  fontWeight: null,
                  color: Colors.white),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: SizedBox(
          width: dw,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KTextWidget(
                  text: '독차란?',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
              KTextWidget(
                  text:
                      '용달을 이용하는 가장 일반적인 방법으로, 기사님이 하나의 화물을 운송하는 방법입니다. 원하시는 시간에 상, 하차가 가능하며 나의 환경에 맞춘 운송이 가능합니다.',
                  size: 14,
                  textAlign: TextAlign.start,
                  fontWeight: null,
                  color: Colors.grey),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _oneWay(double dw) {
  return Column(
    children: [
      const KTextWidget(
          text: '1건의 화물을 상차지 > 하차지로 독차 운송합니다.',
          size: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white),
      const SizedBox(height: 32),
      Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: SizedBox(
          width: dw,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KTextWidget(
                  text: '혼적이란?',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
              KTextWidget(
                  text:
                      '같은 방향으로 향하는 여러 운송을 처리하는 것을 말합니다. 화물 사이즈가 작거나 가벼운 화물에 적합하며, 일반적으로 독차보다 낮은 가격을 제안받을 수 있습니다.',
                  size: 14,
                  textAlign: TextAlign.start,
                  fontWeight: null,
                  color: Colors.grey),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: SizedBox(
          width: dw,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KTextWidget(
                  text: '독차란?',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              KTextWidget(
                  text:
                      '용달을 이용하는 가장 일반적인 방법으로, 기사님이 하나의 화물을 운송하는 방법입니다. 원하시는 시간에 상, 하차가 가능하며 나의 환경에 맞춘 운송이 가능합니다.',
                  size: 14,
                  textAlign: TextAlign.start,
                  fontWeight: null,
                  color: Colors.white),
            ],
          ),
        ),
      ),
    ],
  );
}
