import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/ar_service/ar_main.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class CargoInfoSet extends StatefulWidget {
  const CargoInfoSet({super.key});

  @override
  State<CargoInfoSet> createState() => _CargoInfoSetState();
}

class _CargoInfoSetState extends State<CargoInfoSet> {
  @override
  void initState() {
    super.initState();
    final addProvider = Provider.of<AddProvider>(context, listen: false);
    _garoFocusNode.addListener(() {
      setState(() {}); // 포커스 상태가 변경될 때 UI 업데이트
    });

    _seroFocusNode.addListener(() {
      setState(() {});
    });

    _heightFocusNode.addListener(() {
      setState(() {});
    });

    if (addProvider.addCargoInfo != null) {
      _cargoText.text = addProvider.addCargoInfo.toString();
      _cargoTextNum = _cargoText.text.length;
    }
    if (addProvider.addCargoTon != null) {
      _weText.text = addProvider.addCargoTon.toString();
      _weTextNum = _weText.text.length;
      _weNum = addProvider.addCargoTon;
    }

    if (addProvider.addCargoSizeGaro != null) {
      _garoText.text = addProvider.addCargoSizeGaro.toString();
      _garoTextNum = _garoText.text.length;
      _garoNum = addProvider.addCargoSizeGaro!;

      ///
      _seroText.text = addProvider.addCargoSizeSero.toString();
      _seroTextNum = _seroText.text.length;
      _seroNum = addProvider.addCargoSizeSero!;
      //
      _hiText.text = addProvider.addCargoSizeHi.toString();
      _hiTextNum = _hiText.text.length;
      _hiNum = addProvider.addCargoSizeHi!;
    }
  }

  @override
  void dispose() {
    _garoFocusNode.removeListener(() {});
    _seroFocusNode.removeListener(() {});
    _heightFocusNode.removeListener(() {});

    _hiText.dispose();
    _weText.dispose();
    _garoText.dispose();
    _seroText.dispose();
    _cargoText.dispose();
    _garoFocusNode.dispose();
    _seroFocusNode.dispose();
    _heightFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              const KTextWidget(
                  text: '화물 정보 등록',
                  size: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              const Expanded(child: SizedBox()),
              GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.cancel,
                    color: Colors.grey,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(child: _mainContents(addProvider)),
          const SizedBox(height: 10),
          _btn(addProvider),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _mainContents(AddProvider addProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _cargoInfo(addProvider),
          const SizedBox(height: 24),
          _cargoSized1(addProvider),
          const SizedBox(height: 24),
          _cargoSize(addProvider),
          const SizedBox(height: 250),
        ],
      ),
    );
  }

  TextEditingController _cargoText = TextEditingController();
  TextEditingController _garoText = TextEditingController();
  TextEditingController _seroText = TextEditingController();
  TextEditingController _hiText = TextEditingController();
  TextEditingController _weText = TextEditingController();
  final _garoFocusNode = FocusNode();
  final _seroFocusNode = FocusNode();
  final _heightFocusNode = FocusNode();
  int? _cargoTextNum = 0;
  int? _weTextNum = 0;

  int? _garoTextNum = 0;
  int? _seroTextNum = 0;
  int? _hiTextNum = 0;

  double? _weNum;

  double _garoNum = 0;
  double _seroNum = 0;
  double _hiNum = 0;

  Widget _cargoInfo(AddProvider addProvider) {
    final dw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: dw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KTextWidget(
              text: '화물 유형 입력',
              size: 16,
              fontWeight: FontWeight.bold,
              color: _cargoTextNum! <= 3
                  ? Colors.white
                  : Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 12),
          SizedBox(
            width: dw,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    //height: 56,
                    child: TextFormField(
                  controller: _cargoText,
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
                    counterStyle: const TextStyle(fontSize: 8),
                    errorStyle: const TextStyle(
                        fontSize: 0, height: 0), // 기본 에러 스타일 완전히 숨기기
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
                    hintText:
                        '기사님꼐 어떤 화물을 운송하는지 알려주세요.\n예)타이어 20개, 파레트 10개, 반려동물 등',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: kGreenFontColor, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: noState, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _cargoTextNum = value.length;
                    });
                  },
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cargoSized1(AddProvider addProvider) {
    final dw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: dw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KTextWidget(
              text: '화물 무게 입력',
              size: 16,
              fontWeight: FontWeight.bold,
              color: _weTextNum == 0
                  ? Colors.white
                  : Colors.grey.withOpacity(0.5)),
          if (_weTextNum == 0)
            const Row(
              children: [
                Icon(
                  Icons.info,
                  size: 12,
                  color: Colors.grey,
                ),
                SizedBox(width: 5),
                KTextWidget(
                    text: '정확하지 않아도 괜찮아요! 화물의 무게를 입력하세요!',
                    size: 12,
                    fontWeight: null,
                    color: Colors.grey),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _weText,
                  cursorColor: kGreenFontColor,
                  autocorrect: false,
                  maxLength: 10,
                  // 숫자 키패드 표시
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  // 숫자만 입력 가능하도록 제한
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  textInputAction: TextInputAction.done,
                  minLines: 1,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (addProvider.addCargoTonString == '톤') {
                          addProvider.addCargotonStringState('Kg');
                        } else {
                          addProvider.addCargotonStringState('톤');
                        }
                      },
                      child: Container(
                        width: 80,
                        margin: EdgeInsets.only(
                            left: 10, right: 10, top: 5, bottom: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Spacer(),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: kGreenFontColor,
                            ),
                            const SizedBox(width: 5),
                            KTextWidget(
                                text: addProvider.addCargoTonString.toString(),
                                size: 16,
                                fontWeight: FontWeight.bold,
                                color: kGreenFontColor),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                    counterStyle: const TextStyle(fontSize: 0),
                    errorStyle: const TextStyle(fontSize: 0, height: 0),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: kRedColor),
                    ),
                    errorText: null,
                    filled: true,
                    fillColor: btnColor,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                    hintText: '화물의 무게를 입력하세요!',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: kGreenFontColor, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: noState, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _weTextNum = value.length;
                      _weNum = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _cargoSize(AddProvider addProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KTextWidget(
            text: '화물 사이즈 입력',
            size: 16,
            fontWeight: null,
            color: Colors.grey.withOpacity(0.7)),
        const Row(
          children: [
            Icon(
              Icons.info,
              size: 12,
              color: Colors.grey,
            ),
            SizedBox(width: 5),
            KTextWidget(
                text: '화물 사이즈를 입력하면 배차 가능성이 크게 높아져요!',
                size: 12,
                fontWeight: null,
                color: Colors.grey),
          ],
        ),
        const Row(
          children: [
            Icon(
              Icons.info,
              size: 12,
              color: Colors.grey,
            ),
            SizedBox(width: 5),
            KTextWidget(
                text: '화물 사이즈는 M(미터)단위로 등록해야합니다.',
                size: 12,
                fontWeight: null,
                color: Colors.grey),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _garoText,
                cursorColor: kGreenFontColor,
                autocorrect: false,
                maxLength: 3,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                textInputAction: TextInputAction.done,
                minLines: 1,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  counterStyle: const TextStyle(fontSize: 0),
                  errorStyle: const TextStyle(fontSize: 0, height: 0),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kRedColor),
                  ),
                  errorText: null,
                  filled: true,
                  fillColor: btnColor,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                  hintText: _garoText.text.isNotEmpty || _garoFocusNode.hasFocus
                      ? ''
                      : '가로(M)',
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: kGreenFontColor, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: noState, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // 포커스 상태에서만 보이는 prefix와 suffix
                  prefixText:
                      _garoText.text.isNotEmpty || _garoFocusNode.hasFocus
                          ? '가로 : '
                          : null,

                  suffixText:
                      _garoText.text.isNotEmpty || _garoFocusNode.hasFocus
                          ? 'M'
                          : null,
                ),
                focusNode: _garoFocusNode, // FocusNode 추가 필요
                onChanged: (value) {
                  setState(() {
                    _garoTextNum = value.length;
                    _garoNum = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _seroText,
                cursorColor: kGreenFontColor,
                autocorrect: false,
                maxLength: 3,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                textInputAction: TextInputAction.done,
                minLines: 1,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  counterStyle: const TextStyle(fontSize: 0),
                  errorStyle: const TextStyle(fontSize: 0, height: 0),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kRedColor),
                  ),
                  errorText: null,
                  filled: true,
                  fillColor: btnColor,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                  hintText: _seroText.text.isNotEmpty || _seroFocusNode.hasFocus
                      ? ''
                      : '세로(M)',
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: kGreenFontColor, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: noState, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // 포커스 상태에서만 보이는 prefix와 suffix
                  prefixText:
                      _seroText.text.isNotEmpty || _seroFocusNode.hasFocus
                          ? '세로 : '
                          : null,

                  suffixText:
                      _seroText.text.isNotEmpty || _seroFocusNode.hasFocus
                          ? 'M'
                          : null,
                ),
                focusNode: _seroFocusNode, // FocusNode 추가 필요
                onChanged: (value) {
                  setState(() {
                    _seroTextNum = value.length;
                    _seroNum = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _hiText,
                cursorColor: kGreenFontColor,
                autocorrect: false,
                maxLength: 3,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                textInputAction: TextInputAction.done,
                minLines: 1,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  counterStyle: const TextStyle(fontSize: 0),
                  errorStyle: const TextStyle(fontSize: 0, height: 0),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kRedColor),
                  ),
                  errorText: null,
                  filled: true,
                  fillColor: btnColor,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                  hintText: _hiText.text.isNotEmpty || _heightFocusNode.hasFocus
                      ? ''
                      : '높이(M)',
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: kGreenFontColor, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: noState, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // 포커스 상태에서만 보이는 prefix와 suffix
                  prefixText:
                      _hiText.text.isNotEmpty || _heightFocusNode.hasFocus
                          ? '높이 : '
                          : null,

                  suffixText:
                      _hiText.text.isNotEmpty || _heightFocusNode.hasFocus
                          ? 'M'
                          : null,
                ),
                focusNode: _heightFocusNode, // FocusNode 추가 필요
                onChanged: (value) {
                  setState(() {
                    _hiTextNum = value.length;
                    _hiNum = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_garoNum > 0 || _seroNum > 0 || _hiNum > 0)
              if (!(_garoNum > 0 && _seroNum > 0 && _hiNum > 0)) // 일부만 입력된 경우
                const Row(
                  children: [
                    Icon(
                      Icons.info,
                      size: 12,
                      color: kRedColor,
                    ),
                    SizedBox(width: 5),
                    KTextWidget(
                        text: '가로 x 세로 x 높이가 모두 입력되어야 합니다.',
                        size: 12,
                        fontWeight: null,
                        color: kRedColor),
                  ],
                ),
            const Spacer(),
            GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ARServiceMainPage()),
                  );
                },
                child: const UnderLineWidget(
                    text: 'AR 사이즈 측정', color: kBlueBssetColor))
          ],
        )
      ],
    );
  }

  Widget _btn(AddProvider addProvider) {
    bool state = _cargoTextNum != 0 && _weTextNum != 0;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (!state) {
        } else {
          HapticFeedback.lightImpact();

          if (_garoNum! > 0 && _seroNum! > 0 && _hiNum! > 0) {
            addProvider.addCargoInfoState(_cargoText.text.trim());

            addProvider.addCargoTonState(_weNum);
            addProvider.addCargoSizedState(_garoNum, _seroNum, _hiNum);
            double cbm = double.parse(
                (_garoNum! * _seroNum! * _hiNum!).toStringAsFixed(1));
            addProvider.addCargoCbmState(cbm);
            Navigator.pop(context);
            /*  ScaffoldMessenger.of(context)
                .showSnackBar(currentSnackBar('화물정보 등록이 완료되었습니다.', context)); */
            print('모든 값이 입력됨');
          } else if (_garoNum == 0.0 && _seroNum == 0.0 && _hiNum == 0.0) {
            addProvider.addCargoInfoState(_cargoText.text.trim());
            addProvider.addCargoTonState(_weNum);
            Navigator.pop(context);
            /*   ScaffoldMessenger.of(context)
                .showSnackBar(currentSnackBar('화물정보 등록이 완료되었습니다.', context));
 */
            print('아무것도 입력되지 않음');
          }
        }
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: !state ? noState : kGreenFontColor),
        child: Center(
          child: KTextWidget(
              text: '화물 조건 등록',
              size: 16,
              fontWeight: FontWeight.bold,
              color: !state ? Colors.grey : Colors.white),
        ),
      ),
    );
  }
}
