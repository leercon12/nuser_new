import 'package:flutter/material.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class LIstBottomState extends StatefulWidget {
  final Map<String, dynamic> cargo;
  final String? callType;

  const LIstBottomState({super.key, required this.cargo, this.callType});

  @override
  State<LIstBottomState> createState() => _LIstBottomStateState();
}

class _LIstBottomStateState extends State<LIstBottomState> {
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
    else if (widget.cargo['cargoStat'] == '배차')
      progress = 0.35; // 0.35 -> 0.48
    else if (['상차완료', '하차완료', '운송완료'].contains(widget.cargo['cargoStat']))
      progress = 0.81; // 0.65 -> 0.81
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

  Widget _cargoState() {
    return Container(
      height: 70,
      width: widget.cargo['pickUserUid'] == null ? 50 : 230,
      color: widget.cargo['pickUserUid'] == null
          ? dialogColor.withOpacity(0.3)
          : widget.cargo['cargoStat'] == '상차완료' ||
                  widget.cargo['cargoStat'] == '하차완료'
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
                            ? '상차지로 이동중...'
                            : '화물 상차 완료',
                        size: 15,
                        fontWeight: FontWeight.bold,
                        color: kBlueBssetColor),
                  ],
                ),
                KTextWidget(
                    text: widget.cargo['cargoStat'] == '배차'
                        ? '기사가 배차되어 상차지로 이동중입니다.'
                        : formatDateKorTime(
                            widget.cargo['upDoneTime'].toDate()),
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
              (widget.cargo['cargoStat'] == '배차' ||
                  widget.cargo['cargoStat'] == '대기' ||
                  widget.cargo['cargoStat'] == '상차완료')
          ? 50
          : 230,
      color: widget.cargo['pickUserUid'] == null ||
              (widget.cargo['cargoStat'] == '배차' ||
                  widget.cargo['cargoStat'] == '대기' ||
                  widget.cargo['cargoStat'] == '상차완료')
          ? dialogColor.withOpacity(0.3)
          : widget.cargo['cargoStat'] == '하차완료'
              ? dialogColor.withOpacity(0.3)
              : kRedColor.withOpacity(0.06),
      child: widget.cargo['pickUserUid'] == null ||
              (widget.cargo['cargoStat'] == '배차' ||
                  widget.cargo['cargoStat'] == '대기' ||
                  widget.cargo['cargoStat'] == '상차완료')
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
                          color: kRedColor,
                          size: 16,
                        ),
                      ],
                    ),
                    SizedBox(width: 5),
                    KTextWidget(
                        text: widget.cargo['cargoStat'] == '상차완료'
                            ? '하차지로 이동중...'
                            : '화물 하차 완료',
                        size: 15,
                        fontWeight: FontWeight.bold,
                        color: kRedColor),
                  ],
                ),
                KTextWidget(
                    text: widget.cargo['cargoStat'] == '하차완료'
                        ? formatDateKorTime(
                            widget.cargo['downDoneTime'].toDate())
                        : '상차 후, 하차지로 이동중 입니다.',
                    size: 12,
                    fontWeight: null,
                    color: kRedColor),
              ],
            ),
    );
  }
}
