import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/model/multi_cargo_add_model.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/multi_cargo_set.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/updown/updown_cargo_add/set/updown_set_page.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/updown/updown_set.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/return_state/updown/return_ud_set.dart';
import 'package:flutter_mixcall_normaluser_new/pages/weather/helper.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/future_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/multimap.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class AddReturnUpDown extends StatefulWidget {
  final String? callType;
  final Map<String, dynamic>? cargo;
  const AddReturnUpDown({super.key, this.callType, this.cargo});

  @override
  State<AddReturnUpDown> createState() => _AddReturnUpDownState();
}

class _AddReturnUpDownState extends State<AddReturnUpDown> {
  @override
  void initState() {
    super.initState();
    //  final addProvider = Provider.of<AddProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddProvider>().checkAndUpdateRoute();
    });
    /*  if (addProvider.addMainType == '다구간') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AddProvider>().checkAndUpdateRoute();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AddProvider>().checkAndUpdateSimpleRoute();
      });
    } */
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final addProvider = Provider.of<AddProvider>(context);

    if (addProvider.locationCount == 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AddProvider>().checkAndUpdateRoute();
        print('지도 api호출');
      });
    }
  }

  bool _isRoad = false;
  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    bool isState = addProvider.locations.length == 3 &&
        addProvider.locations[1].address1 != null;
    final result = getAllUpCargos(addProvider);
    int unfinishedCount = result.$2;
    final dw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: dw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              KTextWidget(
                  text: '상, 하차지 등록',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: isState == true
                      ? Colors.grey.withOpacity(0.5)
                      : Colors.white),
              const Spacer(),
              if (unfinishedCount > 0)
                GestureDetector(
                  onTap: () {
                    print(addProvider.locations.length);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.info, color: kRedColor, size: 13),
                      const SizedBox(width: 2),
                      KTextWidget(
                          text: '미 하차 화물 $unfinishedCount 건이 있습니다.',
                          size: 13,
                          fontWeight: FontWeight.bold,
                          color: kRedColor)
                    ],
                  ),
                )
              else
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
          isState == false
              ? const KTextWidget(
                  text: '운송 화물의 상차 > 회차 > 하차 정보를 등록하세요.',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey)
              : const SizedBox(),
          const SizedBox(height: 12),
          _intoBox(addProvider),
          //_setState(addProvider, dw)
        ],
      ),
    );
  }

  Widget _intoBox(AddProvider addProvider) {
    bool isE = addProvider.locations.length == 3 &&
        addProvider.locations[1].address1 != null;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddReturnUpDownPage(
                  callType: widget.callType == null
                      ? '왕복'
                      : widget.callType.toString())),
        );
      },
      child: !isE
          ? Container(
              padding:
                  !isE ? const EdgeInsets.all(16) : const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), color: msgBackColor),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('asset/img/return_c.png', width: 12),
                      const SizedBox(width: 10),
                      const KTextWidget(
                          text: '이곳을 클릭히여 왕복 상, 하차지를 등록하세요.',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)
                    ],
                  )
                ],
              ))
          : _multiNotNullBox(addProvider, context),
    );
  }

  Widget _multiNotNullBox(AddProvider addProvider, context) {
    final result = analyzeCargoData(addProvider.locations);
    var upPoints = result['상차화물수'];
    var downPoints = result['하차화물수'];
    var maxLoad = result['최대적재정보'];
    final dw = MediaQuery.of(context).size.width;
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
                  text: '...',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //const SizedBox(height: 12),
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
                          if (addProvider.locations[0].addressDis == '')
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                KTextWidget(
                                  text: addProvider.setIsBlind == true
                                      ? addressEx2(_isRoad == true
                                          ? addProvider.locations[0].address2
                                              .toString()
                                          : addProvider.locations[0].address1
                                              .toString())
                                      : _isRoad == true
                                          ? addProvider.locations[0].address2
                                              .toString()
                                          : addProvider.locations[0].address1
                                              .toString(),
                                  size: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                if (addProvider.setIsBlind == true)
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
                                    ? addProvider.locations[0].address2
                                        .toString()
                                    : addProvider.locations[0].address1
                                        .toString(),
                                addProvider.locations[0].addressDis.toString(),
                                addProvider.setIsBlind!),
                          Row(
                            children: [
                              dateStateTag(calculateDateStatus2(
                                  addProvider.locations[0].date!)),
                              Flexible(
                                child: timeState(
                                    addProvider.locations[0].dateType
                                        .toString(),
                                    '상차',
                                    addProvider.locations[0].dateStart,
                                    addProvider.locations[0].dateEnd,
                                    addProvider.locations[0].dateAloneString,
                                    addProvider.locations[0].etc.toString()),
                              ),
                              KTextWidget(
                                  text: '(${addProvider.locations[0].howTo})',
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
                //  const SizedBox(height: 12),
                Column(
                  children: [
                    // /const SizedBox(height: 12),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  KTextWidget(
                                    text: '경유(회차)지',
                                    size: 12,
                                    fontWeight: null,
                                    color: Colors.cyanAccent,
                                  ),
                                  if (addProvider.locations[1].addressDis == '')
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        KTextWidget(
                                          text: addProvider.setIsBlind == true
                                              ? addressEx2(_isRoad == true
                                                  ? addProvider
                                                      .locations[1].address2
                                                      .toString()
                                                  : addProvider
                                                      .locations[1].address1
                                                      .toString())
                                              : _isRoad == true
                                                  ? addProvider
                                                      .locations[1].address2
                                                      .toString()
                                                  : addProvider
                                                      .locations[1].address2
                                                      .toString(),
                                          size: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        if (addProvider.setIsBlind == true)
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
                                            ? addProvider.locations[1].address2
                                                .toString()
                                            : addProvider.locations[1].address1
                                                .toString(),
                                        addProvider.locations[1].addressDis
                                            .toString(),
                                        addProvider.setIsBlind!),
                                  Row(
                                    children: [
                                      dateStateTag(calculateDateStatus2(
                                          addProvider.locations[1].date!)),
                                      Flexible(
                                        child: timeState(
                                            addProvider.locations[1].dateType
                                                .toString(),
                                            '상, 하차',
                                            addProvider.locations[1].dateStart,
                                            addProvider.locations[1].dateEnd,
                                            addProvider
                                                .locations[1].dateAloneString,
                                            addProvider.locations[1].etc
                                                .toString()),
                                      ),
                                      KTextWidget(
                                          text:
                                              '(${addProvider.locations[1].howTo})',
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
                        Column(
                          children: [
                            //const SizedBox(height: 12),
                            Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset('asset/img/down_navi.png',
                                        width: 18),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          KTextWidget(
                                            text: '종료 하차지',
                                            size: 12,
                                            fontWeight: null,
                                            color: kRedColor,
                                          ),
                                          if (addProvider
                                                  .locations[2].addressDis ==
                                              '')
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                KTextWidget(
                                                  text: addProvider
                                                              .setIsBlind ==
                                                          true
                                                      ? addressEx2(
                                                          _isRoad == true
                                                              ? addProvider
                                                                  .locations[2]
                                                                  .address2
                                                                  .toString()
                                                              : addProvider
                                                                  .locations[2]
                                                                  .address1
                                                                  .toString())
                                                      : _isRoad == true
                                                          ? addProvider
                                                              .locations[2]
                                                              .address2
                                                              .toString()
                                                          : addProvider
                                                              .locations[2]
                                                              .address1
                                                              .toString(),
                                                  size: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                if (addProvider.setIsBlind ==
                                                    true)
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
                                                    ? addProvider
                                                        .locations[2].address2
                                                        .toString()
                                                    : addProvider
                                                        .locations[2].address1
                                                        .toString(),
                                                addProvider
                                                    .locations[2].addressDis
                                                    .toString(),
                                                addProvider.setIsBlind!),
                                          Row(
                                            children: [
                                              dateStateTag(calculateDateStatus2(
                                                  addProvider
                                                      .locations[2].date!)),
                                              Flexible(
                                                child: timeState(
                                                    addProvider
                                                        .locations[2].dateType
                                                        .toString(),
                                                    '하차',
                                                    addProvider
                                                        .locations[2].dateStart,
                                                    addProvider
                                                        .locations[2].dateEnd,
                                                    addProvider.locations[2]
                                                        .dateAloneString,
                                                    addProvider.locations[2].etc
                                                        .toString()),
                                              ),
                                              KTextWidget(
                                                  text:
                                                      '(${addProvider.locations[2].howTo})',
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
                    value: '상차 ${upPoints}건, 하차${downPoints}건'),
                buildMinimalInfoRow(
                    icon: Icons.route,
                    title: '주행 거리',
                    value: '${addProvider.totalDistance}, ...'),
                buildMinimalInfoRow(
                    icon: Icons.library_add,
                    title: '최대 적재',
                    valueColor: kOrangeBssetColor,
                    value: '${maxLoad['최대무게']}톤, ${maxLoad['최대개수']}개'),
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
                                              const AddReturnUpDownPage(
                                                callType: '',
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
                                                cargo: widget.cargo,
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
    );
  }
}

Widget adress(String ads, String dis, bool isBlind) {
  return LayoutBuilder(
    builder: (context, constraints) {
      // 첫 번째 텍스트 내용
      final String address = isBlind == true ? addressEx2(ads) : ads;

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
      final String secondText = isBlind == true ? '배차 후, 상세정보가 표시됩니다.' : dis;

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


  /*  Row(
          children: [
            /*     Image.asset(
              'asset/img/multi_cargo.png',
              width: 13,
            ), */
            Image.asset('asset/img/return_c.png', width: 12),
            const SizedBox(width: 5),
            const KTextWidget(
                text: '왕복 운송',
                size: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white),
            const Spacer(),
            Row(
              children: [
                if (addProvider.getTodayCount() != 0)
                  Container(
                    margin: addProvider.getTomorrowCount() != 0
                        ? const EdgeInsets.only(right: 5)
                        : null,
                    padding: const EdgeInsets.only(
                        left: 5, right: 5, top: 2, bottom: 2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: kGreenFontColor.withOpacity(0.3)),
                    child: const Center(
                      child: KTextWidget(
                          text: '오늘',
                          size: 13,
                          fontWeight: FontWeight.bold,
                          color: kGreenFontColor),
                    ),
                  ),
                if (addProvider.getTomorrowCount() != 0)
                  Container(
                    margin: addProvider.getFutureCount() != 0
                        ? const EdgeInsets.only(right: 5)
                        : null,
                    padding: const EdgeInsets.only(
                        left: 5, right: 5, top: 2, bottom: 2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: kBlueAssetColor.withOpacity(0.3)),
                    child: const Center(
                      child: KTextWidget(
                          text: '내일',
                          size: 13,
                          fontWeight: FontWeight.bold,
                          color: kBlueBssetColor),
                    ),
                  ),
                if (addProvider.getFutureCount() != 0)
                  Container(
                    padding: const EdgeInsets.only(
                        left: 5, right: 5, top: 2, bottom: 2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: kOrangeAssetColor.withOpacity(0.3)),
                    child: const Center(
                      child: KTextWidget(
                          text: '예약',
                          size: 13,
                          fontWeight: FontWeight.bold,
                          color: kOrangeAssetColor),
                    ),
                  ),
              ],
            )
          ],
        ),
        const SizedBox(height: 18),
        /*   SizedBox(
          width: dw,
          child: Center(
            child: KTextWidget(
                text: addProvider.locations[0].address1.toString(),
                size: 18,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.bold,
                color: null),
          ),
        ), */

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
                    text: addProvider.locations[0].address1.toString(),
                    size: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ],
            )
          ],
        ),
        if (addProvider.locations[0].addressDis != '')
          KTextWidget(
              text: addProvider.locations[0].addressDis.toString(),
              size: 16,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.bold,
              color: Colors.grey),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('asset/img/down_cir.png', width: 20),
            RotatedBox(
                quarterTurns: 2,
                child: Image.asset('asset/img/down_cir.png', width: 20)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KTextWidget(
                    text: addProvider.locations[1].address1.toString(),
                    size: 18,
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.bold,
                    color: null),
                if (addProvider.locations[0].addressDis != '')
                  KTextWidget(
                      text: addProvider.locations[1].addressDis.toString(),
                      size: 16,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
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
        const SizedBox(height: 18),
        Divider(
          color: Colors.grey.withOpacity(0.2),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const KTextWidget(
                text: '상,하차 회수',
                size: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey),
            const Spacer(),
            Row(
              children: [
                KTextWidget(
                    text: '상차 $a 건, ',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: kBlueBssetColor),
                KTextWidget(
                    text: '하차 $b 건',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: kRedColor)
              ],
            ),
          ],
        ),
        Row(
          children: [
            const KTextWidget(
                text: '예상 주행 거리',
                size: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey),
            const Spacer(),
            KTextWidget(
                textAlign: TextAlign.right,
                text: addProvider.totalDistance,
                size: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey)
          ],
        ),
        Row(
          children: [
            const KTextWidget(
                text: '예상 시간',
                size: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey),
            const Spacer(),
            KTextWidget(
                textAlign: TextAlign.right,
                text: addProvider.totalDuration,
                size: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey)
          ],
        ),
        const SizedBox(height: 5),
        Divider(
          color: Colors.grey.withOpacity(0.2),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddReturnUpDownPage(
                              callType: '',
                            )),
                  );
                },
                child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: noState),
                    child: const Center(
                      child: KTextWidget(
                          text: '상, 하차 정보',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    )),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CargoMapPage()),
                  );
                },
                child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: noState),
                    child: const Center(
                      child: KTextWidget(
                          text: '지도 보기',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    )),
              ),
            )
          ],
        ), */