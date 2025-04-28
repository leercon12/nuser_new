import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/model/multi_cargo_add_model.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/multi_cargo_set.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/updown/updown_cargo_add/set/updown_set_page.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/updown/updown_set.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/normal_state/up_down/set_page/updown_set.dart';
import 'package:flutter_mixcall_normaluser_new/pages/weather/helper.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/bottomSheet.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class MultiCargoWidget extends StatefulWidget {
  final int no;
  final CargoLocation cargo;
  const MultiCargoWidget({super.key, required this.no, required this.cargo});

  @override
  State<MultiCargoWidget> createState() => _MultiCargoWidgetState();
}

class _MultiCargoWidgetState extends State<MultiCargoWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // updateStatus();
  }

  String? dateStatus;
  String? dateStatusDown;
  String? extractedText;
  String? extractedText2;
  String? extractedText3;
  String? extractedText4;
  Future<void> updateStatus() async {
    final addProvider = Provider.of<AddProvider>(context);

    DateTime now = DateTime.now();
    if (addProvider.setUpTimeisDone == true) {
      DateTime selDay = widget.cargo.date as DateTime;
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

  bool _isRoad = false;

  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    final dw = MediaQuery.of(context).size.width;
    dateStatus =
        calculateDateStatus(widget.cargo.date as DateTime, DateTime.now());
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            addProvider.clearCargos();
            _selWidget(widget.no);
            addProvider.locationsIndexState(widget.no);
            print(widget.no);
          },
          child: Column(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: widget.cargo.type == '상차'
                            ? kBlueBssetColor.withOpacity(0.1)
                            : kRedColor.withOpacity(0.1),
                      ),
                      child: Row(
                        children: [
                          if (widget.cargo.type == '상차')
                            Image.asset('asset/img/cargo_up.png', width: 13)
                          else
                            Image.asset('asset/img/cargo_down.png', width: 13),
                          const SizedBox(width: 6),
                          KTextWidget(
                            text: widget.cargo.type == '상차' ? '상차 정보' : '하차 정보',
                            size: 12,
                            fontWeight: FontWeight.bold,
                            color: widget.cargo.type == '상차'
                                ? kBlueBssetColor
                                : kRedColor,
                          ),
                        ],
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    //  _dateState(dateStatus.toString()),
                    KTextWidget(
                      text: formatDateTime99(widget.cargo.date!),
                      size: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
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
                        text: addProvider.setIsBlind == true
                            ? addressEx2(widget.cargo.address1.toString())
                            : _isRoad
                                ? widget.cargo.address2.toString()
                                : widget.cargo.address1.toString(),
                        textAlign: TextAlign.center,
                        size: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    if (addProvider.setIsBlind == true)
                      KTextWidget(
                          text: '배차시 상세 정보가 공개됩니다.',
                          size: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    if (widget.cargo.addressDis != null &&
                        widget.cargo.addressDis != '')
                      KTextWidget(
                          text: widget.cargo.addressDis.toString(),
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
                            '${widget.cargo.senderName.toString()}, ${upDownTypeState(widget.cargo.howTo.toString(), widget.cargo.type.toString())}',
                        isSmall: true),
                    if (widget.cargo.isDone != true)
                      Column(
                        children: [
                          buildMinimalInfoRow(
                              icon: Icons.timelapse,
                              title: '시간',
                              value: allTimeState(
                                  widget.cargo.dateType.toString(),
                                  widget.cargo.type.toString(),
                                  widget.cargo.dateStart,
                                  widget.cargo.dateEnd,
                                  widget.cargo.dateAloneString,
                                  widget.cargo.etc.toString()),
                              isSmall: true),
                          buildMinimalInfoRow(
                              icon: Icons.eco,
                              title: '기타',
                              value:
                                  '${widget.cargo.senderType.toString().replaceAll('[', '').replaceAll(']', '')}',
                              isSmall: true,
                              valueColor: kOrangeAssetColor),
                          if (widget.cargo.becareful != '')
                            buildMinimalInfoRow(
                                icon: Icons.warning_rounded,
                                title: '주의',
                                value: widget.cargo.becareful.toString(),
                                valueColor: kOrangeBssetColor,
                                isSmall: true),
                        ],
                      )
                    else if (widget.cargo.isDone == true)
                      buildMinimalInfoRow(
                          icon: Icons.check_box_rounded,
                          title: '운송 완료',
                          value: formatDateTime99(widget.cargo.isDoneTime!),
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
          ),
        ),
        const SizedBox(height: 8),
        _cargoBoxState(dw, addProvider),
        const SizedBox(height: 10),
        widget.no >= 17
            ? const SizedBox()
            : Container(
                width: double.infinity, // 전체 너비 사용
                height: 30, // 적절한 높이 지정
                child: Stack(
                  children: [
                    Center(
                      child: Image.asset('asset/img/down_cir.png', width: 20),
                    ),
                    if (widget.no != null &&
                        addProvider.locations.isNotEmpty &&
                        (addProvider.locationCount != widget.no + 1))
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 150), // 화살표 너비 + 간격
                            GestureDetector(
                              onTap: () {
                                //   print(widget.no);
                                HapticFeedback.lightImpact();

                                addProvider.clearCargos();
                                addProvider.addUpSenderTypeState(null);

                                addProvider.locationsIndexState(widget.no);
                                addBottomSheet(context, true);
                              },
                              child: KTextWidget(
                                  text: '이 위치에 추가하기',
                                  size: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _cargoBoxState(double dw, AddProvider addProvider) {
    return Column(
      children: [
        if (widget.cargo.upCargos.isEmpty && widget.cargo.downCargos.isEmpty)
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), color: msgBackColor),
              child: _dobuleBox(addProvider)),
        if (widget.cargo.upCargos.isNotEmpty &&
            widget.cargo.downCargos.isNotEmpty)
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), color: msgBackColor),
              child: _dobuleBox(addProvider))
        else
          Column(
            children: [
              if (widget.cargo.downCargos.isNotEmpty)
                GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      int _num = widget.no;
                      addProvider.clearCargos();
                      addProvider.locationsIndexState(_num);
                      addProvider
                          .setUpCargos(addProvider.locations[_num].upCargos);
                      addProvider.setDownCargos(
                          addProvider.locations[_num].downCargos);
                      print('다구간_수정_${widget.cargo.type}');
                      print(_num.toString());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MultiAddUpDownSetPage(
                            callType: '다구간_수정_하차',
                            no: widget.no,
                            isSet: true,
                          ),
                        ),
                      );
                    },
                    child: _aloneBox(dw, '하차', addProvider)),
              if (widget.cargo.upCargos.isNotEmpty)
                GestureDetector(
                    onTap: () {
                      addProvider.clearCargos();
                      int _num = widget.no;
                      addProvider.isLocationSaveState(true);
                      addProvider.locationsIndexState(_num);
                      addProvider
                          .setUpCargos(addProvider.locations[_num].upCargos);
                      addProvider.setDownCargos(
                          addProvider.locations[_num].downCargos);
                      print('다구간_수정_${widget.cargo.type}');
                      print(_num.toString());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MultiAddUpDownSetPage(
                            callType: '다구간_수정_상차',
                            no: widget.no,
                            isSet: true,
                          ),
                        ),
                      );
                    },
                    child: _aloneBox(dw, '상차', addProvider)),
            ],
          )
      ],
    );
  }

  Widget _aloneBox(double dw, String callType, AddProvider addProvider) {
    final cargos = callType == '상차'
        ? widget.cargo.upCargos[0]
        : widget.cargo.downCargos[0];

    bool isdb = callType == '상차'
        ? widget.cargo.upCargos.length > 1
        : widget.cargo.downCargos.length > 1;

    final img = callType == '상차'
        ? widget.cargo.upCargos[0].imgFile == null &&
            widget.cargo.upCargos[0].imgUrl == null
        : widget.cargo.downCargos[0].imgFile == null &&
            widget.cargo.downCargos[0].imgUrl == null;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), color: msgBackColor),
          child: isdb
              ? _dobuleBox(addProvider)
              : Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        print(cargos.imgUrl);
                      },
                      child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: noState.withOpacity(0.3)),
                          child: img
                              ? Center(
                                  child: RotatedBox(
                                      quarterTurns: callType == '하차' ? 1 : 3,
                                      child: Icon(
                                        Icons.double_arrow_rounded,
                                        color: callType == '하차'
                                            ? kRedColor
                                            : kBlueBssetColor,
                                      )),
                                )
                              : cargos.imgUrl == null
                                  ? ClipRRect(
                                      // 이미지에도 borderRadius 적용하기 위해 ClipRRect 사용
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        cargos.imgFile as File,
                                        fit: BoxFit.cover, // 여기서 BoxFit 변경
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          print('이미지 로드 에러: $error');
                                          return const Center(
                                            child: Text('이미지를 불러올 수 없습니다'),
                                          );
                                        },
                                      ),
                                    )
                                  : ClipRRect(
                                      // 이미지에도 borderRadius 적용하기 위해 ClipRRect 사용
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        cargos.imgUrl.toString(),
                                        fit: BoxFit.cover, // 여기서 BoxFit 변경
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          print('이미지 로드 에러: $error');
                                          return const Center(
                                            child: Text('이미지를 불러올 수 없습니다'),
                                          );
                                        },
                                      ),
                                    )),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        KTextWidget(
                            text:
                                '${cargos.cargoWe}${cargos.cargoWeType}, ${callType}',
                            size: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                callType == '상차' ? kBlueBssetColor : kRedColor),
                        if (cargos.cbm != null)
                          KTextWidget(
                              text:
                                  'cbm : ${cargos.cbm}, 가로 ${cargos.garo}m X 세로 ${cargos.sero}m X 높이 ${cargos.hi}m',
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
                              text: cargos.cargoType.toString(),
                              size: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    )
                  ],
                ),
        ),
        if (callType == '하차' && widget.cargo.upCargos.isNotEmpty)
          const SizedBox(
            height: 8,
          )
      ],
    );
  }

  Widget _dobuleBox(AddProvider addProvider) {
    final totalTonUp = widget.cargo.upCargos
        .fold<double>(0, (sum, cargo) => sum + (cargo.cargoWe ?? 0));
    final totalTonDown = widget.cargo.downCargos
        .fold<double>(0, (sum, cargo) => sum + (cargo.cargoWe ?? 0));

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
            child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            int _num = widget.no;
            addProvider.locationsIndexState(_num);
            addProvider.setUpCargos(addProvider.locations[_num].upCargos);
            addProvider.setDownCargos(addProvider.locations[_num].downCargos);
            print('다구간_수정_${widget.cargo.type}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MultiAddUpDownSetPage(
                  callType: '상차',
                  no: widget.no,
                  isSet: true,
                ),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                  // /  width: 30,
                  height: 30,
                  /*   decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: noState.withOpacity(0.3)), */
                  child: Center(
                    child: RotatedBox(
                        quarterTurns: 3,
                        child: Icon(
                          Icons.double_arrow_rounded,
                          size: 18,
                          color: widget.cargo.upCargos.isEmpty
                              ? Colors.grey.withOpacity(0.6)
                              : kBlueBssetColor,
                        )),
                  )),
              const SizedBox(width: 5),
              KTextWidget(
                  text: widget.cargo.upCargos.isEmpty
                      ? '상차 없음'
                      : '${widget.cargo.upCargos.length.toString().padLeft(2, '0')}건, ${totalTonUp}톤 상차',
                  size: 15,
                  fontWeight: FontWeight.bold,
                  color: widget.cargo.upCargos.isEmpty
                      ? Colors.grey.withOpacity(0.6)
                      : kBlueBssetColor),
            ],
          ),
        )),
        const SizedBox(width: 8),
        Expanded(
            child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            int _num = widget.no;
            addProvider.setUpCargos(addProvider.locations[_num].upCargos);
            addProvider.setDownCargos(addProvider.locations[_num].downCargos);
            addProvider.locationsIndexState(_num);
            print('다구간_수정_${widget.cargo.type}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MultiAddUpDownSetPage(
                  callType: '하차',
                  no: widget.no,
                  isSet: true,
                ),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                  // width: 30,
                  height: 30,
                  /*     decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: noState.withOpacity(0.3)), */
                  child: Center(
                    child: RotatedBox(
                        quarterTurns: 1,
                        child: Icon(
                          Icons.double_arrow_rounded,
                          size: 18,
                          color: widget.cargo.downCargos.isEmpty
                              ? Colors.grey.withOpacity(0.6)
                              : kRedColor,
                        )),
                  )),
              const SizedBox(width: 5),
              KTextWidget(
                  text: widget.cargo.downCargos.isEmpty
                      ? '하차 없음'
                      : '${widget.cargo.downCargos.length.toString().padLeft(2, '0')}건, ${totalTonDown}톤 하차',
                  size: 15,
                  fontWeight: FontWeight.bold,
                  color: widget.cargo.downCargos.isEmpty
                      ? Colors.grey.withOpacity(0.6)
                      : kRedColor),
            ],
          ),
        )),
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

  void _selWidget(int index) {
    final dw = MediaQuery.of(context).size.width;
    final addProvider = Provider.of<AddProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return BottomSheetWidget(
              contents: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Icon(Icons.info, size: 70, color: kOrangeBssetColor),
                const SizedBox(height: 32),
                const KTextWidget(
                    text: '필요하신 서비스 유형을 선택하세요.',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                const KTextWidget(
                    text: '아래 목록중 지금 필요하신 서비스를 선택하세요.',
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey),
                const KTextWidget(
                    text: '해당 과정을 삭제하거나 수정할 수 있습니다.',
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    await _reset(addProvider);
                    int _num = index;
                    print(_num);
                    addProvider
                        .setUpCargos(addProvider.locations[_num].upCargos);
                    addProvider
                        .setDownCargos(addProvider.locations[_num].downCargos);
                    print('다구간_수정_${widget.cargo.type}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MultiUpDownSetPage(
                                callType: '다구간_수정_${widget.cargo.type}',
                                no: _num,
                                cargo: widget.cargo,
                                isMidUpdate: false,
                              )),
                    );
                  },
                  child: Container(
                    height: 52,
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    width: dw,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: noState),
                    child: const Row(
                      children: [
                        Icon(Icons.settings, color: Colors.grey, size: 16),
                        Spacer(),
                        KTextWidget(
                            text: '정보 수정',
                            size: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    addProvider.removeLocation(widget.no);
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 52,
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    width: dw,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: noState),
                    child: const Row(
                      children: [
                        Icon(Icons.cancel, color: kRedColor, size: 16),
                        Spacer(),
                        KTextWidget(
                            text: '해당 유형 삭제',
                            size: 16,
                            fontWeight: FontWeight.bold,
                            color: kRedColor),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
                //const SizedBox(height: 10),
              ],
            ),
          ));
        });
      },
    );
  }

  Future _reset(AddProvider addProvider) async {
    if (widget.cargo.type == '상차') {
      addProvider.setLocationUpNamePhoneState(
          widget.cargo.senderName, widget.cargo.senderPhone);
      addProvider.setLocationUpDisState(widget.cargo.addressDis);
      addProvider.setLocationUpAddressState(
          widget.cargo.address1, widget.cargo.address2);
      addProvider.addUpSenderTypeState(widget.cargo.senderType);
      addProvider.setLocationUpNLatLngState(widget.cargo.location);
      addProvider.setLocationCargoUpTypeState(widget.cargo.howTo);

      addProvider.setLocationUpTimeTypeState(widget.cargo.dateType);
      if (widget.cargo.dateType == '시간 선택') {
        addProvider.setUpTimeAloneDateState(widget.cargo.dateStart);
      }
      if (widget.cargo.dateType == '시간대 선택') {
        addProvider.setUpTimeDoubleStartState(widget.cargo.dateStart);
      }

      addProvider.setUpTimeDoubleEndState(widget.cargo.dateEnd);
      addProvider.setUpTimeAloneTypeState(widget.cargo.dateAloneString);
      addProvider.setUpDateState(widget.cargo.date);
      if (widget.cargo.etc != null && widget.cargo.etc != '') {
        addProvider.setUpTimeEtcState(widget.cargo.etc);
      }

      addProvider.addMultiEtcState(widget.cargo.becareful);
    } else {
      addProvider.setLocationDownNamePhoneState(
          widget.cargo.senderName, widget.cargo.senderPhone);
      addProvider.setLocationDownDisState(widget.cargo.addressDis);
      addProvider.setLocationDownAddressState(
          widget.cargo.address1, widget.cargo.address2);
      addProvider.addDownSenderTypeState(widget.cargo.senderType);
      addProvider.setLocationDownNLatLngState(widget.cargo.location);
      addProvider.setLocationCargoDownTypeState(widget.cargo.howTo);

      addProvider.setLocationDownTimeTypeState(widget.cargo.dateType);
      if (widget.cargo.dateType == '시간 선택') {
        addProvider.setDownTimeAloneDateState(widget.cargo.dateStart);
      }
      if (widget.cargo.dateType == '시간대 선택') {
        addProvider.setDownTimeDoubleStartState(widget.cargo.dateStart);
      }

      addProvider.setDownTimeDoubleEndState(widget.cargo.dateEnd);
      addProvider.setDownTimeAloneTypeState(widget.cargo.dateAloneString);
      addProvider.setDownDateState(widget.cargo.date);
      if (widget.cargo.etc != null && widget.cargo.etc != '') {
        addProvider.setDownTimeEtcState(widget.cargo.etc);
      }

      /*   addProvider.cargoImageState(widget.cargo.imgFile);
      addProvider.addCargoInfoState(widget.cargo.cargoType);

      addProvider.addCargotonStringState(widget.cargo.cargoWeType);
      addProvider.multiImgUrlState(widget.cargo.imgUrl);
      if (widget.cargo.cbm != null) {
        addProvider.addCargoCbmState(widget.cargo.cbm as double);
        addProvider.addCargoSizedState(widget.cargo.garo as double,
            widget.cargo.sero as double, widget.cargo.hi as double);
      }

      if (widget.cargo.cargoWe != null) {
        addProvider.addCargoTonState(widget.cargo.cargoWe as double);
      } */

      addProvider.addMultiEtcState(widget.cargo.becareful);
    }
  }
}
