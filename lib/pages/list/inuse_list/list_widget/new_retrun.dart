import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/full_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/list/inuse_list/list_widget/bottomState_return.dart';
import 'package:flutter_mixcall_normaluser_new/pages/weather/helper.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class NewRetrunListCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String? callType;
  const NewRetrunListCard({super.key, required this.data, this.callType});

  @override
  State<NewRetrunListCard> createState() => _NewRetrunListCardState();
}

class _NewRetrunListCardState extends State<NewRetrunListCard> {
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
      child: Column(
        children: [
          // 상단 헤더부
          _buildHeader(),

          // 위치 정보
          _buildLocationInfo(),

          // 화물 및 차량 정보
          //_buildCargoAndVehicleInfo(),
          Container(
            color: msgBackColor,
            child: Column(
              children: [
                ListBottomReturnState(cargo: widget.data),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
          /*   const SizedBox(
            height: 16,
          ), */
          // 가격 정보
          _buildPriceInfo(),
        ],
      ),
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
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: msgBackColor,
              ),
              child: SizedBox(
                width: 18,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'asset/img/return_c.png',
                      width: 13,
                    ),
                  ],
                ),
              )),
          const SizedBox(width: 10),

          // 운송 유형

          KTextWidget(
            text: '왕복 배송',
            size: 12,
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
                size: 12,
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
            //  const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('asset/img/up_navi.png', width: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          KTextWidget(
                            text: '시작 상차지 ',
                            size: 12,
                            fontWeight: null,
                            color: kBlueBssetColor,
                          ),
                          KTextWidget(
                            text:
                                '#${widget.data['locations'][0]['senderName']}',
                            size: 12,
                            fontWeight: null,
                            color: kBlueBssetColor,
                          ),
                        ],
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

            const SizedBox(height: 8),
            Center(child: Image.asset('asset/img/down_cir.png', width: 20)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: 22,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('asset/img/return_c.png', width: 16),
                      ],
                    )),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          KTextWidget(
                            text: '경유(회차)지 ',
                            size: 12,
                            fontWeight: null,
                            color: Colors.cyanAccent,
                          ),
                          KTextWidget(
                            text:
                                '#${widget.data['locations'][1]['senderName']}',
                            size: 12,
                            fontWeight: null,
                            color: Colors.cyanAccent,
                          ),
                        ],
                      ),
                      KTextWidget(
                        text: widget.data['isBlind'] == true
                            ? addressEx2(
                                widget.data['locations'][1]['address1'])
                            : widget.data['locations'][1]['address1'],
                        size: 17,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      Row(
                        children: [
                          dateStateTag(calculateDateStatus2(
                              widget.data['locations'][1]['date'].toDate())),
                          Flexible(
                            child: timeState(
                                widget.data['locations'][1]['dateType'],
                                '상차',
                                widget.data['locations'][1]['dateStart'],
                                widget.data['locations'][1]['dateEnd'],
                                widget.data['locations'][1]['dateAloneString'],
                                widget.data['locations'][1]['etc'] ?? ''),
                          ),
                          KTextWidget(
                              text: '(${widget.data['locations'][1]['howTo']})',
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
            Center(child: Image.asset('asset/img/down_cir.png', width: 20)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('asset/img/down_navi.png', width: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          KTextWidget(
                            text: '최종 하차지 ',
                            size: 12,
                            fontWeight: null,
                            color: kRedColor,
                          ),
                          KTextWidget(
                            text:
                                '#${widget.data['locations'][2]['senderName']}',
                            size: 12,
                            fontWeight: null,
                            color: kRedColor,
                          ),
                        ],
                      ),
                      KTextWidget(
                        text: widget.data['isBlind'] == true
                            ? addressEx2(
                                widget.data['locations'][2]['address1'])
                            : widget.data['locations'][2]['address1'],
                        size: 17,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      Row(
                        children: [
                          dateStateTag(calculateDateStatus2(
                              widget.data['locations'][2]['date'].toDate())),
                          Flexible(
                            child: timeState(
                                widget.data['locations'][2]['dateType'],
                                '상차',
                                widget.data['locations'][2]['dateStart'],
                                widget.data['locations'][2]['dateEnd'],
                                widget.data['locations'][2]['dateAloneString'],
                                widget.data['locations'][2]['etc'] ?? ''),
                          ),
                          KTextWidget(
                              text: '(${widget.data['locations'][2]['howTo']})',
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
          ],
        ),
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
                        KTextWidget(
                          text:
                              '운송료 제안중(${widget.data['bidingCom'].length + widget.data['bidingUsers'].length})',
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
                        '운송료 ${formatCurrency(widget.data['payMoney'].toInt())} 원',
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
