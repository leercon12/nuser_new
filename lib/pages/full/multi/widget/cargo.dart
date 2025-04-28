import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';

class FullMultiCargoPage extends StatelessWidget {
  final String? callType;
  final Map<String, dynamic> cargoData;
  const FullMultiCargoPage(
      {super.key, required this.callType, required this.cargoData});

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
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
          _buildHeader(),
          _buildBody(deviceWidth, context),
        ],
      ),
    );
  }

  Widget _buildBody(double deviceWidth, BuildContext context) {
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
          _buildCarInfo(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 8, left: 8),
            child: Divider(
              thickness: 2,
              color: dialogColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildCargoDetails(),
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

  Widget _buildCarInfo() {
    final String carType = cargoData['carType'].toString();
    final String carOption = cargoData['carOption'].toString();
    final dynamic carTon = cargoData['carTon'];

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
  Widget _buildCargoDetails() {
    return Column(
      children: [
        if (cargoData['aloneType'] == '다구간' || cargoData['aloneType'] == '왕복')
          _buildMinimalInfoRow(
            icon: Icons.done_all,
            title: '화물 정보',
            value: '상, 하차 상세 정보를 확인하세요.',
          ),
        _buildMinimalInfoRow(
          icon: Icons.route,
          title: '운송 유형',
          value: '${cargoData['cargoCategory']}, ${cargoData['aloneType']} 배송',
        ),
        _buildMinimalInfoRow(
          icon: Icons.schedule,
          title: '등록 일시',
          value: agoKorTimestamp(cargoData['createdDate']),
        ),
        if (cargoData['isWith'] == true ||
            cargoData['cargoCategory'].contains('조수석'))
          _buildMinimalInfoRow(
              icon: Icons.question_answer_outlined,
              title: '요청',
              fontWeight: FontWeight.bold,
              value: cargoData['isWith'] == true &&
                      cargoData['cargoCategory'].contains('조수석')
                  ? '1인 동반, 조수석 화물'
                  : cargoData['isWith'] == true
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
        if (_hasCargoExtraInfo())
          _buildMinimalInfoRow(
            icon: Icons.warning_rounded,
            title: '주의',
            value: cargoData['cargoEtc'],
          ),
      ],
    );
  }

  Widget _buildMinimalInfoRow({
    required IconData icon,
    required String title,
    required String value,
    FontWeight? fontWeight,
    Color? valueColor,
  }) {
    return Row(
      children: [
        const SizedBox(width: 10),
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 10),
        KTextWidget(
          text: title,
          size: 14,
          fontWeight: null,
          color: Colors.grey,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black26.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: KTextWidget(
              text: value,
              size: 14,
              textAlign: TextAlign.end,
              fontWeight: fontWeight,
              color: valueColor ?? Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // 화물 사이즈 텍스트 구하기
  String _getCargoSizeText() {
    final dynamic cbm = cargoData['cbm'];

    if (cbm == 0 || cbm == null) {
      return '사이즈 정보 없음';
    }

    return '가로 ${cargoData['garo']}m | 세로 ${cargoData['sero']}m | 높이 ${cargoData['he']}m\n[CBM : $cbm]';
  }

// 추가 정보 존재 여부 확인
  bool _hasCargoExtraInfo() {
    final dynamic cargoEtc = cargoData['cargoEtc'];
    return cargoEtc != null && cargoEtc != '';
  }

  Widget _buildHeader() {
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
          if (cargoData['cargoCategory'].contains('조수석'))
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

  // 헤더 태그 위젯
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
}
