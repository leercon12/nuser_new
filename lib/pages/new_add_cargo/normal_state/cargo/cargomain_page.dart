import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/normal_state/cargo/cargo_set.dart';
import 'package:flutter_mixcall_normaluser_new/pages/weather/helper.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/image_dialog.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class AddCargoPage extends StatefulWidget {
  final String? callType;
  const AddCargoPage({super.key, this.callType});

  @override
  State<AddCargoPage> createState() => _AddCargoPageState();
}

class _AddCargoPageState extends State<AddCargoPage> {
  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    final dw = MediaQuery.of(context).size.width;
    bool _isDone = addProvider.setCarType != null &&
        addProvider.carOption.isNotEmpty &&
        addProvider.setCarTon.isNotEmpty;
    return DelayedWidget(
        delayDuration: const Duration(milliseconds: 600),
        animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
        animationDuration: const Duration(milliseconds: 500),
        child: SizedBox(
          width: dw,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              KTextWidget(
                  text: '차량 및 화물 정보 등록',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: _isDone ? Colors.grey.withOpacity(0.5) : Colors.white),
              if (!_isDone)
                const KTextWidget(
                    text: '운송 차량 조건 및 화물 정보를 등록하세요.',
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey),
              const SizedBox(height: 12),
              _noSetBox(addProvider, context)
            ],
          ),
        ));
  }

  Widget _noSetBox(AddProvider addProvider, context) {
    bool _isDone = addProvider.setCarType != null &&
        addProvider.carOption.isNotEmpty &&
        addProvider.setCarTon.isNotEmpty &&
        addProvider.addCargoInfo != null;
    return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CargoSetPage()),
          );
        },
        child: !_isDone
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: msgBackColor),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'asset/img/pack_em.png',
                          width: 15,
                        ),
                        const SizedBox(width: 10),
                        const KTextWidget(
                            text: '이곳을 클릭하여 차량 & 화물 정보를 등록하세요.',
                            size: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)
                      ],
                    )
                  ],
                ),
              )
            : _cargo(addProvider));
  }

  Widget _cargo(AddProvider addProvider) {
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
          _buildHeader(addProvider),
          _buildBody(deviceWidth, addProvider, context),
        ],
      ),
    );
  }

  // 헤더 부분 위젯
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
          if (addProvider.cargoCategory == '조수석화물')
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

// 화물 이미지 위젯
  Widget _buildCargoImage(
      double deviceWidth, AddProvider addProvider, BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showDialog(
            context: context,
            builder: (context) => ImageViewerDialog(
                  imageFile: addProvider.cargoImage,
                ));
      },
      child: Container(
        width: deviceWidth,
        height: 200,
        color: msgBackColor,
        padding: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            addProvider.cargoImage!,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

// 본문 위젯
  Widget _buildBody(
      double deviceWidth, AddProvider addProvider, BuildContext context) {
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
          if (addProvider.cargoImage != null)
            _buildCargoImage(deviceWidth, addProvider, context),
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

  // 차량 정보 위젯
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
        _buildMinimalInfoRow(
          icon: Icons.add_box_rounded,
          title: '화물',
          value: addProvider.addCargoInfo.toString(),
        ),
        if (addProvider.isWith == true ||
            addProvider.cargoCategory!.contains('조수석'))
          _buildMinimalInfoRow(
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
        _buildMinimalInfoRow(
          icon: Icons.token,
          title: '무게',
          valueColor: kGreenFontColor,
          fontWeight: FontWeight.bold,
          value: '${addProvider.addCargoTon} ${addProvider.addCargoTonString}',
        ),
        _buildMinimalInfoRow(
          icon: Icons.photo_size_select_small_rounded,
          title: '사이즈',
          valueColor: kGreenFontColor,
          fontWeight: FontWeight.bold,
          value: _getCargoSizeText(addProvider),
        ),
        if (_hasCargoExtraInfo(addProvider))
          _buildMinimalInfoRow(
            icon: Icons.warning_rounded,
            title: '주의',
            value: addProvider.addCargoEtc.toString(),
          ),
      ],
    );
  }

  String _getCargoSizeText(AddProvider addProvider) {
    final dynamic cbm = addProvider.addCargoCbm;

    if (cbm == 0 || cbm == null) {
      return '사이즈 정보 없음';
    }

    return '가로 ${addProvider.addCargoSizeGaro}m | 세로 ${addProvider.addCargoSizeSero}m | 높이 ${addProvider.addCargoSizeHi}m\n[CBM : $cbm]';
  }

  bool _hasCargoExtraInfo(AddProvider addProvider) {
    final dynamic cargoEtc = addProvider.addCargoEtc;
    return cargoEtc != null && cargoEtc != '';
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
}
