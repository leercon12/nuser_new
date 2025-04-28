import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';

class FullMultiPricePage extends StatefulWidget {
  final String? callType;
  final Map<String, dynamic> cargoData;
  const FullMultiPricePage(
      {super.key, required this.callType, required this.cargoData});

  @override
  State<FullMultiPricePage> createState() => _FullMultiPricePageState();
}

class _FullMultiPricePageState extends State<FullMultiPricePage> {
  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
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
              if (widget.cargoData['comUid'] == null)
                KTextWidget(
                  text: widget.cargoData['senderType'] == '일반'
                      ? '일반인 직접 등록'
                      : '일반 기업 직접 등록',
                  size: 13,
                  fontWeight: FontWeight.bold,
                  color: kOrangeBssetColor,
                )
              else
                const KTextWidget(
                  text: '주선사 등록',
                  size: 13,
                  fontWeight: FontWeight.bold,
                  color: kOrangeBssetColor,
                )
            ],
          ),
        ),
        if (widget.cargoData['comUid'] == null)
          _normalPState()
        else
          _comPState(),
        const SizedBox(height: 8),
        //    _normalReady(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _normalPState() {
    return Container(
      decoration: BoxDecoration(
          color: msgBackColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16))),
      child: Column(
        children: [
          const SizedBox(height: 24),
          if (widget.cargoData['payMoney'] == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KTextWidget(
                    text: '운송료 제안받는 중...',
                    size: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KTextWidget(
                    text:
                        '${formatCurrency(widget.cargoData['payMoney'].toInt())}',
                    size: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                const SizedBox(width: 3),
                const KTextWidget(
                    text: '원',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ],
            ),
          if (widget.cargoData['norPayType'] == '직접 결제')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KTextWidget(
                    text: widget.cargoData['norPayHowto'][1].toString(),
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: kOrangeBssetColor),
              ],
            )
          else
            KTextWidget(
                text: widget.cargoData['norPayType'][1],
                size: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          const SizedBox(height: 16),
          if (widget.cargoData['cashRec'] == true ||
              widget.cargoData['doneRec'] == true ||
              widget.cargoData['normalEtax'] == true)
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
                if (widget.cargoData['cashRec'] == true)
                  _buildMinimalInfoRow(
                      icon: Icons.cases_sharp,
                      title: '현금영수증',
                      value: ' 현금영수증 발행을 요청했습니다.'),
                if (widget.cargoData['doneRec'] == true)
                  _buildMinimalInfoRow(
                      icon: Icons.receipt,
                      title: '인수증',
                      value: '인수증 등록을 요청했습니다.'),
                if (widget.cargoData['normalEtax'] == true)
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
          if (widget.cargoData['cashRec'] == true ||
              widget.cargoData['doneRec'] == true ||
              widget.cargoData['normalEtax'] == true)
            _buildMinimalInfoRow(
                icon: Icons.info,
                title: '안내',
                value: '전자세금계산서, 인수증, 현금영수증은\n운송완료 후, 앱에서 발행 가능합니다.'),
          if (widget.cargoData['priceEtc'] != null &&
              widget.cargoData['priceEtc'] != '')
            _buildMinimalInfoRow(
                icon: Icons.warning_rounded,
                title: '주의',
                value: widget.cargoData['priceEtc'].toString()),
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

  num? _fix1 = 0;

  num? _fix2 = 0;

  num? _fix3 = 0;

  Widget _comPState() {
    num _comPrice = widget.cargoData['payMoney'] + widget.cargoData['vat'];
    num _comPrice2 = (widget.cargoData['payMoney'] + widget.cargoData['vat']) -
        widget.cargoData['sanjeahalf'];

    if (widget.cargoData['fixPayMoney'] != null) {
      _fix1 = (widget.cargoData['fixPayMoney'] + widget.cargoData['fixVat']);
      _fix2 = (widget.cargoData['fixPayMoney'] + widget.cargoData['fixVat']) -
          widget.cargoData['fixSanjeaHalf'];
    }

    if (widget.cargoData['payCommission'] == null) {
      _fix3 = widget.cargoData['payMoney'];
    } else {
      _fix3 = widget.cargoData['payMoney'] - widget.cargoData['payCommission'];
    }
    return Container(
      decoration: BoxDecoration(
          color: msgBackColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16))),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KTextWidget(
                  text:
                      '${formatCurrency(widget.cargoData['payMoney'].toInt())}',
                  size: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              const SizedBox(width: 3),
              const KTextWidget(
                  text: '원',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _normalState(double dw) {
    return Column(
      children: [
        Row(
          children: [
            Image.asset(
              'asset/img/tag.png',
              width: 15,
            ),
            const SizedBox(width: 5),
            const KTextWidget(
                text: '결제 정보', size: 14, fontWeight: null, color: Colors.white)
          ],
        ),
        _price(),
        Divider(
          color: Colors.grey.withOpacity(0.3),
        ),
        const SizedBox(height: 8),
        if (widget.cargoData['payMoney'] == null)
          const KTextWidget(
              text:
                  '일반인 또는 일반 기업이 직접 등록한 운송 건으로,\n운송료를 제안하고 수락해야 배차받을 수 있습니다.\n아래 버튼을 통해 운송료를 제안하세요!',
              size: 14,
              textAlign: TextAlign.center,
              fontWeight: null,
              color: Colors.grey)
        else
          SizedBox(
            width: dw,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                KTextWidget(
                    text: '${widget.cargoData['norPayType']} 결제 방법을 확인하세요.',
                    size: 14,
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.bold,
                    color: kOrangeAssetColor),
                if (widget.cargoData['norPayType'] == '직접 결제')
                  Column(
                    children: [
                      const KTextWidget(
                          text: '직접 결제는 고객이 기사님께 직접 결제하는 것을 말합니다.',
                          size: 14,
                          textAlign: TextAlign.center,
                          fontWeight: null,
                          color: Colors.grey),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          KTextWidget(
                              text: '${widget.cargoData['norPayHowto'][1]}',
                              size: 14,
                              textAlign: TextAlign.center,
                              fontWeight: null,
                              color: kOrangeAssetColor),
                          KTextWidget(
                              text: '로 직접 운송료를 받아야합니다.',
                              size: 14,
                              textAlign: TextAlign.center,
                              fontWeight: null,
                              color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Divider(
          color: Colors.grey.withOpacity(0.3),
        ),
        /*  if (widget.cargoData['cashRec'] == true) _cashRec(),
        if (widget.cargoData['doneRec'] == true) _doneRec(),
        if (widget.cargoData['normalEtax'] == true) _etaxRec(), */
      ],
    );
  }

  Widget _price() {
    return Column(
      children: [
        const SizedBox(height: 18),
        if (widget.cargoData['payMoney'] == null)
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KTextWidget(
                  text: '운송료 제안받는 중...',
                  size: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KTextWidget(
                  text:
                      '${formatCurrency(widget.cargoData['payMoney'].toInt())}',
                  size: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              const SizedBox(width: 3),
              const KTextWidget(
                  text: '원',
                  size: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ],
          ),
        if (widget.cargoData['norPayType'] == '직접 결제')
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KTextWidget(
                  text: widget.cargoData['norPayHowto'][1].toString(),
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: kOrangeBssetColor),
            ],
          )
        else
          KTextWidget(
              text: widget.cargoData['norPayType'][1],
              size: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        if (widget.cargoData['cashRec'] == true ||
            widget.cargoData['doneRec'] == true ||
            widget.cargoData['normalEtax'] == true)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KTextWidget(
                  text: '|',
                  size: 13,
                  fontWeight: FontWeight.bold,
                  color: kGreenFontColor),
              if (widget.cargoData['cashRec'] == true)
                KTextWidget(
                    text:
                        widget.cargoData['doneRec'] == true ? ' 현금영수증 | ' : '',
                    size: 13,
                    fontWeight: FontWeight.bold,
                    color: kGreenFontColor),
              if (widget.cargoData['doneRec'] == true)
                const KTextWidget(
                    text: '인수증 등록 |',
                    size: 13,
                    fontWeight: FontWeight.bold,
                    color: kGreenFontColor),
              if (widget.cargoData['normalEtax'] == true)
                const KTextWidget(
                    text: ' 전자세금계산서 |',
                    size: 13,
                    fontWeight: FontWeight.bold,
                    color: kGreenFontColor),
            ],
          ),
        const SizedBox(height: 18),
      ],
    );
  }
}
