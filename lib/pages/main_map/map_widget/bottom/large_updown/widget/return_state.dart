import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/image_dialog.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';

class BottomReturnWidget extends StatefulWidget {
  final Map<String, dynamic> cargo;
  const BottomReturnWidget({super.key, required this.cargo});

  @override
  State<BottomReturnWidget> createState() => _BottomReturnWidgetState();
}

class _BottomReturnWidgetState extends State<BottomReturnWidget> {
  bool isMax = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    isMax = isPassedDate(widget.cargo['locations'][0]['date'].toDate()) &&
        widget.cargo['pickUserUid'] == null;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        VerticalDottedLine(
          height: 210,
          color: widget.cargo['pickUserUid'] == null
              ? Colors.grey.withOpacity(0.2)
              : kBlueBssetColor.withOpacity(0.5),
        ),
        _upState(),
        VerticalDottedLine(
          height: 210,
          color: widget.cargo['pickUserUid'] == null
              ? Colors.grey.withOpacity(0.2)
              : kGreenFontColor.withOpacity(0.5),
        ),
        _midState(),
        VerticalDottedLine(
          height: 210,
          color: widget.cargo['pickUserUid'] == null
              ? Colors.grey.withOpacity(0.2)
              : kRedColor.withOpacity(0.5),
        ),
        _downState(),
        VerticalDottedLine(
          height: 210,
          color: widget.cargo['pickUserUid'] == null
              ? Colors.grey.withOpacity(0.2)
              : kRedColor.withOpacity(0.5),
        ),
      ],
    );
  }

  Widget _upState() {
    return Container(
      width: 300,
      height: 210,
      padding: const EdgeInsets.all(5),
      color: isMax || widget.cargo['pickUserUid'] == null
          ? Colors.grey.withOpacity(0.03)
          : kBlueBssetColor.withOpacity(0.03),
      child: widget.cargo['pickUserUid'] == null
          ? _nullState()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.cargo['cargoStat'] == '상차완료' ||
                        widget.cargo['cargoStat'] == '회차완료' ||
                        widget.cargo['cargoStat'] == '하차완료'
                    ? const Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 16, color: kBlueBssetColor),
                          SizedBox(width: 5),
                          KTextWidget(
                              text: '상차 완료',
                              size: 16,
                              fontWeight: FontWeight.bold,
                              color: kBlueBssetColor),
                        ],
                      )
                    : const Row(
                        children: [
                          KTextWidget(
                              text: '상차 완료 대기중...',
                              size: 16,
                              fontWeight: FontWeight.bold,
                              color: kBlueBssetColor),
                        ],
                      ),
                KTextWidget(
                    text: widget.cargo['cargoStat'] == '상차완료' ||
                            widget.cargo['cargoStat'] == '회차완료' ||
                            widget.cargo['cargoStat'] == '하차완료'
                        ? '화물의 정상적인 상차가 완료되었습니다.'
                        : '화물을 상차하기 위해 이동중입니다.',
                    size: 13,
                    fontWeight: null,
                    color: kBlueBssetColor),
                if (widget.cargo['locations'][0]['isDoneDate'] != null)
                  KTextWidget(
                      text: formatDateKorTime(
                          widget.cargo['locations'][0]['isDoneDate'].toDate()),
                      size: 12,
                      fontWeight: null,
                      color: kBlueBssetColor),
                const Spacer(),
                if (widget.cargo['locations'][0]['isDone'] == true)
                  Row(
                    children: [
                      if (widget.cargo['locationUrl0_${0}'] != null)
                        _imgBox(widget.cargo['locationUrl0_0']),
                      if (widget.cargo['locationUrl0_${1}'] != null)
                        _imgBox(widget.cargo['locationUrl0_1']),
                      if (widget.cargo['locationUrl0_${2}'] != null)
                        _imgBox(widget.cargo['locationUrl0_2']),
                    ],
                  )
                else
                  const Row(
                    children: [
                      Icon(Icons.location_history,
                          color: kBlueBssetColor, size: 15),
                      SizedBox(width: 5),
                      KTextWidget(
                          text: '버튼을 클릭하여, 기사님 위치를 확인하세요.',
                          size: 14,
                          fontWeight: null,
                          color: kBlueBssetColor)
                    ],
                  ),
              ],
            ),
    );
  }

  Widget _midState() {
    return Container(
      width: 300,
      height: 210,
      padding: const EdgeInsets.all(5),
      color: isMax || widget.cargo['pickUserUid'] == null
          ? Colors.grey.withOpacity(0.03)
          : kGreenFontColor.withOpacity(0.03),
      child: widget.cargo['pickUserUid'] == null
          ? _nullState()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.cargo['cargoStat'] == '회차완료' ||
                        widget.cargo['cargoStat'] == '상차완료'
                    ? const Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 16, color: kGreenFontColor),
                          SizedBox(width: 5),
                          KTextWidget(
                              text: '회차 완료',
                              size: 16,
                              fontWeight: FontWeight.bold,
                              color: kGreenFontColor),
                        ],
                      )
                    : const Row(
                        children: [
                          KTextWidget(
                              text: '회차 완료 대기중...',
                              size: 16,
                              fontWeight: FontWeight.bold,
                              color: kGreenFontColor),
                        ],
                      ),
                KTextWidget(
                    text: widget.cargo['cargoStat'] == '회차완료' ||
                            widget.cargo['cargoStat'] == '하차완료'
                        ? '회차를 완료하고 최종 하차지로 이동중입니다.'
                        : widget.cargo['cargoStat'] == '상차완료'
                            ? '회차지(경유지)로 이동중입니다.'
                            : '화물 상차를 대기중입니다.',
                    size: 13,
                    fontWeight: null,
                    color: kGreenFontColor),
                if (widget.cargo['locations'][1]['isDoneDate'] != null)
                  KTextWidget(
                      text: formatDateKorTime(
                          widget.cargo['locations'][1]['isDoneDate'].toDate()),
                      size: 12,
                      fontWeight: null,
                      color: kGreenFontColor),
                const Spacer(),
                if (widget.cargo['locations'][1]['isDone'] == true)
                  Row(
                    children: [
                      if (widget.cargo['locationUrl1_${0}'] != null &&
                          widget.cargo['locationUrl1_${0}'][0] != null)
                        _imgBox(widget.cargo['locationUrl1_0']),
                      if (widget.cargo['locationUrl1_${1}'] != null)
                        _imgBox(widget.cargo['locationUrl1_1'][0]),
                      if (widget.cargo['locationUrl1_${2}'] != null)
                        _imgBox(widget.cargo['locationUrl1_2'][0]),
                    ],
                  )
                else
                  const Row(children: [
                    Icon(Icons.location_history,
                        color: kGreenFontColor, size: 15),
                    SizedBox(width: 5),
                    KTextWidget(
                        text: '버튼을 클릭하여, 기사님 위치를 확인하세요.',
                        size: 14,
                        fontWeight: null,
                        color: kGreenFontColor)
                  ])
              ],
            ),
    );
  }

  Widget _downState() {
    return Container(
      width: 300,
      height: 210,
      padding: const EdgeInsets.all(5),
      color: isMax || widget.cargo['pickUserUid'] == null
          ? Colors.grey.withOpacity(0.03)
          : kRedColor.withOpacity(0.03),
      child: widget.cargo['pickUserUid'] == null
          ? _nullState()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.cargo['cargoStat'] == '하차완료'
                    ? const Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 16, color: kBlueBssetColor),
                          SizedBox(width: 5),
                          KTextWidget(
                              text: '하차 완료',
                              size: 16,
                              fontWeight: FontWeight.bold,
                              color: kRedColor),
                        ],
                      )
                    : const Row(
                        children: [
                          KTextWidget(
                              text: '하차 완료 대기중...',
                              size: 16,
                              fontWeight: FontWeight.bold,
                              color: kRedColor),
                        ],
                      ),
                KTextWidget(
                    text: widget.cargo['cargoStat'] == '하차완료'
                        ? '모든 운송을 정상적으로 완료하였습니다.'
                        : '이전 과정 완료를 대기중입니다...',
                    size: 13,
                    fontWeight: null,
                    color: kRedColor),
                if (widget.cargo['locations'][2]['isDoneDate'] != null)
                  KTextWidget(
                      text: formatDateKorTime(
                          widget.cargo['locations'][2]['isDoneDate'].toDate()),
                      size: 12,
                      fontWeight: null,
                      color: kRedColor),
                const Spacer(),
                if (widget.cargo['locations'][2]['isDone'] == true)
                  Row(
                    children: [
                      if (widget.cargo['locationUrl2_${0}'] != null)
                        _imgBox(widget.cargo['locationUrl2_0'][0]),
                      if (widget.cargo['locationUrl2_${1}'] != null)
                        _imgBox(widget.cargo['locationUrl2_1'][0]),
                      if (widget.cargo['locationUrl2_${2}'] != null)
                        _imgBox(widget.cargo['locationUrl2_2'][0]),
                    ],
                  )
                else
                  const Row(children: [
                    Icon(Icons.location_history, color: kRedColor, size: 15),
                    SizedBox(width: 5),
                    KTextWidget(
                        text: '버튼을 클릭하여, 기사님 위치를 확인하세요.',
                        size: 14,
                        fontWeight: null,
                        color: kRedColor)
                  ])
              ],
            ),
    );
  }

  Widget _nullState() {
    return SizedBox(
      height: 200,
      width: 300,
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

  Widget _imgBox(List? img) {
    return img == null
        ? const SizedBox()
        : GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              await showDialog(
                context: context,
                builder: (context) => ImageViewerDialog(
                  networkUrl: img[0],
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
                  imageUrl: img[0].toString(),
                  fit: BoxFit.cover, // 이미지를 컨테이너에 맞춰서 보여줍니다.
                ),
              ),
            ),
          );
  }
}
