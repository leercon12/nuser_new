import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/bottom_history/bottom_driver_info.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/full_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/bottom.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class BottomLargeNormal extends StatefulWidget {
  final Map<String, dynamic> cargo;
  final String? callType;
  final double dw;

  const BottomLargeNormal(
      {super.key, required this.cargo, required this.dw, this.callType});

  @override
  State<BottomLargeNormal> createState() => _BottomLargeNormalState();
}

class _BottomLargeNormalState extends State<BottomLargeNormal> {
  final ScrollController _horizontalScrollController = ScrollController();
  double scrollOffset = 0.0;
  double? lastProgress;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController.addListener(() {
      setState(() {
        scrollOffset = _horizontalScrollController.offset;
      });
    });
  }

  void _handleProgressChange(double newProgress) {
    if (lastProgress != newProgress) {
      lastProgress = newProgress;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_horizontalScrollController.hasClients) {
          if (newProgress == 0.15) {
            scrollToPosition(0);
          } else if (newProgress == 0.48) {
            scrollToPosition(270);
          } else if (newProgress == 0.81) {
            scrollToPosition(570);
          }
        }
      });
    }
  }

  void scrollToPosition(double position) {
    _horizontalScrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  double progress = 0.0;
  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    final dataProvider = Provider.of<DataProvider>(context);
    if (widget.cargo['pickUserUid'] == null)
      progress = 0.1; // 0.15 -> 0.35
    else if (widget.cargo['cargoStat'] == '배차')
      progress = 0.48; // 0.35 -> 0.48
    else if (['상차완료', '하차완료'].contains(widget.cargo['cargoStat']))
      progress = 0.81; // 0.65 -> 0.81
    _handleProgressChange(progress);
    return Container(
      margin: const EdgeInsets.only(left: 8, right: 8),
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          color: msgBackColor),
      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: Stack(
          children: [
            /*   if (widget.cargo['pickUserUid'] != null &&
                isPassedDate(widget.cargo['upTime'].toDate()) == false)
              Positioned(
                top: dh * 0.1,
                left: 0,
                child: ProgressLine(
                  width: 900,
                  progress: progress,
                  lineColor: Colors.grey,
                ),
              ), */
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                print(widget.callType);
                if (widget.callType == '지도') {
                  dataProvider.setCurrentCargo(widget.cargo);
                  Navigator.pop(context);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FullMainPage(
                              cargo: widget.cargo,
                            )),
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  VerticalDottedLine(
                    height: 210,
                    color: widget.cargo['pickUserUid'] == null
                        ? Colors.white
                        : Colors.grey.withOpacity(0.5),
                  ),
                  widget.cargo['pickUserUid'] == null
                      ? _newWating()
                      : _waitingState(),
                  VerticalDottedLine(
                    height: 210,
                    color: widget.cargo['pickUserUid'] == null
                        ? Colors.white
                        : widget.cargo['cargoStat'] == '배차'
                            ? kBlueBssetColor
                            : Colors.grey.withOpacity(0.5),
                  ),
                  widget.cargo['pickUserUid'] == null
                      ? nullState(widget.cargo['pickUserUid'] == null &&
                          isPassedDate(widget.cargo['upTime'].toDate()))
                      : _upState(),
                  VerticalDottedLine(
                    height: 210,
                    color: widget.cargo['cargoStat'] == '배차'
                        ? kBlueBssetColor
                        : widget.cargo['cargoStat'] == '상차완료'
                            ? kRedColor
                            : Colors.grey.withOpacity(0.5),
                  ),
                  widget.cargo['pickUserUid'] == null
                      ? nullState(widget.cargo['pickUserUid'] == null &&
                          isPassedDate(widget.cargo['upTime'].toDate()))
                      : _downState(),
                  VerticalDottedLine(
                    height: 210,
                    color: widget.cargo['cargoStat'] == '상차완료'
                        ? kRedColor
                        : Colors.grey.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _newWating() {
    num all =
        widget.cargo['bidingUsers'].length + widget.cargo['bidingCom'].length;
    return widget.cargo['pickUserUid'] == null &&
            isPassedDate(widget.cargo['upTime'].toDate())
        ? exfireState()
        : Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            color: msgBackColor,
            height: 210,
            width: 300,
            child: Column(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    print(widget.callType);
                    /*   Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FullMainPage(
                                cargo: widget.cargo,
                                callType: '보고',
                              )),
                    ); */
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: all == 0
                            ? noState.withOpacity(0.5)
                            : kOrangeBssetColor.withOpacity(0.15)),
                    child: Center(
                      child: KTextWidget(
                          text: all.toString(),
                          size: 28,
                          fontWeight: FontWeight.bold,
                          color: all == 0 ? Colors.grey : kOrangeBssetColor),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const KTextWidget(
                    text: '운송료 제안 받는 중...',
                    size: 16,
                    lineHeight: 0,
                    fontWeight: FontWeight.bold,
                    color: kOrangeBssetColor),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    KTextWidget(
                      text: '상차',
                      size: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.withOpacity(0.7),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.start,
                      color: Colors.grey.withOpacity(0.7),
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    KTextWidget(
                      text: addressEx2(widget.cargo['upAddress']),
                      overflow: TextOverflow.ellipsis,
                      size: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.withOpacity(0.7),
                    ),
                    _dateState(
                        calculateDateStatus(
                          widget.cargo['downTime'].toDate(),
                          DateTime.now(),
                        ),
                        13),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    KTextWidget(
                      text: '하차',
                      size: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.withOpacity(0.7),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.linear_scale_rounded,
                      color: Colors.grey.withOpacity(0.7),
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    KTextWidget(
                      text: addressEx2(widget.cargo['downAddress']),
                      overflow: TextOverflow.ellipsis,
                      size: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.withOpacity(0.7),
                    ),
                    _dateState(
                        calculateDateStatus(
                          widget.cargo['downTime'].toDate(),
                          DateTime.now(),
                        ),
                        13),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 14,
                      child: Stack(
                        children: [
                          Image.asset(
                            'asset/img/cargo_up.png',
                            width: 7,
                          ),
                          Positioned(
                            bottom: 0,
                            child: Image.asset(
                              'asset/img/cargo_down.png',
                              width: 7,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    if (widget.cargo['transitType'] == '무관')
                      KTextWidget(
                          text: '독차, 혼적(일반)',
                          size: 13,
                          fontWeight: null,
                          color: Colors.grey.withOpacity(0.7))
                    else
                      KTextWidget(
                          text: '${widget.cargo['transitType']}(일반)',
                          size: 13,
                          fontWeight: null,
                          color: Colors.grey.withOpacity(0.7)),
                    KTextWidget(
                        text:
                            ' | ${agoKorTimestamp(widget.cargo['createdDate'])}',
                        size: 13,
                        fontWeight: null,
                        color: Colors.grey.withOpacity(0.7))
                  ],
                ),
                const Spacer(),
              ],
            ),
          );
  }

  Widget _waitingState() {
    return widget.cargo['driverCarInfo'] == null
        ? const SizedBox()
        : Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            color: msgBackColor,
            height: 210,
            width: 300,
            child: Column(
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return StatefulBuilder(builder: (context, setState) {
                          return BottomDriverInfoPage(
                            pickUserUid: widget.cargo['pickUserUid'],
                            isReview: true,
                            cargo: widget.cargo,
                          );
                        });
                      },
                    );
                  },
                  child: Column(
                    children: [
                      cirDriver(50, widget.cargo),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          KTextWidget(
                              text: '${widget.cargo['driverName']} 기사님 배차 완료',
                              size: 16,
                              lineHeight: 0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 16,
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          KTextWidget(
                            text: '상차',
                            size: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.withOpacity(0.7),
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            Icons.start,
                            color: Colors.grey.withOpacity(0.7),
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          KTextWidget(
                            text: addressEx2(widget.cargo['upAddress']),
                            overflow: TextOverflow.ellipsis,
                            size: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.withOpacity(0.7),
                          ),
                          _dateState(
                              calculateDateStatus(
                                widget.cargo['downTime'].toDate(),
                                DateTime.now(),
                              ),
                              13),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          KTextWidget(
                            text: '하차',
                            size: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.withOpacity(0.7),
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            Icons.linear_scale_rounded,
                            color: Colors.grey.withOpacity(0.7),
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          KTextWidget(
                            text: addressEx2(widget.cargo['downAddress']),
                            overflow: TextOverflow.ellipsis,
                            size: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.withOpacity(0.7),
                          ),
                          _dateState(
                              calculateDateStatus(
                                widget.cargo['downTime'].toDate(),
                                DateTime.now(),
                              ),
                              13),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 290,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                KTextWidget(
                                    text:
                                        '${getPart(widget.cargo['driverCarInfo'], 0)}',
                                    textAlign: TextAlign.center,
                                    size: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.withOpacity(0.7)),
                                KTextWidget(
                                    text: ' | ',
                                    textAlign: TextAlign.center,
                                    size: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.withOpacity(0.7)),
                                KTextWidget(
                                    text:
                                        '${getPart(widget.cargo['driverCarInfo'], 1)}톤',
                                    textAlign: TextAlign.center,
                                    size: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.withOpacity(0.7)),
                                KTextWidget(
                                    text: ' | ',
                                    textAlign: TextAlign.center,
                                    size: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.withOpacity(0.7)),
                                KTextWidget(
                                    text:
                                        '${getPart(widget.cargo['driverCarInfo'], 2)}',
                                    textAlign: TextAlign.center,
                                    size: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.withOpacity(0.7)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          );
  }

  ///////////////////////////////
  ///
  ///
  ///

  Widget _upState() {
    bool state = widget.cargo['cargoStat'] == '하차완료' ||
        widget.cargo['cargoStat'] == '상차완료';
    return Container(
      color: state ? msgBackColor : kBlueBssetColor.withOpacity(0.02),
      padding: const EdgeInsets.only(left: 5, right: 5),
      height: 210,
      width: 300,
      child: state
          ? Column(
              children: [
                const SizedBox(height: 3),
                Row(
                  children: [
                    Image.asset('asset/img/up_navi.png', width: 13),
                    const SizedBox(width: 5),
                    const KTextWidget(
                        text: '상차 완료',
                        size: 13,
                        fontWeight: null,
                        color: kBlueBssetColor)
                  ],
                ),
                const Spacer(),
                const Icon(
                  Icons.info,
                  size: 50,
                  color: kBlueBssetColor,
                ),
                const SizedBox(height: 24),
                KTextWidget(
                    text: '상차 완료',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.withOpacity(0.7)),
                KTextWidget(
                    text:
                        '${formatDateTime(widget.cargo['upDoneTime'].toDate())}, ${agoKorTimestamp(widget.cargo['upDoneTime'])}',
                    size: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.withOpacity(0.7)),
                const Spacer(),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('asset/img/up_navi.png', width: 50),
                const SizedBox(height: 24),
                const KTextWidget(
                    text: '상차지로 이동중...',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: kBlueBssetColor),
                const KTextWidget(
                    text: '배차완료 후, 상차지로 이동중입니다.',
                    size: 13,
                    fontWeight: FontWeight.bold,
                    color: kBlueBssetColor),
              ],
            ),
    );
  }

  ///////////////////////////////
  ///
  ///
  ///

  Widget _downState() {
    bool state = widget.cargo['cargoStat'] == '하차완료';
    return Container(
      color: state ? msgBackColor : kRedColor.withOpacity(0.02),
      padding: const EdgeInsets.only(left: 5, right: 5),
      height: 210,
      width: 300,
      child: widget.cargo['cargoStat'] == '하차완료'
          ? Column(
              children: [
                const SizedBox(height: 3),
                Row(
                  children: [
                    Image.asset('asset/img/down_navi.png', width: 13),
                    const SizedBox(width: 5),
                    const KTextWidget(
                        text: '하차 완료',
                        size: 13,
                        fontWeight: null,
                        color: kRedColor)
                  ],
                ),
                const Spacer(),
                const Icon(
                  Icons.info,
                  size: 50,
                  color: kBlueBssetColor,
                ),
                const SizedBox(height: 24),
                KTextWidget(
                    text: '하차 완료',
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.withOpacity(0.7)),
                KTextWidget(
                    text:
                        '${formatDateTime(widget.cargo['downDoneTime'].toDate())}, ${agoKorTimestamp(widget.cargo['downDoneTime'])}',
                    size: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.withOpacity(0.7)),
                const Spacer(),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.cargo['cargoStat'] == '상차완료')
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      child: Image.asset(
                        'asset/img/logo.png',
                        errorBuilder: (context, error, stackTrace) {
                          print('이미지 로드 에러: $error');
                          return const Center(
                            child: Text('이미지를 불러올 수 없습니다'),
                          );
                        },
                      ),
                    ),
                  )
                else
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      child: Opacity(
                        opacity: 0.5, // 0.0(완전 투명) ~ 1.0(완전 불투명)
                        child: Image.asset(
                          'asset/img/logo.png',
                          errorBuilder: (context, error, stackTrace) {
                            print('이미지 로드 에러: $error');
                            return const Center(
                              child: Text('이미지를 불러올 수 없습니다'),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                if (widget.cargo['cargoStat'] == '상차완료')
                  KTextWidget(
                      text: '상차 완료 후, 하차지로 이동중...',
                      size: 14,
                      fontWeight: FontWeight.bold,
                      color: kRedColor)
                else
                  KTextWidget(
                      text: '하차 완료 대기중',
                      size: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.withOpacity(0.5))
              ],
            ),
    );
  }

  Widget _dateState(String state, double? size) {
    return Stack(
      children: [
        if (state == 'today')
          KTextWidget(
              text: ', 오늘',
              size: size == null ? 14 : size,
              fontWeight: FontWeight.bold,
              color: kGreenFontColor),
        if (state == 'tmm')
          KTextWidget(
              text: ', 내일',
              size: size == null ? 14 : size,
              fontWeight: FontWeight.bold,
              color: kBlueBssetColor),
        if (state == 'ex')
          KTextWidget(
              text: ', 만료',
              size: size == null ? 14 : size,
              fontWeight: FontWeight.bold,
              color: kRedColor),
        if (state == 'book')
          KTextWidget(
              text: ', 예약',
              size: size == null ? 14 : size,
              fontWeight: FontWeight.bold,
              color: kOrangeBssetColor),
      ],
    );
  }
}

Widget nullState(bool state) {
  return SizedBox(
    height: 200,
    width: 100,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: Opacity(
              opacity: 0.5, // 0.0(완전 투명) ~ 1.0(완전 불투명)
              child: Image.asset(
                'asset/img/logo.png',
                errorBuilder: (context, error, stackTrace) {
                  print('이미지 로드 에러: $error');
                  return const Center(
                    child: Text('이미지를 불러올 수 없습니다'),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        state
            ? const SizedBox()
            : KTextWidget(
                text: '배차 대기중',
                size: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.withOpacity(0.5))
      ],
    ),
  );
}

Widget exfireState() {
  return const SizedBox(
    height: 200,
    width: 300,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.info, color: Colors.grey, size: 50),
        SizedBox(height: 8),
        KTextWidget(
            text: '운송건이 만료되었습니다.',
            size: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey),
        KTextWidget(
            text: '삭제하거나 재등록하세요.',
            size: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey)
      ],
    ),
  );
}
