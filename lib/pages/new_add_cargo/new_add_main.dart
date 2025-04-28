import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/btn_state/multi_btn.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/btn_state/return_btn.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/main_category/maincategory.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/btn_state/normal_btn.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/multi_state/multi_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/normal_state/normal_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/new_add_cargo/return_state/return_main.dart';
import 'package:flutter_mixcall_normaluser_new/providers/addProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/loading_page.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class NewAddMainPage extends StatefulWidget {
  final String callType;
  final Map<String, dynamic>? cargo;
  const NewAddMainPage({
    super.key,
    required this.callType,
    this.cargo,
  });

  @override
  State<NewAddMainPage> createState() => _NewAddMainPageState();
}

class _NewAddMainPageState extends State<NewAddMainPage> {
  @override
  Widget build(BuildContext context) {
    final addProvider = Provider.of<AddProvider>(context);
    final mapProvider = Provider.of<MapProvider>(context);
    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                widget.callType.contains('재등록')
                    ? '운송 재등록'
                    : widget.callType.contains('수정')
                        ? '운송 정보 수정'
                        : '신규 운송 등록',
                style: const TextStyle(fontSize: 20),
              ),
              actions: [
                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.info,
                    color: kOrangeBssetColor,
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ),
            body: SafeArea(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: _typeState(addProvider),
                  ),
                  const SizedBox(height: 16),
                  _btnState(addProvider),
                ],
              ),
            )),
          ),
          if (mapProvider.isLoading == true) const LoadingPage()
        ],
      ),
    );
  }

  Widget _typeState(AddProvider addProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _cargoTypeState(addProvider),
          if (addProvider.addMainType != null)
            Column(
              children: [
                if (addProvider.addMainType == '왕복')
                  ReturnMainPage(
                    callType: widget.callType,
                    cargo: widget.cargo,
                  )
                else if (addProvider.addMainType == '다구간')
                  MultiMainPage(
                    callType: widget.callType,
                    cargo: widget.cargo,
                  )
                else
                  NormalMainState(
                    callType: widget.callType,
                    cargo: widget.cargo,
                  )
              ],
            ),
        ],
      ),
    );
  }

  Widget _btnState(AddProvider addProvider) {
    final dw = MediaQuery.of(context).size.width;
    return SizedBox(
      width: dw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (addProvider.addMainType == '왕복')
            ReturnBtnState(
              callType: widget.callType,
              cargo: widget.cargo,
            )
          else if (addProvider.addMainType == '다구간')
            MultiBtnState(
              callType: widget.callType,
              cargo: widget.cargo,
            )
          else
            NormalBtnState(
              callType: widget.callType.toString(),
              cargo: widget.cargo,
            )
        ],
      ),
    );
  }

  Widget _cargoTypeState(AddProvider addProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            KTextWidget(
                text: '운송 유형 선택',
                size: 16,
                fontWeight: FontWeight.bold,
                color: addProvider.addMainType != null &&
                        addProvider.addSubType != null
                    ? Colors.grey.withOpacity(0.5)
                    : Colors.white),
            const Spacer(),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                addProvider.addMainTypeState(null);
                addProvider.addSubTypeState(null);
              },
              child: KTextWidget(
                  text: '재설정',
                  size: 14,
                  fontWeight: null,
                  color: addProvider.addMainType != null &&
                          addProvider.addSubType != null
                      ? Colors.grey.withOpacity(0.5)
                      : Colors.grey),
            )
          ],
        ),
        if (addProvider.addMainType == null)
          const KTextWidget(
              text: '이용하실 화물 운송 유형을 선택하세요.',
              size: 14,
              fontWeight: null,
              color: Colors.grey),
        const SizedBox(height: 12),
        if (addProvider.addMainType == null)
          Column(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  DelayedWidget(
                    animationDuration: const Duration(milliseconds: 500),
                    animation: DelayedAnimations.SLIDE_FROM_LEFT,
                    child: GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await mainCategoryBottom(context, '무관').then((value) {
                          if (value == true) {
                            addProvider.addMainTypeState('편도');
                            addProvider.addSubTypeState('무관');
                          }
                        });
                      },
                      child: _box2(
                          '편도 운송', '혼적&독차 무관', 'asset/img/normal.png', 45),
                    ),
                  ),
                  DelayedWidget(
                    animationDuration: const Duration(milliseconds: 500),
                    animation: DelayedAnimations.SLIDE_FROM_RIGHT,
                    child: GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await mainCategoryBottom(context, '혼적').then((value) {
                          if (value == true) {
                            addProvider.addMainTypeState('편도');
                            addProvider.addSubTypeState('혼적');
                          }
                        });
                      },
                      child:
                          _box2('편도 운송', '혼적 운송', 'asset/img/normal.png', 45),
                    ),
                  ),
                  DelayedWidget(
                    animationDuration: const Duration(milliseconds: 500),
                    animation: DelayedAnimations.SLIDE_FROM_LEFT,
                    child: GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await mainCategoryBottom(context, '독차').then((value) {
                          if (value == true) {
                            addProvider.addMainTypeState('편도');
                            addProvider.addSubTypeState('독차');
                          }
                        });
                      },
                      child:
                          _box2('편도 운송', '독차 운송', 'asset/img/normal.png', 45),
                    ),
                  ),
                  DelayedWidget(
                      animationDuration: const Duration(milliseconds: 500),
                      animation: DelayedAnimations.SLIDE_FROM_RIGHT,
                      child: GestureDetector(
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            await mainCategoryBottom(context, '왕복')
                                .then((value) {
                              if (value == true) {
                                addProvider.addMainTypeState('왕복');
                                addProvider.addSubTypeState('독차');
                              }
                            });
                          },
                          child: _box2('왕복 운송', '독차만 가능',
                              'asset/img/return_c.png', 40))),
                  DelayedWidget(
                      animationDuration: const Duration(milliseconds: 500),
                      animation: DelayedAnimations.SLIDE_FROM_LEFT,
                      child: GestureDetector(
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            await mainCategoryBottom(context, '다구간')
                                .then((value) {
                              if (value == true) {
                                addProvider.addMainTypeState('다구간');
                                addProvider.addSubTypeState('다구간');
                              }
                            });
                          },
                          child: _box2('다구간 운송', '독차만 가능',
                              'asset/img/multi_cargo.png', 45))),
                ],
              )
            ],
          )
        else
          _selTypeCom(addProvider),
      ],
    );
  }

  Widget _box2(String title, String dis, String img, double size) {
    final dw = MediaQuery.of(context).size.width;
    return Container(
      width: dw * 0.5 - 12,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: msgBackColor, borderRadius: BorderRadius.circular(7)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              // color: noState.withOpacity(0.3),
            ),
            child: Center(
              child: Image.asset(
                img,
                width: size,
              ),
            ),
          ),
          const SizedBox(height: 12),
          KTextWidget(
              text: title,
              lineHeight: 0,
              size: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white),
          KTextWidget(
              text: dis,
              size: 14,
              textAlign: TextAlign.center,
              fontWeight: null,
              color: Colors.grey),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _selTypeCom(AddProvider addProvider) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        addProvider.addMainTypeState(null);
        addProvider.addSubTypeState(null);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          //border: Border.all(color: Colors.blueGrey.withOpacity(0.1)),
          color: msgBackColor,
        ),
        child: Row(
          children: [
            const Spacer(),
            if (addProvider.addMainType == '편도')
              if (addProvider.addSubType == '무관')
                KTextWidget(
                    text: '독차, 혼적 모두 가능 / ${addProvider.addMainType}',
                    size: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)
              else if (addProvider.addSubType == '독차')
                KTextWidget(
                    text: '독차 운송 / ${addProvider.addMainType}',
                    size: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)
              else if (addProvider.addSubType == '혼적')
                KTextWidget(
                    text: '혼적 운송 / ${addProvider.addMainType}',
                    size: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
            if (addProvider.addMainType == '왕복')
              KTextWidget(
                  text: '독차 운송 / ${addProvider.addMainType}',
                  size: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            if (addProvider.addMainType == '다구간')
              const KTextWidget(
                  text: '다구간 상, 하차 운송',
                  size: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
