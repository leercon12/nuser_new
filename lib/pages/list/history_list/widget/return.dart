import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/full_main.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';

import 'package:provider/provider.dart';

class HistoryReturniWidget extends StatelessWidget {
  final Map<String, dynamic> cargoData;
  const HistoryReturniWidget({super.key, required this.cargoData});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FullMainPage(
                    cargo: cargoData,
                  )),
        );
      },
      child: Column(
        children: [
          Container(
              margin: const EdgeInsets.only(
                left: 5,
                right: 5,
              ),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12)),
                color: noState,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    //width: 67,
                    height: 37,
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: cargoData['cargoStat'] == null ||
                                  cargoData['cargoStat'] == '대기' ||
                                  cargoData['cargoStat'] == '배차'
                              ? Colors.grey
                              : cargoData['cargoStat'] == '취소'
                                  ? kRedColor
                                  : cargoData['cargoStat'] == '상차완료'
                                      ? kGreenFontColor
                                      : kBlueBssetColor,
                        )),
                    child: Center(
                      child: KTextWidget(
                        text: cargoData['cargoStat'] == null
                            ? '상차 대기'
                            : cargoData['cargoStat'],
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: cargoData['cargoStat'] == null ||
                                cargoData['cargoStat'] == '대기' ||
                                cargoData['cargoStat'] == '배차'
                            ? Colors.grey
                            : cargoData['cargoStat'] == '취소'
                                ? kRedColor
                                : cargoData['cargoStat'] == '하차완료' ||
                                        cargoData['cargoStat'] == '운송완료'
                                    ? kBlueBssetColor
                                    : kGreenFontColor,
                      ),
                    ),
                  ),
                  if (cargoData['payType'] == '인수증' ||
                      cargoData['normalEtax'] == true)
                    _eTaxState(),
                ],
              )),
          Container(
            margin: const EdgeInsets.only(
              bottom: 8,
              left: 5,
              right: 5,
            ),
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12)),
              color: msgBackColor,
            ),
            child: Column(
              children: [
                _topState(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _eTaxState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (cargoData['eTaxFailState'] == true)
          Container(
            height: 37,
            margin: const EdgeInsets.only(left: 8),
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                //color: kOrangeBssetColor.withOpacity(0.16),
                border: Border.all(color: kRedColor)),
            child: const Center(
              child: KTextWidget(
                text: '전자세금계산서(실패)',
                size: 14,
                fontWeight: FontWeight.bold,
                color: kRedColor,
              ),
            ),
          )
        else if (cargoData['eTaxNtsNum'] != null)
          Container(
            height: 37,
            margin: const EdgeInsets.only(left: 8),
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                //color: kOrangeBssetColor.withOpacity(0.16),
                border: Border.all(color: kOrangeBssetColor)),
            child: const Center(
              child: KTextWidget(
                text: '전자세금계산서',
                size: 14,
                fontWeight: FontWeight.bold,
                color: kOrangeBssetColor,
              ),
            ),
          )
        else
          Container(
            height: 37,
            margin: const EdgeInsets.only(left: 8),
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                //color: kOrangeBssetColor.withOpacity(0.16),
                border: Border.all(color: Colors.grey)),
            child: const Center(
              child: KTextWidget(
                text: '전자세금계산서',
                size: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          )
      ],
    );
  }

  Widget _topState() {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: noState.withOpacity(0.3)),
                  child: Center(
                    child: Image.asset('asset/img/return_c.png', width: 12),
                  )),
              const SizedBox(width: 5),
              const KTextWidget(
                  text: '왕복 운송',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
              const Spacer(),

              /* if (cargoData['state'] == '하차완료')
                Container(
                  padding:
                      EdgeInsets.only(right: 6, left: 6, top: 3, bottom: 3),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey)),
                  child: KTextWidget(
                      text: '운송 완료',
                      size: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ) */
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      KTextWidget(
                          text: '시작, ',
                          size: 12,
                          fontWeight: FontWeight.bold,
                          color: kBlueBssetColor),
                      KTextWidget(
                          text: '종료',
                          size: 12,
                          fontWeight: FontWeight.bold,
                          color: kRedColor),
                      SizedBox(width: 5),
                      Icon(
                        Icons.start,
                        color: kBlueBssetColor,
                        size: 15,
                      ),
                    ],
                  ),
                  KTextWidget(
                      text: cargoData['locations'][0]['address1'].toString(),
                      size: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ],
              )
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('asset/img/down_cir.png', width: 20),
              RotatedBox(
                  quarterTurns: 2,
                  child: Image.asset('asset/img/down_cir.png', width: 20)),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KTextWidget(
                      text: cargoData['locations'][1]['address1'].toString(),
                      size: 18,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.bold,
                      color: null),
                  const Row(
                    children: [
                      KTextWidget(
                          text: '회차지(경유지)',
                          size: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyanAccent),
                      SizedBox(width: 5),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: noState),
          Row(
            children: [
              const KTextWidget(
                  text: '등록 정보',
                  size: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
              const Spacer(),
              KTextWidget(
                  text: formatDateTime(cargoData['createdDate'].toDate()),
                  size: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ],
          ),
          if (cargoData['fixDate'] != null)
            Row(
              children: [
                const KTextWidget(
                    text: '배차 정보',
                    size: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
                const Spacer(),
                KTextWidget(
                    text: formatDateTime(cargoData['fixDate'].toDate()),
                    size: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ],
            ),
          const Divider(color: noState),
        ],
      ),
    );
  }
}
