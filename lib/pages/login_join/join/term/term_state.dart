import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/login_join/join/normal_user/normal_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/mainMenu/agree_term.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/etc.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class TermStatePage extends StatefulWidget {
  const TermStatePage({super.key});

  @override
  State<TermStatePage> createState() => _TermStatePageState();
}

class _TermStatePageState extends State<TermStatePage> {
  bool _agree1 = false;
  bool _agree2 = false;
  bool _agree3 = false;
  bool _agree4 = false;
  bool _agree5 = false;
  bool _isAgree = false;
  @override
  Widget build(BuildContext context) {
    final maprovider = Provider.of<MapProvider>(context);
    bool _state = _agree1 && _agree2 && _agree3 && _agree4 && _agree5;
    return _isAgree == false
        ? Column(children: [
            GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (_agree1 == false) {
                    _agree1 = true;
                  } else {
                    _agree1 = false;
                  }
                  setState(() {});
                },
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        checkBox(option: _agree1),
                        const SizedBox(width: 16),
                        const KTextWidget(
                            text: '혼적콜 가입 및 이용 약관',
                            size: 16,
                            fontWeight: null,
                            color: null),
                        const Expanded(child: SizedBox()),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AgreeMainPage()),
                            );
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: noState),
                              padding: const EdgeInsets.all(10),
                              child: const KTextWidget(
                                  text: '내용보기',
                                  size: 14,
                                  fontWeight: FontWeight.bold,
                                  color: noText)),
                        )
                      ],
                    ),

                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (_agree2 == false) {
                          _agree2 = true;
                        } else {
                          _agree2 = false;
                        }
                        setState(() {});
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              checkBox(option: _agree2),
                              const SizedBox(width: 16),
                              const KTextWidget(
                                  text: '개인정보 처리방침',
                                  size: 16,
                                  fontWeight: null,
                                  color: null),
                              const Expanded(child: SizedBox()),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AgreeMainPage(
                                              type: '혼적콜 개인정보 처리방침',
                                            )),
                                  );
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        color: noState),
                                    padding: const EdgeInsets.all(10),
                                    child: const KTextWidget(
                                        text: '내용보기',
                                        size: 14,
                                        fontWeight: FontWeight.bold,
                                        color: noText)),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    // const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (_agree3 == false) {
                          _agree3 = true;
                        } else {
                          _agree3 = false;
                        }
                        setState(() {});
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              checkBox(option: _agree3),
                              const SizedBox(width: 16),
                              const KTextWidget(
                                  text: '전자금융(포인트)이용 약관',
                                  size: 16,
                                  fontWeight: null,
                                  color: null),
                              const Expanded(child: SizedBox()),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AgreeMainPage(
                                              type: '혼적콜 전자금융(포인트)이용 약관',
                                            )),
                                  );
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        color: noState),
                                    padding: const EdgeInsets.all(10),
                                    child: const KTextWidget(
                                        text: '내용보기',
                                        size: 14,
                                        fontWeight: FontWeight.bold,
                                        color: noText)),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    //const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (_agree4 == false) {
                          _agree4 = true;
                        } else {
                          _agree4 = false;
                        }

                        setState(() {});
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              checkBox(option: _agree4),
                              const SizedBox(width: 16),
                              const KTextWidget(
                                  text: '위치정보 이용약관',
                                  size: 16,
                                  fontWeight: null,
                                  color: null),
                              const Expanded(child: SizedBox()),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AgreeMainPage(
                                              type: '혼적콜 위치정보 이용약관',
                                            )),
                                  );
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        color: noState),
                                    padding: const EdgeInsets.all(10),
                                    child: const KTextWidget(
                                        text: '내용보기',
                                        size: 14,
                                        fontWeight: FontWeight.bold,
                                        color: noText)),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    // const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (_agree5 == false) {
                          _agree5 = true;
                        } else {
                          _agree5 = false;
                        }

                        setState(() {});
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              checkBox(option: _agree5),
                              const SizedBox(width: 16),
                              const KTextWidget(
                                  text: '혼적콜 운송 약관',
                                  size: 16,
                                  fontWeight: null,
                                  color: null),
                              const Expanded(child: SizedBox()),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AgreeMainPage(
                                              type: '혼적콜 운송 약관',
                                            )),
                                  );
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        color: noState),
                                    padding: const EdgeInsets.all(10),
                                    child: const KTextWidget(
                                        text: '내용보기',
                                        size: 14,
                                        fontWeight: FontWeight.bold,
                                        color: noText)),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                )),
            const Expanded(child: SizedBox()),
            DelayedWidget(
              animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
              animationDuration: const Duration(milliseconds: 500),
              child: GestureDetector(
                  onTap: !_state
                      ? () {}
                      : () async {
                          HapticFeedback.lightImpact();

                          setState(() {
                            _isAgree = true;
                          });
                          print('sdfsdf');
                        },
                  child: bottomBox(text: '약관에 동의합니다.', change: _state)),
            ),
          ])
        : maprovider.joinType == '일반'
            ? const NormalUserJoin()
            : Container();
    //여기 기업가입 추가해야함.
    //이거근데, 소속직원 가입도 문제가 있긴하네,,
    // 이거 수정해야되.
  }
}
