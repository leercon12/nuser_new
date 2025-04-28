import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/model/multi_cargo_add_model.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/updown/cargo_dialog/multi_cargo.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/updown/cargo_dialog/multi_down.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/updown/updown_cargo_add/set/down_in_page.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/search/search_main.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/image_dialog.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class MultiAddUpDownSetPage extends StatefulWidget {
  final String callType;
  final int? no;
  final bool isSet;
  const MultiAddUpDownSetPage(
      {super.key, required this.callType, this.no, required this.isSet});

  @override
  State<MultiAddUpDownSetPage> createState() => _MultiAddUpDownSetPageState();
}

class _MultiAddUpDownSetPageState extends State<MultiAddUpDownSetPage> {
  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    final dw = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '화물 정보 등록',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          if (widget.callType.contains('상차'))
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                navigateToPage(
                    context,
                    SearchMainPage(
                      callType: '다구간_화물',
                      type: widget.callType,
                    ));
              },
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                child: const KTextWidget(
                    text: '검색',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: kOrangeBssetColor),
              ),
            ),
        ],
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Text(widget.no.toString()),
            widget.callType.contains('상차')
                ? Expanded(child: _upCargoMain(addProvider, dw))
                : Expanded(child: _downCargoMain(addProvider, dw))
          ],
        ),
      )),
    );
  }

  Widget _upCargoMain(AddProvider addProvider, double dw) {
    return /* addProvider.upCargos.isEmpty
        ? Column(
            children: [
             
            ],
          )
        : */
        Column(
      children: [
        Expanded(
          child: Column(
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: addProvider.upCargos.length,
                  itemBuilder: (context, index) {
                    final cargo = addProvider.upCargos[index];
                    return _listBox(
                        cargo, dw, addProvider, index, widget.callType);
                  }),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  addProvider.cargoImageState(null);

                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return Material(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DelayedWidget(
                              animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
                              animationDuration:
                                  const Duration(milliseconds: 500),
                              child: Container(
                                  width: dw,
                                  height: 654,
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: msgBackColor),
                                  child: MultiCargoInfoSet(
                                    index: null,
                                    callType: widget.callType,
                                    isSet: false,
                                  )),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, right: 15, left: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: msgBackColor),
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
                          text: '상차 화물 추가',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(
                    Icons.info,
                    size: 13,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 5),
                  KTextWidget(
                      text: '버튼을 클릭하여, 하차하실 화물의 정보를 등록하세요.',
                      size: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)
                ],
              ),
              const Row(
                children: [
                  Icon(
                    Icons.info,
                    size: 13,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 5),
                  KTextWidget(
                      text: '상단 리스트에서, 상차 목록중 하차 대상을 선택할 수 있어요.',
                      size: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)
                ],
              ),
              const Row(
                children: [
                  Icon(
                    Icons.info,
                    size: 13,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 5),
                  KTextWidget(
                      text: '하나의 항목에 모든 하차 정보를 입력해도 됩니다!',
                      size: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (addProvider.upCargos.isNotEmpty)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();

              if (widget.isSet == true) {
                if (widget.callType.contains('상차')) {
                  addProvider.setUpCargoList(widget.no!, addProvider.upCargos);
                } else {
                  addProvider.setdownCargoList(
                      widget.no!, addProvider.downCargos);
                }
              }

              print(widget.no);

              Navigator.pop(context);
            },
            child: Container(
              height: 52,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: kBlueBssetColor),
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
                      text: '화물 상차 정보 등록',
                      size: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _downCargoMain(AddProvider addProvider, double dw) {
    final result = getAllUpCargos(addProvider);
    final upCargos = result.$1;
    return /* addProvider.downCargos.isEmpty
        ? Column(
            children: [
             
            ],
          )
        : */
        Column(
      children: [
        Expanded(
          child: Column(
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: addProvider.downCargos.length,
                  itemBuilder: (context, index) {
                    final cargo = addProvider.downCargos[index];
                    return _listBox(
                        cargo, dw, addProvider, index, widget.callType);
                  }),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  addProvider.cargoImageState(null);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => InReadyUpCargos(
                              upList: upCargos,
                              locationsNo: widget.no,
                            )),
                  );
                },
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, right: 15, left: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: msgBackColor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add,
                        color: Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      KTextWidget(
                          text: '상차 목록(${upCargos.length}) 에서 하차',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)
                    ],
                  ),
                ),
              ),
              /*  GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  addProvider.cargoImageState(null);
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return Material(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DelayedWidget(
                              animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
                              animationDuration:
                                  const Duration(milliseconds: 500),
                              child: Container(
                                  width: dw,
                                  height: 654,
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: msgBackColor),
                                  child: MultiCargoInfoSet(
                                    callType: widget.callType,
                                    isSet: widget.isSet,
                                  )),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, right: 15, left: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: msgBackColor),
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
                          text: '하차 화물 추가',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)
                    ],
                  ),
                ),
              ), */
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(
                    Icons.info,
                    size: 13,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 5),
                  KTextWidget(
                      text: '상단 리스트에서 하차 목록을 선택할 수 있습니다.',
                      size: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)
                ],
              ),
              const Row(
                children: [
                  Icon(
                    Icons.info,
                    size: 13,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 5),
                  KTextWidget(
                      text: '버튼을 클릭하여, 하차하실 화물의 정보를 등록하세요.',
                      size: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)
                ],
              ),
              const Row(
                children: [
                  Icon(
                    Icons.info,
                    size: 13,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 5),
                  KTextWidget(
                      text: '하나의 항목에 모든 하차 정보를 입력해도 됩니다!',
                      size: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (addProvider.downCargos.isNotEmpty)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              height: 52,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16), color: kRedColor),
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
                      text: '화물 하차 정보 등록',
                      size: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _listBox(CargoInfo cargo, double dw, AddProvider addProvider,
      int number, String callType) {
    return GestureDetector(
      onTap: () {
        print(number);

        HapticFeedback.lightImpact();
        addProvider.cargoImageState(null);
        if (widget.callType.contains('상차')) {
          print(cargo.id);
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DelayedWidget(
                      animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
                      animationDuration: const Duration(milliseconds: 500),
                      child: Container(
                          width: dw,
                          height: 654,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: msgBackColor),
                          child: MultiCargoInfoSet(
                              index: number,
                              callType: widget.callType,
                              isSet: true,
                              cargoId: cargo.id)),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          print(cargo.id);
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
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                // cargo.imgUrl이 String이면서 실제 값이 'null'인 경우도 체크
                final isUrlValid = cargo.imgUrl != null &&
                    cargo.imgUrl != 'null' &&
                    cargo.imgUrl!.isNotEmpty;

                print('imgFile: ${cargo.imgFile}');
                print('imgUrl: ${cargo.imgUrl}');
                print('type: ${cargo.type}');
                print('isUrlValid: $isUrlValid');

                if (cargo.imgFile == null && isUrlValid) {
                  showDialog(
                    context: context,
                    builder: (context) => ImageViewerDialog(
                      networkUrl: cargo.imgUrl.toString(),
                    ),
                  );
                }
                if (cargo.imgFile != null) {
                  showDialog(
                    context: context,
                    builder: (context) => ImageViewerDialog(
                      imageFile: cargo.imgFile,
                    ),
                  );
                }
              },
              child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: noState.withOpacity(0.3)),
                  child: cargo.imgFile == null
                      ? cargo.imgUrl != null && cargo.imgUrl != 'null'
                          ? ClipRRect(
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
                          : Center(
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
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: dw - 101,
                  child: Row(
                    children: [
                      if (callType.contains('하차'))
                        KTextWidget(
                            text: '${cargo.cargoWe}${cargo.cargoWeType}, 하차',
                            size: 14,
                            fontWeight: FontWeight.bold,
                            color: kRedColor)
                      else
                        KTextWidget(
                            text: '${cargo.cargoWe}${cargo.cargoWeType}, 상차',
                            size: 14,
                            fontWeight: FontWeight.bold,
                            color: kBlueBssetColor),
                      // Text(cargo.id.toString()),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (callType.contains('상차')) {
                            if (widget.isSet == true) {
                              addProvider.removeCargoFromAllLocations(
                                  cargo.id!, addProvider);
                              addProvider.subUpRemoveCargo(number);
                            } else {
                              addProvider.subUpRemoveCargo(number);
                            }
                          } else {
                            if (widget.no != null) {
                              addProvider.removeDownCargo(widget.no!, number);
                            }

                            addProvider.subDownRemoveCargo(number);
                          }
                          setState(() {});
                        },
                        child: const KTextWidget(
                            text: '삭제',
                            size: 14,
                            fontWeight: FontWeight.bold,
                            color: kRedColor),
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

// 방법 1: 튜플 사용 (class로 안 만들고도 가능)
(List<CargoInfo>, int) getAllUpCargos(AddProvider addProvider) {
  List<CargoInfo> allUpCargos = [];
  int unfinishedCount = 0;

  // locations를 순회하면서 상차 화물들을 체크
  for (int upLocationIndex = 0;
      upLocationIndex < addProvider.locations.length;
      upLocationIndex++) {
    var upLocation = addProvider.locations[upLocationIndex];
    if (upLocation.upCargos != null) {
      for (int cargoIndex = 0;
          cargoIndex < upLocation.upCargos.length;
          cargoIndex++) {
        var upCargo = upLocation.upCargos[cargoIndex];
        bool isDownCompleted = false;
        int? downLocationIndex;

        // 모든 location을 확인하여 해당 화물의 하차 위치 찾기
        for (int i = 0; i < addProvider.locations.length; i++) {
          var location = addProvider.locations[i];
          if (location.downCargos != null &&
              location.downCargos
                  .any((downCargo) => downCargo.id == upCargo.id)) {
            isDownCompleted = true;
            downLocationIndex = i; // 하차된 location의 인덱스
            break;
          }
        }

        if (!isDownCompleted) {
          unfinishedCount++;
        }

        CargoInfo newCargo = CargoInfo(
            cargoType: upCargo.cargoType,
            cargoWeType: upCargo.cargoWeType,
            cargoWe: upCargo.cargoWe,
            cbm: upCargo.cbm,
            garo: upCargo.garo,
            sero: upCargo.sero,
            hi: upCargo.hi,
            imgUrl: upCargo.imgUrl,
            imgFile: upCargo.imgFile,
            isDown: isDownCompleted,
            locationIndex: upLocationIndex,
            downIndex: downLocationIndex, // 하차된 location의 인덱스
            id: upCargo.id,
            cargoIndex: cargoIndex);

        allUpCargos.add(newCargo);
      }
    }
  }

  return (allUpCargos, unfinishedCount);
}
