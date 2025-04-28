import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/normal_state/price/price_set.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class AddPricePage extends StatefulWidget {
  final String callType;
  const AddPricePage({super.key, required this.callType});

  @override
  State<AddPricePage> createState() => _AddPricePageState();
}

class _AddPricePageState extends State<AddPricePage> {
  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    final dw = MediaQuery.of(context).size.width;
    bool _isDone = (addProvider.isPriceType == '직접 결제'
        ? addProvider.payHowto.length >= 2
        : addProvider.isPriceType == '포인트 결제');
    return SizedBox(
      width: dw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          KTextWidget(
              text: '결제 및 기타 정보 설정',
              size: 16,
              fontWeight: FontWeight.bold,
              color: _isDone ? Colors.grey.withOpacity(0.5) : Colors.white),
          if (!_isDone)
            const KTextWidget(
                text: '운송료 및 기타 상세 정보를 등록하세요.',
                size: 14,
                fontWeight: null,
                color: Colors.grey),
          const SizedBox(height: 12),
          _noSetBox(addProvider, context)
        ],
      ),
    );
  }

  Widget _noSetBox(AddProvider addProvider, context) {
    bool _isDone = (addProvider.isPriceType == '직접 결제'
        ? addProvider.payHowto.length >= 2
        : addProvider.isPriceType == '포인트 결제');
    return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PriceSetPage(
                      callType: widget.callType,
                    )),
          );
        },
        child: _isDone
            ? _doneState(addProvider)
            : Container(
                padding: _isDone
                    ? const EdgeInsets.all(8)
                    : const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: msgBackColor),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'asset/img/tag.png',
                          width: 15,
                        ),
                        const SizedBox(width: 10),
                        const KTextWidget(
                            text: '이곳을 클릭하여 기타 정보를 설정하세요.',
                            size: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)
                      ],
                    ),
                  ],
                ),
              ));
  }

  Widget _doneState(AddProvider addProvider) {
    return Column(
      children: [
        Container(
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: kOrangeBssetColor.withOpacity(0.1),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'asset/img/tag.png',
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 6),
                    const KTextWidget(
                      text: '결제 정보',
                      size: 13,
                      fontWeight: FontWeight.bold,
                      color: kOrangeBssetColor,
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
              KTextWidget(
                text: addProvider.senderType == '일반'
                    ? '일반인 직접 등록'
                    : '일반 기업 직접 등록',
                size: 13,
                fontWeight: FontWeight.bold,
                color: kOrangeBssetColor,
              )
            ],
          ),
        ),
        _normalPState(addProvider),
        const SizedBox(height: 8),
        _cation(),
      ],
    );
  }

  Widget _normalPState(AddProvider addProvider) {
    return Container(
      decoration: BoxDecoration(
          color: msgBackColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16))),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KTextWidget(
                  text: '운송료 제안받는 중...',
                  size: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ],
          ),
          if (addProvider.payHowto == '직접 결제')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KTextWidget(
                    text: addProvider.payHowto[1].toString(),
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: kOrangeBssetColor),
              ],
            )
          else
            KTextWidget(
                text: addProvider.payHowto[1],
                size: 14,
                fontWeight: FontWeight.bold,
                color: kOrangeBssetColor),
          const SizedBox(height: 16),
          if (addProvider.isCashRec == true ||
              addProvider.isDoneRec == true ||
              addProvider.isNormalEtax == true)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8, left: 8),
                  child: Divider(
                    thickness: 2,
                    color: dialogColor,
                  ),
                ),
                const SizedBox(height: 8),
                if (addProvider.isCashRec == true)
                  _buildMinimalInfoRow(
                      icon: Icons.cases_sharp,
                      title: '현금영수증',
                      value: ' 현금영수증 발행을 요청했습니다.'),
                if (addProvider.isDoneRec == true)
                  _buildMinimalInfoRow(
                      icon: Icons.receipt,
                      title: '인수증',
                      value: '인수증 등록을 요청했습니다.'),
                if (addProvider.isNormalEtax == true)
                  _buildMinimalInfoRow(
                      icon: Icons.receipt,
                      title: '전자세금계산서',
                      value: '전자세금계산서 발행을 요청했습니다.'),
                const SizedBox(height: 8),
              ],
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8, left: 8),
            child: Divider(
              thickness: 2,
              color: dialogColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildMinimalInfoRow(
              icon: Icons.info,
              title: '안내',
              value: '일반인 또는 기업이 직접 등록한 건입니다.\n운송료 제안 후, 승락되면 배차됩니다.'),
          if (addProvider.isCashRec == true ||
              addProvider.isDoneRec == true ||
              addProvider.isNormalEtax == true)
            _buildMinimalInfoRow(
                icon: Icons.info,
                title: '안내',
                value: '전자세금계산서, 인수증, 현금영수증은\n운송완료 후, 앱에서 발행 가능합니다.'),
          /* if (addProvider.etc != null &&
              widget.cargoData['priceEtc'] != '')
            _buildMinimalInfoRow(
                icon: Icons.warning_rounded,
                title: '주의',
                value: widget.cargoData['priceEtc'].toString()), */
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

  Widget _cation() {
    return const Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.info,
              size: 12,
              color: Colors.grey,
            ),
            SizedBox(width: 5),
            KTextWidget(
                text: '잘못된 정보로 인한 문제는 혼적콜이 책임지지 않습니다.',
                size: 12,
                fontWeight: null,
                color: Colors.grey),
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.info,
              size: 12,
              color: Colors.grey,
            ),
            SizedBox(width: 5),
            KTextWidget(
                text: '지정된 주선사로 직접 연결하려면 상단에서 설정하세요.',
                size: 12,
                fontWeight: null,
                color: Colors.grey),
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.info,
              size: 12,
              color: Colors.grey,
            ),
            SizedBox(width: 5),
            KTextWidget(
                text: '등록 후, 입찰에 응하지 않으면 페널티가 부여됩니다.',
                size: 12,
                fontWeight: null,
                color: Colors.grey),
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.info,
              size: 12,
              color: Colors.grey,
            ),
            SizedBox(width: 5),
            KTextWidget(
                text: '혼적콜은 단순 정보 게시 외 결제, 운송 책임을 지지 않습니다.',
                size: 12,
                fontWeight: null,
                color: Colors.grey),
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.info,
              size: 12,
              color: Colors.grey,
            ),
            SizedBox(width: 5),
            KTextWidget(
                text: '안전한 운송을 원하시면, 주선사 입찰건을 선택하세요.',
                size: 12,
                fontWeight: null,
                color: Colors.grey),
          ],
        ),
      ],
    );
  }
}
