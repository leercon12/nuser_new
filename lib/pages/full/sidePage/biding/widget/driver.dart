import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mixcall_normaluser_new/pages/bottom_history/bottom_driver_info.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/sidePage/biding/future/biding_future.dart';
import 'package:flutter_mixcall_normaluser_new/pages/full/sidePage/biding/sel_dialog.dart';
import 'package:flutter_mixcall_normaluser_new/providers/DataProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/hashProvider.dart';
import 'package:flutter_mixcall_normaluser_new/providers/mapProvider.dart';
import 'package:flutter_mixcall_normaluser_new/service/future_service.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/countdown.dart';
import 'package:flutter_mixcall_normaluser_new/setting/helper_widget/helper.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/snackbar.dart';
import 'package:flutter_mixcall_normaluser_new/setting/widget/text_widget.dart';
import 'package:provider/provider.dart';

class BidingDriverWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  final Map<String, dynamic> cargo;

  const BidingDriverWidget(
      {super.key, required this.cargo, required this.data});

  @override
  State<BidingDriverWidget> createState() => _BidingDriverWidgetState();
}

class _BidingDriverWidgetState extends State<BidingDriverWidget> {
  String? distance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final hashProvider = Provider.of<HashProvider>(context, listen: false);
    if (widget.data['location'] != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final calculatedDistance = formatDistance(getDistance(
              hashProvider.decLatLng(widget.cargo['upLocation']['geopoint']),
              hashProvider.decLatLng(widget.data['location'])));

          if (mounted) {
            setState(() {
              distance = calculatedDistance;
            });
          }
        } catch (e) {
          print('거리 계산 오류: $e');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final hashProvider = Provider.of<HashProvider>(context);
    String carInfoString =
        widget.data['carInfo']; // 예: "카고(일반 트럭), 1.2톤, 경유, [무진동, 리프트]"

// 임시로 대괄호 안의 쉼표를 다른 문자로 대체
    String tempString = carInfoString.replaceAllMapped(RegExp(r'\[(.*?)\]'),
        (match) => '[${match.group(1)?.replaceAll(',', '###')}]');

// 이제 쉼표로 분리
    List<String> tempList = tempString.split(',').map((e) => e.trim()).toList();

// 대체했던 문자를 다시 쉼표로 복원
    List<String> carInfoList =
        tempList.map((item) => item.replaceAll('###', ',')).toList();

// 대괄호 처리 - 옵션 항목의 대괄호 제거
    if (carInfoList.length > 3 &&
        carInfoList[3].startsWith('[') &&
        carInfoList[3].endsWith(']')) {
      carInfoList[3] = carInfoList[3].substring(1, carInfoList[3].length - 1);
    }
    final bool isConfirmed = widget.cargo['confirmUser'] == widget.data['uid'];
    final bool otherConfirmed =
        widget.cargo['confirmUser'] != null && !isConfirmed;
    return Column(
      children: [
        Container(
          height: 32,
          padding: EdgeInsets.only(left: 6, right: 6),
          decoration: BoxDecoration(
              color: dialogColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Row(
            children: [
              KTextWidget(
                  text: '기사 제안',
                  size: 12,
                  fontWeight: null,
                  color: Colors.grey),
              const Spacer(),
              KTextWidget(
                  text: agoKorTimestamp(widget.data['date']),
                  size: 10,
                  fontWeight: null,
                  color: Colors.grey)
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: msgBackColor,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return BottomDriverInfoPage(
                                  pickUserUid: widget.data['uid'],
                                  isReview: false,
                                  cargo: widget.cargo,
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: noState.withOpacity(0.5)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: buildProfileImage(
                                      widget.data['photoUrl']),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          KTextWidget(
                              text: maskLastCharacter(
                                  widget.data['name'].toString()),
                              size: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          const SizedBox(height: 6),
                        ],
                      )),
                  KTextWidget(
                      text: '#${carInfoList[0]}, #${carInfoList[1]}',
                      size: 12,
                      fontWeight: null,
                      color: Colors.grey),
                  if (carInfoList.length > 3)
                    KTextWidget(
                        text: '#${carInfoList[2]}, #${carInfoList[3]}',
                        size: 12,
                        fontWeight: null,
                        color: Colors.grey)
                  else
                    KTextWidget(
                        text: '#${carInfoList[2]}, #옵션 없음',
                        size: 12,
                        fontWeight: null,
                        color: Colors.grey),
                  if (distance != null)
                    KTextWidget(
                        text: '#상차까지 : $distance',
                        size: 12,
                        fontWeight: null,
                        color: Colors.grey)
                  else
                    KTextWidget(
                        text: '',
                        size: 12,
                        fontWeight: null,
                        color: Colors.grey),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: otherConfirmed
                        ? () {}
                        : () async {
                            HapticFeedback.lightImpact();

                            // 상차일 만료 확인
                            DateTime pickupDate = widget.cargo['aloneType'] ==
                                        '다구간' ||
                                    widget.cargo['aloneType'] == '왕복'
                                ? widget.cargo['locations'][0]['date'].toDate()
                                : widget.cargo['upTime'].toDate();

                            if (isPassedDate(pickupDate)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  errorSnackBar('상차일이 만료된 운송입니다.', context));
                              return;
                            }

                            // 제안 취소 또는 수락 처리
                            if (isConfirmed) {
                              mapProvider.isLoadingState(true);
                              await bidingCancel(
                                  dataProvider, widget.data, context);
                              mapProvider.isLoadingState(false);
                            } else {
                              await bidingSelStep01BottomSheet(
                                      context, widget.data)
                                  .then((value) async {
                                if (value == true) {
                                  await bidingSelStep02BottomSheet(
                                          context, widget.data, widget.cargo)
                                      .then((value) async {
                                    if (value == true) {
                                      mapProvider.isLoadingState(true);
                                      await selDriverProposal(
                                          dataProvider, widget.data, context);
                                      mapProvider.isLoadingState(false);
                                    }
                                  });
                                }
                              });
                            }
                          },
                    child: otherConfirmed
                        ? Container(
                            margin: EdgeInsets.only(left: 8, right: 8),
                            padding: EdgeInsets.only(top: 8, bottom: 8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.withOpacity(0.16),
                                border: Border.all(color: Colors.grey)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                KTextWidget(
                                    text: '다른 제안 수락 중...',
                                    size: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ],
                            ),
                          )
                        : isConfirmed
                            ? Container(
                                margin: EdgeInsets.only(left: 8, right: 8),
                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: kRedColor.withOpacity(0.16),
                                    border: Border.all(color: kRedColor)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    KTextWidget(
                                        text: '수락 취소',
                                        size: 14,
                                        fontWeight: FontWeight.bold,
                                        color: kRedColor),
                                    const SizedBox(width: 5),
                                    KTextWidget(
                                        text:
                                            '(${agoKorTimestamp(widget.cargo['conDate'])})',
                                        size: 12,
                                        fontWeight: FontWeight.bold,
                                        color: kRedColor),
                                  ],
                                ),
                              )
                            : Container(
                                margin: EdgeInsets.only(left: 8, right: 8),
                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: kBlueBssetColor.withOpacity(0.16),
                                    border: Border.all(color: kBlueBssetColor)),
                                child: Center(
                                  child: KTextWidget(
                                      text:
                                          '${formatCurrency(widget.data['price'])}원 수락',
                                      size: 14,
                                      fontWeight: FontWeight.bold,
                                      color: kBlueBssetColor),
                                ),
                              ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
            if (mapProvider.bidingSelId != widget.data['uid'])
              Positioned.fill(
                  child: Container(
                color: msgBackColor.withOpacity(0.5),
              ))
          ],
        )
      ],
    );
  }

  Widget buildProfileImage(String? photoUrl) {
    final defaultUrl =
        'https://firebasestorage.googleapis.com/v0/b/mixcall.appspot.com/o/user.png?alt=media&token=30cb61dc-dc75-4bfd-a6d8-927a9031bca2';

    if (photoUrl == null || photoUrl == defaultUrl) {
      return Image.asset(
        'asset/img/logo.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('이미지 로드 에러: $error');
          return const Center(
            child: Icon(Icons.person, color: Colors.grey),
          );
        },
      );
    } else {
      return CachedNetworkImage(
        imageUrl: photoUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey,
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          print('이미지 로드 에러: $error');
          return const Center(
            child: Icon(Icons.person, color: Colors.grey),
          );
        },
      );
    }
  }
}
