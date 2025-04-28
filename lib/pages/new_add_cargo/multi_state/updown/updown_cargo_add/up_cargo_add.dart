import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/model/multi_cargo_add_model.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/updown/updown_cargo_add/set/updown_set_page.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class MultiUpDownAddCargo extends StatefulWidget {
  final int? no;
  final String callType;
  const MultiUpDownAddCargo({super.key, required this.callType, this.no});

  @override
  State<MultiUpDownAddCargo> createState() => _MultiUpDownAddCargoState();
}

class _MultiUpDownAddCargoState extends State<MultiUpDownAddCargo> {
  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    final dw = MediaQuery.of(context).size.width;
    return Column(
      children: [
        if (widget.callType.contains('상차'))
          _upState(addProvider.upCargos, dw, addProvider)
        else
          Column(
            children: [
              _upState(addProvider.upCargos, dw, addProvider),
              _downState(addProvider.downCargos, dw, addProvider),
            ],
          ),
      ],
    );
  }

  Widget _upState(
    List<CargoInfo> cargos,
    double dw,
    AddProvider addProvider,
  ) {
    bool isDown = widget.callType.contains('하차');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        KTextWidget(
            text: isDown ? '추가 상차 화물' : '상차 화물 정보',
            size: 16,
            fontWeight: FontWeight.bold,
            color: isDown
                ? Colors.grey.withOpacity(0.7)
                : cargos.isEmpty
                    ? Colors.white
                    : Colors.grey.withOpacity(0.5)),
        KTextWidget(
            text: '하차지에서 상차되는 화물이 있을때 이용하세요.',
            size: 12,
            fontWeight: null,
            color: isDown
                ? Colors.grey.withOpacity(0.7)
                : cargos.isEmpty
                    ? Colors.grey
                    : Colors.grey.withOpacity(0.5)),
        const SizedBox(height: 16),
        GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (widget.no != null) {
                addProvider.setUpCargos(
                    addProvider.locations[widget.no as int].upCargos);
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MultiAddUpDownSetPage(
                    callType: '상차',
                    no: widget.no,
                    isSet: false,
                  ),
                ),
              );
            },
            child: cargos.isEmpty
                ? Container(
                    height: 52,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: widget.callType.contains('상차')
                            ? noState
                            : msgBackColor),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.grey,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        KTextWidget(
                            text: '상차하실 화물 정보를 입력하세요.',
                            size: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)
                      ],
                    ),
                  )
                : cargos.length == 1
                    ? _aloneType(dw, cargos, '상차')
                    : _upDovbleType(dw, cargos, '상차')),
      ],
    );
  }

  Widget _downState(
    List<CargoInfo> cargos,
    double dw,
    AddProvider addProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        KTextWidget(
            text: '하차 화물 정보',
            size: 16,
            fontWeight: FontWeight.bold,
            color:
                cargos.isEmpty ? Colors.white : Colors.grey.withOpacity(0.5)),
        KTextWidget(
            text: '하차지에서 하차하실 화물 정보를 입력하세요.',
            size: 12,
            fontWeight: null,
            color: cargos.isEmpty ? Colors.grey : Colors.grey.withOpacity(0.5)),
        const SizedBox(height: 16),
        GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (widget.no != null) {
                addProvider.setDownCargos(
                    addProvider.locations[widget.no as int].downCargos);
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MultiAddUpDownSetPage(
                    callType: '하차',
                    no: widget.no,
                    isSet: false,
                  ),
                ),
              );
            },
            child: cargos.isEmpty
                ? Container(
                    height: 52,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: addProvider.downCargos.isEmpty
                            ? noState
                            : msgBackColor),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.grey,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        KTextWidget(
                            text: '하차하실 화물 정보를 입력하세요.',
                            size: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)
                      ],
                    ),
                  )
                : cargos.length == 1
                    ? _aloneType(dw, cargos, '하차')
                    : _upDovbleType(dw, cargos, '하차')),
      ],
    );
  }

  Widget _aloneType(
    double dw,
    List<CargoInfo> cargos,
    String callType,
  ) {
    return Container(
      // height: 52,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), color: msgBackColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: noState.withOpacity(0.3)),
              child: cargos[0].imgFile == null
                  ? Center(
                      child: RotatedBox(
                          quarterTurns: callType.contains('상차') ? 3 : 1,
                          child: callType.contains('상차')
                              ? const Icon(
                                  Icons.double_arrow_rounded,
                                  color: kBlueBssetColor,
                                )
                              : const Icon(
                                  Icons.double_arrow_rounded,
                                  color: kRedColor,
                                )),
                    )
                  : ClipRRect(
                      // 이미지에도 borderRadius 적용하기 위해 ClipRRect 사용
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        cargos[0].imgFile as File,
                        fit: BoxFit.cover, // 여기서 BoxFit 변경
                        errorBuilder: (context, error, stackTrace) {
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
                  text: '${cargos[0].cargoWe}${cargos[0].cargoWeType}, 상차',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: callType.contains('상차') ? kBlueBssetColor : kRedColor),
              if (cargos[0].cbm != null)
                KTextWidget(
                    text:
                        'cbm : ${cargos[0].cbm}, 가로 ${cargos[0].garo}m X 세로 ${cargos[0].sero}m X 높이 ${cargos[0].hi}m',
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
                width: dw - 98,
                child: KTextWidget(
                    text: cargos[0].cargoType.toString(),
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

  Widget _upDovbleType(
    double dw,
    List<CargoInfo> cargos,
    String callType,
  ) {
    final totalTon =
        cargos.fold<double>(0, (sum, cargo) => sum + (cargo.cargoWe ?? 0));
    return Container(
      height: 52,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), color: msgBackColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          KTextWidget(
              text: '${callType} 0${cargos.length}건, 총 $totalTon 톤 상차',
              size: 16,
              fontWeight: FontWeight.bold,
              color: callType.contains('상차') ? kBlueBssetColor : kRedColor),
        ],
      ),
    );
  }
}
