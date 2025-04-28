import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class AddCargoDialog extends StatefulWidget {
  const AddCargoDialog({super.key});

  @override
  State<AddCargoDialog> createState() => _AddCargoDialogState();
}

class _AddCargoDialogState extends State<AddCargoDialog> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addProvider = Provider.of<AddProvider>(context, listen: false);
      if (addProvider.carEtc != null && addProvider.carEtc != '') {
        _etcText.text = addProvider.carEtc.toString();
        _etc = _etcText.text.length;
      }
    });
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
                  text: '차량 정보 등록',
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
          _optionSel(addProvider),
        ],
      ),
    );
  }

  Widget _btn(AddProvider addProvider) {
    bool state = addProvider.setCarType != null &&
        addProvider.carOption.isNotEmpty &&
        addProvider.setCarTon.isNotEmpty;
    return GestureDetector(
      onTap: () {
        if (!state) {
        } else {
          HapticFeedback.lightImpact();
          /*  if (addProvider.carOption.contains('없음')) {
            addProvider.clearCarOption();
          } */

          if (_etc > 0) {
            addProvider.carEtcState(_etcText.text.trim());
          }

          Navigator.pop(context);
          ScaffoldMessenger.of(context)
              .showSnackBar(currentSnackBar('차량 정보 등록이 완료되었습니다.', context));
        }
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: !state ? noState : kGreenFontColor),
        child: Center(
          child: KTextWidget(
              text: '차량 조건 등록',
              size: 16,
              fontWeight: FontWeight.bold,
              color: !state ? Colors.grey : Colors.white),
        ),
      ),
    );
  }

  Widget _optionSel(AddProvider addProvider) {
    final dw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: dw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KTextWidget(
                  text: '차량 유형 등록',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: addProvider.setCarType == null
                      ? Colors.white
                      : Colors.grey.withOpacity(0.5)),
              if (addProvider.setCarType == null)
                KTextWidget(
                    text: '원하시는 운송 차량 유형을 선택하세요.',
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey),
            ],
          ),
          addProvider.setCarType == null
              ? Column(
                  children: [
                    const SizedBox(height: 12),
                    _car1(addProvider),
                    const SizedBox(height: 12),
                    _car2(addProvider),
                    const SizedBox(height: 12),
                    _car3(addProvider),
                    const SizedBox(height: 12),
                    _car4(addProvider),
                    const SizedBox(height: 12),
                    _car5(addProvider),
                    const SizedBox(height: 12),
                    _car6(addProvider),
                    const SizedBox(height: 12),
                    _car7(addProvider)
                  ],
                )
              : _inputState(addProvider),
        ],
      ),
    );
  }

  Widget _car1(AddProvider addProvider) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (addProvider.setCarType == '차종 무관') {
          addProvider.setCarTypeState(null);
          addProvider.setCarTonState(0);
          addProvider.setCarTypeSubState(null);
        } else {
          addProvider.setCarTypeState('차종 무관');
          addProvider.clearCarOption();
          addProvider.clearCarTon();
        }
      },
      child: Container(
        height: addProvider.setCarType == '차종 무관' ? null : 182,
        padding: addProvider.setCarType == '차종 무관'
            ? const EdgeInsets.only(top: 12, bottom: 12)
            : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          /*  border: addProvider.setCarType == 'all'
              ? Border.all(color: kGreenFontColor)
              : null, */
          color: noState,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            addProvider.setCarType == '차종 무관'
                ? const SizedBox()
                : Column(
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'asset/img/Union.png',
                            width: 65,
                            height: 65,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                addProvider.setCarType == '차종 무관'
                    ? const Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(
                          Icons.check_circle,
                          color: kGreenFontColor,
                          size: 17,
                        ),
                      )
                    : const SizedBox(),
                KTextWidget(
                    text: '차종 상관 없음',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: addProvider.setCarType == '차종 무관'
                        ? kGreenFontColor
                        : Colors.white),
                const SizedBox(width: 8),
                KTextWidget(
                    text: '0.5 ~ 25 톤',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: addProvider.setCarType == '차종 무관'
                        ? kGreenFontColor
                        : Colors.grey),
              ],
            ),
            //  const SizedBox(height: 8),
            const KTextWidget(
                text: '차종에 상관없이 모든 차량에 운송 요청',
                size: 14,
                fontWeight: null,
                color: Colors.grey),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KTextWidget(
                    text: '[일반] ',
                    size: 12,
                    fontWeight: null,
                    color: Colors.grey),
                KTextWidget(
                    text: '[냉장, 냉동] ',
                    size: 12,
                    fontWeight: null,
                    color: Colors.grey),
                KTextWidget(
                    text: '[무진동] ',
                    size: 12,
                    fontWeight: null,
                    color: Colors.grey),
                KTextWidget(
                    text: '[리프트]',
                    size: 12,
                    fontWeight: null,
                    color: Colors.grey),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _car2(AddProvider addProvider) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (addProvider.setCarType == '카고') {
          addProvider.setCarTypeState(null);
          addProvider.setCarTonState(0);
          addProvider.setCarTypeSubState(null);
        } else {
          addProvider.setCarTypeState('카고');
          addProvider.clearCarOption();
          addProvider.clearCarTon();
        }
      },
      child: Container(
        height: addProvider.setCarType == '카고' ? null : 182,
        padding: addProvider.setCarType == '카고'
            ? const EdgeInsets.only(top: 12, bottom: 12)
            : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: noState,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            addProvider.setCarType == '카고'
                ? const SizedBox()
                : Column(
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'asset/img/set_2.png',
                            width: 105,
                            height: 65,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                addProvider.setCarType == '카고'
                    ? const Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(
                          Icons.check_circle,
                          color: kGreenFontColor,
                          size: 17,
                        ),
                      )
                    : const SizedBox(),
                KTextWidget(
                    text: '카고 차량',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: addProvider.setCarType == '카고'
                        ? kGreenFontColor
                        : Colors.white),
                const SizedBox(width: 8),
                KTextWidget(
                    text: '0.5 ~ 25 톤',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: addProvider.setCarType == '카고'
                        ? kGreenFontColor
                        : Colors.grey),
              ],
            ),
            //  const SizedBox(height: 8),
            const KTextWidget(
                text: '짐칸이 보이는 지붕이 없는 화물 트럭',
                size: 14,
                fontWeight: null,
                color: Colors.grey),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KTextWidget(
                    text: '[일반] ',
                    size: 12,
                    fontWeight: null,
                    color: Colors.grey),
                KTextWidget(
                    text: '[무진동] ',
                    size: 12,
                    fontWeight: null,
                    color: Colors.grey),
                KTextWidget(
                    text: '[리프트]',
                    size: 12,
                    fontWeight: null,
                    color: Colors.grey),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _car3(AddProvider addProvider) {
    bool _state =
        addProvider.setCarType == '탑' || addProvider.setCarType == '호로';
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (_state) {
          addProvider.setCarTypeState(null);
          addProvider.setCarTonState(0);
          addProvider.setCarTypeSubState(null);
        } else {
          addProvider.setCarTypeState('탑');
          addProvider.clearCarOption();
          addProvider.clearCarTon();
        }
      },
      child: Container(
        height: _state ? null : 182,
        padding: _state ? const EdgeInsets.only(top: 12, bottom: 12) : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: noState,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _state
                ? const SizedBox()
                : Column(
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'asset/img/set_3.png',
                            width: 105,
                            height: 65,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _state
                    ? const Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(
                          Icons.check_circle,
                          color: kGreenFontColor,
                          size: 17,
                        ),
                      )
                    : const SizedBox(),
                KTextWidget(
                    text: '탑 차량',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: _state ? kGreenFontColor : Colors.white),
                const SizedBox(width: 8),
                KTextWidget(
                    text: '0.5 ~ 25 톤',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: _state ? kGreenFontColor : Colors.grey),
              ],
            ),
            //  const SizedBox(height: 8),
            const KTextWidget(
                text: '지붕이 있는 화물 트럭',
                size: 14,
                fontWeight: null,
                color: Colors.grey),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KTextWidget(
                    text: '[일반] ',
                    size: 12,
                    fontWeight: null,
                    color: Colors.grey),
                KTextWidget(
                    text: '[냉장, 냉동] ',
                    size: 12,
                    fontWeight: null,
                    color: Colors.grey),
                KTextWidget(
                    text: '[무진동] ',
                    size: 12,
                    fontWeight: null,
                    color: Colors.grey),
                KTextWidget(
                    text: '[리프트]',
                    size: 12,
                    fontWeight: null,
                    color: Colors.grey),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _car4(AddProvider addProvider) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (addProvider.setCarType == '윙') {
          addProvider.setCarTypeState(null);
          addProvider.setCarTonState(0);
          addProvider.setCarTypeSubState(null);
        } else {
          addProvider.setCarTypeState('윙');
          addProvider.clearCarOption();
          addProvider.clearCarTon();
        }
      },
      child: Container(
        height: addProvider.setCarType == '윙' ? null : 182,
        padding: addProvider.setCarType == '윙'
            ? const EdgeInsets.only(top: 12, bottom: 12)
            : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: noState,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            addProvider.setCarType == '윙'
                ? const SizedBox()
                : Column(
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'asset/img/set_4.png',
                            width: 105,
                            height: 65,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                addProvider.setCarType == '윙'
                    ? const Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(
                          Icons.check_circle,
                          color: kGreenFontColor,
                          size: 17,
                        ),
                      )
                    : const SizedBox(),
                KTextWidget(
                    text: '윙바디',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: addProvider.setCarType == '윙'
                        ? kGreenFontColor
                        : Colors.white),
                const SizedBox(width: 8),
                KTextWidget(
                    text: '0.5 ~ 25 톤',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: addProvider.setCarType == '윙'
                        ? kGreenFontColor
                        : Colors.grey),
              ],
            ),
            //  const SizedBox(height: 8),
            const KTextWidget(
                text: '지붕이 있고, 측 ・ 후면이 열리는 화물 트럭  ',
                size: 14,
                fontWeight: null,
                color: Colors.grey),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KTextWidget(
                    text: '[일반] ',
                    size: 12,
                    fontWeight: null,
                    color: Colors.grey),
                KTextWidget(
                    text: '[냉장, 냉동] ',
                    size: 12,
                    fontWeight: null,
                    color: Colors.grey),
                KTextWidget(
                    text: '[무진동] ',
                    size: 12,
                    fontWeight: null,
                    color: Colors.grey),
                KTextWidget(
                    text: '[리프트]',
                    size: 12,
                    fontWeight: null,
                    color: Colors.grey),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _car5(AddProvider addProvider) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (addProvider.setCarType == '크레인') {
          addProvider.setCarTypeState(null);
          addProvider.setCarTonState(0);
          addProvider.setCarTypeSubState(null);
        } else {
          addProvider.setCarTypeState('크레인');
          addProvider.clearCarOption();
          addProvider.clearCarTon();
        }
      },
      child: Container(
        height: addProvider.setCarType == '크레인' ? null : 182,
        padding: addProvider.setCarType == '크레인'
            ? const EdgeInsets.only(top: 12, bottom: 12)
            : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: noState,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            addProvider.setCarType == '크레인'
                ? const SizedBox()
                : Column(
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'asset/img/set_5.png',
                            width: 105,
                            height: 65,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                addProvider.setCarType == '크레인'
                    ? const Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(
                          Icons.check_circle,
                          color: kGreenFontColor,
                          size: 17,
                        ),
                      )
                    : const SizedBox(),
                KTextWidget(
                    text: '크레인',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: addProvider.setCarType == '크레인'
                        ? kGreenFontColor
                        : Colors.white),
                const SizedBox(width: 8),
                KTextWidget(
                    text: '0.5 ~ 25 톤',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: addProvider.setCarType == '크레인'
                        ? kGreenFontColor
                        : Colors.grey),
              ],
            ),
            //  const SizedBox(height: 8),
            const KTextWidget(
                text: '동력을 사용하여 화물을 나르는 트럭',
                size: 14,
                fontWeight: null,
                color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _car6(AddProvider addProvider) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (addProvider.setCarType == '츄레라') {
          addProvider.setCarTypeState(null);
          addProvider.setCarTonState(0);
          addProvider.setCarTypeSubState(null);
        } else {
          addProvider.setCarTypeState('츄레라');
          addProvider.clearCarOption();
          addProvider.clearCarTon();
        }
      },
      child: Container(
        height: addProvider.setCarType == '츄레라' ? null : 182,
        padding: addProvider.setCarType == '츄레라'
            ? const EdgeInsets.only(top: 12, bottom: 12)
            : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: noState,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            addProvider.setCarType == '츄레라'
                ? const SizedBox()
                : Column(
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'asset/img/set_6.png',
                            width: 105,
                            height: 65,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                addProvider.setCarType == '츄레라'
                    ? const Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(
                          Icons.check_circle,
                          color: kGreenFontColor,
                          size: 17,
                        ),
                      )
                    : const SizedBox(),
                KTextWidget(
                    text: '츄레라',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: addProvider.setCarType == '츄레라'
                        ? kGreenFontColor
                        : Colors.white),
                const SizedBox(width: 8),
                KTextWidget(
                    text: '25 톤',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: addProvider.setCarType == '츄레라'
                        ? kGreenFontColor
                        : Colors.grey),
              ],
            ),
            //  const SizedBox(height: 8),
            const KTextWidget(
                text: '동력을 사용하여 화물을 나르는 트럭',
                size: 14,
                fontWeight: null,
                color: Colors.grey),
            const KTextWidget(
                text: '[평판] [덤프] [로우베드] [벌크]',
                size: 12,
                fontWeight: null,
                color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _car7(AddProvider addProvider) {
    return GestureDetector(
      onTap: () {
        /*  HapticFeedback.lightImpact();
        if (addProvider.setCarType == 'lift') {
          addProvider.setCarTypeState(null);
          addProvider.setCarTonState(0);
          addProvider.setCarTypeSubState(null);
        } else {
          addProvider.setCarTypeState('lift');
        } */
      },
      child: Container(
        height: 182,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: noState,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'asset/img/set_7.png',
                  width: 105,
                  height: 65,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KTextWidget(
                    text: '덤프트럭',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: addProvider.setCarType == 'lift'
                        ? kGreenFontColor
                        : Colors.white),
                const SizedBox(width: 8),
                const KTextWidget(
                    text: '25 톤',
                    size: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ],
            ),
            //  const SizedBox(height: 8),
            const KTextWidget(
                text: '흙 또는 석재를 운송하는 트럭',
                size: 14,
                fontWeight: null,
                color: Colors.grey),
            const KTextWidget(
                text: '등록된 기업만 이용하실 수 있습니다.',
                size: 14,
                fontWeight: null,
                color: Colors.grey),
          ],
        ),
      ),
    );
  }

//////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

  Widget _inputState(AddProvider addProvider) {
    final dw = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        children: [
          _cargoState(addProvider),
          const SizedBox(height: 16),
          if (addProvider.setCarType != null) _carTon(addProvider),
          const SizedBox(height: 16),
          if (addProvider.setCarType != null) _carOption(addProvider),
          if (addProvider.addMainType == '다구간' ||
              addProvider.addMainType == '왕복')
            _carEtc(dw)
        ],
      ),
    );
  }

  TextEditingController _etcText = TextEditingController();
  num _etc = 0;
  Widget _carEtc(double dw) {
    return SizedBox(
      width: dw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          KTextWidget(
              text: '차량 관련 안내 사항',
              size: 16,
              fontWeight: FontWeight.bold,
              color: _etc > 0 ? Colors.grey.withOpacity(0.5) : Colors.grey),
          const SizedBox(height: 16),
          Container(
            //   height: 56,
            child: TextFormField(
              controller: _etcText,
              autocorrect: false,
              maxLength: 150,
              maxLines: 3,
              style: const TextStyle(color: kOrangeAssetColor, fontSize: 15),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                suffix: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        _etcText.clear();
                        _etc = 0;
                        setState(() {});
                      },
                      child: Icon(
                        Icons.remove_circle,
                        color: _etc == 0
                            ? Colors.grey.withOpacity(0.2)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
                counterText: '',
                counterStyle: const TextStyle(fontSize: 0),
                hintText: '차량 관련 요구사항 또는 주의사항을 입력하세요.\n필요한 크레인, 리프트 종류 등',
                hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                filled: true,
                fillColor: btnColor,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  // 선택되었을 때 보덕색으로 표시됨
                  borderSide: BorderSide(color: kOrangeAssetColor, width: 1.0),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _etc = value.length;
                });
              },
            ),
          ),
          const SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }

  Widget _cargoState(AddProvider addProvider) {
    return Column(
      children: [
        const SizedBox(height: 12),
        if (addProvider.setCarType == '차종 무관') _car1(addProvider),
        if (addProvider.setCarType == '카고') _car2(addProvider),
        if (addProvider.setCarType == '탑' || addProvider.setCarType == '호로')
          _car3(addProvider),
        if (addProvider.setCarType == '윙') _car4(addProvider),
        if (addProvider.setCarType == '크레인') _car5(addProvider),
        if (addProvider.setCarType == '츄레라') _car6(addProvider),
      ],
    );
  }

  ///////////// 자돵차 옵션 선택 /////////

  Widget _carOption(AddProvider addProvider) {
    final dw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: dw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (addProvider.setCarType == '탑' || addProvider.setCarType == '호로')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KTextWidget(
                    text: '차량 유형 상세 선택',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: addProvider.carOption.isEmpty
                        ? Colors.white
                        : Colors.grey.withOpacity(0.5)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [_senderPick3('탑'), _senderPick3('호로')],
                ),
                const SizedBox(height: 24),
              ],
            ),
          if (addProvider.setCarType != '크레인')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KTextWidget(
                    text: '차량 옵션 선택',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: addProvider.carOption.isEmpty
                        ? Colors.white
                        : Colors.grey.withOpacity(0.5)),
                if (addProvider.carOption.isEmpty)
                  const Row(
                    children: [
                      Icon(
                        Icons.info,
                        size: 12,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 3),
                      KTextWidget(
                          text: '옵션을 선택할 경우, 추가비용이 발생할 수 있습니다.',
                          size: 12,
                          fontWeight: null,
                          color: Colors.grey),
                    ],
                  ),
                const SizedBox(height: 16),
              ],
            ),
          if (addProvider.setCarType == '차종 무관')
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _senderPick('없음'),
                _senderPick('호로'),
                _senderPick('냉장'),
                _senderPick('냉동'),
                _senderPick('무진동'),
                _senderPick('리프트'),
                _senderPick('크레인'),
                _senderPick('장축'),
                _senderPick('초장축'),
              ],
            ),
          if (addProvider.setCarType == '윙')
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _senderPick('없음'),
                _senderPick('냉장'),
                _senderPick('냉동'),
                _senderPick('리프트'),
                _senderPick('무진동'),
                _senderPick('장축'),
                _senderPick('초장축'),
              ],
            ),
          if (addProvider.setCarType == '카고')
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _senderPick('없음'),
                _senderPick('호로'),
                _senderPick('무진동'),
                _senderPick('리프트'),
                _senderPick('크레인'),
                _senderPick('장축'),
                _senderPick('초장축'),
              ],
            ),
          if (addProvider.setCarType == '츄레라')
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _senderPick('평판'),
                _senderPick('덤프'),
                _senderPick('로우베드'),
                _senderPick('벌크'),
              ],
            ),
          if (addProvider.setCarType == '탑')
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _senderPick('없음'),
                _senderPick('냉장'),
                _senderPick('냉동'),
                _senderPick('무진동'),
                _senderPick('리프트'),
                _senderPick('장축'),
                _senderPick('초장축'),
              ],
            ),
          if (addProvider.setCarType == '호로')
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _senderPick('없음'),
                _senderPick('무진동'),
                _senderPick('리프트'),
                _senderPick('장축'),
                _senderPick('초장축'),
              ],
            ),
          if (addProvider.setCarType == '크레인')
            const SizedBox()
          else
            const SizedBox(height: 24),
        ],
      ),
    );
  }

  /*     Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [_senderPick3('탑'), _senderPick3('호로')],
                ),
                const SizedBox(height: 6), */

  Widget _carTon(AddProvider addProvider) {
    final dw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: dw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KTextWidget(
              text: '차량 중량 선택(최대3개)',
              size: 16,
              fontWeight: FontWeight.bold,
              color: addProvider.setCarTon.isEmpty
                  ? Colors.white
                  : Colors.grey.withOpacity(0.5)),
          if (addProvider.setCarTon.isEmpty)
            const KTextWidget(
                text: '원하시는 차량의 중량을 모두 선택하세요.',
                size: 12,
                fontWeight: null,
                color: Colors.grey),
          const SizedBox(height: 16),
          if (addProvider.setCarType == '차종 무관' ||
              addProvider.setCarType == '카고')
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _senderPick2(999),
                _senderPick2(0.5),
                _senderPick2(1),
                _senderPick2(1.4),
                _senderPick2(2.5),
                _senderPick2(3.5),
                _senderPick2(5),
                _senderPick2(11),
                _senderPick2(15),
                _senderPick2(18),
                _senderPick2(22),
                _senderPick2(25),
              ],
            ),
          if (addProvider.setCarType == '윙')
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _senderPick2(999),
                _senderPick2(0.5),
                _senderPick2(1),
                _senderPick2(1.4),
                _senderPick2(2.5),
                _senderPick2(3.5),
                _senderPick2(5),
                _senderPick2(11),
                _senderPick2(18),
                _senderPick2(25),
              ],
            ),
          if (addProvider.setCarType == '츄레라')
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _senderPick2(25),
              ],
            ),
          if (addProvider.setCarType == '크레인')
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _senderPick2(999),
                _senderPick2(1),
                _senderPick2(1.4),
                _senderPick2(2.5),
                _senderPick2(3.5),
                _senderPick2(5),
                _senderPick2(8),
                _senderPick2(9.5),
                _senderPick2(16),
                _senderPick2(22),
                _senderPick2(25),
              ],
            ),
          if (addProvider.setCarType == '탑')
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _senderPick2(999),
                _senderPick2(0.5),
                _senderPick2(1),
                _senderPick2(1.4),
                _senderPick2(2.5),
                _senderPick2(3.5),
                _senderPick2(5),
                _senderPick2(11),
                _senderPick2(18),
                _senderPick2(25),
              ],
            ),
          if (addProvider.setCarType == '호로')
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _senderPick2(999),
                _senderPick2(0.5),
                _senderPick2(1),
                _senderPick2(1.4),
                _senderPick2(2.5),
                _senderPick2(3.5),
                _senderPick2(5),
                _senderPick2(11),
              ],
            ),
        ],
      ),
    );
  }

  Widget _senderPick3(String text) {
    final addProvider = Provider.of<AddProvider>(context);

    return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          addProvider.setCarTypeState(text);
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: addProvider.setCarType == text
                  ? kGreenFontColor.withOpacity(0.16)
                  : btnColor,
              border: Border.all(
                  color: addProvider.setCarType == text
                      ? kGreenFontColor
                      : Colors.grey.withOpacity(0.3))),
          child: Column(
            children: [
              KTextWidget(
                  text: text == '탑' ? ' 탑 ' : text,
                  size: 15,
                  fontWeight:
                      addProvider.setCarType == text ? FontWeight.bold : null,
                  color: addProvider.setCarType == text
                      ? kGreenFontColor
                      : Colors.grey),
            ],
          ),
        ));
  }

  Widget _senderPick(String text) {
    final addProvider = Provider.of<AddProvider>(context);

    return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (text == '없음') {
            addProvider.clearCarOption();
            addProvider.carOptionState('없음');
          } else {
            if (addProvider.carOption.contains('없음')) {
              addProvider.clearCarOption();
              addProvider.carOptionState(text);
            } else {
              addProvider.carOptionState(text);
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: addProvider.carOption!.contains(text)
                  ? kGreenFontColor.withOpacity(0.16)
                  : btnColor,
              border: Border.all(
                  color: addProvider.carOption!.contains(text)
                      ? kGreenFontColor
                      : Colors.grey.withOpacity(0.3))),
          child: Column(
            children: [
              KTextWidget(
                  text: text,
                  size: 15,
                  fontWeight: addProvider.carOption!.contains(text)
                      ? FontWeight.bold
                      : null,
                  color: addProvider.carOption!.contains(text)
                      ? kGreenFontColor
                      : Colors.grey),
            ],
          ),
        ));
  }

  Widget _senderPick2(double text) {
    final addProvider = Provider.of<AddProvider>(context);

    return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (text == 999) {
            addProvider.clearCarTon();
            addProvider.setCarTonState(999);
          } else {
            if (addProvider.setCarTon.contains(999)) {
              addProvider.clearCarTon();
              addProvider.setCarTonState(text);
            } else {
              addProvider.setCarTonState(text);
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: addProvider.setCarTon!.contains(text)
                  ? kGreenFontColor.withOpacity(0.16)
                  : btnColor,
              border: Border.all(
                  color: addProvider.setCarTon!.contains(text)
                      ? kGreenFontColor
                      : Colors.grey.withOpacity(0.3))),
          child: Column(
            children: [
              if (text == 999)
                KTextWidget(
                    text: '중량 무관',
                    size: 15,
                    fontWeight: addProvider.setCarTon!.contains(text)
                        ? FontWeight.bold
                        : null,
                    color: addProvider.setCarTon!.contains(text)
                        ? kGreenFontColor
                        : Colors.grey)
              else
                KTextWidget(
                    text: text.toString() + '톤',
                    size: 15,
                    fontWeight: addProvider.setCarTon!.contains(text)
                        ? FontWeight.bold
                        : null,
                    color: addProvider.setCarTon!.contains(text)
                        ? kGreenFontColor
                        : Colors.grey),
            ],
          ),
        ));
  }
}

//3561559765613
