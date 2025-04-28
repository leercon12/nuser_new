import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/full_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/large_updown/widget/return_state.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/large_updown/widget/wait_state.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:provider/provider.dart';

class BottomLargeReturn extends StatefulWidget {
  final Map<String, dynamic> cargo;
  const BottomLargeReturn({super.key, required this.cargo});

  @override
  State<BottomLargeReturn> createState() => _BottomLargeReturnState();
}

class _BottomLargeReturnState extends State<BottomLargeReturn> {
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
          if (widget.cargo['pickUserUid'] == null) {
            scrollToPosition(0); // 첫 번째 박스가 보이도록
          } else if (widget.cargo['cargoStat'] == '배차') {
            scrollToPosition(300); // 두 번째 박스가 보이도록
          } else if (widget.cargo['cargoStat'] == '상차완료') {
            scrollToPosition(600); // 세 번째 박스가 보이도록
          } else if (widget.cargo['cargoStat'] == '회차완료') {
            scrollToPosition(900); // 네 번째 박스가 보이도록
          }
        }
      });
    }
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
    // 4단계로 progress 수정
    if (widget.cargo['pickUserUid'] == null) {
      progress = 150 / 1200; // 첫 번째 박스 중간 (300/2 = 150)
    } else if (widget.cargo['cargoStat'] == '배차') {
      progress = 430 / 1200; // 두 번째 박스 중간 (300 + 300/2 = 450)
    } else if (widget.cargo['cargoStat'] == '상차완료') {
      progress = 730 / 1200; // 세 번째 박스 중간 (600 + 300/2 = 750)
    } else if (widget.cargo['cargoStat'] == '회차완료') {
      progress = 1030 / 1200; // 네 번째 박스 중간 (900 + 300/2 = 1050)
    }
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    _handleProgressChange(progress);
    return Stack(
      children: [
        if (widget.cargo['pickUserUid'] != null)
          Positioned(
            top: dh * 0.1,
            left: -scrollOffset, // 스크롤 오프셋 만큼 이동
            child: /* isPassedDate(widget.cargo['upTime'].toDate()) == true &&
                  widget.cargo['pickUserUid'] == null
              ? StaticProgressLine(
                  width: 200,
                  progress: 0.7, // 0.0부터 1.0 사이의 값
                  lineColor: Colors.grey.withOpacity(0.5),
                )
              : */

                ProgressLine(
              width: 1200,
              progress: progress,
              lineColor: widget.cargo['cargoStat'] == '배차'
                  ? kBlueBssetColor
                  : widget.cargo['cargoStat'] == '회차완료'
                      ? kRedColor
                      : kGreenFontColor,
            ),
          ),
        SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              VerticalDottedLine(
                height: 210,
                color: Colors.grey.withOpacity(0.5),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  dataProvider.isUpState(false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FullMainPage(
                              cargo: widget.cargo,
                            )),
                  );
                },
                child: WaitStatePage(
                  cargo: widget.cargo,
                  callType: '왕복',
                ),
              ),
              GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    dataProvider.isUpState(false);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FullMainPage(
                                cargo: widget.cargo,
                              )),
                    );
                  },
                  child: BottomReturnWidget(cargo: widget.cargo)),
              /* NormalUpDownStatePage(
                cargo: widget.cargo,
                callType: widget.callType.toString(),
              ) */
              /*  _upState(),
              VerticalDottedLine(
                height: 210,
                color: kRedColor.withOpacity(0.5),
              ),
              _downState(),
              VerticalDottedLine(
                height: 210,
                color: kRedColor.withOpacity(0.5),
              ), */
            ],
          ),
        ),
      ],
    );
  }

  void scrollToPosition(double position) {
    _horizontalScrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
  }
}
