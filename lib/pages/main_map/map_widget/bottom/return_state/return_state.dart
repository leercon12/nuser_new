import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/bottom.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/bottom_btn.dart';

import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/multi_state/multi_state.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/normal_state/short_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/return_state/return_sec.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class BottomReturnStateMain extends StatefulWidget {
  const BottomReturnStateMain({super.key});

  @override
  State<BottomReturnStateMain> createState() => _BottomReturnStateMainState();
}

class _BottomReturnStateMainState extends State<BottomReturnStateMain> {
  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    final dataProvider = Provider.of<DataProvider>(context);
    final cargo = dataProvider.currentCargo;
    return dataProvider.isUp == false
        ? Column(
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

  Widget _shortPage(
      double dw, Map<String, dynamic> cargo, DataProvider dataProvider) {
    num a = cargo['bidingUsers'].length + cargo['bidingCom'].length;

    final counts = countCargos(cargo);
    final totalDocNum = cargo['locations'].length;
    final totalUpCargos = counts['upCargos']; // 전체 상차 수
    final totalDownCargos = counts['downCargos']; // 전체 하차 수
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
                            : cargo['cargoStat'] == '하차완료'
                                ? Colors.grey.withOpacity(0.2)
                                : kBlueBssetColor),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    KTextWidget(
                        text: cargo['driverName'].toString(),
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: cargo['cargoStat'] == '하차완료'
                            ? Colors.grey
                            : Colors.white),
                    const SizedBox(width: 3),
                    if (cargo['cargoStat'] == '배차' ||
                        cargo['cargoStat'] == null)
                      const KTextWidget(
                          text: '기사님이 시작지로 이동중...',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)
                    else if (cargo['cargoStat'] == '상차완료')
                      const KTextWidget(
                          text: '기사님이 회차지로 가는중...',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)
                    else if (cargo['cargoStat'] == '회차완료')
                      const KTextWidget(
                          text: '기사님이 최종목적지로 가는중...',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)
                    else if (cargo['cargoStat'] == '하차완료')
                      const KTextWidget(
                          text: '기사님이 운송을 완료하였습니다.',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                  ],
                ),
              ),
        Row(
          children: [
            KTextWidget(
                text:
                    '${cargo['aloneType']}(${cargo['locations'].length}) 운송, ',
                size: 14,
                fontWeight: FontWeight.bold,
                color: kOrangeBssetColor),
            KTextWidget(
                text: '상차 ${totalUpCargos}건',
                size: 14,
                fontWeight: FontWeight.bold,
                color: kBlueBssetColor),
            const SizedBox(width: 5),
            KTextWidget(
                text: '하차 ${totalDownCargos}건',
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
            /*   const Icon(
              Icons.linear_scale_rounded,
              size: 15,
              color: kRedColor,
            ), */
            SizedBox(
              width: 15,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'asset/img/return_c.png',
                    width: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: dw - 137,
              child: KTextWidget(
                  text: cargo['locations'][1]['address1'],
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
        Expanded(
            child: BottomLargeReturn(
          cargo: dataProvider.currentCargo!,
        )),
        /*   Expanded(
            child: LargeUpDown(
                cargo: dataProvider.currentCargo!, dw: dw)), // Expan ded 제거  */

        BottomBtnState(
            dw: dw,
            cargo: dataProvider.currentCargo!,
            callType: dataProvider.currentCargo!['aloneType']),
        const SizedBox(height: 20),
      ],
    );
  }
}
