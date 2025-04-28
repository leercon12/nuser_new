import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/normal_state/cargo/dialog/dialog.dart';
import 'package:flutter_mixcall_normaluser_new/pages/weather/helper.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class MultiCarMain extends StatefulWidget {
  const MultiCarMain({super.key});

  @override
  State<MultiCarMain> createState() => _MultiCarMainState();
}

class _MultiCarMainState extends State<MultiCarMain> {
  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    final dh = MediaQuery.of(context).size.height;
    final addProvider = Provider.of<AddProvider>(context);
    bool isState = addProvider.setCarTon.isEmpty;
    return SizedBox(
      width: dw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //const SizedBox(height: 12),
          KTextWidget(
              text: '운송 차량 정보 등록',
              size: 16,
              fontWeight: FontWeight.bold,
              color: !isState ? Colors.grey.withOpacity(0.5) : Colors.white),
          isState
              ? const KTextWidget(
                  text: '원하시는 운송 차량의 정보를 등록하세요.',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey)
              : const SizedBox(),
          const SizedBox(height: 12),
          _multiCargo(addProvider, dw, dh)
        ],
      ),
    );
  }

  Widget _multiCargo(AddProvider addProvider, double dw, double dh) {
    return GestureDetector(
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
                          height: dh * 0.8, // 고정 높이 유지
                          padding: const EdgeInsets.only(left: 10, right: 10),
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
      child: addProvider.setCarTon.isNotEmpty
          ? _completeState(addProvider)
          : Container(
              padding: addProvider.setCarTon.isNotEmpty
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
                        'asset/img/box-truck.png',
                        width: 15,
                      ),
                      const SizedBox(width: 10),
                      const KTextWidget(
                          text: '이곳을 클릭하여 차량 정보를 등록하세요.',
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

  Widget _completeState(AddProvider addProvider) {
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
          _buildHeader(addProvider),
          _buildBody(
            addProvider,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AddProvider addProvider) {
    return Container(
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
          _buildHeaderTag(),
          const Spacer(),
          if (addProvider.cargoCategory!.contains('조수석'))
            const KTextWidget(
              text: '조수석 화물',
              size: 13,
              fontWeight: FontWeight.bold,
              color: kGreenFontColor,
            )
          else
            const KTextWidget(
              text: '일반 화물',
              size: 13,
              fontWeight: FontWeight.bold,
              color: kGreenFontColor,
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: kGreenFontColor.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Image.asset(
            'asset/img/box-truck.png',
            width: 16,
            height: 16,
          ),
          const SizedBox(width: 6),
          const KTextWidget(
            text: '요청 차량 정보',
            size: 13,
            fontWeight: FontWeight.bold,
            color: kGreenFontColor,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AddProvider addProvider) {
    return Container(
      decoration: const BoxDecoration(
        color: msgBackColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          _buildCarInfo(addProvider),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 8, left: 8),
            child: Divider(
              thickness: 2,
              color: dialogColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildCargoDetails(addProvider),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 8, left: 8),
            child: Divider(
              thickness: 2,
              color: dialogColor,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCarInfo(AddProvider addProvider) {
    final String carType = addProvider.setCarType.toString();
    final String carOption = addProvider.carOption.toString();
    final dynamic carTon = addProvider.setCarTon;

    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KTextWidget(
              text: carType,
              size: 18,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            if (!carOption.contains('없음'))
              KTextWidget(
                text: '_[${carOption.replaceAll('[', '').replaceAll(']', '')}]',
                size: 14,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.bold,
                color: kGreenFontColor,
              ),
          ],
        ),
        KTextWidget(
          text: carTon.toString().contains('999')
              ? '중량 무관'
              : '${carTon.toString().replaceAll('[', '').replaceAll(']', '')}톤',
          size: 14,
          fontWeight: null,
          color: Colors.grey,
        ),
      ],
    );
  }

  // 화물 세부정보 위젯
  Widget _buildCargoDetails(AddProvider addProvider) {
    return Column(
      children: [
        if (addProvider.addMainType == '다구간' || addProvider.addMainType == '왕복')
          buildMinimalInfoRow(
            icon: Icons.done_all,
            title: '화물 정보',
            value: '상, 하차 상세 정보를 확인하세요.',
          ),
        buildMinimalInfoRow(
          icon: Icons.route,
          title: '운송 유형',
          value: '${addProvider.cargoCategory}, ${addProvider.addMainType} 배송',
        ),
        buildMinimalInfoRow(
          icon: Icons.schedule,
          title: '등록 일시',
          value: '...',
        ),
        if (addProvider.isWith == true ||
            addProvider.cargoCategory!.contains('조수석'))
          buildMinimalInfoRow(
              icon: Icons.question_answer_outlined,
              title: '요청',
              fontWeight: FontWeight.bold,
              value: addProvider.isWith == true &&
                      addProvider.cargoCategory!.contains('조수석')
                  ? '1인 동반, 조수석 화물'
                  : addProvider.isWith == true
                      ? '1인 동반 탑승'
                      : '조수석 화물',
              valueColor: kOrangeAssetColor),
        /*   _buildMinimalInfoRow(
          icon: Icons.token,
          title: '무게',
          valueColor: kGreenFontColor,
          fontWeight: FontWeight.bold,
          value: '${cargoData['cargoWe']} ${cargoData['cargoWeType']}',
        ),
        _buildMinimalInfoRow(
          icon: Icons.photo_size_select_small_rounded,
          title: '사이즈',
          valueColor: kGreenFontColor,
          fontWeight: FontWeight.bold,
          value: _getCargoSizeText(),
        ), */
        if (addProvider.addCargoEtc != null && addProvider.addCargoEtc != '')
          buildMinimalInfoRow(
            icon: Icons.warning_rounded,
            title: '주의',
            value: addProvider.addCargoEtc.toString(),
          ),
      ],
    );
  }
}
