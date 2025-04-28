import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/multi_cargo_set.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/updown/updown_cargo_add/set/updown_set_page.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/return_state/updown/return_updown.dart';
import 'package:flutter_mixcall_normaluser_new/pages/weather/helper.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/multimap.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class MultiUpDownMainPage extends StatefulWidget {
  final String? callType;
  final Map<String, dynamic>? cargo;
  const MultiUpDownMainPage({super.key, this.callType, this.cargo});

  @override
  State<MultiUpDownMainPage> createState() => _MultiUpDownMainPageState();
}

class _MultiUpDownMainPageState extends State<MultiUpDownMainPage> {
  var upPoints;
  var downPoints;

  var maxLoad;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final addProvider = Provider.of<AddProvider>(context);
    // 서버에서 받은 Map 형태 데이터 사용 시
    final serverResult = analyzeCargoData(addProvider.locations);

// 결과 사용
    upPoints = serverResult['상차지점리스트'];
    downPoints = serverResult['하차지점리스트'];
    print('상차지점 수: ${upPoints.length}');

    maxLoad = serverResult['최대적재정보'];
    print('최대 적재 무게: ${maxLoad['최대무게']}kg');
  }

  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    final mapProvider = Provider.of<MapProvider>(context);
    bool isState = addProvider.locationCount >= 3;
    final result = getAllUpCargos(addProvider);
    int unfinishedCount = result.$2;
    return Column(
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
              Row(
                children: [
                  Icon(Icons.info, color: kRedColor, size: 13),
                  const SizedBox(width: 2),
                  KTextWidget(
                      text: '미 하차 화물 $unfinishedCount 건이 있습니다.',
                      size: 13,
                      fontWeight: FontWeight.bold,
                      color: kRedColor)
                ],
              )
          ],
        ),
        isState == false
            ? const KTextWidget(
                text: '다구간 상차, 하차 정보를 등록하세요.',
                size: 14,
                fontWeight: null,
                color: Colors.grey)
            : const SizedBox(),
        const SizedBox(height: 12),
        _multiCargo(addProvider, context),
      ],
    );
  }

  Widget _multiCargo(AddProvider addProvider, context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MultiCargoSetPage()),
        );
      },
      child: addProvider.locations.isNotEmpty
          ? _multiNotNullBox(addProvider, context)
          : Container(
              padding: addProvider.locations.isNotEmpty
                  ? const EdgeInsets.all(8)
                  : const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), color: msgBackColor),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'asset/img/multi_cargo.png',
                        width: 15,
                      ),
                      const SizedBox(width: 10),
                      const KTextWidget(
                          text: '이곳을 클릭하여 상, 하차지 정보를 등록하세요.',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)
                    ],
                  )
                ],
              ),
            ),
    );
  }

  bool _isRoad = false;

  Widget _multiNotNullBox(AddProvider addProvider, context) {
    int a = addProvider.getPickupCount();
    int b = addProvider.getDropoffCount();

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
                        text: '다구간(${addProvider.locations.length}) 운송',
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
                          if (addProvider.locations[0].addressDis == '')
                            Column(
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
                      text: '다구간 ${addProvider.locationCount - 2} 개의 장소 경유',
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
                          if (addProvider.locations.last.addressDis == '')
                            Column(
                              children: [
                                KTextWidget(
                                  text: addProvider.setIsBlind == true
                                      ? addressEx2(_isRoad == true
                                          ? addProvider.locations.last.address2
                                              .toString()
                                          : addProvider.locations.last.address1
                                              .toString())
                                      : _isRoad == true
                                          ? addProvider.locations.last.address2
                                              .toString()
                                          : addProvider.locations.last.address1
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
                                    ? addProvider.locations.last.address2
                                        .toString()
                                    : addProvider.locations.last.address1
                                        .toString(),
                                addProvider.locations.last.addressDis
                                    .toString(),
                                addProvider.setIsBlind!),
                          Row(
                            children: [
                              dateStateTag(calculateDateStatus2(
                                  addProvider.locations.last.date!)),
                              Flexible(
                                child: timeState(
                                    addProvider.locations.last.dateType
                                        .toString(),
                                    '상차',
                                    addProvider.locations.last.dateStart,
                                    addProvider.locations.last.dateEnd,
                                    addProvider.locations.last.dateAloneString,
                                    addProvider.locations.last.etc.toString()),
                              ),
                              KTextWidget(
                                  text: '(${addProvider.locations.last.howTo})',
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
                    value: '총 ${addProvider.locationCount}개 장소'),
                buildMinimalInfoRow(
                    icon: Icons.unfold_less,
                    title: '상, 하차 횟수',
                    value: '상차 ${a}건, 하차${b}건'),
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
                                              const MultiCargoSetPage()),
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



/*  Row(
          children: [
            Image.asset(
              'asset/img/multi_cargo.png',
              width: 13,
            ),
            const SizedBox(width: 10),
            const KTextWidget(
                text: '다구간 상하차',
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
                        color: kRedColor.withOpacity(0.3)),
                    child: const Center(
                      child: KTextWidget(
                          text: '예약',
                          size: 13,
                          fontWeight: FontWeight.bold,
                          color: kRedColor),
                    ),
                  ),
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                //color: kBlueBssetColor.withOpacity(0.2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'asset/img/cargo_up.png',
                    width: 15,
                  ),
                  const SizedBox(width: 10),
                  const KTextWidget(
                      text: '상차',
                      size: 18,
                      fontWeight: FontWeight.bold,
                      color: kBlueBssetColor),
                  const SizedBox(width: 5),
                  KTextWidget(
                      text: a >= 10 ? '${a}' : '0${a}',
                      size: 21,
                      fontWeight: FontWeight.bold,
                      color: kBlueBssetColor)
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                //color: kBlueBssetColor.withOpacity(0.2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'asset/img/cargo_down.png',
                    width: 15,
                  ),
                  const SizedBox(width: 10),
                  const KTextWidget(
                      text: '하차',
                      size: 18,
                      fontWeight: FontWeight.bold,
                      color: kRedColor),
                  const SizedBox(width: 5),
                  KTextWidget(
                      text: b >= 10 ? '${b}' : '0${b}',
                      size: 21,
                      fontWeight: FontWeight.bold,
                      color: kRedColor)
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(
          color: Colors.grey.withOpacity(0.2),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const KTextWidget(
                text: '예상 주행 거리',
                size: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey),
            const SizedBox(width: 10),
            SizedBox(
              width: dw - 139.5,
              child: KTextWidget(
                  textAlign: TextAlign.right,
                  text: addProvider.totalDistance,
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            )
          ],
        ),
        Row(
          children: [
            const KTextWidget(
                text: '예상 시간',
                size: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey),
            const SizedBox(width: 10),
            SizedBox(
              width: dw - 111.5,
              child: KTextWidget(
                  textAlign: TextAlign.right,
                  text: addProvider.totalDuration,
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            )
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
                        builder: (context) => const MultiCargoSetPage()),
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