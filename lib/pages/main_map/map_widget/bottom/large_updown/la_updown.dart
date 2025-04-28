import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/full_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/large_updown/widget/normal_state.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/large_updown/widget/wait_state.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class LargeUpDown extends StatefulWidget {
  final Map<String, dynamic> cargo;
  final double dw;
  final String? callType;
  const LargeUpDown(
      {super.key, required this.cargo, required this.dw, this.callType});

  @override
  State<LargeUpDown> createState() => _LargeUpDownState();
}

class _LargeUpDownState extends State<LargeUpDown> {
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

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  double progress = 0.0;
  @override
  Widget build(BuildContext context) {
    final dh = MediaQuery.of(context).size.height;
    if (widget.cargo['pickUserUid'] == null)
      progress = 0.15;
    else if (widget.cargo['cargoStat'] == '배차')
      progress = 0.48;
    else if (widget.cargo['cargoStat'] == '상차완료' ||
        widget.cargo['cargoStat'] == '하차완료') progress = 0.81;
    _handleProgressChange(progress);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
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
              width: 900,
              progress: progress,
              lineColor: widget.cargo['cargoStat'] == '상차완료'
                  ? kRedColor
                  : kBlueBssetColor,
            ),
          ),
        SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              if (widget.callType == '노링크') {
              } else {
                dataProvider.isUpState(false);
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
                  color: Colors.grey.withOpacity(0.5),
                ),
                WaitStatePage(
                  cargo: widget.cargo,
                ),
                NormalUpDownStatePage(
                  cargo: widget.cargo,
                  callType: widget.callType.toString(),
                )
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
