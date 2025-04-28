import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/bottom.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/bottom_btn.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/large_updown/multi_large.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/normal_state/short_main.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class BottomMultiMain extends StatefulWidget {
  const BottomMultiMain({super.key});

  @override
  State<BottomMultiMain> createState() => _BottomMultiMainState();
}

class _BottomMultiMainState extends State<BottomMultiMain> {
  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    final dataProvider = Provider.of<DataProvider>(context);
    final cargo = dataProvider.currentCargo;
    return dataProvider.isUp == false
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_drop_up_rounded,
                    color: kGreenFontColor,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              if (cargo != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cirDriver(dw * 0.18, cargo!),
                    const SizedBox(width: 10),
                    if (cargo != null)
                      isPassedDate(cargo['locations'][0]['date'].toDate()) &&
                              cargo['pickUserUid'] == null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                const KTextWidget(
                                    text: '상차일이 만료된 화물입니다.',
                                    size: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                const KTextWidget(
                                    text: '상차일이 만료된 화물입니다.',
                                    size: 14,
                                    fontWeight: null,
                                    color: Colors.grey),
                                SizedBox(
                                  width: dw - 118,
                                  child: const KTextWidget(
                                      text: '운송건을 삭제하거나, 변경하여 재등록하세요. ',
                                      size: 14,
                                      fontWeight: null,
                                      color: Colors.grey),
                                ),
                              ],
                            )
                          : _shortPage(dw, cargo, dataProvider)
                  ],
                )
              else
                SizedBox(
                  height: 110,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //  / const Spacer(),
                      const SizedBox(height: 19),
                      SizedBox(
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(
                          color: kGreenFontColor.withOpacity(0.5),
                        ),
                      ),
                      const Spacer(),
                      KTextWidget(
                          text: '운송 정보를 확인중입니다.',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.withOpacity(0.5)),
                      const Spacer(),
                    ],
                  ),
                ),
            ],
          )
        : Expanded(child: _largeState(dw, dataProvider));
  }

  int? number;
  Widget _shortPage(
      double dw, Map<String, dynamic> cargo, DataProvider dataProvider) {
    num a = cargo['bidingUsers'].length + cargo['bidingCom'].length;

    final counts = countCargos(cargo);
    final totalDocNum = cargo['locations'].length;
    final totalUpCargos = counts['upCargos']; // 전체 상차 수
    final totalDownCargos = counts['downCargos']; // 전체 하차 수
    final totalUp = counts['upLocations'];
    final totalDown = counts['downLocations'];
    if (cargo['cargoStat'] != null &&
        cargo['cargoStat'] != '배차' &&
        cargo['cargoStat'] != '운송완료' &&
        cargo['cargoStat'] != '대기') {
      String cargoStat = cargo['cargoStat'];
      String numberOnly = cargoStat.replaceAll(RegExp(r'[^0-9]'), '');
      number = int.parse(numberOnly);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        cargo['pickUserUid'] == null
            ? Row(
                children: [
                  if (a == 0)
                    Row(
                      children: [
                        const KTextWidget(
                            text: '기사 및 주선사가 제안 중...(00)',
                            size: 14,
                            fontWeight: null,
                            color: Colors.grey),
                        const SizedBox(width: 5),
                        SizedBox(
                          width: 11,
                          height: 11,
                          child: CircularProgressIndicator(
                            color: a == 0 ? Colors.grey : kOrangeBssetColor,
                            strokeWidth: 1,
                          ),
                        )
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          //border: Border.all(color: kOrangeBssetColor),
                          color: kOrangeBssetColor.withOpacity(0.3)),
                      child: Row(
                        children: [
                          KTextWidget(
                              text: a <= 9
                                  ? '운송료 제안 0${a}건이 도착헀습니다.'
                                  : '운송료 제안 ${a}건이 도착헀습니다.',
                              size: 14,
                              fontWeight: FontWeight.bold,
                              color: kOrangeBssetColor)
                        ],
                      ),
                    ),
                ],
              )
            : Container(
                padding: const EdgeInsets.only(left: 8, right: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    //border: Border.all(color: kOrangeBssetColor),
                    color:
                        cargo['cargoStat'] == '배차' || cargo['cargoStat'] == null
                            ? kGreenFontColor
                            : cargo['cargoStat'] == '운송완료'
                                ? Colors.grey.withOpacity(0.2)
                                : kBlueBssetColor.withOpacity(0.3)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    KTextWidget(
                        text: '${cargo['driverName']}',
                        size: 14,
                        fontWeight: FontWeight.bold,
                        color: cargo['cargoStat'] == '배차'
                            ? Colors.white
                            : cargo['cargoStat'] == '운송완료'
                                ? Colors.grey
                                : kBlueBssetColor),
                    const SizedBox(width: 3),
                    if (cargo['cargoStat'] == '배차' ||
                        cargo['cargoStat'] == null)
                      const KTextWidget(
                          text: '님이 첫번째 지역으로 이동중...',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)
                    else if (cargo['cargoStat'] == '운송완료')
                      const KTextWidget(
                          text: '기사님이 운송을 완료하였습니다.',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)
                    else
                      KTextWidget(
                          text: '${number}번 완료, ${number! + 1}번 이동중...',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: kBlueBssetColor)
                  ],
                ),
              ),
        Row(
          children: [
            KTextWidget(
                text:
                    '${cargo['transitType']}(${cargo['locations'].length}) 운송, ',
                size: 14,
                fontWeight: FontWeight.bold,
                color: kOrangeBssetColor),
            KTextWidget(
                text: '상차 ${totalUp}건',
                size: 14,
                fontWeight: FontWeight.bold,
                color: kBlueBssetColor),
            const SizedBox(width: 5),
            KTextWidget(
                text: '하차 ${totalDown}건',
                size: 14,
                fontWeight: FontWeight.bold,
                color: kRedColor)
          ],
        ),
        Row(
          children: [
            const Icon(
              Icons.start,
              size: 15,
              color: kBlueBssetColor,
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: dw - 137,
              child: KTextWidget(
                  text: cargo['locations'][0]['address1'],
                  size: 14,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: null,
                  color: Colors.grey),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(
              Icons.linear_scale_rounded,
              size: 15,
              color: kRedColor,
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: dw - 137,
              child: KTextWidget(
                  text: cargo['locations'][totalDocNum - 1]['address1'],
                  size: 14,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: null,
                  color: Colors.grey),
            ),
          ],
        ),
        /*   const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_left_rounded,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  KTextWidget(
                      text: '슬라이드하여 다른 운송 보기',
                      size: 14,
                      fontWeight: null,
                      color: Colors.grey.withOpacity(0.3)),
                  Icon(
                    Icons.arrow_right_rounded,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ],
              ) */
      ],
    );
  }

  Widget _largeState(double dw, DataProvider dataProvider) {
    return Column(
      mainAxisSize: MainAxisSize.min, // 추가
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /* Icon(
                Icons.arrow_drop_down_rounded,
                color: kGreenFontColor,
              ), */
            Container(
              width: 50,
              height: 3,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: kGreenFontColor),
            )
          ],
        ),
        const SizedBox(height: 18),
        Expanded(child: MultiUpDownLarge(cargo: dataProvider.currentCargo!)),
        /*   Expanded(
            child: LargeUpDown(
                cargo: dataProvider.currentCargo!, dw: dw)), // Expan ded 제거  */

        BottomBtnState(
            dw: dw,
            cargo: dataProvider.currentCargo!,
            callType: dataProvider.currentCargo!['transitType']),
        const SizedBox(height: 20),
      ],
    );
  }
}

Map<String, int> countCargos(Map<String, dynamic> data) {
  int upLocations = 0; // 상차 위치 개수
  int downLocations = 0; // 하차 위치 개수
  int totalUp = 0; // 상차 화물 개수
  int totalDown = 0; // 하차 화물 개수

  final locations = data['locations'] as List;

  for (var location in locations) {
    // 위치 타입 카운트
    if (location['type'] == '상차') {
      upLocations++;
    } else if (location['type'] == '하차') {
      downLocations++;
    }

    // 화물 개수 카운트
    totalUp += (location['upCargos'] as List?)?.length ?? 0;
    totalDown += (location['downCargos'] as List?)?.length ?? 0;
  }

  return {
    'upLocations': upLocations, // 상차 위치 수
    'downLocations': downLocations, // 하차 위치 수
    'upCargos': totalUp, // 상차 화물 수
    'downCargos': totalDown, // 하차 화물 수
    'total': totalUp + totalDown, // 전체 화물 수
  };
}
