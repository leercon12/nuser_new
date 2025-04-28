import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/multi/widget/cargo_bottom/cargo_state.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/sidePage/state_page/multi/multi_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/weather/helper.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/loading_page.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/image_dialog.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class FullMultiUpDownSecPage extends StatefulWidget {
  final Map<String, dynamic> cargo;
  final String? callType;
  const FullMultiUpDownSecPage({super.key, required this.cargo, this.callType});

  @override
  State<FullMultiUpDownSecPage> createState() => _FullMultiUpDownSecPageState();
}

class _FullMultiUpDownSecPageState extends State<FullMultiUpDownSecPage> {
  bool _isReturn = false;

  @override
  void initState() {
    super.initState();

    if (widget.callType == '왕복') {
      _isReturn = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              _isReturn ? '왕복 상세 정보' : '다구간 상세 정보',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          body: SafeArea(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cargo['locations'].length,
                    itemBuilder: (context, index) {
                      final data = widget.cargo['locations'][index];
                      final orderNumber = index + 1; // 순번 계산
                      final isLastItem =
                          index == widget.cargo['locations'].length - 1;

                      return Column(
                        children: [
                          GestureDetector(
                              onTap: () async {
                                HapticFeedback.lightImpact();
                                await cargoInfo(context, widget.cargo, data,
                                        orderNumber)
                                    .then((value) async {
                                  if (value == true) {
                                    print(value);
                                    mapProvider.isLoadingState(true);

                                    await Future.delayed(
                                        const Duration(seconds: 3), () async {
                                      await stateMultiUpdateNoImg(
                                          data['type'],
                                          index,
                                          0,
                                          widget.cargo,
                                          widget.cargo['transitType'] == '다구간'
                                              ? false
                                              : true);
                                    });

                                    mapProvider.isLoadingState(false);
                                    setState(() {});
                                  }
                                });
                              },
                              child: _locationsBox(data['type'], data,
                                  orderNumber, dataProvider)),
                          const SizedBox(height: 8),
                          _cargoState(data, orderNumber, mapProvider, index),
                          const SizedBox(height: 10),
                          orderNumber == 15 || isLastItem
                              ? const SizedBox()
                              : Center(
                                  child: Image.asset('asset/img/down_cir.png',
                                      width: 20)),
                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
                )
              ],
            ),
          )),
        ),
        if (mapProvider.isLoading == true) const LoadingPage()
      ],
    );
  }

  Widget _cargoState(
      dynamic data, int num, MapProvider mapProvider, int index) {
    // 1. null 체크
    if (data == null) return const SizedBox();

    // 2. 배열이 비어있거나 null인 경우 체크
    final hasUpCargos = data['upCargos'] != null && data['upCargos'].isNotEmpty;
    final hasDownCargos =
        data['downCargos'] != null && data['downCargos'].isNotEmpty;

    if (!hasUpCargos && !hasDownCargos) return const SizedBox();

    return Column(
      children: [
        // 3. 복수의 화물이 있거나 상/하차 모두 있는 경우
        if ((hasUpCargos && hasDownCargos) ||
            (data['upCargos']?.length >= 2 || data['downCargos']?.length >= 2))
          InkWell(
            onTap: () async {
              HapticFeedback.lightImpact();
              await cargoInfo(context, widget.cargo, data, index)
                  .then((value) async {
                if (value == true) {
                  print(value);
                  mapProvider.isLoadingState(true);

                  await Future.delayed(const Duration(seconds: 3), () async {
                    await stateMultiUpdateNoImg(
                        data['type'],
                        index,
                        0,
                        widget.cargo,
                        widget.cargo['transitType'] == '다구간' ? false : true);
                  });

                  mapProvider.isLoadingState(false);
                  setState(() {});
                }
              });
            },
            child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: msgBackColor),
                child: _doubleBox(data, num)),
          )
        // 4. 단일 화물인 경우
        else if (hasUpCargos || hasDownCargos)
          GestureDetector(
              onTap: () async {
                HapticFeedback.lightImpact();
                await cargoInfo(context, widget.cargo, data, index)
                    .then((value) async {
                  if (value == true) {
                    print(value);
                    mapProvider.isLoadingState(true);
                    await Future.delayed(const Duration(seconds: 3), () async {
                      await stateMultiUpdateNoImg(
                          data['type'],
                          index,
                          0,
                          widget.cargo,
                          widget.cargo['transitType'] == '다구간' ? false : true);
                    });

                    mapProvider.isLoadingState(false);
                    setState(() {});
                  }
                });
              },
              child: _aloneBox(data, num)),
      ],
    );
  }

  Widget _aloneBox(dynamic data, int num) {
    final dw = MediaQuery.of(context).size.width;
    final inData =
        data['type'] == '상차' ? data['upCargos'][0] : data['downCargos'][0];
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: msgBackColor),
      child: Row(
        children: [
          Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: noState.withOpacity(0.3)),
              child: inData['imgUrl'] == null || inData['imgUrl'] == 'null'
                  ? Center(
                      child: RotatedBox(
                          quarterTurns: data['type'] == '하차' ? 1 : 3,
                          child: Icon(
                            Icons.double_arrow_rounded,
                            color: data['type'] == '하차'
                                ? kRedColor
                                : kBlueBssetColor,
                          )),
                    )
                  : GestureDetector(
                      onTap: () {
                        print(inData['imgUrl']);
                        HapticFeedback.lightImpact();
                        showDialog(
                            context: context,
                            builder: (context) => ImageViewerDialog(
                                  networkUrl: inData['imgUrl'],
                                ));
                      },
                      child: ClipRRect(
                        // 이미지에도 borderRadius 적용하기 위해 ClipRRect 사용
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          inData['imgUrl'].toString(),
                          fit: BoxFit.cover, // 여기서 BoxFit 변경
                          errorBuilder: (context, error, stackTrace) {
                            print('이미지 로드 에러: $error');
                            return const Center(
                              child: Text('이미지를 불러올 수 없습니다'),
                            );
                          },
                        ),
                      ),
                    )),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              KTextWidget(
                  text:
                      '${inData['cargoWe']}${inData['cargoWeType']}, ${data['type']}',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: data['type'] == '상차' ? kBlueBssetColor : kRedColor),
              if (inData['cbm'] != null && inData['cbm'] != 0)
                KTextWidget(
                    text:
                        'cbm : ${inData['cbm']}, 가로 ${inData['garo']}m X 세로 ${inData['sero']}m X 높이 ${inData['hi']}m',
                    size: 12,
                    fontWeight: null,
                    color: Colors.grey)
              else
                const KTextWidget(
                    text: '화물 사이즈 정보 없음',
                    size: 12,
                    fontWeight: null,
                    color: Colors.grey),
              SizedBox(
                width: dw - 100,
                child: KTextWidget(
                    text: inData['cargoType'].toString(),
                    size: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _doubleBox(dynamic data, int num) {
    final totalTonUp = data['upCargos'].fold<double>(
        0.0,
        (double sum, dynamic cargo) =>
            sum + (cargo['cargoWe']?.toDouble() ?? 0.0));

    final totalTonDown = data['downCargos'].fold<double>(
        0.0,
        (double sum, dynamic cargo) =>
            sum + (cargo['cargoWe']?.toDouble() ?? 0.0));
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: msgBackColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: Row(
            children: [
              Container(
                  // /  width: 30,
                  //height: 30,
                  /*   decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: noState.withOpacity(0.3)), */
                  child: Center(
                child: RotatedBox(
                    quarterTurns: 3,
                    child: Icon(
                      Icons.double_arrow_rounded,
                      size: 18,
                      color: data['upCargos'].isEmpty
                          ? Colors.grey.withOpacity(0.3)
                          : kBlueBssetColor,
                    )),
              )),
              const SizedBox(width: 5),
              KTextWidget(
                  text: data['upCargos'].isEmpty
                      ? '상차 없음'
                      : '${data['upCargos'].length.toString().padLeft(2, '0')}건, ${totalTonUp}톤 상차',
                  size: 15,
                  fontWeight: FontWeight.bold,
                  color: data['upCargos'].isEmpty
                      ? Colors.grey.withOpacity(0.3)
                      : kBlueBssetColor),
            ],
          )),
          const SizedBox(width: 8),
          Expanded(
              child: Row(
            children: [
              Container(
                  // width: 30,
                  //height: 30,
                  /*     decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: noState.withOpacity(0.3)), */
                  child: Center(
                child: RotatedBox(
                    quarterTurns: 1,
                    child: Icon(
                      Icons.double_arrow_rounded,
                      size: 18,
                      color: data['downCargos'].isEmpty
                          ? Colors.grey.withOpacity(0.3)
                          : kRedColor,
                    )),
              )),
              const SizedBox(width: 5),
              KTextWidget(
                  text: data['downCargos'].isEmpty
                      ? '하차 없음'
                      : '${data['downCargos'].length.toString().padLeft(2, '0')}건, ${totalTonDown}톤 하차',
                  size: 15,
                  fontWeight: FontWeight.bold,
                  color: data['downCargos'].isEmpty
                      ? Colors.grey.withOpacity(0.3)
                      : kRedColor),
            ],
          )),
        ],
      ),
    );
  }

  Widget _locationsBox(
      String callType, dynamic data, int num, DataProvider dataProvider) {
    final dw = MediaQuery.of(context).size.width;
    return _isReturn
        ? _returnState(callType, data, num)
        : _mulitState(callType, data, num);
  }

  bool _isRoad = false;

  Widget _mulitState(String callType, dynamic data, int num) {
    // final dw = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: dialogColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: data['type'] == '상차'
                      ? kBlueBssetColor.withOpacity(0.1)
                      : kRedColor.withOpacity(0.1),
                ),
                child: Row(
                  children: [
                    if (data['type'] == '상차')
                      Image.asset('asset/img/cargo_up.png', width: 13)
                    else
                      Image.asset('asset/img/cargo_down.png', width: 13),
                    const SizedBox(width: 6),
                    KTextWidget(
                      text: data['type'] == '상차' ? '상차 정보' : '하차 정보',
                      size: 12,
                      fontWeight: FontWeight.bold,
                      color: data['type'] == '상차' ? kBlueBssetColor : kRedColor,
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
              //  _dateState(dateStatus.toString()),
              KTextWidget(
                text: formatDateTime99(data['date'].toDate()),
                size: 12,
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
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Column(
            children: [
              //  const SizedBox(height: 12),
              KTextWidget(
                  text: widget.cargo['isBlind'] == true
                      ? addressEx2(data['address1'])
                      : _isRoad
                          ? data['address2'].toString()
                          : data['address1'].toString(),
                  textAlign: TextAlign.center,
                  size: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              if (widget.cargo['isBlind'] == true)
                KTextWidget(
                    text: '배차시 상세 정보가 공개됩니다.',
                    size: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              if (data['addressDis'] != null && data['addressDis'] != '')
                KTextWidget(
                    text: data['addressDis'].toString(),
                    size: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: Divider(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              buildMinimalInfoRow(
                  icon: Icons.info,
                  title: '정보',
                  value:
                      '${data['senderName'].toString()}, ${upDownTypeState(data['howTo'].toString(), data['type'].toString())}',
                  isSmall: true),
              if (data['isDone'] != true)
                Column(
                  children: [
                    buildMinimalInfoRow(
                        icon: Icons.timelapse,
                        title: '시간',
                        value: _timeState(
                            data['dateType'].toString(),
                            data['type'].toString(),
                            data['dateStart'] == null
                                ? null
                                : data['dateStart'].toDate(),
                            data['dateEnd'] == null
                                ? null
                                : data['dateEnd'].toDate(),
                            data['dateAloneString'],
                            data['etc'].toString()),
                        isSmall: true),
                    buildMinimalInfoRow(
                        icon: Icons.eco,
                        title: '기타',
                        value:
                            '${data['senderType'].toString().replaceAll('[', '').replaceAll(']', '')}',
                        isSmall: true,
                        valueColor: kOrangeAssetColor),
                    if (data['becareful'] != '')
                      buildMinimalInfoRow(
                          icon: Icons.warning_rounded,
                          title: '주의',
                          value: '${data['becareful']}',
                          valueColor: kOrangeBssetColor,
                          isSmall: true),
                  ],
                )
              else if (data['isDone'] == true)
                buildMinimalInfoRow(
                    icon: Icons.check_box_rounded,
                    title: '운송 완료',
                    value: formatDateKorTime(data['isDoneDate'].toDate()),
                    valueColor: kOrangeBssetColor,
                    isSmall: true),
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: Divider(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _returnState(String callType, dynamic data, int num) {
    final dw = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: dialogColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: num == 1
                      ? kBlueBssetColor.withOpacity(0.1)
                      : num == 2
                          ? Colors.cyanAccent.withOpacity(0.1)
                          : kRedColor.withOpacity(0.1),
                ),
                child: Row(
                  children: [
                    if (num == 1)
                      Image.asset('asset/img/cargo_up.png', width: 13),
                    if (num == 2)
                      Image.asset('asset/img/return_c.png', width: 11),
                    if (num == 3)
                      Image.asset('asset/img/cargo_down.png', width: 13),
                    const SizedBox(width: 6),
                    KTextWidget(
                      text: num == 1
                          ? '시작 상차지'
                          : num == 2
                              ? '경유(회차)지'
                              : '최종 하차지',
                      size: 12,
                      fontWeight: FontWeight.bold,
                      color: num == 1
                          ? kBlueBssetColor
                          : num == 2
                              ? Colors.cyanAccent
                              : kRedColor,
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
              //  _dateState(dateStatus.toString()),
              KTextWidget(
                text: formatTimestamp99(data['date']),
                size: 12,
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
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Column(
            children: [
              KTextWidget(
                  text: widget.cargo['isBlind'] == true
                      ? addressEx2(data['address1'])
                      : _isRoad
                          ? data['address2'].toString()
                          : data['address1'].toString(),
                  textAlign: TextAlign.center,
                  size: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              if (widget.cargo['isBlind'] == true)
                KTextWidget(
                    text: '배차시 상세 정보가 공개됩니다.',
                    size: 15,
                    fontWeight: null,
                    color: Colors.grey),
              if (data['addressDis'] != null && data['addressDis'] != '')
                KTextWidget(
                    text: data['addressDis'].toString(),
                    size: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: Divider(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              buildMinimalInfoRow(
                  icon: Icons.info,
                  title: '정보',
                  value:
                      '${data['senderName'].toString()}, ${upDownTypeState(data['howTo'].toString(), data['type'].toString())}',
                  isSmall: true),
              if (data['isDone'] != true)
                Column(
                  children: [
                    buildMinimalInfoRow(
                        icon: Icons.timelapse,
                        title: '시간',
                        value: _timeState(
                            data['dateType'].toString(),
                            data['type'].toString(),
                            data['dateStart'] == null
                                ? null
                                : data['dateStart'].toDate(),
                            data['dateEnd'] == null
                                ? null
                                : data['dateEnd'].toDate(),
                            data['dateAloneString'],
                            data['etc'].toString()),
                        isSmall: true),
                    buildMinimalInfoRow(
                        icon: Icons.eco,
                        title: '기타',
                        value:
                            '${data['senderType'].toString().replaceAll('[', '').replaceAll(']', '')}',
                        isSmall: true,
                        valueColor: kOrangeAssetColor),
                    if (data['becareful'] != '')
                      buildMinimalInfoRow(
                          icon: Icons.warning_rounded,
                          title: '주의',
                          value: '${data['becareful']}',
                          valueColor: kOrangeBssetColor,
                          isSmall: true),
                  ],
                )
              else if (data['isDone'] == true)
                buildMinimalInfoRow(
                    icon: Icons.check_box_rounded,
                    title: '운송 완료',
                    value: formatDateKorTime(data['isDoneDate'].toDate()),
                    valueColor: kOrangeBssetColor,
                    isSmall: true),
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: Divider(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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

  String _timeState(String type, String updown, Timestamp? start,
      Timestamp? end, String? aloneType, String etc) {
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
      return etc;
    } else {
      return ''; // 기본 빈 문자열 반환
    }
  }
}
