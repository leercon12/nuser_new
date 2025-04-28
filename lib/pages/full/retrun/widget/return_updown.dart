import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/multi/widget/updown_sec.dart';
import 'package:flutter_mixcall_normaluser_new/pages/weather/helper.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/multimap.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class FullReturnUpDown extends StatefulWidget {
  final Map<String, dynamic> cargoData;
  const FullReturnUpDown({super.key, required this.cargoData});

  @override
  State<FullReturnUpDown> createState() => _FullReturnUpDownState();
}

class _FullReturnUpDownState extends State<FullReturnUpDown> {
  @override
  void initState() {
    super.initState();
    // addProvider.locations 사용 시
    //  final result = analyzeCargoData(addProvider.locations);

// 서버에서 받은 Map 형태 데이터 사용 시
    final serverResult = analyzeCargoData(widget.cargoData);

// 결과 사용
    upPoints = serverResult['상차지점리스트'];
    downPoints = serverResult['하차지점리스트'];
    print('상차지점 수: ${upPoints.length}');

    maxLoad = serverResult['최대적재정보'];
    print('최대 적재 무게: ${maxLoad['최대무게']}kg');
  }

  bool _isRoad = false;
  bool _isBlind = false;

  @override
  void didUpdateWidget(covariant FullReturnUpDown oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    updateBlindStatus();
  }

  void updateBlindStatus() {
    if (widget.cargoData['isBlind'] == true) {
      _isBlind = true;
    } else {
      _isBlind = false;
    }
  }

  var upPoints;
  var downPoints;

  var maxLoad;

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 8),
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
            const SizedBox(width: 8),
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
        _upLocations(),
      ],
    );
  }

  Widget _upLocations() {
    final dw = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        /*   HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FullMultiUpDownSecPage(
                    cargo: widget.cargoData,
                    callType: '왕복',
                  )),
        ); */
      },
      child: Container(
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
                      color: Colors.cyanAccent.withOpacity(0.1),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'asset/img/return_c.png',
                          width: 13,
                          height: 13,
                        ),
                        const SizedBox(width: 6),
                        const KTextWidget(
                          text: '왕복 정보',
                          size: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyanAccent,
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

            // 경로 정보

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
                  Column(
                    children: [
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
                                if (widget.cargoData['locations'][0]
                                        ['addressDis'] ==
                                    '')
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      KTextWidget(
                                        text: _isBlind == true
                                            ? addressEx2(_isRoad == true
                                                ? widget.cargoData['locations']
                                                    [0]['address2']
                                                : widget.cargoData['locations']
                                                    [0]['address1'])
                                            : _isRoad == true
                                                ? widget.cargoData['locations']
                                                    [0]['address2']
                                                : widget.cargoData['locations']
                                                    [0]['address1'],
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
                                      widget.cargoData['locations'][0]
                                          ['addressDis']),
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
                                          widget.cargoData['locations'][0]
                                              ['dateEnd'],
                                          widget.cargoData['locations'][0]
                                              ['dateAloneString'],
                                          widget.cargoData['locations'][0]
                                                  ['etc'] ??
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 18,
                              height: 18,
                              child: Image.asset('asset/img/down_cir.png')),
                        ],
                      ),
                      // 경유
                      Column(
                        children: [
                          //   const SizedBox(height: 12),
                          Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    child: Column(
                                      children: [
                                        Image.asset('asset/img/return_c.png',
                                            width: 13),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        KTextWidget(
                                          text: '경유(회차)지',
                                          size: 12,
                                          fontWeight: null,
                                          color: Colors.cyanAccent,
                                        ),
                                        if (widget.cargoData['locations'][1]
                                                ['addressDis'] ==
                                            '')
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              KTextWidget(
                                                text: _isBlind == true
                                                    ? addressEx2(_isRoad == true
                                                        ? widget.cargoData[
                                                                'locations'][1]
                                                            ['address2']
                                                        : widget.cargoData[
                                                                'locations'][1]
                                                            ['address1'])
                                                    : _isRoad == true
                                                        ? widget.cargoData[
                                                                'locations'][1]
                                                            ['address2']
                                                        : widget.cargoData[
                                                                'locations'][1]
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
                                                  ? widget.cargoData[
                                                          'locations'][1]
                                                      ['address2']
                                                  : widget.cargoData[
                                                          'locations'][1]
                                                      ['address1'],
                                              widget.cargoData['locations'][1]
                                                  ['addressDis']),
                                        Row(
                                          children: [
                                            dateStateTag(calculateDateStatus2(
                                                widget.cargoData['locations'][1]
                                                        ['date']
                                                    .toDate())),
                                            Flexible(
                                              child: timeState(
                                                  widget.cargoData['locations']
                                                      [1]['dateType'],
                                                  '상, 하차',
                                                  widget.cargoData['locations']
                                                      [1]['dateStart'],
                                                  widget.cargoData['locations']
                                                      [1]['dateEnd'],
                                                  widget.cargoData['locations']
                                                      [1]['dateAloneString'],
                                                  widget.cargoData['locations']
                                                          [1]['etc'] ??
                                                      ''),
                                            ),
                                            KTextWidget(
                                                text:
                                                    '(${widget.cargoData['locations'][1]['howTo']})',
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: Image.asset(
                                          'asset/img/down_cir.png')),
                                ],
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                  // 경유
                  Column(
                    children: [
                      //const SizedBox(height: 12),
                      Column(
                        children: [
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
                                    if (widget.cargoData['locations'][2]
                                            ['addressDis'] ==
                                        '')
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          KTextWidget(
                                            text: _isBlind == true
                                                ? addressEx2(_isRoad == true
                                                    ? widget.cargoData[
                                                            'locations'][2]
                                                        ['address2']
                                                    : widget.cargoData[
                                                            'locations'][2]
                                                        ['address1'])
                                                : _isRoad == true
                                                    ? widget.cargoData[
                                                            'locations'][2]
                                                        ['address2']
                                                    : widget.cargoData[
                                                            'locations'][2]
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
                                              ? widget.cargoData['locations'][2]
                                                  ['address2']
                                              : widget.cargoData['locations'][2]
                                                  ['address1'],
                                          widget.cargoData['locations'][2]
                                              ['addressDis']),
                                    Row(
                                      children: [
                                        dateStateTag(calculateDateStatus2(widget
                                            .cargoData['locations'][2]['date']
                                            .toDate())),
                                        Flexible(
                                          child: timeState(
                                              widget.cargoData['locations'][2]
                                                  ['dateType'],
                                              '하차',
                                              widget.cargoData['locations'][2]
                                                  ['dateStart'],
                                              widget.cargoData['locations'][2]
                                                  ['dateEnd'],
                                              widget.cargoData['locations'][2]
                                                  ['dateAloneString'],
                                              widget.cargoData['locations'][2]
                                                      ['etc'] ??
                                                  ''),
                                        ),
                                        KTextWidget(
                                            text:
                                                '(${widget.cargoData['locations'][2]['howTo']})',
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
                      )
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
                                                  callType: '왕복',
                                                )),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Icons
                                                .signal_wifi_statusbar_connected_no_internet_4,
                                            size: 16,
                                            color: Colors.cyanAccent),
                                        const SizedBox(width: 8),
                                        const KTextWidget(
                                          text: '상, 하차 상세 정보 보기',
                                          size: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.cyanAccent,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget adress(String ads, String dis) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 첫 번째 텍스트 내용
        final String address = _isBlind == true ? addressEx2(ads) : ads;

        // 텍스트 스타일
        final TextStyle textStyle = TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        );
        final TextStyle textStyle2 = TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        );
        // 첫 번째 텍스트가 한 줄에 표시될 수 있는지 확인
        final TextPainter textPainter = TextPainter(
          text: TextSpan(text: address, style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        // 실제 텍스트 높이와 한 줄 높이 비교
        final bool addressWrapped =
            textPainter.height > textPainter.preferredLineHeight;

        // 두 번째 텍스트
        final String secondText = _isBlind == true ? '배차 후, 상세정보가 표시됩니다.' : dis;

        // 텍스트가 줄바꿈되는 경우와 그렇지 않은 경우에 따라 다른 위젯 반환
        if (addressWrapped) {
          // 첫 번째 텍스트가 줄바꿈됨 - 두 텍스트를 하나의 RichText로 표시
          return RichText(
            text: TextSpan(
              children: [
                TextSpan(text: address, style: textStyle),
                TextSpan(text: ', ', style: textStyle), // 공백 추가
                TextSpan(text: secondText, style: textStyle2),
              ],
            ),
          );
        } else {
          // 첫 번째 텍스트가 한 줄에 표시됨 - 두 텍스트를 분리하여 표시
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address,
                style: textStyle,
              ),
              Text(
                secondText,
                style: textStyle2,
              ),
            ],
          );
        }
      },
    );
  }
}
