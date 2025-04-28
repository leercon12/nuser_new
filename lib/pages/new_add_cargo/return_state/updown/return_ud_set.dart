import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/model/multi_cargo_add_model.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/updown/updown_cargo_add/set/updown_set_page.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/updown/updown_set.dart';
import 'package:flutter_mixcall_normaluser_new/pages/weather/helper.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class AddReturnUpDownPage extends StatefulWidget {
  final String callType;
  const AddReturnUpDownPage({super.key, required this.callType});

  @override
  State<AddReturnUpDownPage> createState() => _AddReturnUpDownPageState();
}

class _AddReturnUpDownPageState extends State<AddReturnUpDownPage> {
  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    final addProvider = Provider.of<AddProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '왕복 상, 하차 등록',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<AddProvider>().checkAndUpdateRoute();
              Navigator.pop(context);
            },
            child: const KTextWidget(
                text: '등록',
                size: 16,
                fontWeight: FontWeight.bold,
                color: kGreenFontColor),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
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
              _setState(addProvider, dw),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.grey.withOpacity(0.5),
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  KTextWidget(
                      text: '왕복으로 운송하는 건만 등록됩니다.',
                      size: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.withOpacity(0.5))
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.grey.withOpacity(0.5),
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  KTextWidget(
                      text: '상차 > 회차 > 하차 순으로 등록합니다.',
                      size: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.withOpacity(0.5))
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.grey.withOpacity(0.5),
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  KTextWidget(
                      text: '왕복 구성임으로, 상차지와 하차지는 반드시 같아야 합니다.',
                      size: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.withOpacity(0.5))
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.grey.withOpacity(0.5),
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  KTextWidget(
                      text: '편도 또는 다구간 운송은 다른 메뉴를 이용하세요.',
                      size: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.withOpacity(0.5))
                ],
              )
            ],
          ),
        ),
      )),
    );
  }

  Widget _setState(AddProvider addProvider, double dw) {
    return Column(
      children: [
        //  Text(addProvider.locations.length.toString()),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            addProvider.mulitiAddReset();
            addProvider.locationsIndexState(0);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MultiUpDownSetPage(
                        callType: '왕복_상차',
                        cargo: addProvider.locations.isNotEmpty &&
                                addProvider.locations[0].address1 != null
                            ? addProvider.locations[0]
                            : null,
                        isMidUpdate: false,
                      )),
            );
          },
          child: addProvider.locations.isNotEmpty &&
                  addProvider.locations.first.address1 != null
              ? _comBox(
                  addProvider.locations, 0, 'asset/img/cargo_up.png', '시작 상차지')
              : _notComBox(addProvider, 0, '이곳을 클릭하여 상차 정보를 등록하세요.',
                  'asset/img/cargo_up.png'),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('asset/img/down_cir.png', width: 30),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            HapticFeedback.lightImpact();
            if (addProvider.locations.isEmpty) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(errorSnackBar('상차정보를 먼저 등록하세요.', context));
            } else {
              addProvider.mulitiAddReset();
              addProvider.locationsIndexState(1);
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MultiUpDownSetPage(
                          callType: '왕복_회차',
                          cargo: addProvider.locations.isNotEmpty &&
                                  addProvider.locations[1].address1 != null
                              ? addProvider.locations[1]
                              : null,
                          isMidUpdate: false,
                        )),
              ).then((value) {
                setState(() {});
              });
            }
          },
          child: addProvider.locations.length >= 3 &&
                  addProvider.locations[1].address1 != null
              ? _comBox(addProvider.locations, 1, '회차', '회차 경유지')
              : _notComBox(addProvider, 1, '이곳을 클릭하여 경유지 정보를 등록하세요.', '회차'),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('asset/img/down_cir.png', width: 30),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (addProvider.locations.isEmpty ||
                  addProvider.locations.length == 1) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(errorSnackBar('상차정보를 먼저 등록하세요.', context));
              } else {
                addProvider.mulitiAddReset();
                addProvider.locationsIndexState(2);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MultiUpDownSetPage(
                            callType: '왕복_하차',
                            cargo: addProvider.locations.isNotEmpty &&
                                    addProvider.locations[2].address1 != null
                                ? addProvider.locations[2]
                                : null,
                            isMidUpdate: false,
                          )),
                );
              }
            },
            child: addProvider.locations.isNotEmpty &&
                    addProvider.locations.last.address1 != null
                ? _comBox(addProvider.locations, 2, 'asset/img/cargo_down.png',
                    '최종 하차지')
                : _notComBox(addProvider, 2, '이곳을 클릭하여 최종 하차 정보를 등록하세요.',
                    'asset/img/cargo_down.png')),
      ],
    );
  }

  Widget _notComBox(
      AddProvider addProvider, int index, String title, String img) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: msgBackColor),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (img == '회차')
                Image.asset('asset/img/return_c.png', width: 12)
              else
                Image.asset(
                  img,
                  width: 15,
                ),
              const SizedBox(width: 10),
              KTextWidget(
                  text: title,
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)
            ],
          )
        ],
      ),
    );
  }

  bool _isRoad = false;
  Widget _comBox(
      List<CargoLocation> data, int index, String img, String title) {
    final dw = MediaQuery.of(context).size.width;
    bool _isT = data[index].type == '상차';
    final addProvider = Provider.of<AddProvider>(context);
    final into = addProvider.locations[index];
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
                  color: index == 0
                      ? kBlueBssetColor.withOpacity(0.1)
                      : index == 1
                          ? Colors.cyanAccent.withOpacity(0.1)
                          : kRedColor.withOpacity(0.1),
                ),
                child: Row(
                  children: [
                    if (index == 0)
                      Image.asset('asset/img/up_navi.png', width: 13),
                    if (index == 1)
                      Image.asset('asset/img/return_c.png', width: 11),
                    if (index == 2)
                      Image.asset('asset/img/down_navi.png', width: 13),
                    const SizedBox(width: 6),
                    KTextWidget(
                      text: index == 0
                          ? '시작 상차지'
                          : index == 1
                              ? '경유(회차)지'
                              : '최종 하차지 ',
                      size: 12,
                      fontWeight: FontWeight.bold,
                      color: index == 0
                          ? kBlueBssetColor
                          : index == 1
                              ? Colors.cyanAccent
                              : kRedColor,
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
              //  _dateState(dateStatus.toString()),
              KTextWidget(
                text: formatDateTime99(addProvider.locations[0].date!),
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
              const SizedBox(height: 12),
              KTextWidget(
                  text: !_isRoad
                      ? addProvider.setIsBlind == true
                          ? addressEx2(into.address1.toString())
                          : into.address1.toString()
                      : addProvider.setIsBlind == true
                          ? addressEx2(into.address2.toString())
                          : into.address2.toString(),
                  textAlign: TextAlign.center,
                  size: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              if (addProvider.setIsBlind == true)
                KTextWidget(
                    text: '배차시 상세 정보가 공개됩니다.',
                    size: 15,
                    fontWeight: null,
                    color: Colors.grey),
              if (into.addressDis != null && into.addressDis != '')
                KTextWidget(
                    text: into.addressDis.toString(),
                    size: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              const SizedBox(height: 12),
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
                      '${into.senderName}, ${upDownTypeState(into.howTo.toString(), into.type.toString())}',
                  isSmall: true),
              Column(
                children: [
                  buildMinimalInfoRow(
                      icon: Icons.timelapse,
                      title: '시간',
                      value: allTimeState(
                          into.dateType.toString(),
                          index == 1 ? '상, 하차' : into.type.toString(),
                          into.dateStart,
                          into.dateEnd,
                          into.dateAloneString,
                          into.etc.toString()),
                      isSmall: true),
                  buildMinimalInfoRow(
                      icon: Icons.eco,
                      title: '기타',
                      value:
                          '${into.senderType.toString().replaceAll('[', '').replaceAll(']', '')}',
                      isSmall: true,
                      valueColor: kOrangeAssetColor),
                  if (into.becareful != '')
                    buildMinimalInfoRow(
                        icon: Icons.warning_rounded,
                        title: '주의',
                        value: '${into.becareful}',
                        valueColor: kOrangeBssetColor,
                        isSmall: true),
                ],
              ),
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
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _cargoBoxState(dw, data, index),
        )
      ],
    );
  }

  Widget _cargoBoxState(
    double dw,
    List<CargoLocation> data,
    int index,
  ) {
    final addProvider = Provider.of<AddProvider>(context);
    return Column(
      children: [
        if (data[index].upCargos.isEmpty && data[index].downCargos.isEmpty)
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), color: msgBackColor),
              child: _dobuleBox(data, index)),
        if (data[index].upCargos.isNotEmpty &&
            data[index].downCargos.isNotEmpty)
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), color: msgBackColor),
              child: _dobuleBox(data, index))
        else
          Column(
            children: [
              if (data[index].downCargos.isNotEmpty)
                GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      addProvider.clearCargos();
                      addProvider.locationsIndexState(index);
                      print('@@@@@@@@@@@@@!!!!!!!!!!!!');
                      print(index.toString());
                      addProvider
                          .setUpCargos(addProvider.locations[index].upCargos);
                      addProvider.setDownCargos(
                          addProvider.locations[index].downCargos);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MultiAddUpDownSetPage(
                            callType: '왕복_수정_하차',
                            no: index,
                            isSet: true,
                          ),
                        ),
                      );
                    },
                    child: _aloneBox(dw, '하차', index, data)),
              if (data[index].upCargos.isNotEmpty)
                GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      addProvider.clearCargos();
                      addProvider.locationsIndexState(index);
                      print('@@@@@@@@@@@@@!!!!!!!!!!!!');
                      print(index.toString());
                      addProvider
                          .setUpCargos(addProvider.locations[index].upCargos);
                      addProvider.setDownCargos(
                          addProvider.locations[index].downCargos);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MultiAddUpDownSetPage(
                            callType: '왕복_수정_상차',
                            no: index,
                            isSet: true,
                          ),
                        ),
                      );
                    },
                    child: _aloneBox(dw, '상차', index, data)),
            ],
          )
      ],
    );
  }

  Widget _aloneBox(
    double dw,
    String callType,
    int index,
    List<CargoLocation> data,
  ) {
    final cargos =
        callType == '상차' ? data[index].upCargos[0] : data[index].downCargos[0];

    bool isdb = callType == '상차'
        ? data[index].upCargos.length > 1
        : data[index].downCargos.length > 1;

    final img = callType == '상차'
        ? data[index].upCargos[0].imgFile == null &&
            data[index].upCargos[0].imgUrl == null
        : data[index].downCargos[0].imgFile == null &&
            data[index].downCargos[0].imgUrl == null;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), color: msgBackColor),
          child: isdb
              ? _dobuleBox(data, index)
              : Row(
                  children: [
                    Container(
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
                            : ClipRRect(
                                // 이미지에도 borderRadius 적용하기 위해 ClipRRect 사용
                                borderRadius: BorderRadius.circular(8),
                                child: cargos.imgFile == null
                                    ? Image.network(
                                        cargos.imgUrl.toString(),
                                        fit: BoxFit.cover, // 여기서 BoxFit 변경
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          print('이미지 로드 에러: $error');
                                          return const Center(
                                            child: Text('이미지를 불러올 수 없습니다'),
                                          );
                                        },
                                      )
                                    : Image.file(
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
                              )),
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
        if (callType == '하차' && data[index].upCargos.isNotEmpty)
          const SizedBox(
            height: 8,
          )
      ],
    );
  }

  Widget _dobuleBox(
    List<CargoLocation> data,
    int index,
  ) {
    final totalTonUp = data[index]
        .upCargos
        .fold<double>(0, (sum, cargo) => sum + (cargo.cargoWe ?? 0));
    final totalTonDown = data[index]
        .downCargos
        .fold<double>(0, (sum, cargo) => sum + (cargo.cargoWe ?? 0));
    final addProvider = Provider.of<AddProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
            child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            addProvider.setUpCargos(addProvider.locations[index].upCargos);
            addProvider.setDownCargos(addProvider.locations[index].downCargos);
            addProvider.locationsIndexState(index);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MultiAddUpDownSetPage(
                  callType: '상차',
                  no: index,
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
                          color: data[index].upCargos.isEmpty
                              ? Colors.grey.withOpacity(0.6)
                              : kBlueBssetColor,
                        )),
                  )),
              const SizedBox(width: 5),
              KTextWidget(
                  text: data[index].upCargos.isEmpty
                      ? '상차 없음'
                      : '${data[index].upCargos.length.toString().padLeft(2, '0')}건, ${totalTonUp}톤 상차',
                  size: 15,
                  fontWeight: FontWeight.bold,
                  color: data[index].upCargos.isEmpty
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
            addProvider.setUpCargos(addProvider.locations[index].upCargos);
            addProvider.setDownCargos(addProvider.locations[index].downCargos);
            addProvider.locationsIndexState(index);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MultiAddUpDownSetPage(
                  callType: '하차',
                  no: index,
                  isSet: false,
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
                          color: data[index].downCargos.isEmpty
                              ? Colors.grey.withOpacity(0.6)
                              : kRedColor,
                        )),
                  )),
              const SizedBox(width: 5),
              KTextWidget(
                  text: data[index].downCargos.isEmpty
                      ? '하차 없음'
                      : '${data[index].downCargos.length.toString().padLeft(2, '0')}건, ${totalTonDown}톤 하차',
                  size: 15,
                  fontWeight: FontWeight.bold,
                  color: data[index].downCargos.isEmpty
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

  Widget _timeState(String type, String updown, DateTime? start, DateTime? end,
      DateTime? alone) {
    final addProvider = Provider.of<AddProvider>(context);
    final dw = MediaQuery.of(context).size.width;
    if (type == '시간 선택') {
      _timeDis(alone!, null);
    } else if (type == '시간대 선택') {
      _timeDis(start!, end!);
    }

    return Stack(
      children: [
        if (type == '미정')
          KTextWidget(
              text: '${updown}시간 미정',
              size: 14,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        if (type == '도착시 상차' || type == '도착시 하차')
          KTextWidget(
              text: '도착하면 ${updown}',
              size: 14,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        if (type.contains('전화로'))
          KTextWidget(
              text: '${updown}지와 전화로 확인 필요',
              size: 14,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        if (type == '시간 선택')
          KTextWidget(
              text:
                  '${fase3String(alone as DateTime)} ${alone.hour} 시 : ${alone.minute == 0 ? 00 : alone.minute} 분 ${updown == '상차' ? addProvider.setUpTimeAloneType : addProvider.setDownTimeAloneType}',
              size: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        /*   KTextWidget(
              text: '${start2} ${formatTime(start!)} ${aloneType} ${updown}',
              size: 14,
              textAlign: TextAlign.center,
              fontWeight: null,
              color: Colors.grey), */
        if (type == '시간대 선택')
          KTextWidget(
              text:
                  '${fase3String(start as DateTime)} ${start.hour}시 : ${start.minute == 0 ? 00 : start.minute}분 부터 ~ ${fase3String(end as DateTime)} ${end.hour}시 : ${end.minute == 0 ? 00 : end.minute}분 까지',
              size: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        /*  KTextWidget(
              text: '${formatTime(start!)} ~  ${formatTime(end!)} 까지 ${updown}',
              size: 14,
              textAlign: TextAlign.center,
              fontWeight: null,
              color: Colors.grey), */
        if (type.contains('기타') == true)
          SizedBox(
            width: dw * 0.75 - 15,
            child: KTextWidget(
                text: updown == '상차'
                    ? addProvider.setUpTimeEtc.toString()
                    : addProvider.setDownTimeEtc.toString(),
                size: 14,
                textAlign: TextAlign.right,
                fontWeight: FontWeight.bold,
                color: kOrangeBssetColor),
          ),
      ],
    );
  }
}
