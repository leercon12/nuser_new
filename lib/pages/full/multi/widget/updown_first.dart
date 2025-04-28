import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/multi/widget/updown_sec.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/return_state/updown/return_updown.dart';
import 'package:flutter_mixcall_normaluser_new/pages/weather/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/multimap.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';

class FullUpDownFirstPage extends StatefulWidget {
  final String? callType;
  final Map<String, dynamic> cargoData;
  const FullUpDownFirstPage(
      {super.key, required this.callType, required this.cargoData});

  @override
  State<FullUpDownFirstPage> createState() => _FullUpDownFirstPageState();
}

class _FullUpDownFirstPageState extends State<FullUpDownFirstPage> {
  bool _isRoad = false;
  bool _isBlind = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateBlindStatus();
  }

  void updateBlindStatus() {
    if (widget.cargoData['isBlind'] == true) {
      _isBlind = true;
    } else {
      _isBlind = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: dw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              KTextWidget(
                  text: '상-하차 정보',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: null),
              const Expanded(child: SizedBox()),
              if (_isBlind == false)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (_isRoad == false) {
                      _isRoad = true;
                      setState(() {});
                    } else {
                      _isRoad = false;
                      setState(() {});
                    }
                  },
                  child: KTextWidget(
                      text: '도로명 주소',
                      size: 13,
                      fontWeight: null,
                      color: _isRoad == true ? kOrangeBssetColor : null),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.grey.withOpacity(0.16), width: 1.5),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.withOpacity(0.06),
              boxShadow: [],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey.withOpacity(0.5),
                  size: 15,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: KTextWidget(
                    text: "'상, 하차 상세 정보 보기'로 상세 위치 정보를 확인하세요.",
                    size: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _upLoactions(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _upLoactions() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: dialogColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: kGreenFontColor.withOpacity(0.1),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'asset/img/multi_cargo.png',
                        width: 13,
                        height: 13,
                      ),
                      const SizedBox(width: 6),
                      KTextWidget(
                        text: '다구간(${widget.cargoData['multiNum']}) 운송',
                        size: 13,
                        fontWeight: FontWeight.bold,
                        color: kGreenFontColor,
                      ),
                    ],
                  ),
                ),
                const Expanded(child: SizedBox()),
                //  _dateState(dateStatus.toString()),
                KTextWidget(
                  text: formatTimestamp99(widget.cargoData['upTime']),
                  size: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            decoration: BoxDecoration(
              color: msgBackColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('asset/img/up_navi.png', width: 18),
                    const SizedBox(width: 5),
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
                          if (widget.cargoData['locations'][0]['addressDis'] ==
                              '')
                            Column(
                              children: [
                                KTextWidget(
                                  text: _isBlind == true
                                      ? addressEx2(_isRoad == true
                                          ? widget.cargoData['locations'][0]
                                              ['address2']
                                          : widget.cargoData['locations'][0]
                                              ['address1'])
                                      : _isRoad == true
                                          ? widget.cargoData['locations'][0]
                                              ['address2']
                                          : widget.cargoData['locations'][0]
                                              ['address1'],
                                  size: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                if (_isBlind == true)
                                  KTextWidget(
                                    text: '배차 후, 상세정보가 표시됩니다.',
                                    size: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                              ],
                            )
                          else
                            adress(
                                _isRoad == true
                                    ? widget.cargoData['locations'][0]
                                        ['address2']
                                    : widget.cargoData['locations'][0]
                                        ['address1'],
                                widget.cargoData['locations'][0]['addressDis'],
                                _isBlind),
                          Row(
                            children: [
                              dateStateTag(calculateDateStatus2(widget
                                  .cargoData['locations'][0]['date']
                                  .toDate())),
                              Flexible(
                                child: timeState(
                                    widget.cargoData['locations'][0]
                                        ['dateType'],
                                    '상차',
                                    widget.cargoData['locations'][0]
                                        ['dateStart'],
                                    widget.cargoData['locations'][0]['dateEnd'],
                                    widget.cargoData['locations'][0]
                                        ['dateAloneString'],
                                    widget.cargoData['locations'][0]['etc'] ??
                                        ''),
                              ),
                              KTextWidget(
                                  text:
                                      '(${widget.cargoData['locations'][0]['howTo']})',
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 18,
                      child: Column(
                        children: [
                          Image.asset('asset/img/multi_cargo.png', width: 16),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    UnderLineWidget(
                      text:
                          '다구간 ${widget.cargoData['locations'].length - 2} 개의 장소 경유',
                      color: kGreenFontColor,
                      size: 14,
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('asset/img/down_navi.png', width: 18),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          KTextWidget(
                            text: '종료 하차지',
                            size: 12,
                            fontWeight: null,
                            color: kRedColor,
                          ),
                          if (widget
                                  .cargoData['locations'].last['addressDis'] ==
                              '')
                            Column(
                              children: [
                                KTextWidget(
                                  text: _isBlind == true
                                      ? addressEx2(_isRoad == true
                                          ? widget.cargoData['locations']
                                              .last['address2']
                                          : widget.cargoData['locations']
                                              .last['address1'])
                                      : _isRoad == true
                                          ? widget.cargoData['locations']
                                              .last['address2']
                                          : widget.cargoData['locations']
                                              .last['address1'],
                                  size: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                if (_isBlind == true)
                                  KTextWidget(
                                    text: '배차 후, 상세정보가 표시됩니다.',
                                    size: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                              ],
                            )
                          else
                            adress(
                                _isRoad == true
                                    ? widget
                                        .cargoData['locations'].last['address2']
                                    : widget.cargoData['locations']
                                        .last['address1'],
                                widget
                                    .cargoData['locations'].last['addressDis'],
                                _isBlind),
                          Row(
                            children: [
                              dateStateTag(calculateDateStatus2(widget
                                  .cargoData['locations'].last['date']
                                  .toDate())),
                              Flexible(
                                child: timeState(
                                    widget.cargoData['locations']
                                        .last['dateType'],
                                    '하차',
                                    widget.cargoData['locations']
                                        .last['dateStart'],
                                    widget
                                        .cargoData['locations'].last['dateEnd'],
                                    widget.cargoData['locations']
                                        .last['dateAloneString'],
                                    widget.cargoData['locations'].last['etc'] ??
                                        ''),
                              ),
                              KTextWidget(
                                  text:
                                      '(${widget.cargoData['locations'].last['howTo']})',
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
                // 구분선
                Padding(
                  padding: const EdgeInsets.only(right: 8, left: 8),
                  child: Divider(
                    thickness: 2,
                    color: dialogColor,
                  ),
                ),
                buildMinimalInfoRow(
                    icon: Icons.location_searching,
                    title: '다구간 장소',
                    value: '총 ${widget.cargoData['multiNum']}개 장소'),
                buildMinimalInfoRow(
                    icon: Icons.unfold_less,
                    title: '상, 하차 횟수',
                    value:
                        '상차 ${widget.cargoData['totalUpcargos']}건, 하차${widget.cargoData['totalDowncargos']}건'),
                buildMinimalInfoRow(
                    icon: Icons.route,
                    title: '주행 거리',
                    value:
                        '${widget.cargoData['allDis']}, ${widget.cargoData['allDur']}'),
                buildMinimalInfoRow(
                    icon: Icons.library_add,
                    title: '최대 적재',
                    valueColor: kOrangeBssetColor,
                    value:
                        '${widget.cargoData['totalCargoInfos']['최대무게']}톤, ${widget.cargoData['totalCargoInfos']['최대개수']}개'),

                Padding(
                  padding: const EdgeInsets.only(right: 8, left: 8),
                  child: Divider(
                    thickness: 2,
                    color: dialogColor,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: dialogColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            // 액션 처리
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FullMultiUpDownSecPage(
                                                cargo: widget.cargoData,
                                                callType: '다구간',
                                              )),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(
                                          Icons
                                              .signal_wifi_statusbar_connected_no_internet_4,
                                          size: 16,
                                          color: kGreenFontColor),
                                      const SizedBox(width: 8),
                                      const KTextWidget(
                                        text: '상, 하차 상세 정보 보기',
                                        size: 14,
                                        fontWeight: FontWeight.bold,
                                        color: kGreenFontColor,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const KTextWidget(
                                  text: '|',
                                  size: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                InkWell(
                                  onTap: () async {
                                    HapticFeedback.lightImpact();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CargoMapPage(
                                                cargo: widget.cargoData,
                                              )),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on_sharp,
                                          size: 16, color: Colors.white),
                                      const SizedBox(width: 8),
                                      const KTextWidget(
                                        text: '지도 보기',
                                        size: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
