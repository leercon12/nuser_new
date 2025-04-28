import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/image_dialog.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';

class DetailCargoCarInfo extends StatefulWidget {
  final Map<String, dynamic> cargoData;
  const DetailCargoCarInfo({super.key, required this.cargoData});

  @override
  State<DetailCargoCarInfo> createState() => _DetailCargoCarInfoState();
}

class _DetailCargoCarInfoState extends State<DetailCargoCarInfo> {
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

  // 헤더 부분 위젯
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
          if (widget.cargoData['cargoCategory'].contains('조수석'))
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
            'asset/img/pack_de.png',
            width: 16,
            height: 16,
          ),
          const SizedBox(width: 6),
          const KTextWidget(
            text: '화물 & 차량 정보',
            size: 13,
            fontWeight: FontWeight.bold,
            color: kGreenFontColor,
          ),
        ],
      ),
    );
  }

// 본문 위젯
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
          if (widget.cargoData['cargoPhotoUrl'] != null)
            _buildCargoImage(deviceWidth, context),
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

// 화물 이미지 위젯
  Widget _buildCargoImage(double deviceWidth, BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showDialog(
          context: context,
          builder: (context) => ImageViewerDialog(
            networkUrl: widget.cargoData['cargoPhotoUrl'].toString(),
            callType: 'url',
          ),
        );
      },
      child: Container(
        width: deviceWidth,
        height: 200,
        color: msgBackColor,
        padding: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: widget.cargoData['cargoPhotoUrl'],
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

// 차량 정보 위젯
  Widget _buildCarInfo() {
    final String carType = widget.cargoData['carType'].toString();
    final String carOption = widget.cargoData['carOption'].toString();
    final dynamic carTon = widget.cargoData['carTon'];

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
        _buildMinimalInfoRow(
          icon: Icons.add_box_rounded,
          title: '화물',
          value: widget.cargoData['cargoType'],
        ),
        if (widget.cargoData['isWith'] == true ||
            widget.cargoData['cargoCategory'].contains('조수석'))
          _buildMinimalInfoRow(
              icon: Icons.question_answer_outlined,
              title: '요청',
              fontWeight: FontWeight.bold,
              value: widget.cargoData['isWith'] == true &&
                      widget.cargoData['cargoCategory'].contains('조수석')
                  ? '1인 동반, 조수석 화물'
                  : widget.cargoData['isWith'] == true
                      ? '1인 동반 탑승'
                      : '조수석 화물',
              valueColor: kOrangeAssetColor),
        _buildMinimalInfoRow(
          icon: Icons.token,
          title: '무게',
          valueColor: kGreenFontColor,
          fontWeight: FontWeight.bold,
          value:
              '${widget.cargoData['cargoWe']} ${widget.cargoData['cargoWeType']}',
        ),
        _buildMinimalInfoRow(
          icon: Icons.photo_size_select_small_rounded,
          title: '사이즈',
          valueColor: kGreenFontColor,
          fontWeight: FontWeight.bold,
          value: _getCargoSizeText(),
        ),
        if (_hasCargoExtraInfo())
          _buildMinimalInfoRow(
            icon: Icons.warning_rounded,
            title: '주의',
            value: widget.cargoData['cargoEtc'],
          ),
      ],
    );
  }

// 화물 사이즈 텍스트 구하기
  String _getCargoSizeText() {
    final dynamic cbm = widget.cargoData['cbm'];

    if (cbm == 0 || cbm == null) {
      return '사이즈 정보 없음';
    }

    return '가로 ${widget.cargoData['garo']}m | 세로 ${widget.cargoData['sero']}m | 높이 ${widget.cargoData['he']}m\n[CBM : $cbm]';
  }

// 추가 정보 존재 여부 확인
  bool _hasCargoExtraInfo() {
    final dynamic cargoEtc = widget.cargoData['cargoEtc'];
    return cargoEtc != null && cargoEtc != '';
  }

// 정보 행 위젯
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
}
