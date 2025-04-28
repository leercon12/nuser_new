import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/full_main.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/image_dialog.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';

class NormalUpDownStatePage extends StatefulWidget {
  final Map<String, dynamic> cargo;
  final String callType;
  const NormalUpDownStatePage(
      {super.key, required this.cargo, required this.callType});

  @override
  State<NormalUpDownStatePage> createState() => _NormalUpDownStatePageState();
}

class _NormalUpDownStatePageState extends State<NormalUpDownStatePage> {
  bool isMax = false;

  @override
  Widget build(BuildContext context) {
    isMax = (isPassedDate(widget.cargo['upTime'].toDate()) &&
            widget.cargo['pickUserUid'] == null) ||
        (widget.cargo['cargoStat'] == '대기' ||
            widget.cargo['cargoStat'] == null);
    return Row(
      children: [
        VerticalDottedLine(
          height: 210,
          color: isMax
              ? Colors.grey.withOpacity(0.2)
              : kBlueBssetColor.withOpacity(0.5),
        ),
        _upState(),
        VerticalDottedLine(
          height: 210,
          color:
              isMax ? Colors.grey.withOpacity(0.2) : kRedColor.withOpacity(0.5),
        ),
        _downState(),
        VerticalDottedLine(
          height: 210,
          color:
              isMax ? Colors.grey.withOpacity(0.2) : kRedColor.withOpacity(0.5),
        ),
      ],
    );
  }

  Widget _upState() {
    return Container(
      width: 300,
      height: 210,
      padding: const EdgeInsets.all(5),
      color: isMax
          ? Colors.grey.withOpacity(0.03)
          : kBlueBssetColor.withOpacity(0.03),
      child: Column(
        children: [
          if (isMax || widget.cargo['cargoStat'] == '대기') _outState(),
          if (widget.cargo['cargoStat'] == '배차') _readyUpState(),
          if (widget.cargo['cargoStat'] == '상차완료') _comUpState(),
        ],
      ),
    );
  }

  Widget _downState() {
    return Container(
      width: 300,
      height: 210,
      padding: const EdgeInsets.all(5),
      color:
          isMax ? Colors.grey.withOpacity(0.03) : kRedColor.withOpacity(0.03),
      child: Column(
        children: [
          if (isMax || widget.cargo['cargoStat'] == '배차')
            _outState()
          else
            widget.cargo['cargoStat'] == '하차완료'
                ? _comDownState()
                : _readyDownState()
        ],
      ),
    );
  }

  Widget _outState() {
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

  Widget _readyUpState() {
    return SizedBox(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KTextWidget(
                  text: '기사님이 상차지로 이동중...',
                  size: 14,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.bold,
                  color: kBlueBssetColor),
            ],
          ),
          KTextWidget(
              text: '상세한 정보를 확인하시려면 이곳을 클릭하세요.',
              size: 13,
              fontWeight: null,
              color: kBlueBssetColor.withOpacity(0.5)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_history,
                  size: 40, color: kBlueBssetColor.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KTextWidget(
                  text: '하단 버튼으로 기사님 위치를 확인할 수 있어요.',
                  size: 13,
                  fontWeight: null,
                  color: kBlueBssetColor.withOpacity(0.5)),
            ],
          )
        ],
      ),
    );
  }

  Widget _comUpState() {
    return SizedBox(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: kBlueBssetColor),
              SizedBox(width: 5),
              KTextWidget(
                  text: '상차 완료',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: kBlueBssetColor),
            ],
          ),
          KTextWidget(
              text: '정상적으로 상차를 완료하였습니다.',
              size: 12,
              fontWeight: null,
              color: kBlueBssetColor.withOpacity(0.7)),
          KTextWidget(
              text: formatDateKorTime(widget.cargo['upDoneTime'].toDate()),
              size: 12,
              fontWeight: null,
              color: kBlueBssetColor.withOpacity(0.7)),
          const Spacer(),
          Row(
            children: [
              _imgBox(widget.cargo['upDonePhotoURl0']),
              _imgBox(widget.cargo['upDonePhotoURl1']),
              _imgBox(widget.cargo['upDonePhotoURl2']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _readyDownState() {
    return SizedBox(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KTextWidget(
                  text: '기사님이 하차지로 이동중...',
                  size: 14,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.bold,
                  color: kRedColor),
            ],
          ),
          KTextWidget(
              text: '상세한 정보를 확인하시려면 이곳을 클릭하세요.',
              size: 13,
              fontWeight: null,
              color: kRedColor.withOpacity(0.5)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_history,
                  size: 40, color: kRedColor.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KTextWidget(
                  text: '하단 버튼으로 기사님 위치를 확인할 수 있어요.',
                  size: 13,
                  fontWeight: null,
                  color: kRedColor.withOpacity(0.5)),
            ],
          )
        ],
      ),
    );
  }

  Widget _comDownState() {
    return SizedBox(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: kBlueBssetColor),
              SizedBox(width: 5),
              KTextWidget(
                  text: '하차 완료',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: kRedColor),
            ],
          ),
          KTextWidget(
              text: '정상적으로 하차를 완료하였습니다.',
              size: 12,
              fontWeight: null,
              color: kBlueBssetColor.withOpacity(0.7)),
          KTextWidget(
              text: formatDateKorTime(widget.cargo['downDoneTime'].toDate()),
              size: 12,
              fontWeight: null,
              color: kBlueBssetColor.withOpacity(0.7)),
          const Spacer(),
          Row(
            children: [
              _imgBox(widget.cargo['downDonePhotoURl0']),
              _imgBox(widget.cargo['downDonePhotoURl1']),
              _imgBox(widget.cargo['downDonePhotoURl2']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _downStat2() {
    bool isState = widget.cargo['cargoStat'] == '하차완료';
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (widget.callType == '노링크') {
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
      child: Container(
        width: 300,
        height: 210,
        padding: const EdgeInsets.all(5),
        color:
            isMax ? Colors.grey.withOpacity(0.03) : kRedColor.withOpacity(0.03),
        child: Stack(
          children: [
            isMax
                ? SizedBox(
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
                  )
                : widget.cargo['cargoStat'] == '상차완료'
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.cargo['cargoStat'] == '하차완료'
                              ? const Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        size: 16, color: kRedColor),
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
                                  ? '화물의 정상적인 하차가 완료되었습니다.'
                                  : '화물을 하차하기 위해 이동중입니다.',
                              size: 13,
                              fontWeight: null,
                              color: kRedColor),
                          const Spacer(),

                          Row(
                            children: [
                              _imgBox(widget.cargo['downDonePhotoURl0']),
                              _imgBox(widget.cargo['downDonePhotoURl1']),
                              _imgBox(widget.cargo['downDonePhotoURl2']),
                            ],
                          ),
                          //const SizedBox(height: 5),
                          if (widget.cargo['downDoneTime'] != null)
                            KTextWidget(
                                text: formatDateKorTime(
                                    widget.cargo['downDoneTime'].toDate()),
                                size: 12,
                                fontWeight: null,
                                color: kRedColor)
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          KTextWidget(
                              text: '하차 대기중...',
                              size: 16,
                              fontWeight: null,
                              color: isState
                                  ? kRedColor.withOpacity(0.5)
                                  : kRedColor.withOpacity(0.5)),
                          KTextWidget(
                              text: '아직 화물의 상차가 완료되지 않았어요.',
                              size: 13,
                              fontWeight: null,
                              color: isState
                                  ? kRedColor.withOpacity(0.5)
                                  : kRedColor.withOpacity(0.5)),
                          const Spacer(),
                        ],
                      ),
          ],
        ),
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
