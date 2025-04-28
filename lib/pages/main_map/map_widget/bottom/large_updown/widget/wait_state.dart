import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/image_dialog.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class WaitStatePage extends StatefulWidget {
  final Map<String, dynamic> cargo;
  final String? callType;
  const WaitStatePage({super.key, required this.cargo, this.callType});

  @override
  State<WaitStatePage> createState() => _WaitStatePageState();
}

class _WaitStatePageState extends State<WaitStatePage> {
  @override
  Widget build(BuildContext context) {
    bool isState = widget.cargo['pickUserUid'] == null;
    final upTime = widget.callType == '다구간' || widget.callType == '왕복'
        ? widget.cargo['locations'][0]['date'].toDate()
        : widget.cargo['upTime'].toDate();
    return Container(
      width: 300,
      height: 210,
      padding: const EdgeInsets.all(5),
      color: Colors.grey.withOpacity(0.03),
      child: widget.cargo['isShow'] == false
          ? IsShowFalse()
          : Column(
              children: [
                if (isPassedDate(upTime) && widget.cargo['pickUserUid'] == null)
                  _isPassDate(),
                if (isPassedDate(upTime) == false &&
                    widget.cargo['pickUserUid'] == null)
                  _isCState(),
                if (widget.cargo['pickUserUid'] != null) _conState()
              ],
            ),
    );
  }

  Widget _isPassDate() {
    return SizedBox(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info,
            size: 60,
            color: Colors.grey.withOpacity(0.7),
          ),
          const SizedBox(height: 8),
          KTextWidget(
              text: '만료된 화물 운송건입니다.',
              size: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.withOpacity(0.7)),
          KTextWidget(
              text: '이곳을 클릭하여 해당 운송건을 취소하거나,',
              size: 13,
              fontWeight: null,
              color: Colors.grey.withOpacity(0.5)),
          KTextWidget(
              text: '상차일을 변경하여 다시 등록하세요.',
              size: 13,
              fontWeight: null,
              color: Colors.grey.withOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _isCState() {
    final dataProvider = Provider.of<DataProvider>(context);
    return SizedBox(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
            ),
            child: ClipRRect(
              // 이미지에도 borderRadius 적용하기 위해 ClipRRect 사용
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: Image.asset(
                'asset/img/logo.png',
                // fit: BoxFit.fitHeight, // 여기서 BoxFit 변경
                errorBuilder: (context, error, stackTrace) {
                  print('이미지 로드 에러: $error');
                  return const Center(
                    child: Text('이미지를 불러올 수 없습니다'),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          const KTextWidget(
              text: '현재 운송료를 제안중입니다.',
              size: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white),
          /*  const SizedBox(height: 8),
          const KTextWidget(
              text: '현재 기사 및 주선사가 운송료를 제안중입니다.',
              size: 13,
              fontWeight: null,
              color: Colors.grey), */

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KTextWidget(
                  text: '기사 제안(${widget.cargo!['bidingUsers'].length})',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: kOrangeBssetColor),
              const SizedBox(width: 5),
              KTextWidget(
                  text: '전문 주선사 제안(${widget.cargo['bidingCom'].length})',
                  size: 14,
                  fontWeight: FontWeight.bold,
                  color: kOrangeBssetColor),
            ],
          ),
          const KTextWidget(
              text: '이곳을 클릭하여 운송료를 선택하세요.',
              size: 13,
              fontWeight: null,
              color: Colors.grey),
        ],
      ),
    );
  }

  Widget _conState() {
    return Container(
      width: 300,
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.grey.withOpacity(0.7),
              ),
              const SizedBox(width: 5),
              KTextWidget(
                text: '배차 완료',
                size: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.withOpacity(0.7),
              ),
            ],
          ),
          KTextWidget(
              text: widget.cargo['comUid'] == null
                  ? '기사님 직접 제안으로 배차가 완료되었습니다.'
                  : '전문 주선사 제안으로 배차가 완료되었습니다.',
              size: 13,
              fontWeight: null,
              color: Colors.grey),
          KTextWidget(
              text: formatDateKorTime(widget.cargo['fixDate'].toDate()),
              size: 12,
              fontWeight: null,
              color: Colors.grey),
          const Spacer(),
          Row(
            children: [
              Container(
                  height: 50,
                  width: 50,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: noState.withOpacity(0.4)),
                  child: Center(
                    child: KTextWidget(
                        text: widget.cargo['aloneType'],
                        size: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  )),
              Container(
                  height: 50,
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: noState.withOpacity(0.4)),
                  child: Center(
                    child: KTextWidget(
                        text: formatCurrency(widget.cargo['payMoney']) + '원',
                        size: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  )),
              if (widget.cargo['comUidPhoto'] != null)
                _imgBox(widget.cargo['comUidPhoto'])
            ],
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
                  imageUrl: img,
                  fit: BoxFit.cover, // 이미지를 컨테이너에 맞춰서 보여줍니다.
                ),
              ),
            ),
          );
  }
}

class IsShowFalse extends StatelessWidget {
  const IsShowFalse({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.info,
                size: 60,
                color: kRedColor,
              )),
          const SizedBox(height: 8),
          const KTextWidget(
              text: '현재 노출되지 않는 상태입니다.',
              size: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white),
          /*  const SizedBox(height: 8),
          const KTextWidget(
              text: '현재 기사 및 주선사가 운송료를 제안중입니다.',
              size: 13,
              fontWeight: null,
              color: Colors.grey), */

          const KTextWidget(
              text: '이곳을 클릭하여 운송 의뢰를 활성하세요.',
              size: 13,
              fontWeight: null,
              color: Colors.grey),
        ],
      ),
    );
  }
}
