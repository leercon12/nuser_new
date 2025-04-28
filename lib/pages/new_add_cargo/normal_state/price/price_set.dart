import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/etc.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PriceSetPage extends StatefulWidget {
  final String callType;
  const PriceSetPage({super.key, required this.callType});

  @override
  State<PriceSetPage> createState() => _PriceSetPageState();
}

class _PriceSetPageState extends State<PriceSetPage> {
  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '결제 정보 등록',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          hideKeyboard(context);
        },
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _mainContents(addProvider)),
              if (addProvider.senderType != null &&
                      addProvider.isPriceType == '직접 결제'
                  ? addProvider.payHowto.length >= 2
                  : addProvider.isPriceType == '포인트 결제')
                _btnMain(addProvider)
            ],
          ),
        )),
      ),
    );
  }

  Widget _mainContents(AddProvider addProvider) {
    final dw = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        children: [
          _senderType(addProvider),
          if (addProvider.senderType == '기업') _eTaxSet(addProvider, dw),
          if (addProvider.senderType != null) _priceSel(addProvider),
          if (addProvider.isPriceType == '직접 결제')
            DelayedWidget(
                delayDuration: const Duration(milliseconds: 100),
                animationDuration: const Duration(milliseconds: 500),
                animation: DelayedAnimations.SLIDE_FROM_TOP,
                child: _noPoint(addProvider, dw)),
          if (addProvider.isPriceType == '포인트 결제')
            DelayedWidget(
                delayDuration: const Duration(milliseconds: 100),
                animationDuration: const Duration(milliseconds: 500),
                animation: DelayedAnimations.SLIDE_FROM_TOP,
                child: _price(addProvider)),
          const SizedBox(height: 120),
          //_price(addProvider)
        ],
      ),
    );
  }

  bool _boxOpen = false;
  Widget _senderType(AddProvider addProvider) {
    final dataProvider = Provider.of<DataProvider>(context);
    final hashProvider = Provider.of<HashProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextWidget(
            text: '의뢰 유형 선택',
            size: 16,
            fontWeight: FontWeight.bold,
            color: addProvider.senderType == null
                ? Colors.white
                : Colors.grey.withOpacity(0.7)),
        KTextWidget(
            text: '개인 또는 소속된 기업, 단체 중 유형을 선택하세요.',
            size: 12,
            fontWeight: null,
            color: addProvider.senderType == null
                ? Colors.white
                : Colors.grey.withOpacity(0.7)),
        const SizedBox(height: 16),
        InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            if (widget.callType.contains('기사업데이트') ||
                widget.callType.contains('수정')) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(errorSnackBar('의뢰 유형은 수정할 수 없습니다.', context));
            } else {
              if (_boxOpen) {
                _boxOpen = false;
              } else {
                _boxOpen = true;
              }
              setState(() {});
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: _boxOpen ? 200 : 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: addProvider.senderType == null
                      ? _boxOpen
                          ? kGreenFontColor
                          : Colors.grey.withOpacity(0.5)
                      : kGreenFontColor),
            ),
            child: !_boxOpen
                ? Row(
                    children: [
                      const Spacer(),
                      KTextWidget(
                          text: addProvider.senderType != null
                              ? addProvider.senderType == '일반'
                                  ? dataProvider.name.length > 15
                                      ? '${hashProvider.decryptData(dataProvider.name)}님 일반 의뢰'
                                      : '${dataProvider.name}님 일반 의뢰'
                                  : '${dataProvider.comName}님 기업 의뢰'
                              : '의뢰 유형을 선택하세요.',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_drop_down,
                      ),
                      const SizedBox(width: 15),
                    ],
                  )
                : Column(
                    children: [
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          addProvider.senderTypeState('일반');
                          print(addProvider.senderType);
                          _boxOpen = false;
                          setState(() {});
                        },
                        child: Container(
                          height: 56,
                          child: Center(
                            child: KTextWidget(
                                text: dataProvider.name.length > 15
                                    ? '${hashProvider.decryptData(dataProvider.name)}님 일반 의뢰'
                                    : '${dataProvider.name}님 일반 의뢰',
                                size: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (dataProvider.comName != '') {
                            addProvider.senderTypeState('기업');
                            print(addProvider.senderType);
                            _boxOpen = false;
                            setState(() {});
                          }
                        },
                        child: Container(
                          height: 56,
                          child: Center(
                            child: KTextWidget(
                                text: dataProvider.comName == ''
                                    ? '소속 정보 없음'
                                    : '${dataProvider.comName}의 기업(단체)의뢰',
                                size: 15,
                                fontWeight: FontWeight.bold,
                                color: dataProvider.comName == ''
                                    ? Colors.grey
                                    : Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _eTaxSet(AddProvider addProvider, double dw) {
    return SizedBox(
      width: dw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KTextWidget(
              text: '전자세금계산서 선택',
              size: 16,
              fontWeight: FontWeight.bold,
              color: addProvider.senderType == null
                  ? Colors.white
                  : Colors.grey.withOpacity(0.7)),
          KTextWidget(
              text: '전자세금계산서 발행이 필요한 경우 선택하세요.',
              size: 12,
              fontWeight: null,
              color: addProvider.senderType == null
                  ? Colors.white
                  : Colors.grey.withOpacity(0.7)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (addProvider.isNormalEtax == false) {
                addProvider.isNormalEtaxState(true);
              } else {
                addProvider.isNormalEtaxState(false);
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: addProvider.isNormalEtax == true
                          ? kGreenFontColor
                          : btnColor),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      color: addProvider.isNormalEtax == true
                          ? Colors.white
                          : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KTextWidget(
                        text: '전자세금계산서 발행',
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    KTextWidget(
                        text: '운송이후, 플랫폼을 통해 전자세금계산서를 발행합니다.\n산재보험료가 징부됩니다.',
                        size: 13,
                        fontWeight: null,
                        color: Colors.grey)
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

  Widget _priceSel(AddProvider addProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextWidget(
            text: '결제 유형 선택',
            size: 16,
            fontWeight: FontWeight.bold,
            color: addProvider.isPriceType == null
                ? Colors.white
                : Colors.grey.withOpacity(0.7)),
        KTextWidget(
            text: '운송료를 어떻게 결제할지 선택하세요!',
            size: 12,
            fontWeight: null,
            color: addProvider.isPriceType == null
                ? Colors.white
                : Colors.grey.withOpacity(0.7)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            addProvider.isPriceTypeState('직접 결제');
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: addProvider.isPriceType == '직접 결제'
                        ? kGreenFontColor
                        : btnColor),
                child: Center(
                  child: Icon(
                    Icons.check,
                    color: addProvider.isPriceType == '직접 결제'
                        ? Colors.white
                        : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KTextWidget(
                      text: '직접 결제',
                      size: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  KTextWidget(
                      text: '기사와 직접 결제합니다.\n현장에서 현금으로 결제하거나, 계좌이체로 결제합니다.',
                      size: 13,
                      fontWeight: null,
                      color: Colors.grey)
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            // addProvider.isPriceTypeState('카드 결제');
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(errorSnackBar(
                '죄송합니다. 현재 지원하지 않습니다.\n최대한 빠른 시일안에 제공할 예정입니다.', context));
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: addProvider.isPriceType == '카드 결제'
                        ? kGreenFontColor
                        : btnColor),
                child: Center(
                  child: Icon(
                    Icons.check,
                    color: addProvider.isPriceType == '카드 결제'
                        ? Colors.white
                        : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KTextWidget(
                      text: '카드 결제',
                      size: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  KTextWidget(
                      text:
                          'PG를 이용하여 카드로 결제합니다.\n기사가 전자결제를 신청하지 않은경우, 카드결제가 불가합니다.',
                      size: 13,
                      fontWeight: null,
                      color: Colors.grey)
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _noPoint(AddProvider addProvider, double dw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        KTextWidget(
            text: '결제 방법 선택',
            size: 16,
            fontWeight: FontWeight.bold,
            color: addProvider.payHowto!.length < 2
                ? Colors.white
                : Colors.grey.withOpacity(0.7)),
        KTextWidget(
            text: '운송료 결제 방법을 등록하세요.',
            size: 12,
            fontWeight: null,
            color: addProvider.payHowto!.length < 2
                ? Colors.white
                : Colors.grey.withOpacity(0.7)),
        const SizedBox(height: 16),
        if (addProvider.addMainType == '다구간')
          _nultiState(addProvider, dw)
        else if (addProvider.addMainType == '왕복')
          _returnState(addProvider, dw)
        else
          _nomralState(addProvider, dw),
        _etcState(addProvider, dw),
        const SizedBox(height: 8),
        const Row(
          children: [
            Icon(
              Icons.info,
              size: 12,
              color: Colors.grey,
            ),
            SizedBox(width: 5),
            KTextWidget(
                text: '고객이 직접 기사에게 결제합니다.',
                size: 13,
                fontWeight: null,
                color: Colors.grey)
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Column(
              children: [
                SizedBox(height: 3),
                Icon(
                  Icons.info,
                  size: 12,
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: dw * 0.9,
              child: const KTextWidget(
                  text: '현금영수증 및 인수증은 기사에게 직접 요청해야합니다.',
                  size: 13,
                  fontWeight: null,
                  color: Colors.grey),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Column(
              children: [
                SizedBox(height: 3),
                Icon(
                  Icons.info,
                  size: 12,
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(width: 5),
            SizedBox(
              width: dw * 0.9,
              child: const KTextWidget(
                  text:
                      '혼적콜은 운송료 책정 및 직접결제에 대해 관여하지 않음으로, 고객 기사간 발생되는 분쟁 및 문제에 대해 책임을 지지 않습니다.',
                  size: 13,
                  fontWeight: null,
                  color: Colors.grey),
            )
          ],
        )
      ],
    );
  }

  Widget _nomralState(AddProvider addProvider, double dw) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _pick('현금 결제', addProvider)),
            const SizedBox(width: 5),
            Expanded(child: _pick('계좌 이체', addProvider)),
          ],
        ),
        if (addProvider.payHowto.isNotEmpty)
          Column(
            children: [
              const SizedBox(height: 16),
              if (addProvider.payHowto.contains('현금 결제'))
                Column(
                  children: [
                    _pick2('상차지에서 현금 결제', addProvider, dw),
                    const SizedBox(height: 5),
                    _pick2('하차지에서 현금 결제', addProvider, dw),
                  ],
                )
              else
                Column(
                  children: [
                    _pick2('배차 후, 계좌 이체', addProvider, dw),
                    const SizedBox(height: 5),
                    _pick2('상차 완료 후, 계좌 이체', addProvider, dw),
                    const SizedBox(height: 5),
                    _pick2('하차 완료 후, 계좌 이체', addProvider, dw),
                  ],
                )
            ],
          ),
      ],
    );
  }

  Widget _returnState(AddProvider addProvider, double dw) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _pick('현금 결제', addProvider)),
            const SizedBox(width: 5),
            Expanded(child: _pick('계좌 이체', addProvider)),
          ],
        ),
        if (addProvider.payHowto.isNotEmpty)
          Column(
            children: [
              const SizedBox(height: 16),
              if (addProvider.payHowto.contains('현금 결제'))
                Column(
                  children: [
                    _pick2('상차지에서 현금 결제', addProvider, dw),
                    const SizedBox(height: 5),
                    _pick2('경유지에서 현금 결제', addProvider, dw),
                    const SizedBox(height: 5),
                    _pick2('하차지에서 현금 결제', addProvider, dw),
                  ],
                )
              else
                Column(
                  children: [
                    _pick2('배차 후, 계좌 이체', addProvider, dw),
                    const SizedBox(height: 5),
                    _pick2('운송 완료 후, 계좌 이체', addProvider, dw),
                  ],
                )
            ],
          ),
      ],
    );
  }

  Widget _nultiState(AddProvider addProvider, double dw) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _pick('현금 결제', addProvider)),
            const SizedBox(width: 5),
            Expanded(child: _pick('계좌 이체', addProvider)),
          ],
        ),
        if (addProvider.payHowto.isNotEmpty)
          Column(
            children: [
              const SizedBox(height: 16),
              if (addProvider.payHowto.contains('현금 결제'))
                Column(
                  children: [
                    _pick2('최초 장소에서 현금 결제', addProvider, dw),
                    const SizedBox(height: 5),
                    _pick2('마지막 장소에서 현금 결제', addProvider, dw),
                  ],
                )
              else
                Column(
                  children: [
                    _pick2('배차 후, 계좌 이체', addProvider, dw),
                    const SizedBox(height: 5),
                    _pick2('운송 완료 후, 계좌 이체', addProvider, dw),
                  ],
                )
            ],
          ),
      ],
    );
  }

  Widget _etcState(AddProvider addProvider, double dw) {
    return Column(
      children: [
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            if (addProvider.isDoneRec == true) {
              addProvider.isDoneRecState(false);
            } else {
              addProvider.isDoneRecState(true);
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: addProvider.isDoneRec == true
                        ? kGreenFontColor
                        : btnColor),
                child: Center(
                  child: Icon(
                    Icons.check,
                    color: addProvider.isDoneRec == true
                        ? Colors.white
                        : Colors.grey,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const KTextWidget(
                      text: '화물 인수증 등록 요청',
                      size: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  SizedBox(
                    width: dw * 0.85,
                    child: const KTextWidget(
                        text:
                            '하차지에서 운송을 완료했음을 의미하는 인수증 또는 운송증을 교부하는 경우, 등록을 요청할 수 있습니다.',
                        size: 12,
                        fontWeight: null,
                        color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pick(String text, AddProvider addProvider) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        addProvider.payHowtoState(text);
      },
      child: Container(
        padding:
            const EdgeInsets.only(top: 12, bottom: 12, right: 16, left: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: addProvider.payHowto!.contains(text)
                ? kGreenFontColor.withOpacity(0.16)
                : btnColor,
            border: Border.all(
                color: addProvider.payHowto!.contains(text)
                    ? kGreenFontColor
                    : Colors.grey.withOpacity(0.3))),
        child: Column(
          children: [
            KTextWidget(
                text: text,
                size: 15,
                fontWeight: addProvider.payHowto!.contains(text)
                    ? FontWeight.bold
                    : null,
                color: addProvider.payHowto!.contains(text)
                    ? kGreenFontColor
                    : Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _pick2(String text, AddProvider addProvider, double dw) {
    print('Current payHowto before tap: ${addProvider.payHowto}'); // 탭하기 전 상태

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        print('Tapped text: $text'); // 어떤 텍스트가 탭되었는지
        addProvider.payHowtoState(text);
        print(
            'payHowto after state update: ${addProvider.payHowto}'); // 상태 업데이트 후
      },
      child: Container(
        width: dw,
        padding:
            const EdgeInsets.only(top: 12, bottom: 12, right: 16, left: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: addProvider.payHowto!.contains(text)
                ? kGreenFontColor.withOpacity(0.16)
                : btnColor,
            border: Border.all(
                color: addProvider.payHowto!.contains(text)
                    ? kGreenFontColor
                    : Colors.grey.withOpacity(0.3))),
        child: Column(
          children: [
            KTextWidget(
                text: text,
                size: 15,
                fontWeight: addProvider.payHowto!.contains(text)
                    ? FontWeight.bold
                    : null,
                color: addProvider.payHowto!.contains(text)
                    ? kGreenFontColor
                    : Colors.grey),
          ],
        ),
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
                  text: '결제 정보 등록',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)
            ],
          ),
        ),
      ),
    );
  }

  TextEditingController _priceText = TextEditingController();
  int _priceNum = 0;
  num? _pricedb;

  Widget _price(AddProvider addProvider) {
    final dw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: dw,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 32),
          Row(
            children: [
              Icon(
                Icons.info,
                size: 12,
                color: Colors.grey,
              ),
              SizedBox(width: 5),
              KTextWidget(
                  text: '혼적콜 포인트로 운송료를 결제합니다.',
                  size: 13,
                  fontWeight: null,
                  color: Colors.grey)
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
                  text: '포인트 이용시 PG사의 결제 수수료가 적용됩니다.',
                  size: 13,
                  fontWeight: null,
                  color: Colors.grey)
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
                  text: '결제 수수료외 기사나 고객에 비용을 청구하지 않습니다.',
                  size: 13,
                  fontWeight: null,
                  color: Colors.grey)
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
                  text: '포인트 결제시, 부가세(vat)가 청구됩니다.',
                  size: 13,
                  fontWeight: null,
                  color: Colors.grey)
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
                  text: '결제대행(PG)에서 현금영수증을 요청할 수 있습니다.',
                  size: 13,
                  fontWeight: null,
                  color: Colors.grey)
            ],
          )
        ],
      ),
    );
  }
}
