import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/bottom_history/bottom_driver_info.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/full_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/bottom.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/large_updown/la_updown.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/new_btm_large_state/normal_state/normal_main.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';

import 'package:provider/provider.dart';

class ListNormalCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String? callType;
  const ListNormalCard({super.key, required this.data, this.callType});

  @override
  State<ListNormalCard> createState() => _ListNormalCardState();
}

class _ListNormalCardState extends State<ListNormalCard> {
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    return dataProvider.cargoList.isEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info,
                color: Colors.grey.withOpacity(0.5),
                size: 60,
              ),
              const SizedBox(height: 12),
              KTextWidget(
                  text: '진행중인 운송이 없습니다.',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.withOpacity(0.5))
            ],
          )
        : Column(
            children: [
              //  _contents(dataProvider),

              //   _newContetns(dataProvider),
              _stateList(),
              _bottomState(),
            ],
          );
  }

  Widget _stateList() {
    final dw = MediaQuery.of(context).size.width;
    return BottomLargeNormal(
      cargo: widget.data,
      dw: dw,
      callType: widget.callType,
    );
  }

  Widget _newContetns(DataProvider dataProvider) {
    final dw = MediaQuery.of(context).size.width;
    num all =
        widget.data['bidingUsers'].length + widget.data['bidingCom'].length;
    return Container(
      width: dw,
      margin: const EdgeInsets.only(left: 8, right: 8),
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          color: msgBackColor),
      child: Column(
        children: [
          SizedBox(
            width: dw,
            child: Row(
              children: [
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: noState.withOpacity(0.3)),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 5, // 상단 여백
                        left: 9, // 좌우 중앙 정렬을 위한 값
                        child: Image.asset(
                          'asset/img/cargo_up.png',
                          width: 8,
                        ),
                      ),
                      Positioned(
                        bottom: 5, // 하단 여백
                        left: 9, // 좌우 중앙 정렬을 위한 값
                        child: Image.asset(
                          'asset/img/cargo_down.png',
                          width: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                if (widget.data['transitType'] == '무관')
                  const KTextWidget(
                      text: '독차, 혼적(일반)',
                      size: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)
                else
                  KTextWidget(
                      text: '${widget.data['transitType']}(일반)',
                      size: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                const Spacer(),
                /* KTextWidget(
                    text: '${widget.data['allDis']}',
                    size: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey) */
                /* if (widget.data['cargoStat'] == '대기')
                  const KTextWidget(
                      text: '제안중...',
                      size: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey) */
              ],
            ),
          ),
          //  const SizedBox(height: 8),
          /*  if (all != 0)
            GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return StatefulBuilder(builder: (context, setState) {
                        return BottomDriverInfoPage(
                          pickUserUid: widget.data['pickUserUid'],
                          isReview: true,
                          cargo: widget.data,
                        );
                      });
                    },
                  );
                },
                child: cirDriver(80, widget.data))
          else
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FullMainPage(
                            cargo: widget.data,
                            callType: '보고',
                          )),
                );
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100), color: noState),
                child: Stack(
                  children: [
                    Positioned.fill(
                        child: Container(
                      color: msgBackColor.withOpacity(0.7),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 18,
                          ),
                          KTextWidget(
                              text: all.toString(),
                              size: 50,
                              lineHeight: 0,
                              fontWeight: FontWeight.bold,
                              color: kOrangeBssetColor),
                        ],
                      ),
                    )),
                    const Positioned(
                      top: 8,
                      right: 27,
                      child: KTextWidget(
                          text: '제안',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          lineHeight: 0,
                          color: kOrangeBssetColor),
                    )
                  ],
                ),
              ),
            ), */
          //   const SizedBox(height: 8),
          /*   Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: widget.data['cargoStat'] == '대기'
                            ? kOrangeBssetColor
                            : kGreenFontColor)),
                child: KTextWidget(
                    text: '운송료 제안받는 중...',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: kOrangeBssetColor),
              ),
            ],
          ), */
          const SizedBox(height: 12),
          SizedBox(
            width: dw,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const KTextWidget(
                    text: '시작',
                    size: 13,
                    fontWeight: FontWeight.bold,
                    color: kBlueBssetColor),
                const SizedBox(width: 5),
                const Icon(
                  Icons.start,
                  color: kBlueBssetColor,
                  size: 16,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Column(
                    children: [
                      KTextWidget(
                          text: addressEx2(widget.data['upAddress']),
                          overflow: TextOverflow.ellipsis,
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      /*   if (widget.data['upAddressDis'] != '')
                        KTextWidget(
                            text: widget.data['upAddressDis'],
                            overflow: TextOverflow.ellipsis,
                            size: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey), */
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            width: dw,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const KTextWidget(
                    text: ' 종료',
                    size: 13,
                    fontWeight: FontWeight.bold,
                    color: kRedColor),
                const SizedBox(width: 5),
                const Icon(
                  Icons.linear_scale_rounded,
                  color: kRedColor,
                  size: 16,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Column(
                    children: [
                      KTextWidget(
                          text: addressEx2(widget.data['downAddress']),
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      /*    if (widget.data['downAddressDis'] != '')
                        KTextWidget(
                            text: widget.data['downAddressDis'],
                            overflow: TextOverflow.ellipsis,
                            size: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey), */
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: dw,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dateState(
                    calculateDateStatus(
                        widget.data['upTime'].toDate(), DateTime.now()),
                    ''),
                const KTextWidget(
                    text: ' 시작, ',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
                _dateState(
                    calculateDateStatus(
                        widget.data['downTime'].toDate(), DateTime.now()),
                    ''),
                const KTextWidget(
                    text: ' 종료',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)
              ],
            ),
          ),
          SizedBox(
            width: dw,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    KTextWidget(
                        text: '${widget.data['carType']} / ',
                        textAlign: TextAlign.center,
                        size: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    //if (widget.data['carTon'].contains(authProvider.userDriver!.carTon))
                    KTextWidget(
                        text: widget.data['carTon'].contains(999)
                            ? ' 중량 제한 없음'
                            : '${widget.data['carTon'].toString().replaceAll(RegExp(r'[\[\]]'), '')}톤 차량',
                        size: 14,
                        fontWeight: FontWeight.bold,
                        color: kOrangeBssetColor),
                  ],
                )
              ],
            ),
          ),
          if (widget.data['carOption'].contains('없음') == false)
            SizedBox(
              width: dw,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  KTextWidget(
                      text:
                          '${widget.data['carOption'].toString().replaceAll(RegExp(r'[\[\]]'), '')}',
                      textAlign: TextAlign.center,
                      size: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _bottomState() {
    final dw = MediaQuery.of(context).size.width;
    return Container(
      width: dw,
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12)),
          color: noState),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              widget.data['comUid'] == null
                  ? KTextWidget(
                      text: '${widget.data['norPayHowto'][1]}',
                      size: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)
                  : KTextWidget(
                      text: '${widget.data['payType']}',
                      size: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
              const Spacer(),
              widget.data['pickUserUid'] == null
                  ? const KTextWidget(
                      text: '운송료 제안중',
                      size: 14,
                      fontWeight: FontWeight.bold,
                      color: kOrangeBssetColor)
                  : KTextWidget(
                      text: '${formatCurrency(widget.data['payMoney'])} 원',
                      size: 14,
                      fontWeight: FontWeight.bold,
                      color: kGreenFontColor),
              const SizedBox(width: 5),
              Icon(
                Icons.double_arrow_rounded,
                color: widget.data['pickUserUid'] == null
                    ? kOrangeBssetColor
                    : kGreenFontColor,
                size: 16,
              )
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _dateState(String state, String callType) {
    if (state == 'today') {
      return const KTextWidget(
          text: '오늘',
          size: 14,
          fontWeight: FontWeight.bold,
          color: kGreenFontColor);
    }
    if (state == 'tmm') {
      return const KTextWidget(
          text: '내일',
          size: 14,
          fontWeight: FontWeight.bold,
          color: kBlueBssetColor);
    }
    if (state == 'ex') {
      return const KTextWidget(
          text: '만료', size: 14, fontWeight: FontWeight.bold, color: kRedColor);
    }
    if (state == 'book') {
      return const KTextWidget(
          text: '예3',
          size: 14,
          fontWeight: FontWeight.bold,
          color: kOrangeBssetColor);
    }
    return const SizedBox.shrink(); // 기본 반환값
  }

  Widget _timeState(String type, String updown, Timestamp? start,
      Timestamp? end, String? aloneType) {
    return Stack(
      children: [
        if (type == '미정')
          KTextWidget(
              text: '${updown}시간 미정',
              size: 13,
              textAlign: TextAlign.end,
              fontWeight: null,
              overflow: TextOverflow.ellipsis,
              color: Colors.grey),
        if (type == '도착시 상차' || type == '도착시 하차')
          KTextWidget(
              text: '도착하면 ${updown}',
              size: 13,
              textAlign: TextAlign.end,
              fontWeight: null,
              overflow: TextOverflow.ellipsis,
              color: Colors.grey),
        if (type.contains('전화로'))
          KTextWidget(
              text: '${updown}지와 전화로 확인 필요',
              size: 13,
              textAlign: TextAlign.end,
              fontWeight: null,
              overflow: TextOverflow.ellipsis,
              color: Colors.grey),
        if (type == '시간 선택')
          KTextWidget(
              text:
                  '${fase3String(start!.toDate() as DateTime)} ${formatDateTime(start!.toDate())} ${aloneType} ${updown}',
              size: 13,
              textAlign: TextAlign.end,
              fontWeight: null,
              overflow: TextOverflow.ellipsis,
              color: Colors.grey),
        if (type == '시간대 선택')
          KTextWidget(
              text:
                  '${fase3String(start!.toDate() as DateTime)} ${formatDateTime(start!.toDate())} ~ ${fase3String(end!.toDate() as DateTime)} ${formatDateTime(end!.toDate())} 까지 ${updown}',
              size: 13,
              textAlign: TextAlign.end,
              fontWeight: null,
              overflow: TextOverflow.ellipsis,
              color: Colors.grey),
        if (type.contains('기타') == true)
          SizedBox(
            width: 280,
            child: KTextWidget(
                text: updown == '상차'
                    ? widget.data['upTimeEtc']
                    : widget.data['downTimeEtc'],
                size: 14,
                textAlign: TextAlign.end,
                fontWeight: null,
                overflow: TextOverflow.ellipsis,
                color: kOrangeBssetColor),
          ),
      ],
    );
  }
}
