import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/full_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/inuse_list/list_widget/bottomState_multi.dart';
import 'package:flutter_mixcall_normaluser_new/pages/weather/helper.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class NewMultiListCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String? callType;
  const NewMultiListCard({super.key, required this.data, this.callType});

  @override
  State<NewMultiListCard> createState() => _NewMultiListCardState();
}

class _NewMultiListCardState extends State<NewMultiListCard> {
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    return InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          if (widget.callType == '지도') {
            dataProvider.setCurrentCargo(widget.data);
            Navigator.pop(context);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FullMainPage(
                        cargo: widget.data,
                        callType: '',
                      )),
            );
          }
        },
        child: _buildCard());
  }

  Widget _buildCard() {
    return Column(
      children: [
        // 상단 헤더부
        _buildHeader(),

        // 위치 정보
        _buildLocationInfo(),

        Container(
          color: msgBackColor,
          child: Column(
            children: [
              ListBottomMultiState(cargo: widget.data),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
        // 화물 및 차량 정보
        // _buildInfoSection(),

        // 가격 정보
        _buildPriceInfo(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: dialogColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
              width: 28,
              height: 28,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: msgBackColor,
              ),
              child: Image.asset(
                'asset/img/multi_cargo.png',
                width: 18,
              )),
          const SizedBox(width: 10),

          // 운송 유형

          KTextWidget(
            text: '다구간(${widget.data['multiNum']}) 운송',
            size: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),

          const Spacer(),

          Row(
            children: [
              Icon(Icons.route, size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              KTextWidget(
                text: '${widget.data['allDis']}',
                size: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ],
          ), // 도착지
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      color: msgBackColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 출발지
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('asset/img/up_navi.png', width: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KTextWidget(
                        text: '시작 상차지',
                        size: 12,
                        fontWeight: null,
                        color: kBlueBssetColor,
                      ),
                      KTextWidget(
                        text: widget.data['isBlind'] == true
                            ? addressEx2(
                                widget.data['locations'][0]['address1'])
                            : widget.data['locations'][0]['address1'],
                        size: 17,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      Row(
                        children: [
                          dateStateTag(calculateDateStatus2(
                              widget.data['locations'][0]['date'].toDate())),
                          Flexible(
                            child: timeState(
                                widget.data['locations'][0]['dateType'],
                                '상차',
                                widget.data['locations'][0]['dateStart'],
                                widget.data['locations'][0]['dateEnd'],
                                widget.data['locations'][0]['dateAloneString'],
                                widget.data['locations'][0]['etc'] ?? ''),
                          ),
                          KTextWidget(
                              text: '(${widget.data['locations'][0]['howTo']})',
                              size: 12,
                              fontWeight: null,
                              color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  child: Column(
                    children: [
                      Image.asset('asset/img/multi_cargo.png', width: 13),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                UnderLineWidget(
                  text: widget.data['locations'] == null
                      ? '다구간 ${widget.data['multiNum'] - 2} 개의 장소 경유'
                      : '다구간 ${widget.data['locations'].length - 2} 개의 장소 경유',
                  color: kGreenFontColor,
                  size: 14,
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('asset/img/down_navi.png', width: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KTextWidget(
                        text: '최종 하차지',
                        size: 12,
                        fontWeight: null,
                        color: kRedColor,
                      ),
                      KTextWidget(
                        text: widget.data['isBlind'] == true
                            ? addressEx2(
                                widget.data['locations'].last['address1'])
                            : widget.data['locations'].last['address1'],
                        size: 17,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      Row(
                        children: [
                          dateStateTag(calculateDateStatus2(
                              widget.data['locations'].last['date'].toDate())),
                          Flexible(
                            child: timeState(
                                widget.data['locations'].last['dateType'],
                                '하차',
                                widget.data['locations'].last['dateStart'],
                                widget.data['locations'].last['dateEnd'],
                                widget
                                    .data['locations'].last['dateAloneString'],
                                widget.data['locations'].last['etc'] ?? ''),
                          ),
                          KTextWidget(
                              text:
                                  '(${widget.data['locations'].last['howTo']})',
                              size: 12,
                              fontWeight: null,
                              color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    final dw = MediaQuery.of(context).size.width;
    return Container(
      width: dw,
      padding: const EdgeInsets.only(top: 6, left: 12, right: 12, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 화물 타입
              /*   Flexible(
                child: _buildInfoTag(
                ,
                  Colors.white70,
                  Colors.black26,
                ),
              ),
              const SizedBox(width: 6), */
              if (widget.data['totalUpcargos'] != null)
                Flexible(
                    child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      KTextWidget(
                        text: '다구간 ${widget.data['multiNum']} 장소, ',
                        size: 13,
                        fontWeight: FontWeight.bold,
                        color: kGreenFontColor,
                      ),
                      KTextWidget(
                        text: '상${widget.data['totalUpcargos']} ',
                        size: 13,
                        fontWeight: FontWeight.bold,
                        color: kBlueBssetColor,
                      ),
                      KTextWidget(
                        text: '하${widget.data['totalDowncargos']}',
                        size: 13,
                        fontWeight: FontWeight.bold,
                        color: kRedColor,
                      ),
                    ],
                  ),
                )),
              const SizedBox(width: 5),
              if (widget.data['totalCargoInfos'] != null)
                buildInfoTag(
                  '최대 적재 ${widget.data['totalCargoInfos']['최대무게']}톤, ${widget.data['totalCargoInfos']['최대개수']}개',
                  kOrangeBssetColor,
                  kOrangeBssetColor.withOpacity(0.2),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // 차량 타입
              buildInfoTag(
                widget.data['carType'],
                Colors.grey,
                Colors.black26,
              ),

              const SizedBox(width: 6),

              // 톤수 정보
              if (widget.data['carTon'].contains(999))
                buildInfoTag(
                  '중량 제한 없음',
                  kGreenFontColor,
                  kGreenFontColor.withOpacity(0.2),
                )
              else
                buildInfoTag(
                  '${widget.data['carTon'].toString().replaceAll(RegExp(r'[\[\]]'), '')}톤',
                  Colors.grey,
                  Colors.black26,
                ),

              // 옵션 정보 (있을 경우)
              if (widget.data['carOption'] != null &&
                  !widget.data['carOption'].contains('없음'))
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: buildInfoTag(
                    widget.data['carOption']
                        .toString()
                        .replaceAll(RegExp(r'[\[\]]'), ''),
                    kOrangeBssetColor,
                    kOrangeBssetColor.withOpacity(0.2),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dialogColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: widget.data['payMoney'] == null
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                KTextWidget(
                  text: widget.data['norPayType'] == '직접 결제'
                      ? widget.data['norPayHowto'][1].toString()
                      : widget.data['norPayType'],
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                const Spacer(),
                if (widget.data['isBiding'] == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: kBlueBssetColor.withOpacity(0.2),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.paid_outlined,
                          size: 14,
                          color: kBlueBssetColor,
                        ),
                        const SizedBox(width: 5),
                        const KTextWidget(
                          text: '운송료 제안',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: kBlueBssetColor,
                        ),
                      ],
                    ),
                  ),
              ],
            )
          : Row(
              children: [
                KTextWidget(
                  text: widget.data['payType'] == null
                      ? widget.data['norPayHowto'][1].toString()
                      : widget.data['payType'],
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: kGreenFontColor.withOpacity(0.2),
                  ),
                  child: KTextWidget(
                    text:
                        '운송료 ${formatCurrency(widget.data['payMoney'].toInt())}원',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: kGreenFontColor,
                  ),
                ),
              ],
            ),
    );
  }
}
