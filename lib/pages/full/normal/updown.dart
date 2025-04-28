import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/weather/helper.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/multimap.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';

class DetailUpDown extends StatefulWidget {
  final Map<String, dynamic> cargo;
  final String callType;
  const DetailUpDown({super.key, required this.cargo, required this.callType});

  @override
  State<DetailUpDown> createState() => _DetailUpDownState();
}

class _DetailUpDownState extends State<DetailUpDown> {
  String? dateStatus;
  String? dateStatusDown;
  String? extractedText;
  String? extractedText2;
  String? extractedText3;
  String? extractedText4;
  bool _isRoad = false;

  bool _isT = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      _isT = widget.callType.contains('상차');
    });
  }
  /*  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateStatus();
    // WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  Map<String, dynamic>? data;
  Future<void> updateStatus() async {
    final dataProvider = Provider.of<DataProvider>(context);
    DateTime now = DateTime.now();
    data = widget.cargo == null ? dataProvider.currentCargo : widget.cargo;

    DateTime selDay = data!['upDate'] == null
        ? data!['upTime'].toDate()
        : data!['upDate'].toDate();
    dateStatus = calculateDateStatus(selDay, now);
    extractedText = await addressEx(data!['upAddress']);

    DateTime selDay2 = data!['downDate'] == null
        ? data!['downTime'].toDate()
        : data!['downDate'].toDate();
    dateStatusDown = calculateDateStatus(selDay2, now);
    extractedText2 = await addressEx(data!['downAddress']);

    print('@@updown');
    setState(() {});
  } */

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    return Column(
      children: [
        /* Row(
          children: [
            const SizedBox(width: 8),
            KTextWidget(
                text: '상-하차 정보',
                size: 14,
                fontWeight: FontWeight.bold,
                color: null),
            const Expanded(child: SizedBox()),
            if (widget.cargo['isBlind'] == false)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (addProvider.isRoad == false) {
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
        ), */
        // const SizedBox(height: 16),
        _upLocation(),
      ],
    );
  }

  Widget _upLocation() {
    final addProvider = Provider.of<AddProvider>(context);
    final dw = MediaQuery.of(context).size.width;
    //final dataProvider = Provider.of<DataProvider>(context);

    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          // 헤더 부분
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
                    color: _isT
                        ? kBlueBssetColor.withOpacity(0.1)
                        : kRedColor.withOpacity(0.1),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        _isT
                            ? 'asset/img/up_navi.png'
                            : 'asset/img/down_navi.png',
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
                  text: formatTimestamp99(
                      _isT ? widget.cargo['upTime'] : widget.cargo['downTime']),
                  size: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ],
            ),
          ),

          // 본문 부분
          Container(
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
                // 주소 정보
                const SizedBox(height: 8),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: dw,
                    child: KTextWidget(
                      text: widget.cargo['isBlind'] == true
                          ? extractedText.toString()
                          : addProvider.isRoad == false
                              ? _isT
                                  ? widget.cargo['upAddress']
                                  : widget.cargo['downAddress']
                              : _isT
                                  ? widget.cargo['upRoadAddress']
                                  : widget.cargo['downRoadAddress'],
                      size: 18,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.bold,
                      color: null,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                if (_isT
                    ? (widget.cargo['upAddressDis'] != '')
                    : (widget.cargo['downAddressDis'] != ''))
                  Container(
                    width: dw,
                    alignment: Alignment.center,
                    child: KTextWidget(
                      text: _isT
                          ? widget.cargo['upAddressDis']
                          : widget.cargo['downAddressDis'],
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
                      buildMinimalInfoRow(
                        icon: Icons.add_box_rounded,
                        title: '정보',
                        value: _isT
                            ? _typeState(
                                widget.cargo['upType'].toString(), '상차')
                            : _typeState(
                                widget.cargo['downType'].toString(), '하차'),
                      ),
                      const SizedBox(height: 6),
                      buildMinimalInfoRow(
                        icon: Icons.timelapse_rounded,
                        title: '시간',
                        value: _isT
                            ? _timeState(
                                    widget.cargo['upTimeType'],
                                    '상차',
                                    widget.cargo['upStart'],
                                    widget.cargo['upEnd'],
                                    widget.cargo['upAloneType'])
                                .toString()
                            : _timeState(
                                    widget.cargo['downTimeType'],
                                    '하차',
                                    widget.cargo['downStart'],
                                    widget.cargo['downEnd'],
                                    widget.cargo['downAloneType'])
                                .toString(),
                      ),
                      const SizedBox(height: 6),
                      buildMinimalInfoRow(
                        icon: Icons.eco_outlined,
                        title: '기타',
                        value: _isT
                            ? (widget.cargo['upComType'] as List).join(', ')
                            : (widget.cargo['downComType'] as List).join(', '),
                        valueColor: kOrangeAssetColor,
                      ),
                      if (_isT
                          ? (widget.cargo['upEtc'] != null &&
                              widget.cargo['upEtc'] != '')
                          : (widget.cargo['downEtc'] != null &&
                              widget.cargo['downEtc'] != ''))
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: buildMinimalInfoRow(
                            icon: Icons.warning_rounded,
                            title: '주의',
                            value: _isT
                                ? widget.cargo['upEtc']
                                : widget.cargo['downEtc'],
                            valueColor: Colors.white,
                          ),
                        ),
                    ],
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
                                    /*   HapticFeedback.lightImpact();
                                    if (widget.cargoData['pickUserUid'] ==
                                        authProvider.userDriver!.uid) {
                                      makePhoneCall(widget.cargoData['upPhone']
                                          .toString());
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(errorSnackBar(
                                              '배차받은 기사만 전화연결이 가능합니다.',
                                              context));
                                    } */
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(Icons.phone,
                                          size: 16, color: Colors.white),
                                      const SizedBox(width: 8),
                                      KTextWidget(
                                        text: _isT ? '상차지 전화' : '하차지 전화',
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
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

/*    Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: msgBackColor),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: dw - 32,
                child: Row(
                  children: [
                    Image.asset(
                      isT
                          ? 'asset/img/cargo_up.png'
                          : 'asset/img/cargo_down.png',
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 6),
                    KTextWidget(
                        text: isT ? '상차' : '하차',
                        size: 14,
                        fontWeight: FontWeight.bold,
                        color: null),
                    const Expanded(child: SizedBox()),
                    dateState(
                        isT ? dateStatus.toString() : dateStatusDown.toString(),
                        null),
                    KTextWidget(
                        text: formatDate(isT
                            ? data!['upTime'].toDate()
                            : data!['downTime'].toDate()),
                        size: 14,
                        fontWeight: null,
                        color: Colors.grey)
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _adress(dw, isT),
          const SizedBox(height: 8),
          _locationInfo(dw, isT)
        ],
      ),
    ); */

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

  String _typeState(String type, String updown) {
    String a =
        updown == '하차' ? widget.cargo['downName'] : widget.cargo['upName'];

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

  String _timeState(String type, String updown, Timestamp? start,
      Timestamp? end, String? aloneType) {
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
          ? widget.cargo['upTimeEtc']
          : widget.cargo['downTimeEtc'];
    } else {
      return ''; // 기본 빈 문자열 반환
    }
  }
}
