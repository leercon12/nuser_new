import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/full_main.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/large_updown/widget/multi_state.dart';
import 'package:flutter_mixcall_normaluser_new/pages/main_map/map_widget/bottom/large_updown/widget/wait_state.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:provider/provider.dart';

class MultiUpDownLarge extends StatefulWidget {
  final Map<String, dynamic> cargo;
  const MultiUpDownLarge({super.key, required this.cargo});

  @override
  State<MultiUpDownLarge> createState() => _MultiUpDownLargeState();
}

class _MultiUpDownLargeState extends State<MultiUpDownLarge> {
  final ScrollController _horizontalScrollController = ScrollController();
  double scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController.addListener(() {
      setState(() {
        scrollOffset = _horizontalScrollController.offset;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_horizontalScrollController.hasClients) {
        if (progress == 0.15) {
          scrollToPosition(0);
        }
        if (progress == 0.47) {
          scrollToPosition(265);
        }
        if (progress == 0.81) {
          scrollToPosition(570);
        }
      }
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  double progress = 0.0;

  void scrollToPosition(double position) {
    _horizontalScrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
  }

  double calculateProgressLineWidth(DataProvider dataProvider) {
    final double waitStateWidth = 300.0;
    // 두 번째 박스의 실제 너비 계산
    final double useStateWidth = widget.cargo['locations'].length <= 9
        ? 300.0
        : widget.cargo['locations'].length * 40.0; // 각 위치당 필요한 공간 계산
    final double comStateWidth = 300.0;

    if (progress == 0.15) {
      return waitStateWidth / 2;
    } else if (progress == 0.47) {
      // 첫 번째 박스 전체 + 두 번째 박스의 절반
      return waitStateWidth + (useStateWidth / 2);
    } else if (progress == 0.81) {
      return waitStateWidth + useStateWidth + (comStateWidth / 2);
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    final dh = MediaQuery.of(context).size.height;

    // 필요한 데이터 체크
    if (widget.cargo == null ||
        !widget.cargo.containsKey('locations') ||
        !widget.cargo.containsKey('cargoStat')) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.cargo['pickUserUid'] == null) {
      progress = 0.15;
    } else if (widget.cargo['cargoStat'] == '운송완료') {
      progress = 0.81;
    } else {
      progress = 0.47;
    }

    return ChangeNotifierProvider(
      create: (context) => DataProvider(),
      child: Builder(builder: (context) {
        final dataProvider = Provider.of<DataProvider>(context);
        return Stack(
          children: [
            if (widget.cargo['pickUserUid'] != null &&
                dataProvider.selNum != null)
              Positioned(
                top: dh * 0.1,
                left: -scrollOffset - 25, // 패딩값 보정
                child: ProgressLine(
                  width: calculateProgressLineWidth(dataProvider),
                  progress: 1.0,
                  lineColor: widget.cargo['cargoStat'] == '운송완료'
                      ? Colors.grey
                      : widget.cargo['locations'][dataProvider.selNum]
                                  ['type'] ==
                              '상차'
                          ? kGreenFontColor
                          : kRedColor,
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
                      callType: '다구간',
                    ),
                  ),
                  BottomMultiWidget(
                    cargo: widget.cargo,
                  )
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
