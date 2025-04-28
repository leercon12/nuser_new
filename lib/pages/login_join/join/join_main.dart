import 'package:delayed_widget/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/login_join/join/term/term_state.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/loading_page.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class JoinMainPage extends StatefulWidget {
  const JoinMainPage({super.key});

  @override
  State<JoinMainPage> createState() => _JoinMainPageState();
}

class _JoinMainPageState extends State<JoinMainPage> {
  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    final maprovider = Provider.of<MapProvider>(context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              '회원 가입', style: TextStyle(fontSize: 20),
              //style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: maprovider.joinType == null
                      ? Column(
                          children: [
                            _normalUser(maprovider, dw),
                            const SizedBox(height: 8),
                            _comUser(maprovider, dw)
                          ],
                        )
                      : const TermStatePage())),
        ),
        if (maprovider.isLoading == true)
          const Positioned.fill(child: LoadingPage())
      ],
    );
  }

  Widget _normalUser(MapProvider mapProvider, double dw) {
    return DelayedWidget(
      animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
      animationDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          mapProvider.joinTypeState('일반');
        },
        child: Container(
          width: dw,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8), color: msgBackColor),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100), color: kColorA),
                child: const Icon(
                  Icons.person_add_alt_1,
                  color: null,
                ),
              ),
              const SizedBox(height: 25),
              const KTextWidget(
                  text: '일반 회원으로 가입하기',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: null),
              const KTextWidget(
                  text: '#사업자등록번호 없이 혼적콜 이용하기',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey),
              const SizedBox(height: 16),
              const SizedBox(
                width: 290,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: kGreenFontColor, size: 13),
                        SizedBox(width: 10),
                        KTextWidget(
                            text: 'AR, 화물 사진을 이용한 간편한 화물 등록',
                            size: 14,
                            fontWeight: null,
                            color: Colors.grey),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 290,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: kGreenFontColor, size: 13),
                        SizedBox(width: 10),
                        KTextWidget(
                            text: '회원 주선사가 화물 정보 확인후 운송료 입찰',
                            size: 14,
                            fontWeight: null,
                            color: Colors.grey),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 290,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: kGreenFontColor, size: 13),
                        SizedBox(width: 10),
                        KTextWidget(
                            text: '회원 기사가 직접 화물 정보 확인후 운송료 입찰',
                            size: 14,
                            fontWeight: null,
                            color: Colors.grey),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 290,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: kGreenFontColor, size: 13),
                        SizedBox(width: 10),
                        KTextWidget(
                            text: '기사 동의에 따라 실시간 위치 표시',
                            size: 14,
                            fontWeight: null,
                            color: Colors.grey),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 290,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outlined, color: kRedColor, size: 13),
                        SizedBox(width: 10),
                        KTextWidget(
                            text: '전자세금계산서 발행 불가',
                            size: 14,
                            fontWeight: null,
                            color: Colors.grey),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _comUser(MapProvider mapProvider, double dw) {
    return DelayedWidget(
      delayDuration: const Duration(milliseconds: 300),
      animation: DelayedAnimations.SLIDE_FROM_BOTTOM,
      animationDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: () {
          /*  HapticFeedback.lightImpact();
          mapProvider.joinTypeState('일반'); */
          showDialog(
              context: context, builder: (context) => _normalComDialog());
        },
        child: Container(
          width: dw,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8), color: msgBackColor),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100), color: kColorB),
                child: const Icon(
                  Icons.person_add_alt_1,
                  color: null,
                ),
              ),
              const SizedBox(height: 25),
              const KTextWidget(
                  text: '기업, 단체 회원으로 가입하기',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: null),
              const KTextWidget(
                  text: '#전자세금계산서 #산재보험',
                  size: 14,
                  fontWeight: null,
                  color: Colors.grey),
              const SizedBox(height: 16),
              const SizedBox(
                width: 290,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: kGreenFontColor, size: 13),
                        SizedBox(width: 10),
                        KTextWidget(
                            text: '전용 Web을 통한 기업, 단체 전용 페이지 제공',
                            size: 14,
                            fontWeight: null,
                            color: Colors.grey),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 290,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: kGreenFontColor, size: 13),
                        SizedBox(width: 10),
                        KTextWidget(
                            text: '일반, 가격제안 배차 화물 등록',
                            size: 14,
                            fontWeight: null,
                            color: Colors.grey),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 290,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: kGreenFontColor, size: 13),
                        SizedBox(width: 10),
                        KTextWidget(
                            text: '실시간 화물 관리 및 내역 관리 제공',
                            size: 14,
                            fontWeight: null,
                            color: Colors.grey),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 290,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: kGreenFontColor, size: 13),
                        SizedBox(width: 10),
                        KTextWidget(
                            text: '전자세금계산서, 산재보험 발행 및 관리 가능',
                            size: 14,
                            fontWeight: null,
                            color: Colors.grey),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 2),
              const SizedBox(
                width: 290,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: kGreenFontColor, size: 13),
                        SizedBox(width: 10),
                        SizedBox(
                          width: 267,
                          child: KTextWidget(
                              text: '소속 멤버에게는 모든 정보가 실시간 공유',
                              size: 14,
                              lineHeight: 0,
                              fontWeight: null,
                              color: Colors.grey),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _normalComDialog() {
    return DefaultTextStyle(
      style: TextStyle(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 320,
            margin: EdgeInsets.only(left: 10, right: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), color: msgBackColor),
            child: Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.cancel,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                Icon(Icons.info, color: kGreenFontColor, size: 80),
                const SizedBox(height: 32),
                KTextWidget(
                    text: '일반 회원 가입 후, 소속을 등록하세요!',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                /*  const SizedBox(height: 5),
                KTextWidget(
                    text: '기업 소속 및 등록이 모두 통합되었어요!',
                    size: 14,
                    fontWeight: null,
                    color: Colors.grey), */
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: KTextWidget(
                      text:
                          '이제 일반 회원으로 가입 후, 메뉴의 "소속 등록"을 통해 소속을 설정하실 수 있습니다. 일반 회원 가입 후, 소속을 검색하여 등록하시거나 검색이 안될 경우 직접 기업을 등록하실 수 있습니다.',
                      size: 14,
                      fontWeight: null,
                      color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: KTextWidget(
                      text:
                          '소속이 등록되면, 소속 이름으로 운송되는 모든 운송의 실시간 관리 및 운송 관리이력이 가능합니다.',
                      size: 14,
                      fontWeight: null,
                      color: Colors.grey),
                ),
                const SizedBox(height: 48),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 52,
                    margin: EdgeInsets.only(left: 12, right: 12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: kGreenFontColor),
                    child: const Center(
                      child: KTextWidget(
                          text: '확인',
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
