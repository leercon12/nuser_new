import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class ListBottomMultiState extends StatefulWidget {
  final Map<String, dynamic> cargo;
  const ListBottomMultiState({super.key, required this.cargo});

  @override
  State<ListBottomMultiState> createState() => _ListBottomMultiStateState();
}

class _ListBottomMultiStateState extends State<ListBottomMultiState> {
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
          } else if (newProgress == 0.35) {
            scrollToPosition(230);
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
      progress = 0.15; // 0.15 -> 0.35

    else if (['운송완료'].contains(widget.cargo['cargoStat']))
      progress = 0.81;
    else
      progress = 0.35; // 0.35 -> 0.48
    _handleProgressChange(progress);
    return Padding(
      padding: const EdgeInsets.only(left: 45),
      child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: isPassedDate(widget.cargo['downTime'].toDate()) &&
                  widget.cargo['pickUserUid'] == null
              ? _exfireNoPick()
              : Row(
                  children: [
                    VerticalDottedLine(
                      height: 70,
                      color: widget.cargo['pickUserUid'] == null
                          ? Colors.white
                          : Colors.grey.withOpacity(0.5),
                    ),
                    _waitingState(),
                    VerticalDottedLine(
                      height: 70,
                      color: widget.cargo['pickUserUid'] == null
                          ? Colors.white
                          : Colors.grey.withOpacity(0.5),
                    ),
                    _cargoState(),
                    VerticalDottedLine(
                      height: 70,
                      color: widget.cargo['pickUserUid'] == null
                          ? Colors.white
                          : Colors.grey.withOpacity(0.5),
                    ),
                    _comState(),
                    VerticalDottedLine(
                      height: 70,
                      color: widget.cargo['pickUserUid'] == null
                          ? Colors.white
                          : Colors.grey.withOpacity(0.5),
                    ),
                  ],
                )),
    );
  }

  Widget _exfireNoPick() {
    final dw = MediaQuery.of(context).size.width;
    return Row(
      children: [
        VerticalDottedLine(
          height: 70,
          color: widget.cargo['pickUserUid'] == null
              ? Colors.white
              : Colors.grey.withOpacity(0.5),
        ),
        widget.cargo['pickUserUid'] == null
            ? Container(
                height: 70,
                width: dw - 65,
                color: dialogColor.withOpacity(0.3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 2.5),
                            Icon(
                              Icons.cancel,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ],
                        ),
                        SizedBox(width: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            KTextWidget(
                                text: '운송 기간 만료, 배차에 실패하였습니다.',
                                size: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ],
                        )
                      ],
                    ),
                    KTextWidget(
                        text: '운송을 재등록하거나, 삭제하세요.',
                        size: 12,
                        fontWeight: null,
                        color: Colors.grey),
                  ],
                ),
              )
            : Container(
                height: 70,
                width: dw - 65,
                color: dialogColor.withOpacity(0.3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 2.5),
                            Icon(
                              Icons.cancel,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ],
                        ),
                        SizedBox(width: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            KTextWidget(
                                text: '운송 기간 만료, 배차에 실패하였습니다.',
                                size: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ],
                        )
                      ],
                    ),
                    KTextWidget(
                        text: '운송을 재등록하거나, 삭제하세요.',
                        size: 12,
                        fontWeight: null,
                        color: Colors.grey),
                  ],
                ),
              ),
        VerticalDottedLine(
          height: 70,
          color: widget.cargo['pickUserUid'] == null
              ? Colors.white
              : Colors.grey.withOpacity(0.5),
        ),
      ],
    );
  }

  Widget _waitingState() {
    num a =
        widget.cargo['bidingCom'].length + widget.cargo['bidingUsers'].length;
    return Container(
      height: 70,
      width: 230,
      color: dialogColor.withOpacity(0.3),
      child: widget.cargo['pickUserUid'] == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 2.5),
                        Icon(
                          Icons.check_circle,
                          color: a > 0 ? kOrangeBssetColor : Colors.grey,
                          size: 16,
                        ),
                      ],
                    ),
                    SizedBox(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        KTextWidget(
                            text: '운송료 제안 받는중(${a})',
                            size: 15,
                            fontWeight: FontWeight.bold,
                            color: a > 0 ? kOrangeBssetColor : Colors.grey),
                      ],
                    )
                  ],
                ),
                KTextWidget(
                    text: '제안을 수락하여 운송을 시작하세요.',
                    size: 12,
                    fontWeight: null,
                    color: a > 0 ? kOrangeBssetColor : Colors.grey),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 2.5),
                        Icon(
                          Icons.check_circle,
                          color: kGreenFontColor,
                          size: 16,
                        ),
                      ],
                    ),
                    SizedBox(width: 5),
                    KTextWidget(
                        text: '기사 배차 완료',
                        size: 15,
                        fontWeight: FontWeight.bold,
                        color: kGreenFontColor),
                  ],
                ),
                KTextWidget(
                    text: formatDateKorTime(widget.cargo['fixDate'].toDate()),
                    size: 12,
                    fontWeight: null,
                    color: kGreenFontColor),
              ],
            ),
    );
  }

//////
  var info;
  Widget _cargoState() {
    info = widget.cargo['cargoStat'] != null
        ? extractCargoStatInfo(widget.cargo['cargoStat'])
        : {'number': 0, 'type': '', 'isCompleted': false};
    print(info['number'] - 1);
    return Container(
      height: 70,
      width: widget.cargo['pickUserUid'] == null ? 50 : 230,
      color: widget.cargo['pickUserUid'] == null
          ? dialogColor.withOpacity(0.3)
          : widget.cargo['cargoStat'] == '운송완료'
              ? dialogColor.withOpacity(0.3)
              : kBlueBssetColor.withOpacity(0.06),
      child: widget.cargo['pickUserUid'] == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /* Column(
                      children: [
                        const SizedBox(height: 2.5),
                        Icon(
                          Icons.check_circle,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ],
                    ), */
                    SizedBox(width: 5),
                    KTextWidget(
                        text: '...',
                        size: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ],
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 2.5),
                        Icon(
                          Icons.check_circle,
                          color: kBlueBssetColor,
                          size: 16,
                        ),
                      ],
                    ),
                    SizedBox(width: 5),
                    KTextWidget(
                        text: widget.cargo['cargoStat'] == '배차'
                            ? '1번 상차지로 이동중...'
                            : '다구간 ${info['number']}번, ${info['type']} 완료',
                        size: 15,
                        fontWeight: FontWeight.bold,
                        color: kBlueBssetColor),
                  ],
                ),
                if (widget.cargo['cargoStat'] == '운송완료')
                  KTextWidget(
                      text: formatDateKorTime(widget
                          .cargo['locations'].last['isDoneDate']
                          .toDate()),
                      size: 12,
                      fontWeight: null,
                      color: kBlueBssetColor)
                else
                  KTextWidget(
                      text: widget.cargo['cargoStat'] == '배차'
                          ? '기사가 배차되어 상차지로 이동중입니다.'
                          : widget.cargo['locations'][info['number'] - 1]
                                      ['isDoneDate'] ==
                                  null
                              ? '...'
                              : formatDateKorTime(widget.cargo['locations']
                                      [info['number'] - 1]['isDoneDate']
                                  .toDate()),
                      size: 12,
                      fontWeight: null,
                      color: kBlueBssetColor),
              ],
            ),
    );
  }

  Widget _comState() {
    return Container(
      height: 70,
      width: widget.cargo['pickUserUid'] == null ||
              (widget.cargo['cargoStat'] != '운송완료')
          ? 50
          : 230,
      color: dialogColor.withOpacity(0.3),
      child: widget.cargo['pickUserUid'] == null ||
              (widget.cargo['cargoStat'] != '운송완료')
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /* Column(
                      children: [
                        const SizedBox(height: 2.5),
                        Icon(
                          Icons.check_circle,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ],
                    ), */
                    SizedBox(width: 5),
                    KTextWidget(
                        text: '...',
                        size: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ],
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 2.5),
                        Icon(
                          Icons.check_circle,
                          color: kOrangeBssetColor,
                          size: 16,
                        ),
                      ],
                    ),
                    SizedBox(width: 5),
                    KTextWidget(
                        text: '다구간(${widget.cargo['multiNum']}) 운송 완료',
                        size: 15,
                        fontWeight: FontWeight.bold,
                        color: kOrangeBssetColor),
                  ],
                ),
                KTextWidget(
                    text: formatDateKorTime(
                        widget.cargo['locations'].last['isDoneDate'].toDate()),
                    size: 12,
                    fontWeight: null,
                    color: kOrangeBssetColor),
              ],
            ),
    );
  }
}

Map<String, dynamic> extractCargoStatInfo(String cargoStat) {
  // 결과를 저장할 맵
  Map<String, dynamic> result = {
    'number': 0, // 기본값은 정수 0
    'type': '',
    'isCompleted': false
  };

  // 입력값이 null이거나 비어있는 경우 기본값 반환
  if (cargoStat == null || cargoStat.isEmpty) {
    return result;
  }

  // 숫자 추출 (1번, 2번 등에서 숫자 부분)
  RegExp numberRegex = RegExp(r'(\d+)번');
  final numberMatch = numberRegex.firstMatch(cargoStat);
  if (numberMatch != null && numberMatch.groupCount >= 1) {
    // 문자열을 정수로 변환 (실패 시 0 반환)
    result['number'] = int.tryParse(numberMatch.group(1) ?? '0') ?? 0;
  }

  // 상차/하차 여부 추출
  if (cargoStat.contains('상차')) {
    result['type'] = '상차';
  } else if (cargoStat.contains('하차')) {
    result['type'] = '하차';
  }

  // 완료 여부 확인
  result['isCompleted'] = cargoStat.contains('완료');

  return result;
}
