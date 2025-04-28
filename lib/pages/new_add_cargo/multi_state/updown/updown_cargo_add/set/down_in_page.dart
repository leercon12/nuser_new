import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/model/multi_cargo_add_model.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/updown/cargo_dialog/multi_cargo.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class InReadyUpCargos extends StatefulWidget {
  final dynamic upList;
  final int? locationsNo;

  const InReadyUpCargos({
    super.key,
    required this.upList,
    this.locationsNo,
  });

  @override
  State<InReadyUpCargos> createState() => _InReadyUpCargosState();
}

class _InReadyUpCargosState extends State<InReadyUpCargos> {
  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    final addProvider = Provider.of<AddProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '상차된 화물 목록',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: widget.upList.length,
                  itemBuilder: (context, index) {
                    final cargo = widget.upList[index];
                    return DelayedWidget(
                      delayDuration:
                          Duration(milliseconds: 100 * index), // 각 아이템마다 지연 효과
                      animationDuration: const Duration(milliseconds: 300),
                      animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
                      child: _listBox(
                        cargo,
                        dw,
                        addProvider,
                        index,
                        '상차',
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              if (_selNum.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (_selNum.isEmpty) {
                      // 선택된 항목이 없을 때 처리
                      Navigator.pop(context);
                    }

                    // 선택된 모든 화물에 대해 처리
                    for (int index in _selNum) {
                      final selectedCargo = widget.upList[index];
                      final cargo = CargoInfo(
                          id: selectedCargo.id,
                          cargoType: selectedCargo.cargoType,
                          cargoWeType: selectedCargo.cargoWeType,
                          cargoWe: selectedCargo.cargoWe,
                          cbm: selectedCargo.cbm,
                          garo: selectedCargo.garo,
                          sero: selectedCargo.sero,
                          hi: selectedCargo.hi,
                          downIndex: addProvider.locationsIndex,
                          imgUrl: selectedCargo.imgUrl,
                          imgFile: selectedCargo.imgFile,
                          type: '하차');

                      addProvider.subDownAddCargo(cargo);
                      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
                      // 생성된 cargo 객체 확인
                      print('Created cargo with downIndex: ${cargo.downIndex}');
                    }

                    if (widget.locationsNo != null) {
                      addProvider.setdownCargoList(
                          widget.locationsNo!, addProvider.downCargos);
                      print(
                          'Saved cargo downIndex: ${addProvider.downCargos.last.downIndex}');
                    }

                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: kRedColor),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        KTextWidget(
                            text: '하차 정보 등록',
                            size: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool checkIfSelIDExists(String selID, AddProvider addProvider) {
    // addProvider.upCargos가 null이 아닌지 확인
    if (addProvider.upCargos == null || addProvider.upCargos.isEmpty) {
      return false;
    }

    // upCargos 리스트에서 id가 selID와 일치하는 항목이 있는지 확인
    return addProvider.upCargos.any((cargo) => cargo.id == selID);
  }

  List _selNum = [];
  Widget _listBox(CargoInfo cargo, double dw, AddProvider addProvider,
      int number, String callType) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();

        print(cargo.id);

        if (checkIfSelIDExists(cargo.id.toString(), addProvider) == true) {
          ScaffoldMessenger.of(context)
              .showSnackBar(errorSnackBar('상차지와 하차지가 같습니다.', context));
        } else if (cargo.isDown == true) {
          /*  addProvider.removeDownCargo(widget.locationsNo!, number);
          addProvider.subDownRemoveCargo(number); */
          ScaffoldMessenger.of(context)
              .showSnackBar(errorSnackBar('이미 하차된 화물입니다.', context));
        } else {
          if (_selNum.contains(number)) {
            setState(() {
              _selNum.remove(number);
            });
          } else {
            setState(() {
              _selNum!.add(number);
            });
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: msgBackColor,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: noState.withOpacity(0.3)),
                child: cargo.imgFile == null
                    ? cargo.imgUrl == null || cargo.imgUrl == 'null'
                        ? Center(
                            child: RotatedBox(
                                quarterTurns: callType == '상차' ? 3 : 1,
                                child: callType == '상차'
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
                            child: Image.network(
                              cargo.imgUrl.toString(),
                              fit: BoxFit.cover, // 여기서 BoxFit 변경
                              errorBuilder: (context, error, stackTrace) {
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
                        child: Image.file(
                          cargo.imgFile!,
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
                //Text(cargo.id.toString()),
                SizedBox(
                  width: dw - 101,
                  child: Row(
                    children: [
                      KTextWidget(
                          text:
                              '${cargo.cargoWe}${cargo.cargoWeType}, ${cargo.locationIndex! + 1}번 장소 상차',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: kBlueBssetColor),
                      const Spacer(),
                      if (cargo.isDown == true)
                        KTextWidget(
                            text: '${cargo.downIndex! + 1}번 장소 하차됨',
                            size: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      if (_selNum.contains(number))
                        const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: kBlueBssetColor,
                              size: 14,
                            ),
                            SizedBox(width: 5),
                            KTextWidget(
                                text: '선택됨',
                                size: 14,
                                fontWeight: FontWeight.bold,
                                color: kBlueBssetColor)
                          ],
                        )
                    ],
                  ),
                ),
                if (cargo.cbm != null)
                  KTextWidget(
                      text:
                          'cbm : ${cargo.cbm}, 가로 ${cargo.garo}m X 세로 ${cargo.sero}m X 높이 ${cargo.hi}m',
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
                  width: dw - 101,
                  child: KTextWidget(
                      text: cargo.cargoType.toString(),
                      size: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
