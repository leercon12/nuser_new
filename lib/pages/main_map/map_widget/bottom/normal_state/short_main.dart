import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/inuse_list/inuse_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/bottom.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/bottom_btn.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/large_updown/la_updown.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/future_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class BottomNormalMain extends StatefulWidget {
  const BottomNormalMain({super.key});

  @override
  State<BottomNormalMain> createState() => _BottomNormalMainState();
}

class _BottomNormalMainState extends State<BottomNormalMain> {
  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();
    final dw = MediaQuery.of(context).size.width;
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
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cirDriver(dw * 0.18, cargo!),
                    const SizedBox(width: 10),
                    isPassedDate(cargo['upTime'].toDate()) &&
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
                        : _shortNoPick(dw, cargo)
                  ],
                ),
              const SizedBox(height: 8),
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
              )
            ],
          )
        : Expanded(
            child: _largeState(
              dataProvider,
              dw,
            ),
          );
  }

  Widget _shortNoPick(double dw, Map<String, dynamic> cargo) {
    num a = cargo['bidingUsers'].length + cargo['bidingCom'].length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        cargo['pickUserUid'] == null
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  /*   if (a == 0)
                    const KTextWidget(
                        text: '(00)',
                        size: 14,
                        fontWeight: null,
                        color: Colors.grey)
                  else
                    KTextWidget(
                        text: cargo['bidingUsers'].length < 10
                            ? ' 0${a}'
                            : ' (${a})',
                        size: 14,
                        fontWeight: null,
                        color: kOrangeBssetColor), */
                ],
              )
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        //border: Border.all(color: kOrangeBssetColor),
                        color: cargo['cargoStat'] == '배차' ||
                                cargo['cargoStat'] == null
                            ? kBlueBssetColor
                            : cargo['cargoStat'] == '상차완료'
                                ? kBlueBssetColor
                                : Colors.grey.withOpacity(0.2)),
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
                              text: '기사님이 상차지로 이동중...',
                              size: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)
                        else if (cargo['cargoStat'] == '상차완료')
                          const KTextWidget(
                              text: '기사님이 하차지로 가는중...',
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
                  const SizedBox(height: 5),
                ],
              ),
        Row(
          children: [
            Image.asset(
              'asset/img/cargo_up.png',
              width: 13,
              height: 13,
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: dw - 135,
              child: KTextWidget(
                  text: cargo['upAddress'],
                  size: 14,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: null,
                  color: Colors.grey),
            ),
          ],
        ),
        Row(
          children: [
            Image.asset(
              'asset/img/cargo_down.png',
              width: 13,
              height: 13,
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: dw - 135,
              child: KTextWidget(
                  text: cargo['downAddress'],
                  size: 14,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: null,
                  color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _largeState(
    DataProvider dataProvider,
    double dw,
  ) {
    if (dataProvider.currentCargo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      child: Column(
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
              child: LargeUpDown(
                  cargo: dataProvider.currentCargo!, dw: dw)), // Expanded 제거

          BottomBtnState(
              dw: dw,
              cargo: dataProvider.currentCargo!,
              callType: dataProvider.currentCargo!['transitType']),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
