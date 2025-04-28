import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/full_main.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/image_dialog.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class BottomMultiWidget extends StatefulWidget {
  final Map<String, dynamic> cargo;
  const BottomMultiWidget({super.key, required this.cargo});

  @override
  State<BottomMultiWidget> createState() => _BottomMultiWidgetState();
}

class _BottomMultiWidgetState extends State<BottomMultiWidget> {
  final GlobalKey _useStateKey = GlobalKey();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSelNum();
      _updateWidth();
    });
  }

  void _updateWidth() {
    final RenderBox? renderBox =
        _useStateKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final multiWidgetProvider =
          Provider.of<DataProvider>(context, listen: false);
      multiWidgetProvider.updateWidth(renderBox.size.width);
    }
  }

  void _initializeSelNum() {
    // Find the first index where isDone is null
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    for (int i = 0; i < widget.cargo['locations'].length; i++) {
      if (widget.cargo['locations'][i]['isDone'] == null) {
        setState(() {
          _selNum = i;
        });
        dataProvider.selNumState(i);
        break;
      }
    }
    // If no null isDone found, default to 0 or handle as needed
    if (_selNum == null) {
      setState(() {
        _selNum = 0;
      });
      dataProvider.selNumState(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    return Row(
      children: [
        VerticalDottedLine(
          height: 210,
          color: widget.cargo['pickUserUid'] == null
              ? Colors.grey.withOpacity(0.3)
              : widget.cargo['locations'][_selNum]['type'] == '상차'
                  ? kGreenFontColor.withOpacity(0.5)
                  : kRedColor.withOpacity(0.5),
        ),
        InkWell(
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
            child: _useState()),
        VerticalDottedLine(
          height: 210,
          color: Colors.grey.withOpacity(0.3),
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
            child: _comState()),
        VerticalDottedLine(
          height: 210,
          color: Colors.grey.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _useState() {
    final positions = _selNum! + 1;
    return Container(
      key: _useStateKey, // GlobalKey 추가
      height: 210,
      width: widget.cargo['locations'].length <= 9 ? 300 : null,
      padding: const EdgeInsets.all(5),
      color: widget.cargo['pickUserUid'] == null
          ? Colors.grey.withOpacity(0.03)
          : widget.cargo['locations'][_selNum]['type'] == '상차'
              ? kGreenFontColor.withOpacity(0.03)
              : kRedColor.withOpacity(0.03),
      child: widget.cargo['pickUserUid'] == null
          ? _useOutState()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    widget.cargo['locations'].length,
                    (index) => _cirBox(index),
                  ),
                ),
                const Spacer(),
                if (widget.cargo['locations'][_selNum]['isDone'] == null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KTextWidget(
                          text:
                              '${_selNum! + 1}번 ${widget.cargo['locations'][_selNum]['type']} 완료 대기중...',
                          size: 14,
                          fontWeight: null,
                          color:
                              widget.cargo['locations'][_selNum]['type'] == '상차'
                                  ? kGreenFontColor
                                  : kRedColor),
                      Row(
                        children: [
                          Icon(Icons.location_history,
                              color: widget.cargo['locations'][_selNum]
                                          ['type'] ==
                                      '상차'
                                  ? kGreenFontColor
                                  : kRedColor,
                              size: 15),
                          const SizedBox(width: 5),
                          KTextWidget(
                              text: '버튼을 클릭하여, 기사님 위치를 확인하세요.',
                              size: 14,
                              fontWeight: null,
                              color: widget.cargo['locations'][_selNum]
                                          ['type'] ==
                                      '상차'
                                  ? kGreenFontColor
                                  : kRedColor)
                        ],
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // if (widget.cargo['locations'][_selNum]['isDone'] == true)

                      if (widget.cargo['locationUrl${_selNum}_${0}'] != null ||
                          widget.cargo['locationUrl${_selNum}_${1}'] != null ||
                          widget.cargo['locationUrl${_selNum}_${2}'] != null)
                        Column(
                          children: [
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                if (widget
                                        .cargo['locationUrl${_selNum}_${0}'] !=
                                    null)
                                  _imgBox(widget
                                      .cargo['locationUrl${_selNum}_${0}'][0]),
                                if (widget
                                        .cargo['locationUrl${_selNum}_${1}'] !=
                                    null)
                                  _imgBox(widget
                                      .cargo['locationUrl${_selNum}_${1}'][0]),
                                if (widget
                                        .cargo['locationUrl${_selNum}_${2}'] !=
                                    null)
                                  _imgBox(widget
                                      .cargo['locationUrl${_selNum}_${2}'][0]),
                              ],
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle,
                                    size: 13,
                                    color: widget.cargo['locations'][_selNum]
                                                ['type'] ==
                                            '상차'
                                        ? kGreenFontColor
                                        : kRedColor),
                                const SizedBox(width: 3),
                                KTextWidget(
                                    text:
                                        '${_selNum! + 1}번 ${widget.cargo['locations'][_selNum]['type']} 완료',
                                    size: 13,
                                    fontWeight: null,
                                    color: widget.cargo['locations'][_selNum]
                                                ['type'] ==
                                            '상차'
                                        ? kGreenFontColor
                                        : kRedColor),
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 13,
                              color: widget.cargo['locations'][_selNum]
                                          ['type'] ==
                                      '상차'
                                  ? kGreenFontColor
                                  : kRedColor),
                          const SizedBox(width: 2),
                          KTextWidget(
                              text:
                                  '${formatDateKorTime(widget.cargo['locations'][_selNum]['isDoneDate'].toDate())}',
                              size: 12,
                              fontWeight: null,
                              color: widget.cargo['locations'][_selNum]
                                          ['type'] ==
                                      '상차'
                                  ? kGreenFontColor
                                  : kRedColor),
                        ],
                      ),
                      /*  if (widget.cargo['locations'][_selNum]['isDoneTime'] !=
                          null)
                        KTextWidget(
                            text: formatDateKorTime(widget.cargo['locations']
                                    [_selNum]['isDoneTime']
                                .toDate()),
                            size: 13,
                            fontWeight: null,
                            color: widget.cargo['locations'][_selNum]['type'] ==
                                    '상차'
                                ? kGreenFontColor
                                : kRedColor), */
                    ],
                  )
              ],
            ),
    );
  }

  Widget _useOutState() {
    return SizedBox(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
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
            ],
          ),
        ],
      ),
    );
  }

  int? _selNum = 0;

  Widget _cirBox(int index) {
    // index 파라미터 추가
    final dataProvider = Provider.of<DataProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _selNum = index;
            });
            dataProvider.selNumState(_selNum);
          },
          child: Container(
            margin: const EdgeInsets.only(right: 5),
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: index == _selNum
                        ? widget.cargo['locations'][index]['type'] == '상차'
                            ? kGreenFontColor
                            : kRedColor
                        : widget.cargo['locations'][index]['type'] == '상차'
                            ? kGreenFontColor.withOpacity(0.3)
                            : kRedColor.withOpacity(0.3))),
            child: Center(
              child: KTextWidget(
                text: (index + 1).toString(),
                size: 15,
                fontWeight: FontWeight.bold,
                color: index == _selNum
                    ? widget.cargo['locations'][index]['type'] == '상차'
                        ? kGreenFontColor
                        : kRedColor
                    : widget.cargo['locations'][index]['type'] == '상차'
                        ? kGreenFontColor.withOpacity(0.5)
                        : kRedColor.withOpacity(0.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        if (widget.cargo['locations'][index]['isDone'] != null)
          SizedBox(
            width: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: 10,
                    height: 2,
                    color: widget.cargo['locations'][index]['type'] == '상차'
                        ? kGreenFontColor
                        : kRedColor),
              ],
            ),
          ),
      ],
    );
  }

  Widget _comState() {
    return Container(
      width: 300,
      height: 210,
      padding: const EdgeInsets.all(5),
      color: Colors.grey.withOpacity(0.03),
      child: widget.cargo['pickUserUid'] == null
          ? _comOutState()
          : widget.cargo['cargoStat'] == '운송완료'
              ? Column(
                  children: [],
                )
              : SizedBox(
                  height: 200,
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
                      const SizedBox(height: 5),
                      KTextWidget(
                          text: '운송 완료를 대기중입니다...',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.withOpacity(0.5))
                    ],
                  ),
                ),
    );
  }

  Widget _comOutState() {
    return SizedBox(
      height: 200,
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
        ],
      ),
    );
  }

  Widget _imgBox(String? img) {
    return img == null
        ? const SizedBox()
        : GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              await showDialog(
                context: context,
                builder: (context) => ImageViewerDialog(
                  networkUrl: img,
                ),
              );
            },
            child: Container(
              height: 50,
              width: 50,
              margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: img.toString(),
                  fit: BoxFit.cover, // 이미지를 컨테이너에 맞춰서 보여줍니다.
                ),
              ),
            ),
          );
  }
}
