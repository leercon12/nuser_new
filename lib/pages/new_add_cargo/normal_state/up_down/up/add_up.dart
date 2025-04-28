import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/weather/helper.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/multimap.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';

class AddUpPage extends StatefulWidget {
  final String callType;
  const AddUpPage({super.key, required this.callType});

  @override
  State<AddUpPage> createState() => _AddUpPageState();
}

class _AddUpPageState extends State<AddUpPage> {
  String? dateStatus;
  String? dateStatusDown;
  String? extractedText;
  String? extractedText2;
  String? extractedText3;
  String? extractedText4;
  bool _isRoad = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddProvider>().checkAndUpdateSimpleRoute();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateStatus();
  }

  Future<void> updateStatus() async {
    final addProvider = Provider.of<AddProvider>(context);
    print(addProvider.setUpDate);

    DateTime now = DateTime.now();
    if (addProvider.setUpTimeisDone == true) {
      DateTime selDay = addProvider.setUpDate as DateTime;
      dateStatus = calculateDateStatus(selDay, now);
      extractedText =
          await addressEx(addProvider.setLocationUpAddress1.toString());
    }

    if (addProvider.setDownTimeisDone == true) {
      DateTime selDay2 = addProvider.setDownDate as DateTime;
      dateStatusDown = calculateDateStatus(selDay2, now);
      extractedText2 =
          await addressEx(addProvider.setLocationDownAddress1.toString());
    }
    print('@@updown');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    bool _isT = widget.callType.contains('상차');
    final dw = MediaQuery.of(context).size.width;

    if (dateStatus == null) {
      dateStatus = calculateDateStatus(
          addProvider.setUpDate as DateTime, DateTime.now());
      dateStatusDown = calculateDateStatus(
          addProvider.setDownDate as DateTime, DateTime.now());
    }
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
                    color: !_isT
                        ? kRedColor.withOpacity(0.1)
                        : kBlueBssetColor.withOpacity(0.1),
                  ),
                  child: Row(
                    children: [
                      _isT
                          ? Image.asset(
                              'asset/img/up_navi.png',
                              width: 16,
                              height: 16,
                            )
                          : Image.asset(
                              'asset/img/down_navi.png',
                              width: 16,
                              height: 16,
                            ),
                      const SizedBox(width: 6),
                      KTextWidget(
                        text: _isT ? '상차 정보' : '하차 정보',
                        size: 13,
                        fontWeight: FontWeight.bold,
                        color: _isT ? kBlueBssetColor : kRedColor,
                      ),
                    ],
                  ),
                ),
                const Expanded(child: SizedBox()),
                _dateState(dateStatus.toString()),
                KTextWidget(
                  text: formatDateTime99(
                      _isT ? addProvider.setUpDate! : addProvider.setDownDate!),
                  size: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          // 본문 정보
          Container(
            decoration: BoxDecoration(
              color: msgBackColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                //const SizedBox(height: 8),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    width: dw,
                    child: KTextWidget(
                      text: addProvider.setIsBlind == true
                          ? _isT
                              ? extractedText.toString()
                              : extractedText2.toString()
                          : _isRoad == false
                              ? _isT
                                  ? addProvider.setLocationUpAddress1.toString()
                                  : addProvider.setLocationDownAddress1
                                      .toString()
                              : _isT
                                  ? addProvider.setLocationUpAddress2.toString()
                                  : addProvider.setLocationDownAddress2
                                      .toString(),
                      size: 18,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.bold,
                      color: null,
                    ),
                  ),
                ),
                if (addProvider.setIsBlind == true)
                  Container(
                    width: dw,
                    alignment: Alignment.center,
                    child: const KTextWidget(
                      text: '배차시, 모든 정보가 공개됩니다.',
                      size: 16,
                      textAlign: TextAlign.center,
                      fontWeight: null,
                      color: Colors.grey,
                    ),
                  )
                else if (_isT
                    ? (addProvider.setLocationUpDis != '' &&
                        addProvider.setLocationUpDis != null)
                    : (addProvider.setLocationDownDis != '' &&
                        addProvider.setLocationDownDis != null))
                  Container(
                    width: dw,
                    alignment: Alignment.center,
                    child: KTextWidget(
                      text: _isT
                          ? addProvider.setLocationUpDis.toString()
                          : addProvider.setLocationDownDis.toString(),
                      size: 16,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                // const SizedBox(height: 16),
                const SizedBox(height: 8),
                // 구분선
                Padding(
                  padding: const EdgeInsets.only(right: 8, left: 8),
                  child: Divider(
                    thickness: 2,
                    color: dialogColor,
                  ),
                ),

                const SizedBox(height: 8),
                // 정보 섹션 - 미니멀한 디자인
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      //  Text(addProvider.setLocationCargoUpType.toString()),
                      buildMinimalInfoRow(
                        icon: Icons.add_box_rounded,
                        title: '정보',
                        value: _typeState(
                            _isT
                                ? addProvider.setLocationCargoUpType.toString()
                                : addProvider.setLocationCargoDownType
                                    .toString(),
                            _isT ? '상차' : '하차',
                            addProvider),
                      ),
                      const SizedBox(height: 6),
                      buildMinimalInfoRow(
                        icon: Icons.timelapse_rounded,
                        title: '시간',
                        value: _timeState(
                                _isT
                                    ? addProvider.setUpTimeType.toString()
                                    : addProvider.setDownTimeType.toString(),
                                _isT ? '상차' : '하차',
                                _isT
                                    ? addProvider.setUpDateDoubleStart
                                    : addProvider.setDownDateDoubleStart,
                                _isT
                                    ? addProvider.setUpDateDoubleEnd
                                    : addProvider.setDownDateDoubleEnd,
                                _isT
                                    ? addProvider.setUpTimeAloneType.toString()
                                    : addProvider.setDownTimeAloneType
                                        .toString(),
                                addProvider)
                            .toString(),
                      ),
                      const SizedBox(height: 6),
                      buildMinimalInfoRow(
                        icon: Icons.eco_outlined,
                        title: '기타',
                        value: _isT
                            ? addProvider.addUpSenderType!.join(', ')
                            : addProvider.addDownSenderType!.join(', '),
                        valueColor: kOrangeAssetColor,
                      ),
                      if (_isT
                          ? (addProvider.setUpEtc != null &&
                              addProvider.setUpEtc != '')
                          : addProvider.setDownEtc != null &&
                              addProvider.setDownEtc != '')
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: buildMinimalInfoRow(
                            icon: Icons.warning_rounded,
                            title: '주의',
                            value: _isT
                                ? addProvider.setUpEtc.toString()
                                : addProvider.setDownEtc.toString(),
                            valueColor: Colors.white,
                          ),
                        ),
                      const SizedBox(height: 8),

                      // 구분선
                      Padding(
                        padding: const EdgeInsets.only(right: 8, left: 8),
                        child: Divider(
                          thickness: 2,
                          color: dialogColor,
                        ),
                      ),

                      const SizedBox(height: 8),
                      // 하단 액션 영역 - 세련된 디자인
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
                                  HapticFeedback.lightImpact();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      errorSnackBar(
                                          '기사만 확인할 수 있습니다.', context));
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
                                        },
                                        child: Row(
                                          children: [
                                            const Icon(Icons.phone,
                                                size: 16, color: Colors.white),
                                            const SizedBox(width: 8),
                                            const KTextWidget(
                                              text: '하차지 전화',
                                              size: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
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
                                                builder: (context) =>
                                                    CargoMapPage(cargo: null)),
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
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _dateState(String state) {
    return Stack(
      children: [
        if (state == 'today')
          const Center(
            child: KTextWidget(
                text: '오늘, ',
                size: 13,
                fontWeight: FontWeight.bold,
                color: kGreenFontColor),
          ),
        if (state == 'tmm')
          const Center(
            child: KTextWidget(
                text: '내일, ',
                size: 13,
                fontWeight: FontWeight.bold,
                color: kBlueBssetColor),
          ),
        if (state == 'ex')
          const Center(
            child: KTextWidget(
                text: '만료, ',
                size: 13,
                fontWeight: FontWeight.bold,
                color: kRedColor),
          ),
        if (state == 'book')
          const Center(
            child: KTextWidget(
                text: '예약, ',
                size: 13,
                fontWeight: FontWeight.bold,
                color: kOrangeBssetColor),
          ),
      ],
    );
  }

/*   Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: msgBackColor),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: dw - 32,
                child: Row(
                  children: [
                    Image.asset(
                      _isT
                          ? 'asset/img/cargo_up.png'
                          : 'asset/img/cargo_down.png',
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 6),
                    KTextWidget(
                        text: _isT ? '상차' : '하차',
                        size: 14,
                        fontWeight: FontWeight.bold,
                        color: null),
                    const Expanded(child: SizedBox()),
                    dateState(
                        _isT
                            ? dateStatus.toString()
                            : dateStatusDown.toString(),
                        null),
                    KTextWidget(
                        text: formatDate(_isT
                            ? addProvider.setUpDate as DateTime
                            : addProvider.setDownDate as DateTime),
                        size: 14,
                        fontWeight: null,
                        color: Colors.grey)
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _adress(dw, addProvider, _isT),
          if (!_isT && addProvider.isTmm == true)
            const KTextWidget(
                text: '협의하면, 내일 하차도 가능한 운송입니다.',
                size: 14,
                fontWeight: FontWeight.bold,
                color: kBlueBssetColor),
          //const SizedBox(height: 18),
          const SizedBox(height: 8),
          _locationInfo(dw, addProvider, _isT)
        ],
      ),
    );
 */
  Widget _adress(double dw, AddProvider addProvider, bool _isT) {
    //updateStatus();
    return Column(
      children: [
        SizedBox(
          width: dw,
          child: Center(
            child: KTextWidget(
                text: addProvider.setIsBlind == true
                    ? _isT
                        ? extractedText.toString()
                        : extractedText2.toString()
                    : _isRoad == false
                        ? _isT
                            ? addProvider.setLocationUpAddress1.toString()
                            : addProvider.setLocationDownAddress1.toString()
                        : _isT
                            ? addProvider.setLocationUpAddress2 == null
                                ? '도로명 주소 없음'
                                : addProvider.setLocationUpAddress2.toString()
                            : addProvider.setLocationDownAddress2 == null
                                ? '도로명 주소 없음'
                                : addProvider.setLocationDownAddress2
                                    .toString(),
                size: 18,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.bold,
                color: null),
          ),
        ),
      ],
    );
  }

////////////////////////////////////
////////////////////////////////////
////////////////////////////////////

  Widget _locationInfo(double dw, AddProvider addProvider, bool _isT) {
    return addProvider.setIsBlind == true
        ? SizedBox(
            width: dw,
            child: const Center(
              child: KTextWidget(
                  text: '배차시, 모든 정보가 공개됩니다.',
                  size: 16,
                  textAlign: TextAlign.center,
                  fontWeight: null,
                  color: Colors.grey),
            ),
          )
        : Column(
            children: [
              _isT ? _upDis() : _downsDis(),
              const SizedBox(height: 18),
              Divider(
                height: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
              const SizedBox(height: 9),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  KTextWidget(
                      text: _isT ? '상차 정보' : '하차 정보',
                      size: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                  const Expanded(child: SizedBox()),
                  KTextWidget(
                      text: _isT
                          ? addProvider.setLocationUpName.toString()
                          : addProvider.setLocationDownName.toString(),
                      size: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ],
              ),
              Row(
                children: [
                  const Spacer(),
                  KTextWidget(
                      text: _isT
                          ? addProvider.addUpSenderType
                              .toString()
                              .replaceAll('[', '')
                              .replaceAll(']', '')
                          : addProvider.addDownSenderType
                              .toString()
                              .replaceAll('[', '')
                              .replaceAll(']', ''),
                      size: 14,
                      fontWeight: null,
                      color: Colors.grey),
                ],
              ),
              Row(
                children: [
                  KTextWidget(
                      text: _isT ? '상차 방법' : '하차 방법',
                      size: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                  const Expanded(child: SizedBox()),
                  _isT
                      ? KTextWidget(
                          text: upDownTypeState(
                              addProvider.setLocationCargoUpType.toString(),
                              '상차'),
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)
                      : KTextWidget(
                          text: upDownTypeState(
                              addProvider.setLocationCargoDownType.toString(),
                              '하차'),
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)
                ],
              ),
              /*   Row(
                children: [
                  KTextWidget(
                      text: _isT ? '상차 시간' : '하차 시간',
                      size: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                  const Expanded(child: SizedBox()),
                  _isT
                      ? _timeState(
                          addProvider.setDownTimeType.toString(),
                          '상차',
                          addProvider.setUpDateDoubleStart,
                          addProvider.setUpDateDoubleEnd,
                          addProvider.setUpTimeAloneType,
                          addProvider)
                      : _timeState(
                          addProvider.setDownTimeType.toString(),
                          '하차',
                          addProvider.setDownDateDoubleStart == null
                              ? null
                              : addProvider.setDownDateDoubleStart as DateTime,
                          addProvider.setDownDateDoubleEnd == null
                              ? null
                              : addProvider.setDownDateDoubleEnd as DateTime,
                          addProvider.setDownDateDoubleStart == null
                              ? null
                              : addProvider.setDownDateDoubleStart as DateTime)
                ],
              ), */
              if (widget.callType.contains('상차')
                  ? (addProvider.setUpEtc != null && addProvider.setUpEtc != '')
                  : (addProvider.setDownEtc != null &&
                      addProvider.setDownEtc != ''))
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const KTextWidget(
                        text: '주의 사항',
                        size: 14,
                        fontWeight: null,
                        color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: KTextWidget(
                          textAlign: TextAlign.end,
                          text: _isT
                              ? addProvider.setUpEtc.toString()
                              : addProvider.setDownEtc.toString(),
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: kOrangeBssetColor),
                    ),
                  ],
                ),
              const SizedBox(height: 9),
              Divider(
                height: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                            errorSnackBar('배차받은 기사만 전화연결이 가능합니다.', context));
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: noState),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: Icon(
                                Icons.phone,
                                color: noText,
                                size: 16,
                              ),
                            ),
                            SizedBox(width: 6),
                            KTextWidget(
                                text: '전화',
                                size: 15,
                                fontWeight: FontWeight.bold,
                                color: noText)
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();

                        if (addProvider.setLocationUpNLatLng != null &&
                            addProvider.setLocationDownNLatLng != null) {
                          context
                              .read<AddProvider>()
                              .checkAndUpdateSimpleRoute();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CargoMapPage(
                                      cargo: null,
                                    )),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              errorSnackBar(
                                  '상, 하차지 설정이 모두 완료되어야 합니다.', context));
                        }
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: noState),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: Icon(
                                Icons.location_on,
                                color: noText,
                                size: 16,
                              ),
                            ),
                            SizedBox(width: 6),
                            KTextWidget(
                                text: '지도',
                                size: 15,
                                fontWeight: FontWeight.bold,
                                color: noText)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
  }

  String? upDis;
  String? downDis;
  Future _map() async {
    final addProvider = Provider.of<AddProvider>(context, listen: false);

    downDis = await addDisCurrent2Up(
      context,
      addProvider.setLocationUpNLatLng as NLatLng,
      addProvider.setLocationDownNLatLng as NLatLng,
    );
  }

  Widget _upDis() {
    final dw = MediaQuery.of(context).size.width;
    final addProvider = Provider.of<AddProvider>(context);
    return Column(
      children: [
        if (addProvider.setIsBlind == false &&
            (addProvider.setLocationUpDis == null ||
                addProvider.setLocationUpDis == ''))
          const SizedBox()
        else
          SizedBox(
            width: dw,
            child: Center(
              child: KTextWidget(
                  text: addProvider.setLocationUpDis.toString(),
                  size: 16,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _downsDis() {
    final dw = MediaQuery.of(context).size.width;
    final addProvider = Provider.of<AddProvider>(context);
    return Column(
      children: [
        if (addProvider.setIsBlind == false &&
            (addProvider.setLocationDownDis == null ||
                addProvider.setLocationDownDis == ''))
          const SizedBox()
        else
          SizedBox(
            width: dw,
            child: Center(
              child: KTextWidget(
                  text: addProvider.setLocationDownDis.toString(),
                  size: 16,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
          ),
      ],
    );
  }

  String _typeState(String type, String updown, AddProvider addProvider) {
    String a = updown == '하차'
        ? addProvider.setLocationDownName.toString()
        : addProvider.setLocationUpName.toString();

    if (type == '지게차' || type == '호이스트' || type == '컨베이어') {
      return '#${a}, ${type}로 ${updown}';
    } else if (type == '수작업' || type == '크레인') {
      return '#${a}, ${type}으로 ${updown}';
    } else if (type == '미정') {
      return '#${a}, 상차 방법 미정';
    } else if (type == '전화로 확인') {
      return '#${a}, 전화로 확인';
    } else {
      return ''; // 기본 빈 문자열 반환
    }
  }

  String? start2;
  String? end2;
  Future _timeDis(DateTime? start, DateTime? end) async {
    if (start != null) {
      start2 = await fase3String(start as DateTime);
    }
    if (end != null) {
      end2 = await fase3String(end as DateTime);
    }
  }

/*   String _timeState(String type, String updown, Timestamp? start,
      Timestamp? end, String? aloneType, AddProvider addProvider) {
    if (type == '미정') {
      return '${updown}시간 미정';
    } else if (type == '도착시 상차' || type == '도착시 하차') {
      return '도착하면 ${updown}';
    } else if (type.contains('전화로')) {
      return '${updown}지와 전화로 확인 필요';
    } else if (type == '시간 선택') {
      return '${fase3String(start!.toDate() as DateTime)} ${formatTime(start!)} ${aloneType} ${updown}';
    } else if (type == '시간대 선택') {
      return '${fase3String(start!.toDate() as DateTime)} ${formatTimeEnd(start!)} ~ ${fase3String(end!.toDate() as DateTime)} ${formatTimeEnd(end!)} 까지 ${updown}';
    } else if (type.contains('기타') == true) {
      return updown == '상차'
          ? addProvider.setUpTimeEtc.toString()
          : addProvider.setDownTimeEtc.toString();
    } else {
      return ''; // 기본 빈 문자열 반환
    }
  } */

  String _timeState(String type, String updown, DateTime? start, DateTime? end,
      String? aloneType, AddProvider addProvider) {
    if (type == '미정') {
      return '${updown}시간 미정';
    } else if (type == '도착시 상차' || type == '도착시 하차') {
      return '도착하면 ${updown}';
    } else if (type.contains('전화로')) {
      return '${updown}지와 전화로 확인 필요';
    } else if (type == '시간 선택') {
      return '${fase3String(start!)} ${formatTime2(start!)} ${aloneType} ${updown}';
    } else if (type == '시간대 선택') {
      return '${fase3String(start!)} ${formatTimeEnd2(start!)} ~ ${fase3String(end!)} ${formatTimeEnd2(end!)} 까지 ${updown}';
    } else if (type.contains('기타') == true) {
      return updown == '상차'
          ? addProvider.setUpTimeEtc.toString()
          : addProvider.setDownTimeEtc.toString();
    } else {
      return ''; // 기본 빈 문자열 반환
    }
  }
}
