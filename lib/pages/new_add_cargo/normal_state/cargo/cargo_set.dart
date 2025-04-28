import 'dart:io';

import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/normal_state/cargo/dialog/cargoInfo_dialog.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/normal_state/cargo/dialog/dialog.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/normal_state/up_down/set_page/address.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/search/search_main.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/pick_image_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/loading_page.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/bottomSheet.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class CargoSetPage extends StatefulWidget {
  const CargoSetPage({super.key});

  @override
  State<CargoSetPage> createState() => _CargoSetPageState();
}

class _CargoSetPageState extends State<CargoSetPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final addProvider = Provider.of<AddProvider>(context, listen: false);
    if (addProvider.addCargoEtc != null) {
      _multiText.text = addProvider.addCargoEtc.toString();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _multiText.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '차량 & 화물 정보 등록',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchMainPage(
                    callType: '화물',
                    type: '기본',
                  ),
                ),
              );

              // 결과 데이터가 있으면 TextController에 설정
              if (result != null) {}
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
      body: GestureDetector(
        onTap: () {
          hideKeyboard(context);
        },
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(child: _contents(addProvider)),
                  if (addProvider.setCarType != null &&
                      addProvider.addCargoInfo != null)
                    _btnMain(addProvider),
                ],
              ),
              if (addProvider.addLoading == true) const LoadingPage()
            ],
          ),
        )),
      ),
    );
  }

  Widget _btnMain(AddProvider addProvider) {
    return DelayedWidget(
      animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
      animationDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: () async {
          HapticFeedback.lightImpact();
          addProvider.addCargoEtcState(_multiText.text.trim());
          Navigator.pop(context);
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), color: kGreenFontColor),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KTextWidget(
                  text: '차량 & 화물 정보 등록',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)
            ],
          ),
        ),
      ),
    );
  }

  Widget _contents(AddProvider addProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _cargoInfo(addProvider),
          _carTypeSel(addProvider),
          _cargoInfoPhoto(addProvider),
          _multiEtc(addProvider),
          const SizedBox(height: 150),
        ],
      ),
    );
  }

  Widget _cargoInfo(AddProvider addProvider) {
    final dw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: dw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KTextWidget(
              text: '운송 조건 선택',
              size: 16,
              fontWeight: null,
              color: Colors.grey.withOpacity(0.7)),
          KTextWidget(
              text: '운송하실 화물의 기본 정보를 선택하세요.',
              size: 12,
              fontWeight: null,
              color: Colors.grey.withOpacity(0.7)),
          const SizedBox(height: 16),
          Container(
            // height: 125,
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), color: msgBackColor),
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 20),
                    const KTextWidget(
                        text: '상세 정보',
                        size: 14,
                        fontWeight: null,
                        color: Colors.grey),
                    const Expanded(child: SizedBox()),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        addProvider.setIsBlindState(false);
                      },
                      child: Container(
                        //width: 76,
                        padding: const EdgeInsets.only(right: 16),
                        height: 34,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: addProvider.setIsBlind == false
                                ? kGreenFontColor.withOpacity(0.16)
                                : null),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check,
                              color: addProvider.setIsBlind == false
                                  ? kGreenFontColor
                                  : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            KTextWidget(
                                text: '공개',
                                size: 15,
                                fontWeight: FontWeight.bold,
                                color: addProvider.setIsBlind == false
                                    ? kGreenFontColor
                                    : Colors.grey)
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        addProvider.setIsBlindState(true);
                      },
                      child: Container(
                        //  width: 76,
                        margin: const EdgeInsets.only(right: 16),
                        height: 34,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: addProvider.setIsBlind == true
                                ? kRedColor.withOpacity(0.16)
                                : null),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check,
                              color: addProvider.setIsBlind == true
                                  ? kRedColor
                                  : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            KTextWidget(
                                text: '비공개',
                                size: 15,
                                fontWeight: FontWeight.bold,
                                color: addProvider.setIsBlind == true
                                    ? kRedColor
                                    : Colors.grey),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Divider(
                    height: 1,
                    color: Colors.grey.withOpacity(0.25),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const SizedBox(width: 20),
                    const KTextWidget(
                        text: '조수석 화물',
                        size: 14,
                        fontWeight: null,
                        color: Colors.grey),
                    const Expanded(child: SizedBox()),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        addProvider.cargoCategoryState('일반화물');
                      },
                      child: Container(
                        //width: 76,
                        padding: const EdgeInsets.only(right: 16),
                        height: 34,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: addProvider.cargoCategory == '일반화물'
                                ? kGreenFontColor.withOpacity(0.16)
                                : null),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check,
                              color: addProvider.cargoCategory == '일반화물'
                                  ? kGreenFontColor
                                  : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            KTextWidget(
                                text: '일반',
                                size: 15,
                                fontWeight: FontWeight.bold,
                                color: addProvider.cargoCategory == '일반화물'
                                    ? kGreenFontColor
                                    : Colors.grey)
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        addProvider.cargoCategoryState('조수석 화물');
                        _btm1();
                      },
                      child: Container(
                        //  width: 76,
                        margin: const EdgeInsets.only(right: 16),
                        height: 34,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: addProvider.cargoCategory == '조수석 화물'
                                ? kGreenFontColor.withOpacity(0.16)
                                : null),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check,
                              color: addProvider.cargoCategory == '조수석 화물'
                                  ? kGreenFontColor
                                  : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            KTextWidget(
                                text: '조수석',
                                size: 15,
                                fontWeight: FontWeight.bold,
                                color: addProvider.cargoCategory == '조수석 화물'
                                    ? kGreenFontColor
                                    : Colors.grey),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Divider(
                    height: 1,
                    color: Colors.grey.withOpacity(0.25),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const SizedBox(width: 20),
                    const KTextWidget(
                        text: '동승 여부',
                        size: 14,
                        fontWeight: null,
                        color: Colors.grey),
                    const Expanded(child: SizedBox()),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        addProvider.isWithState(true);
                        _btm2();
                      },
                      child: Container(
                        height: 34,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: addProvider.isWith == true
                                ? kBlueBssetColor.withOpacity(0.16)
                                : null),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check,
                              color: addProvider.isWith == true
                                  ? kBlueBssetColor
                                  : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            KTextWidget(
                                text: '1인 동승',
                                size: 15,
                                fontWeight: FontWeight.bold,
                                color: addProvider.isWith == true
                                    ? kBlueBssetColor
                                    : Colors.grey),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        addProvider.isWithState(false);
                      },
                      child: Container(
                        //  width: 76,
                        height: 34,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: addProvider.isWith == false
                                ? kRedColor.withOpacity(0.16)
                                : null),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check,
                              color: addProvider.isWith == false
                                  ? kRedColor
                                  : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            KTextWidget(
                                text: '없음',
                                size: 15,
                                fontWeight: FontWeight.bold,
                                color: addProvider.isWith == false
                                    ? kRedColor
                                    : Colors.grey),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _btm1() {
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
                const Icon(Icons.info, size: 70, color: kGreenFontColor),
                const SizedBox(height: 32),
                const KTextWidget(
                    text: '조수석 화물에 대한 안내를 확인하세요.',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                const KTextWidget(
                    text: '현재, 조수석 화물을 선택하셨습니다.',
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey),
                const KTextWidget(
                    text:
                        '조수석 화물은 차량의 조수석에 화물을 운송하는 것으로,\n반려동물 또는  작은 사이즈 화물에 적합합니다.',
                    size: 14,
                    textAlign: TextAlign.center,
                    fontWeight: null,
                    color: Colors.grey),
                const KTextWidget(
                    text: '화물 등록시, 꼭 화물 사진을 첨부하세요!',
                    size: 14,
                    textAlign: TextAlign.center,
                    fontWeight: null,
                    color: Colors.grey),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 52,
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    width: dw,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: kGreenFontColor),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const KTextWidget(
                            text: '확인',
                            size: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ));
        });
      },
    );
  }

  void _btm2() {
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
                const Icon(Icons.info, size: 70, color: kBlueBssetColor),
                const SizedBox(height: 32),
                const KTextWidget(
                    text: '동반 탑승에 대한 안내를 확인하세요.',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                const KTextWidget(
                    text: '현재, 동반 탑승을 선택하였습니다.',
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey),
                const KTextWidget(
                    text: '화물과 함께 1인이 동반하여 탑승하는 것을 말합니다.',
                    size: 14,
                    textAlign: TextAlign.center,
                    fontWeight: null,
                    color: Colors.grey),
                const KTextWidget(
                    text: '동반 탑승시 추가 비용이 발생합니다.',
                    size: 14,
                    textAlign: TextAlign.center,
                    fontWeight: null,
                    color: Colors.grey),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 52,
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    width: dw,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: kBlueBssetColor),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const KTextWidget(
                            text: '확인',
                            size: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ));
        });
      },
    );
  }

  Widget _carTypeSel(AddProvider addProvider) {
    final dw = MediaQuery.of(context).size.width;
    bool _isDone =
        addProvider.setCarType != null && addProvider.setCarTon.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextWidget(
            text: '운송 차량 등록',
            size: 16,
            fontWeight: FontWeight.bold,
            color: _isDone ? Colors.grey.withOpacity(0.5) : Colors.white),
        if (!_isDone)
          const KTextWidget(
              text: '원하시는 운송 차량 유형을 선택하세요.',
              size: 12,
              fontWeight: null,
              color: Colors.grey),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end, // 하단 정렬로 변경
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context)
                              .viewInsets
                              .bottom, // 키보드 높이만큼 패딩
                        ),
                        child: DelayedWidget(
                          animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
                          animationDuration: const Duration(milliseconds: 500),
                          child: Container(
                              width: dw,
                              height: 654, // 고정 높이 유지
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: msgBackColor),
                              child: const AddCargoDialog()),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Container(
            height: 56,
            //padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color:
                    addProvider.setCarTon.isNotEmpty ? msgBackColor : noState),
            child: _isDone
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /* if (addProvider.carTon.contains(999))
                            KTextWidget(
                                text: addProvider.setCarType.toString() +
                                    ' ' +
                                    '${addProvider.carOption}',
                                size: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white), */

                          RichText(
                              text: TextSpan(children: [
                            if (addProvider.setCarType == '카고')
                              const TextSpan(
                                  text: '카고 트럭',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold))
                            else if (addProvider.setCarType == '윙')
                              const TextSpan(
                                  text: '윙바디',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold))
                            else if (addProvider.setCarType == '탑')
                              const TextSpan(
                                  text: '탑 트럭',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold))
                            else if (addProvider.setCarType == '탑')
                              const TextSpan(
                                  text: '호로 트럭',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold))
                            else
                              TextSpan(
                                  text: addProvider.setCarType.toString(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            if (addProvider.carOption.contains('없음') == false)
                              TextSpan(
                                  text: ' ${addProvider.carOption}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                          ])),
                          if (addProvider.setCarTon.contains(999))
                            const KTextWidget(
                                text: '중량 무관',
                                size: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)
                          else
                            KTextWidget(
                                text: addProvider.setCarTon
                                        .toString()
                                        .replaceAll('[', '')
                                        .replaceAll(']', '') +
                                    '톤',
                                size: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)
                        ],
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_shipping_outlined),
                      const SizedBox(width: 10),
                      const KTextWidget(
                          text: '운송 차량 정보 등록',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  ///////////////////////////////////////////////////

  Widget _cargoInfoPhoto(AddProvider addProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextWidget(
            text: '화물 정보 등록',
            size: 16,
            fontWeight: FontWeight.bold,
            color: addProvider.addCargoInfo != null
                ? Colors.grey.withOpacity(0.5)
                : Colors.white),
        if (addProvider.addCargoInfo == null)
          const Row(
            children: [
              Icon(
                Icons.info,
                size: 12,
                color: Colors.grey,
              ),
              SizedBox(width: 5),
              KTextWidget(
                  text: '가능한 상세한 화물 정보를 등록하세요.',
                  size: 12,
                  fontWeight: null,
                  color: Colors.grey),
            ],
          ),
        if (addProvider.addCargoInfo == null)
          const Row(
            children: [
              Icon(
                Icons.info,
                size: 12,
                color: Colors.grey,
              ),
              SizedBox(width: 5),
              KTextWidget(
                  text: '화물 사진을 등록하면, 배차확률이 높아져요!',
                  size: 12,
                  fontWeight: null,
                  color: Colors.grey),
            ],
          ),
        const SizedBox(height: 16),
        _cargoBoxUp(addProvider),
        const SizedBox(height: 8),
        _cargoBoxDown(addProvider),
      ],
    );
  }

  Widget _cargoBoxUp(AddProvider addProvider) {
    final dw = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        hideKeyboard(context);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return PickImageBottom(
              callType: '화물등록',
              comUid: 'null',
            );
          },
        );
      },
      child: addProvider.cargoImage == null && addProvider.resetImgUrl == null
          ? Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: msgBackColor,
              ),
              child: Column(
                children: [
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: noState,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          color: Colors.white,
                          size: 19,
                        ),
                        SizedBox(width: 5),
                        KTextWidget(
                          text: '화물 사진을 등록하세요!',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          : Stack(
              children: [
                Container(
                  width: dw,
                  height: 200,
                  child: addProvider.cargoImage != null
                      ? ClipRRect(
                          // 이미지에도 borderRadius 적용하기 위해 ClipRRect 사용
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20)),
                          child: Image.file(
                            addProvider.cargoImage!,
                            fit: BoxFit.cover, // 여기서 BoxFit 변경
                            errorBuilder: (context, error, stackTrace) {
                              print('이미지 로드 에러: $error');
                              return const Center(
                                child: Text('이미지를 불러올 수 없습니다'),
                              );
                            },
                          ),
                        )
                      : addProvider.resetImgUrl != null
                          ? ClipRRect(
                              // 이미지에도 borderRadius 적용하기 위해 ClipRRect 사용
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20)),
                              child: Image.network(
                                addProvider.resetImgUrl.toString(),
                                fit: BoxFit.cover, // 여기서 BoxFit 변경
                                errorBuilder: (context, error, stackTrace) {
                                  print('이미지 로드 에러: $error');
                                  return const Center(
                                    child: Text('이미지를 불러올 수 없습니다'),
                                  );
                                },
                              ),
                            )
                          : const Center(
                              child: Text('이미지가 없습니다'),
                            ),
                ),
                Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        addProvider.cargoImageState(null);
                        addProvider.resetImgUrlState(null);
                      },
                      child: const Icon(
                        Icons.cancel,
                        color: kRedColor,
                      ),
                    ))
              ],
            ),
    );
  }

  bool _isLoad = false;
  Widget _cargoBoxDown(AddProvider addProvider) {
    final dw = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (addProvider.setCarType == null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(errorSnackBar('운송 차량 정보를 먼저 등록하세요.', context));
        } else {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end, // 하단 정렬로 변경
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context)
                            .viewInsets
                            .bottom, // 키보드 높이만큼 패딩
                      ),
                      child: DelayedWidget(
                        animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
                        animationDuration: const Duration(milliseconds: 500),
                        child: Container(
                            width: dw,
                            height: 654, // 고정 높이 유지
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: msgBackColor),
                            child: const CargoInfoSet()),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
      child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              color: msgBackColor),
          child:
              addProvider.addCargoInfo != null && addProvider.setCarTon != null
                  ? _cargoInfoCom(addProvider)
                  : Column(
                      children: [
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: noState),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.document_scanner_outlined,
                                color: Colors.white,
                                size: 19,
                              ),
                              SizedBox(width: 5),
                              KTextWidget(
                                  text: '화물 정보를 등록하세요!',
                                  size: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)
                            ],
                          ),
                        )
                      ],
                    )),
    );
  }

  Widget _cargoInfoCom(AddProvider addProvider) {
    final dw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: dw,
      child: Column(
        children: [
          Divider(
            color: Colors.grey.withOpacity(0.5),
          ),
          Row(
            children: [
              const KTextWidget(
                  text: '화물 정보',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(
                child: KTextWidget(
                    text: addProvider.addCargoInfo.toString(),
                    size: 14,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              )
            ],
          ),
          Row(
            children: [
              const KTextWidget(
                  text: '화물 중량',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey),
              const Spacer(),
              KTextWidget(
                  text:
                      '${addProvider.addCargoTon} ${addProvider.addCargoTonString}',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)
            ],
          ),
          /*   if (addProvider.addCargoSizeGaro != null ||
              addProvider.addCargoSizeGaro != 0.0) */
          Row(
            children: [
              const KTextWidget(
                  text: '화물 사이즈',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey),
              const Spacer(),
              if (addProvider.addCargoCbm ==
                      null ||
                  addProvider.addCargoCbm == 0)
                const KTextWidget(
                    text: '사이즈 정보 없음',
                    size: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)
              else
                KTextWidget(
                    text:
                        '가로 ${addProvider.addCargoSizeGaro}m | 세로 ${addProvider.addCargoSizeSero}m | 높이 ${addProvider.addCargoSizeHi}m',
                    size: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)
            ],
          ),
          Row(
            children: [
              const KTextWidget(
                  text: 'CBM', size: 14, fontWeight: null, color: Colors.grey),
              const Spacer(),
              if (addProvider.addCargoCbm == null ||
                  addProvider.addCargoCbm == 0)
                const KTextWidget(
                    text: 'CBM 정보 없음',
                    size: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)
              else
                KTextWidget(
                    text: addProvider.addCargoCbm.toString(),
                    size: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)
            ],
          ),
          Divider(
            color: Colors.grey.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  /////////////////////////////

  TextEditingController _multiText = TextEditingController();

  Widget _multiEtc(AddProvider addProvider) {
    final dw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: dw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          KTextWidget(
              text: '안내, 주의사항',
              size: 16,
              fontWeight: null,
              color: Colors.grey.withOpacity(0.7)),
          KTextWidget(
              text: '화물에 대한 주의사항 또는 안내사항을 입력하세요.',
              size: 12,
              fontWeight: null,
              color: Colors.grey.withOpacity(0.7)),
          const SizedBox(height: 12),
          Container(
              //height: 56,
              child: TextFormField(
            controller: _multiText,
            cursorColor: kGreenFontColor,
            autocorrect: false,
            maxLength: 100,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            minLines: 3,
            maxLines: 3,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              counterStyle: const TextStyle(fontSize: 0),
              errorStyle:
                  const TextStyle(fontSize: 0, height: 0), // 기본 에러 스타일 완전히 숨기기
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: kRedColor)),
              errorText: null, // 기본 에러 텍스트 비활성화
              filled: true,
              fillColor: btnColor,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 10,
              ),
              hintText: '화물 특성 또는 참고사항은 입력하세요.(필요 시)',
              hintStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.grey,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: kGreenFontColor, width: 1.0),
                borderRadius: BorderRadius.circular(10),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          )),
        ],
      ),
    );
  }
}
